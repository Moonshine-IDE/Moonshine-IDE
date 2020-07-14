import { EventEmitter } from 'events';
import { ExceptionBreakpoints, IThreadActorProxy } from '../firefox/actorProxy/thread';
import { ConsoleActorProxy } from '../firefox/actorProxy/console';
import { ISourceActorProxy } from '../firefox/actorProxy/source';
import { FrameAdapter } from './frame';
import { ScopeAdapter } from './scope';
import { SourceAdapter } from './source';
import { ObjectGripAdapter } from './objectGrip';
import { VariablesProvider } from './variablesProvider';
import { VariableAdapter } from './variable';
import { ThreadCoordinator } from '../coordinator/thread';
import { ThreadPauseCoordinator } from '../coordinator/threadPause';
import { Variable } from 'vscode-debugadapter';
import { Log } from '../util/log';
import { FirefoxDebugSession } from '../firefoxDebugSession';
import { pathsAreEqual } from '../util/misc';
import { Location } from '../location';
import { AttachOptions } from '../firefox/actorProxy/thread';
import { PendingRequest } from '../util/pendingRequests';

let log = Log.create('ThreadAdapter');

export interface SourceLocation extends Location {
	source: SourceAdapter;
}

/**
 * Adapter class for a thread
 */
export class ThreadAdapter extends EventEmitter {

	public id: number;
	public get actorName() {
		return this.actor.name;
	}

	public readonly coordinator: ThreadCoordinator;

	/**
	 * All `SourceAdapter`s for this thread. They will be disposed when this `ThreadAdapter` is disposed.
	 */
	private sources: SourceAdapter[] = [];

	/**
	 * Sometimes `SourceActor`s are referenced in stack frames before the corresponding `newSource`
	 * event was sent by Firefox. In this case the `ThreadAdapter` returns a `Promise` for the
	 * corresponding `SourceAdapter` which is resolved when the `newSource` event was received.
	 */
	private sourcePromises = new Map<string, Promise<SourceAdapter>>();
	private pendingSources = new Map<string, PendingRequest<SourceAdapter>>();

	/**
	 * When the thread is paused, this is set to a Promise that resolves to the `FrameAdapter`s for
	 * the stacktrace for the current thread pause. At the end of the thread pause, these are disposed.
	 */
	private framesPromise: Promise<FrameAdapter[]> | undefined = undefined;

	/**
	 * All `ScopeAdapter`s that have been created for the current thread pause. They will be disposed
	 * at the end of the thread pause.
	 */
	private scopes: ScopeAdapter[] = [];

	/**
	 * All `ObjectGripAdapter`s that should be disposed at the end of the current thread pause
	 */
	private pauseLifetimeObjects: ObjectGripAdapter[] = [];

	/**
	 * All `ObjectGripAdapter`s that should be disposed when this `ThreadAdapter` is disposed
	 */
	private threadLifetimeObjects: ObjectGripAdapter[] = [];

	public constructor(
		public readonly actor: IThreadActorProxy,
		private readonly consoleActor: ConsoleActorProxy,
		private readonly pauseCoordinator: ThreadPauseCoordinator,
		public readonly name: string,
		public readonly debugSession: FirefoxDebugSession
	) {
		super();

		this.id = debugSession.threads.register(this);

		this.coordinator = new ThreadCoordinator(this.id, this.name, this.actor, this.consoleActor,
			this.pauseCoordinator, () => this.disposePauseLifetimeAdapters());

		this.coordinator.onPaused(async (event) => {

			const sourceLocation = event.frame.where;

			try {

				const sourceAdapter = await this.findSourceAdapterForActorName(sourceLocation.actor);
	
				if (sourceAdapter.actor.source.isBlackBoxed) {

					// skipping (or blackboxing) source files is usually done by Firefox itself,
					// but when the debugger hits an exception in a source that was just loaded and
					// should be skipped, we may not have been able to tell Firefox that we want
					// to skip this file, so we have to do it here
					this.resume();
					return;

				}

				if ((event.why.type === 'breakpoint') &&
					event.why.actors && (event.why.actors.length > 0)) {

					const breakpointAdapter = sourceAdapter.findBreakpointAdapterForLocation(sourceLocation);

					if (breakpointAdapter) {

						if (breakpointAdapter.breakpointInfo.hitCount) {

							// Firefox doesn't have breakpoints with hit counts, so we have to
							// implement this here
							breakpointAdapter.hitCount++;
							if (breakpointAdapter.hitCount < breakpointAdapter.breakpointInfo.hitCount) {

								this.resume();
								return;

							}
						}
					}
				}
			} catch(err) {
				log.warn(err);
			}

			if (event.why.type === 'exception') {

				let frames = await this.fetchAllStackFrames();
				let startFrame = (frames.length > 0) ? frames[frames.length - 1] : undefined;
				if (startFrame) {
					try {

						const sourceAdapter = await this.findSourceAdapterForActorName(startFrame.frame.where.actor);

						if (sourceAdapter.actor.source.introductionType === 'debugger eval') {

							// skip exceptions triggered by debugger eval code
							this.resume();
							return;
	
						}
					} catch(err) {
						log.warn(err);
					}
				}
			}

			this.emit('paused', event.why);
			// pre-fetch the stackframes, we're going to need them later
			this.fetchAllStackFrames();
		});
	}

