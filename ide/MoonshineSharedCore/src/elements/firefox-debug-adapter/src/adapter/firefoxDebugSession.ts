import * as path from 'path';
import * as fs from 'fs-extra';
import { Socket } from 'net';
import { ChildProcess } from 'child_process';
import * as chokidar from 'chokidar';
import debounce from 'debounce';
import isAbsoluteUrl from 'is-absolute-url';
import { DebugProtocol } from 'vscode-debugprotocol';
import { InitializedEvent, TerminatedEvent, StoppedEvent, OutputEvent, ThreadEvent, ContinuedEvent, Event } from 'vscode-debugadapter';
import { Log } from './util/log';
import { AddonManager } from './adapter/addonManager';
import { launchFirefox, openNewTab } from './firefox/launch';
import { DebugConnection } from './firefox/connection';
import { TabActorProxy } from './firefox/actorProxy/tab';
import { WorkerActorProxy } from './firefox/actorProxy/worker';
import { ObjectGripActorProxy } from './firefox/actorProxy/objectGrip';
import { LongStringGripActorProxy } from './firefox/actorProxy/longString';
import { AddonsActorProxy } from './firefox/actorProxy/addons';
import { ExceptionBreakpoints, IThreadActorProxy } from './firefox/actorProxy/thread';
import { ConsoleActorProxy } from './firefox/actorProxy/console';
import { ISourceActorProxy } from './firefox/actorProxy/source';
import { FrameAdapter } from './adapter/frame';
import { SourceAdapter } from './adapter/source';
import { VariablesProvider } from './adapter/variablesProvider';
import { VariableAdapter } from './adapter/variable';
import { Registry } from './adapter/registry';
import { ThreadAdapter } from './adapter/thread';
import { ConsoleAPICallAdapter } from './adapter/consoleAPICall';
import { BreakpointsManager } from './adapter/breakpointsManager';
import { DataBreakpointsManager } from './adapter/dataBreakpointsManager';
import { SkipFilesManager } from './adapter/skipFilesManager';
import { ThreadPauseCoordinator } from './coordinator/threadPause';
import { ParsedConfiguration } from './configuration';
import { PathMapper } from './util/pathMapper';
import { isWindowsPlatform as detectWindowsPlatform, delay } from '../common/util';
import { connect, waitForSocket } from './util/net';
import { NewSourceEventBody, ThreadStartedEventBody, ThreadExitedEventBody, RemoveSourcesEventBody } from '../common/customEvents';
import { PreferenceActorProxy } from './firefox/actorProxy/preference';
import { DeviceActorProxy } from './firefox/actorProxy/device';

let log = Log.create('FirefoxDebugSession');
let consoleActorLog = Log.create('ConsoleActor');

export class FirefoxDebugSession {

	public readonly isWindowsPlatform = detectWindowsPlatform();
	public readonly pathMapper: PathMapper;
	public readonly breakpointsManager: BreakpointsManager;
	public dataBreakpointsManager?: DataBreakpointsManager;
	public readonly skipFilesManager: SkipFilesManager;
	public readonly addonManager?: AddonManager;
	private reloadWatcher?: chokidar.FSWatcher;
	private threadPauseCoordinator = new ThreadPauseCoordinator();

	private firefoxProc?: ChildProcess;
	private firefoxClosedPromise?: Promise<void>;
	public firefoxDebugConnection!: DebugConnection;
	private firefoxDebugSocketClosed = false;

	public preferenceActor!: PreferenceActorProxy;
	public addonsActor?: AddonsActorProxy;
	public deviceActor!: DeviceActorProxy;

	public readonly tabs = new Registry<TabActorProxy>();
	public readonly threads = new Registry<ThreadAdapter>();
	public readonly sources = new Registry<SourceAdapter>();
	public readonly frames = new Registry<FrameAdapter>();
	public readonly variablesProviders = new Registry<VariablesProvider>();

	private exceptionBreakpoints: ExceptionBreakpoints = ExceptionBreakpoints.Uncaught;

	private reloadTabs = false;
	private attachToNextTab = false;

	/**
	 * The ID of the last thread that the user interacted with. This thread will be used when the
	 * user wants to evaluate an expression in VS Code's debug console.
	 */
	private lastActiveThreadId: number = 0;