	/**
	 * Attach to the thread, fetch sources and resume.
	 */
	public async init(exceptionBreakpoints: ExceptionBreakpoints): Promise<void> {

		const attachOptions: AttachOptions = {
			ignoreFrameEnvironment: true,
			pauseOnExceptions: (exceptionBreakpoints !== ExceptionBreakpoints.None),
			ignoreCaughtExceptions: (exceptionBreakpoints !== ExceptionBreakpoints.All)
		};

		await this.pauseCoordinator.requestInterrupt(this.id, this.name, 'auto');
		try {
			await this.actor.attach(attachOptions);
			this.pauseCoordinator.notifyInterrupted(this.id, this.name, 'auto');
		} catch(e) {
			this.pauseCoordinator.notifyInterruptFailed(this.id, this.name);
			throw e;
		}

		await this.actor.fetchSources();

		await this.coordinator.resume();
	}

	public createSourceAdapter(actor: ISourceActorProxy, path: string | undefined): SourceAdapter {

		let adapter = new SourceAdapter(this.debugSession.sources, actor, path, this);

		this.sources.push(adapter);

		if (this.pendingSources.has(actor.name)) {
			this.pendingSources.get(actor.name)!.resolve(adapter);
			this.pendingSources.delete(actor.name);
		} else {
			this.sourcePromises.set(actor.name, Promise.resolve(adapter));
		}

		return adapter;
	}

	public replaceSourceActor(oldActor: string, newActor: string): void {

		if (this.sourcePromises.has(oldActor)) {

			const adapterPromise = this.sourcePromises.get(oldActor)!;
			this.sourcePromises.set(newActor, adapterPromise);

			if (this.pendingSources.has(newActor)) {
				(async () => {
					try {

						const adapter = await adapterPromise;

						if (this.pendingSources.has(newActor)) {
							this.pendingSources.get(newActor)!.resolve(adapter);
							this.pendingSources.delete(newActor);
						}

					} catch(err) {
						log.warn(err);
					}
				})();
			}

		} else {
			log.warn(`SourceAdapter for ${oldActor} (replaced by ${newActor}) not found`);
		}
	}

	public registerScopeAdapter(scopeAdapter: ScopeAdapter) {
		this.scopes.push(scopeAdapter);
	}

	public registerObjectGripAdapter(objectGripAdapter: ObjectGripAdapter) {
		if (objectGripAdapter.threadLifetime) {
			this.threadLifetimeObjects.push(objectGripAdapter);
		} else {
			this.pauseLifetimeObjects.push(objectGripAdapter);
		}
	}

	/**
	 * extend the given adapter's lifetime to threadLifetime (if it isn't already)
	 */
	public threadLifetime(objectGripAdapter: ObjectGripAdapter): void {

		if (!objectGripAdapter.threadLifetime) {

			const index = this.pauseLifetimeObjects.indexOf(objectGripAdapter);
			if (index >= 0) {
				this.pauseLifetimeObjects.splice(index, 1);
			}

			this.threadLifetimeObjects.push(objectGripAdapter);
			objectGripAdapter.threadLifetime = true;
		}
	}