	public constructor(
		public readonly config: ParsedConfiguration,
		private readonly sendEvent: (ev: DebugProtocol.Event) => void
	) {
		this.pathMapper = new PathMapper(this.config.pathMappings, this.config.addon);
		this.breakpointsManager = new BreakpointsManager(
			this.threads, this.config.suggestPathMappingWizard, this.sendEvent);
		this.skipFilesManager = new SkipFilesManager(this.config.filesToSkip, this.threads);
		if (this.config.addon) {
			this.addonManager = new AddonManager(config.enableCRAWorkaround, this);
		}
	}

	/**
	 * Connect to Firefox and start the debug session. Returns a Promise that is resolved when the
	 * initial response from Firefox was processed.
	 */
	public start(): Promise<void> {
		return new Promise<void>(async (resolve, reject) => {

			let socket: Socket;
			try {
				socket = await this.connectToFirefox();
			} catch(err) {
				reject(err);
				return;
			}

			this.firefoxDebugConnection = new DebugConnection(this.config.enableCRAWorkaround, this.pathMapper, socket);
			let rootActor = this.firefoxDebugConnection.rootActor;

			// attach to all tabs, register the corresponding threads and inform VSCode about them
			rootActor.onTabOpened(async ([tabActor, consoleActor]) => {

				log.info(`Tab opened with url ${tabActor.url}`);

				if (!this.attachToNextTab &&
					(!this.config.tabFilter.include.some(tabFilter => tabFilter.test(tabActor.url)) ||
					 this.config.tabFilter.exclude.some(tabFilter => tabFilter.test(tabActor.url)))) {
					log.info('Not attaching to this tab');
					return;
				}

				this.attachToNextTab = false;

				let tabId = this.tabs.register(tabActor);
				let threadAdapter = await this.attachTabOrAddon(tabActor, consoleActor, `Tab ${tabId}`, tabId);
				if (threadAdapter !== undefined) {
					this.attachConsole(consoleActor, threadAdapter);
				}
			});

			rootActor.onTabListChanged(() => {
				rootActor.fetchTabs();
			});

			rootActor.onInit(async (initialResponse) => {

				if (initialResponse.traits.webExtensionAddonConnect &&
					!initialResponse.traits.nativeLogpoints) {
					reject('Your version of Firefox is not supported anymore - please upgrade to Firefox 68 or later');
					return;
				}

				if (initialResponse.traits.watchpoints) {
					this.dataBreakpointsManager = new DataBreakpointsManager(this.variablesProviders);
				}

				const actors = await rootActor.fetchRoot();

				this.preferenceActor = actors.preference;
				this.addonsActor = actors.addons;
				this.deviceActor = actors.device;

				if (this.addonManager) {
					if (actors.addons) {
						this.addonManager.sessionStarted(
							rootActor, actors.addons, actors.preference,
							!!initialResponse.traits.webExtensionAddonConnect
						);
					} else {
						reject('No AddonsActor received from Firefox');
					}
				}

				await rootActor.fetchTabs();

				this.reloadTabs = false;

				if (this.config.attach && (this.tabs.count === 0)) {
					this.attachToNextTab = true;
					if (!await openNewTab(this.config.attach, await this.deviceActor.getDescription())) {
						reject('None of the tabs opened in Firefox match the given URL. If you specify the path to Firefox by setting "firefoxExecutable" in your attach configuration, a new tab for the given URL will be opened automatically.');
						return;
					}
				}

				resolve();
			});

			socket.on('close', () => {
				log.info('Connection to Firefox closed - terminating debug session');
				this.firefoxDebugSocketClosed = true;
				this.sendEvent(new TerminatedEvent());
			});

			if (this.config.reloadOnChange) {

				this.reloadWatcher = chokidar.watch(this.config.reloadOnChange.watch, {
					ignored: this.config.reloadOnChange.ignore,
					ignoreInitial: true
				});

				let reload: () => void;
				if (this.config.addon) {

					reload = () => {
						if (this.addonManager) {
							log.debug('Reloading add-on');

							this.addonManager.reloadAddon();
						}
					}

				} else {

					reload = () => {
						log.debug('Reloading tabs');

						for (let [, tabActor] of this.tabs) {
							tabActor.reload();
						}
					}
				}

				if (this.config.reloadOnChange.debounce > 0) {
					reload = debounce(reload, this.config.reloadOnChange.debounce);
				}

				this.reloadWatcher.on('add', reload);
				this.reloadWatcher.on('change', reload);
				this.reloadWatcher.on('unlink', reload);
			}

			// now we are ready to accept breakpoints -> fire the initialized event to give UI a chance to set breakpoints
			this.sendEvent(new InitializedEvent());
		});
	}

	/**
	 * Terminate the debug session
	 */
	public async stop(): Promise<void> {

		let detachPromises: Promise<void>[] = [];
		if (!this.firefoxDebugSocketClosed) {
			for (let [, threadAdapter] of this.threads) {
				detachPromises.push(threadAdapter.detach());
			}
		}
		await Promise.all(detachPromises);

		await this.disconnectFirefoxAndCleanup();
	}

	public setExceptionBreakpoints(exceptionBreakpoints: ExceptionBreakpoints) {

		this.exceptionBreakpoints = exceptionBreakpoints;

		for (let [, threadAdapter] of this.threads) {
			threadAdapter.setExceptionBreakpoints(this.exceptionBreakpoints);
		}
	}

	public setActiveThread(threadAdapter: ThreadAdapter): void {
		this.lastActiveThreadId = threadAdapter.id;
	}

	public getActiveThread(): ThreadAdapter | undefined {

		let threadAdapter = this.threads.find(this.lastActiveThreadId);
		if (threadAdapter !== undefined) {
			return threadAdapter;
		}

		// last active thread not found -> we return the first thread we get from the registry
		for (let [, threadAdapter] of this.threads) {
			this.setActiveThread(threadAdapter);
			return threadAdapter;
		}

		return undefined;
	}

	public getOrCreateObjectGripActorProxy(objectGrip: FirefoxDebugProtocol.ObjectGrip): ObjectGripActorProxy {
		return this.firefoxDebugConnection.getOrCreate(objectGrip.actor, () =>
			new ObjectGripActorProxy(objectGrip, this.firefoxDebugConnection));
	}

	public getOrCreateLongStringGripActorProxy(longStringGrip: FirefoxDebugProtocol.LongStringGrip): LongStringGripActorProxy {
		return this.firefoxDebugConnection.getOrCreate(longStringGrip.actor, () =>
			new LongStringGripActorProxy(longStringGrip, this.firefoxDebugConnection));
	}

	private async connectToFirefox(): Promise<Socket> {

		let socket: Socket | undefined = undefined;

		if (this.config.attach) {
			try {

				socket = await connect(this.config.attach.port, this.config.attach.host);

				this.reloadTabs = this.config.attach.reloadTabs;

			} catch(err) {
				if (!this.config.launch) {
					throw err;
				}
			}
		}

		if (socket === undefined) {

			const firefoxProc = await launchFirefox(this.config.launch!);

			if (firefoxProc && !this.config.launch!.detached) {

				// set everything up so that Firefox can be terminated at the end of this debug session
				this.firefoxProc = firefoxProc;

				// firefoxProc may be a short-lived startup process - we remove the reference to it
				// when it exits so that we don't try to kill it with a SIGTERM signal (which may
				// end up killing an unrelated process) at the end of this debug session
				this.firefoxProc.once('exit', () => { this.firefoxProc = undefined; });

				// the `close` event from firefoxProc seems to be the only reliable notification
				// that Firefox is exiting
				this.firefoxClosedPromise = new Promise<void>(resolve => {
					this.firefoxProc!.once('close', resolve);
				});
			}

			socket = await waitForSocket(this.config.launch!.port, this.config.launch!.timeout);

			// we ignore the tabFilter for the first tab after launching Firefox
			this.attachToNextTab = true;
		}

		return socket;
	}