	public findCorrespondingSourceAdapter(url: string | undefined): SourceAdapter | undefined {
		if (!url) return undefined;

		for (let sourceAdapter of this.sources) {
			if (sourceAdapter.actor.source.url === url) {
				return sourceAdapter;
			}
		}

		return undefined;
	}

	public findSourceAdaptersForPathOrUrl(pathOrUrl: string): SourceAdapter[] {
		if (!pathOrUrl) return [];

		return this.sources.filter((sourceAdapter) =>
			pathsAreEqual(pathOrUrl, sourceAdapter.sourcePath) || (sourceAdapter.actor.url === pathOrUrl)
		);
	}

	public findSourceAdaptersForUrlWithoutQuery(url: string): SourceAdapter[] {

		return this.sources.filter((sourceAdapter) => {

			let sourceUrl = sourceAdapter.actor.url;
			if (!sourceUrl) return false;

			let queryStringIndex = sourceUrl.indexOf('?');
			if (queryStringIndex >= 0) {
				sourceUrl = sourceUrl.substr(0, queryStringIndex);
			}

			return url === sourceUrl;
		});
	}

	public findSourceAdapterForActorName(actorName: string): Promise<SourceAdapter> {

		if (!this.sourcePromises.has(actorName)) {

			this.sourcePromises.set(actorName, new Promise<SourceAdapter>((resolve, reject) => {

				this.pendingSources.set(actorName, { resolve, reject });

				setTimeout(() => {
					if (this.pendingSources.has(actorName)) {
						this.pendingSources.get(actorName)!.reject(`Couldn't find source adapter for ${actorName}`);
						this.pendingSources.delete(actorName);
					}
				}, 1000);
			}));
		}

		return this.sourcePromises.get(actorName)!;
	}

	public async findOriginalSourceLocation(
		generatedUrl: string,
		line: number,
		column?: number
	): Promise<SourceLocation | undefined> {

		const originalLocation = await this.actor.findOriginalLocation(generatedUrl, line, column);
		if (originalLocation) {
			const sourceAdapter = this.findCorrespondingSourceAdapter(originalLocation.url);
			if (sourceAdapter) {
				return {
					source: sourceAdapter,
					line: originalLocation.line,
					column: originalLocation.column
				};
			}
		}

		return undefined;
	}

	public interrupt(): Promise<void> {
		return this.coordinator.interrupt();
	}

	public resume(): Promise<void> {
		return this.coordinator.resume();
	}

	public stepOver(): Promise<void> {
		return this.coordinator.stepOver();
	}

	public stepIn(): Promise<void> {
		return this.coordinator.stepIn();
	}

	public stepOut(): Promise<void> {
		return this.coordinator.stepOut();
	}

	public setExceptionBreakpoints(exceptionBreakpoints: ExceptionBreakpoints) {
		const pauseOnExceptions = (exceptionBreakpoints !== ExceptionBreakpoints.None);
		const ignoreCaughtExceptions = (exceptionBreakpoints !== ExceptionBreakpoints.All);
		this.actor.pauseOnExceptions(pauseOnExceptions, ignoreCaughtExceptions);
	}

	private fetchAllStackFrames(): Promise<FrameAdapter[]> {

		if (!this.framesPromise) {
			this.framesPromise = this.coordinator.runOnPausedThread(

				async () => {

					let frames = await this.actor.fetchStackFrames();

					let frameAdapters = frames.map((frame) =>
						new FrameAdapter(this.debugSession.frames, frame, this));

					let threadPausedReason = this.coordinator.threadPausedReason;
					if ((threadPausedReason !== undefined) && (frameAdapters.length > 0)) {

						const scopeAdapters = await frameAdapters[0].getScopeAdapters();

						if (threadPausedReason.frameFinished !== undefined) {

							if (threadPausedReason.frameFinished.return !== undefined) {

								scopeAdapters[0].addReturnValue(
									threadPausedReason.frameFinished.return);

							} else if (threadPausedReason.frameFinished.throw !== undefined) {

								scopeAdapters.unshift(ScopeAdapter.fromGrip(
									'Exception', threadPausedReason.frameFinished.throw, frameAdapters[0]));
							}

						} else if (threadPausedReason.exception !== undefined) {

							scopeAdapters.unshift(ScopeAdapter.fromGrip(
								'Exception', threadPausedReason.exception, frameAdapters[0]));
						}
					}

					return frameAdapters;
				}
			);
		}

		return this.framesPromise;
	}