	private async disconnectFirefoxAndCleanup(): Promise<void> {

		if (this.reloadWatcher !== undefined) {
			this.reloadWatcher.close();
			this.reloadWatcher = undefined;
		}

		if (!this.config.terminate) {
			await this.firefoxDebugConnection.disconnect();
			return;
		}

		if (this.firefoxProc) {

			log.debug('Trying to kill Firefox using a SIGTERM signal');
			this.firefoxProc.kill('SIGTERM');
			await Promise.race([ this.firefoxClosedPromise, delay(1000) ]);

		} else if (!this.firefoxDebugSocketClosed && this.addonsActor) {

			log.debug('Trying to close Firefox using the Terminator WebExtension');
			const terminatorPath = path.join(__dirname, 'terminator');
			await this.addonsActor.installAddon(terminatorPath);
			await Promise.race([ this.firefoxClosedPromise, delay(1000) ]);

		}

		if (!this.firefoxDebugSocketClosed) {
			log.warn("Couldn't terminate Firefox");
			await this.firefoxDebugConnection.disconnect();
			return;
		}

		if (this.config.launch && (this.config.launch.tmpDirs.length > 0)) {

			// after closing all connections to this debug adapter Firefox will still be using
			// the temporary profile directory for a short while before exiting
			await delay(500);

			log.debug("Removing " + this.config.launch.tmpDirs.join(" , "));
			try {
				await Promise.all(this.config.launch.tmpDirs.map(
					(tmpDir) => fs.remove(tmpDir)));
			} catch (err) {
				log.warn(`Failed to remove temporary directory: ${err}`);
			}
		}
	}

	public async attachTabOrAddon(
		tabActor: TabActorProxy,
		consoleActor: ConsoleActorProxy,
		threadName: string,
		tabId?: number
	): Promise<ThreadAdapter | undefined> {

		let reload = (tabId != null) && this.reloadTabs;

		let threadActor: IThreadActorProxy;
		try {
			threadActor = await tabActor.attach();
		} catch (err) {
			log.error(`Failed attaching to tab: ${err}`);
			return undefined;
		}

		log.debug(`Attached to tab ${tabActor.name}`);

		let threadAdapter = new ThreadAdapter(threadActor, consoleActor,
			this.threadPauseCoordinator, threadName, this);

		this.sendThreadStartedEvent(threadAdapter);

		this.attachThread(threadAdapter, threadActor.name);

		tabActor.onFramesDestroyed(() => {
			this.sendEvent(new Event('removeSources', <RemoveSourcesEventBody>{
				threadId: threadAdapter.id
			}));
			if (this.config.clearConsoleOnReload) {
				this.sendEvent(new OutputEvent('\x1b[2J'));
			}
		});

		if (tabId != null) {

			let nextWorkerId = 1;
			tabActor.onWorkerStarted(async (workerActor) => {

				log.info(`Worker started with url ${tabActor.url}`);

				let workerId = nextWorkerId++;

				try {
					await this.attachWorker(workerActor, tabId, workerId);
				} catch (err) {
					log.error(`Failed attaching to worker: ${err}`);
				}
			});

			tabActor.onWorkerListChanged(() => tabActor.fetchWorkers());
			tabActor.fetchWorkers();

			tabActor.onDetached(() => {

				this.threadPauseCoordinator.threadTerminated(threadAdapter.id, threadAdapter.name);

				if (this.threads.has(threadAdapter.id)) {
					this.threads.unregister(threadAdapter.id);
					this.sendThreadExitedEvent(threadAdapter);
				}

				threadAdapter.dispose();

				this.tabs.unregister(tabId);

				tabActor.dispose();
			});
		}

		try {

			await threadAdapter.init(this.exceptionBreakpoints);

			if (reload) {
				await tabActor.reload();
			}

			return threadAdapter;

		} catch (err) {
			log.info(`Failed attaching to tab: ${err}`);
			return undefined;
		}
	}

	private async attachWorker(workerActor: WorkerActorProxy, tabId: number, workerId: number): Promise<void> {

		await workerActor.attach();
		let [threadActor, consoleActor] = await workerActor.connect();

		log.debug(`Attached to worker ${workerActor.name}`);

		let threadAdapter = new ThreadAdapter(threadActor, consoleActor,
			this.threadPauseCoordinator, `Worker ${tabId}/${workerId}`, this);

		this.sendThreadStartedEvent(threadAdapter);

		this.attachThread(threadAdapter, threadActor.name);

		await threadAdapter.init(this.exceptionBreakpoints);

		workerActor.onClose(() => {
			this.threads.unregister(threadAdapter.id);
			this.sendThreadExitedEvent(threadAdapter);
		});
	}

	private attachThread(threadAdapter: ThreadAdapter, actorName: string): void {

		threadAdapter.onNewSource((sourceActor) => {
			this.attachSource(sourceActor, threadAdapter);
		});

		threadAdapter.onPaused((reason) => {
			log.info(`Thread ${actorName} paused , reason: ${reason.type}`);
			this.sendStoppedEvent(threadAdapter, reason);
		});

		threadAdapter.onResumed(() => {
			log.info(`Thread ${actorName} resumed unexpectedly`);
			this.sendEvent(new ContinuedEvent(threadAdapter.id));
		});

		threadAdapter.onExited(() => {
			log.info(`Thread ${actorName} exited`);
			this.threads.unregister(threadAdapter.id);
			this.sendThreadExitedEvent(threadAdapter);
		});
	}