	public async fetchStackFrames(start: number, count: number): Promise<[FrameAdapter[], number]> {

		let frameAdapters = await this.fetchAllStackFrames();

		let requestedFrames = (count > 0) ? frameAdapters.slice(start, start + count) : frameAdapters.slice(start);

		return [requestedFrames, frameAdapters.length];
	}

	/** this will cause VS Code to reload the current stackframes from this adapter */
	public triggerStackframeRefresh(): void {
		if (this.coordinator.threadTarget === 'paused') {
			this.debugSession.sendStoppedEvent(this, this.coordinator.threadPausedReason);
		}
	}

	public async fetchVariables(variablesProvider: VariablesProvider): Promise<Variable[]> {

		let variableAdapters = await variablesProvider.getVariables();

		return variableAdapters.map((variableAdapter) => variableAdapter.getVariable());
	}

	public async evaluate(expr: string, skipBreakpoints: boolean, frameActorName?: string): Promise<Variable> {

		if (skipBreakpoints) {

			let grip = await this.coordinator.evaluate(expr, frameActorName);
			let variableAdapter = this.variableFromGrip(grip, (frameActorName === undefined));
			return variableAdapter.getVariable();

		} else {

			let grip = await this.consoleActor.evaluate(expr, frameActorName);
			let variableAdapter = this.variableFromGrip(grip, true);
			return variableAdapter.getVariable();
		}
	}

	public async autoComplete(text: string, column: number, frameActorName?: string): Promise<string[]> {
		return await this.consoleActor.autoComplete(text, column, frameActorName);
	}

	public detach(): Promise<void> {
		return this.actor.detach();
	}

	private variableFromGrip(grip: FirefoxDebugProtocol.Grip | undefined, threadLifetime: boolean): VariableAdapter {
		if (grip !== undefined) {
			return VariableAdapter.fromGrip('', undefined, undefined, grip, threadLifetime, this);
		} else {
			return new VariableAdapter('', undefined, undefined, 'undefined', this);
		}
	}

	/**
	 * Called by the `ThreadCoordinator` before resuming the thread
	 */
	private async disposePauseLifetimeAdapters(): Promise<void> {

		if (this.framesPromise) {
			let frames = await this.framesPromise;
			frames.forEach((frameAdapter) => {
				frameAdapter.dispose();
			});
			this.framesPromise = undefined;
		}

		this.scopes.forEach((scopeAdapter) => {
			scopeAdapter.dispose();
		});
		this.scopes = [];

		this.pauseLifetimeObjects.forEach((objectGripAdapter) => {
			objectGripAdapter.dispose();
		});

		this.pauseLifetimeObjects = [];
	}

	public async dispose(): Promise<void> {

		await this.disposePauseLifetimeAdapters();

		this.threadLifetimeObjects.forEach((objectGripAdapter) => {
			objectGripAdapter.dispose();
		});

		this.sources.forEach((source) => {
			source.dispose();
		});

		this.actor.dispose();
		this.consoleActor.dispose();
	}

	/**
	 * The `paused` event is sent when we receive a `paused` event from the thread actor and
	 * neither the `ThreadCoordinator` nor the `ThreadAdapter` decide that Firefox should be
	 * resumed immediately.
	 */
	public onPaused(cb: (event: FirefoxDebugProtocol.ThreadPausedReason) => void) {
		this.on('paused', cb);
	}

	public onResumed(cb: () => void) {
		this.actor.onResumed(cb);
	}

	public onExited(cb: () => void) {
		this.actor.onExited(cb);
	}

	public onWrongState(cb: () => void) {
		this.actor.onWrongState(cb);
	}

	public onNewSource(cb: (newSource: ISourceActorProxy) => void) {
		this.actor.onNewSource(cb);
	}
}