	private attachSource(sourceActor: ISourceActorProxy, threadAdapter: ThreadAdapter): void {

		const source = sourceActor.source;
		let sourceAdapter = threadAdapter.findCorrespondingSourceAdapter(source.url || undefined);

		if (sourceAdapter !== undefined) {
			sourceAdapter.replaceActor(sourceActor);
			this.sendNewSourceEvent(threadAdapter, sourceAdapter);
			return;
		}

		const sourcePath = this.pathMapper.convertFirefoxSourceToPath(source);
		sourceAdapter = threadAdapter.createSourceAdapter(sourceActor, sourcePath);

		this.sendNewSourceEvent(threadAdapter, sourceAdapter);

		// check if this source should be skipped
		let skipThisSource: boolean | undefined = undefined;
		if (sourcePath !== undefined) {
			skipThisSource = this.skipFilesManager.shouldSkip(sourcePath);
		} else if (source.generatedUrl && (!source.url || !isAbsoluteUrl(source.url))) {
			skipThisSource = this.skipFilesManager.shouldSkip(this.pathMapper.removeQueryString(source.generatedUrl));
		} else if (source.url) {
			skipThisSource = this.skipFilesManager.shouldSkip(this.pathMapper.removeQueryString(source.url));
		}

		if (skipThisSource !== undefined) {
			if (source.isBlackBoxed !== skipThisSource) {
				sourceActor.setBlackbox(skipThisSource);
			}
		}

		this.breakpointsManager.onNewSource(sourceAdapter);
	}

	public attachConsole(consoleActor: ConsoleActorProxy, threadAdapter: ThreadAdapter): void {

		consoleActor.onConsoleAPICall(async (consoleEvent) => {
			consoleActorLog.debug(`Console API: ${JSON.stringify(consoleEvent)}`);

			if (consoleEvent.level === 'clear') {
				this.sendEvent(new OutputEvent('\x1b[2J'));
				return;
			}

			let category = (consoleEvent.level === 'error') ? 'stderr' :
				(consoleEvent.level === 'warn') ? 'console' : 'stdout';

			let outputEvent: DebugProtocol.OutputEvent;
			if ((consoleEvent.arguments.length === 1) && (typeof consoleEvent.arguments[0] !== 'object')) {

				let msg = String(consoleEvent.arguments[0]);
				if (this.config.showConsoleCallLocation) {
					let filename = this.pathMapper.convertFirefoxUrlToPath(consoleEvent.filename);
					msg += ` (${filename}:${consoleEvent.lineNumber}:${consoleEvent.columnNumber})`;
				}

				outputEvent = new OutputEvent(msg + '\n', category);

			} else {

				let args = consoleEvent.arguments.map((grip, index) => {
					if (typeof grip !== 'object') {
						return new VariableAdapter(String(index), undefined, undefined, String(grip), threadAdapter);
					} else {
						return VariableAdapter.fromGrip(String(index), undefined, undefined, grip, true, threadAdapter);
					}
				});

				if ((consoleEvent.level === 'logPoint') && (args[args.length - 1].displayValue === '')) {
					args.pop();
				}

				if (this.config.showConsoleCallLocation) {
					let filename = this.pathMapper.convertFirefoxUrlToPath(consoleEvent.filename);
					let locationVar = new VariableAdapter(
						'location', undefined, undefined,
						`(${filename}:${consoleEvent.lineNumber}:${consoleEvent.columnNumber})`,
						threadAdapter);
					args.push(locationVar);
				}

				let argsAdapter = new ConsoleAPICallAdapter(args, threadAdapter);

				outputEvent = new OutputEvent('', category);
				outputEvent.body.variablesReference = argsAdapter.variablesProviderId;
			}

			await this.addLocation(outputEvent, consoleEvent.filename, consoleEvent.lineNumber, consoleEvent.columnNumber);

			this.sendEvent(outputEvent);
		});

		consoleActor.onPageErrorCall(async (err) => {
			consoleActorLog.debug(`Page Error: ${JSON.stringify(err)}`);

			if (err.category === 'content javascript') {

				let category = err.exception ? 'stderr' : 'stdout';
				let outputEvent = new OutputEvent(err.errorMessage + '\n', category);
				await this.addLocation(outputEvent, err.sourceName, err.lineNumber, err.columnNumber);

				this.sendEvent(outputEvent);
			}
		});

		consoleActor.startListeners();
		consoleActor.getCachedMessages();
	}

	private async addLocation(
		outputEvent: DebugProtocol.OutputEvent,
		url: string,
		line: number,
		column: number
	) {

		for (let [, thread] of this.threads) {
			let originalSourceLocation = await thread.findOriginalSourceLocation(url, line, column);
			if (originalSourceLocation) {
				const sourceAdapter = originalSourceLocation.source;
				outputEvent.body.source = sourceAdapter.source;
				outputEvent.body.line = originalSourceLocation.line;
				outputEvent.body.column = originalSourceLocation.column;
				return;
			}
		}
	}

	public sendStoppedEvent(
		threadAdapter: ThreadAdapter,
		reason?: FirefoxDebugProtocol.ThreadPausedReason
	): void {

		let pauseType = reason ? reason.type : 'interrupt';
		let stoppedEvent: DebugProtocol.StoppedEvent = new StoppedEvent(pauseType, threadAdapter.id);
		stoppedEvent.body.allThreadsStopped = false;

		if (reason && reason.exception) {

			if (typeof reason.exception === 'string') {

				stoppedEvent.body.text = reason.exception;

			} else if ((typeof reason.exception === 'object') && (reason.exception.type === 'object')) {

				let exceptionGrip = <FirefoxDebugProtocol.ObjectGrip>reason.exception;
				if (exceptionGrip.preview && (exceptionGrip.preview.kind === 'Error')) {
					stoppedEvent.body.text = `${exceptionGrip.class}: ${exceptionGrip.preview.message}`;
				} else {
					stoppedEvent.body.text = exceptionGrip.class;
				}
			}
		}

		this.sendEvent(stoppedEvent);
	}

	public findSourceAdapter(url: string, tryWithoutQueryString = false): SourceAdapter | undefined {

		for (let [, thread] of this.threads) {
			let sources = thread.findSourceAdaptersForPathOrUrl(url);
			if (sources.length > 0) {
				return sources[0]!;
			}
		}

		// workaround for VSCode issue #32845: the url may have contained a query string that got lost,
		// in this case we look for a Source whose url is the same if the query string is removed
		if (tryWithoutQueryString && (url.indexOf('?') < 0)) {
			for (let [, thread] of this.threads) {
				let sources = thread.findSourceAdaptersForUrlWithoutQuery(url);
				if (sources.length > 0) {
					return sources[0]!;
				}
			}
		}

		return undefined;
	}

	/** tell VS Code and the [Loaded Scripts Explorer](../extension/loadedScripts) about a new thread */
	private sendThreadStartedEvent(threadAdapter: ThreadAdapter): void {
		this.sendEvent(new ThreadEvent('started', threadAdapter.id));
		this.sendEvent(new Event('threadStarted', <ThreadStartedEventBody>{
			name: threadAdapter.name,
			id: threadAdapter.id
		}));
	}

	/** tell VS Code and the [Loaded Scripts Explorer](../extension/loadedScripts) to remove a thread */
	private sendThreadExitedEvent(threadAdapter: ThreadAdapter): void {
		this.sendEvent(new ThreadEvent('exited', threadAdapter.id));
		this.sendEvent(new Event('threadExited', <ThreadExitedEventBody>{
			id: threadAdapter.id
		}));
	}

	/** tell the [Loaded Scripts Explorer](../extension/loadedScripts) about a new source */
	private sendNewSourceEvent(threadAdapter: ThreadAdapter, sourceAdapter: SourceAdapter): void {

		const sourceUrl = sourceAdapter.actor.url;

		if (sourceUrl && !sourceUrl.startsWith('javascript:')) {
			this.sendEvent(new Event('newSource', <NewSourceEventBody>{
				threadId: threadAdapter.id,
				sourceId: sourceAdapter.id,
				url: sourceUrl,
				path: sourceAdapter.sourcePath
			}));
		}
	}

	public sendCustomEvent(event: string, eventBody: any): void {
		this.sendEvent(new Event(event, eventBody));
	}
}
