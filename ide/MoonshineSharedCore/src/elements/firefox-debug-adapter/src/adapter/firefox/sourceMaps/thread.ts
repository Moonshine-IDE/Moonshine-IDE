import { EventEmitter } from 'events';
import * as url from 'url';
import * as fs from 'fs-extra';
import isAbsoluteUrl from 'is-absolute-url';
import { SourceMapConsumer, RawSourceMap } from 'source-map';
import { Log } from '../../util/log';
import { PathMapper } from '../../util/pathMapper';
import { getUri, urlDirname } from '../../util/net';
import { PendingRequest } from '../../util/pendingRequests';
import { DebugConnection } from '../connection';
import { ISourceActorProxy, SourceActorProxy } from '../actorProxy/source';
import { SourceMappingSourceActorProxy } from './source';
import { IThreadActorProxy, ExceptionBreakpoints, AttachOptions } from '../actorProxy/thread';
import { SourceMappingInfo } from './info';
import { MappedLocation, UrlLocation } from '../../location';

let log = Log.create('SourceMappingThreadActorProxy');

export class SourceMappingThreadActorProxy extends EventEmitter implements IThreadActorProxy {

	private sourceMappingInfos = new Map<string, Promise<SourceMappingInfo>>();
	private pendingSources = new Map<string, PendingRequest<SourceMappingInfo>>();

	public constructor(
		private readonly underlyingActorProxy: IThreadActorProxy,
		private readonly pathMapper: PathMapper,
		private readonly connection: DebugConnection
	) {
		super();

		underlyingActorProxy.onNewSource(async (generatedSourceActor) => {
			let sourceMappingInfo = await this.getOrCreateSourceMappingInfo(generatedSourceActor.source);
			for (let originalSourceActor of sourceMappingInfo.sources) {
				this.emit('newSource', originalSourceActor);
			}
			if (!sourceMappingInfo.sources.some(actor => actor === generatedSourceActor)) {
				this.emit('newSource', generatedSourceActor);
			}
		});
	}

	public get name(): string {
		return this.underlyingActorProxy.name;
	}

	public async fetchSources(): Promise<FirefoxDebugProtocol.Source[]> {

		let underlyingSources = await this.underlyingActorProxy.fetchSources();

		let allMappedSources: FirefoxDebugProtocol.Source[] = [];
		for (let source of underlyingSources) {
			let info = await this.getOrCreateSourceMappingInfo(source);
			let mappedSources = info.sources.map((actor) => actor.source);
			allMappedSources.push(...mappedSources);
		}

		return allMappedSources;
	}

	private getOrCreateSourceMappingInfo(
		source: FirefoxDebugProtocol.Source
	): Promise<SourceMappingInfo> {

		if (this.sourceMappingInfos.has(source.actor)) {

			if (this.pendingSources.has(source.actor)) {

				const pending = this.pendingSources.get(source.actor)!;
				this.pendingSources.delete(source.actor);

				(async () => {
					try {

						const sourceMappingInfos = await this.createSourceMappingInfo(source);
						pending.resolve(sourceMappingInfos);

					} catch(e) {
						pending.reject(e);
					}
				})();
			}

			return this.sourceMappingInfos.get(source.actor)!;

		} else {

			let sourceMappingInfoPromise = this.createSourceMappingInfo(source);
			this.sourceMappingInfos.set(source.actor, sourceMappingInfoPromise);
			return sourceMappingInfoPromise;
		}
	}

	private async createSourceMappingInfo(
		source: FirefoxDebugProtocol.Source
	): Promise<SourceMappingInfo> {

		if (log.isDebugEnabled()) {
			log.debug(`Trying to sourcemap ${JSON.stringify(source)}`);
		}

		let sourceActor = this.connection.getOrCreate(
			source.actor, () => new SourceActorProxy(source, this.connection));

		let sourceMapUrl = source.sourceMapURL;
		if (!sourceMapUrl) {
			return new SourceMappingInfo([sourceActor], sourceActor);
		}

		if (!isAbsoluteUrl(sourceMapUrl)) {
			if (source.url) {
				sourceMapUrl = url.resolve(urlDirname(source.url), sourceMapUrl);
			} else {
				log.warn(`Can't create absolute sourcemap URL from ${sourceMapUrl} - giving up`);
				return new SourceMappingInfo([sourceActor], sourceActor);
			}
		}

		let rawSourceMap: RawSourceMap | undefined = undefined;
		try {

			const sourceMapPath = this.pathMapper.convertFirefoxUrlToPath(sourceMapUrl);
			if (sourceMapPath && !isAbsoluteUrl(sourceMapPath)) {
				try {
					const sourceMapString = await fs.readFile(sourceMapPath, 'utf8');
					log.debug('Loaded sourcemap from disk');
					rawSourceMap = JSON.parse(sourceMapString);
					log.debug('Parsed sourcemap');
				} catch(e) {
					log.debug(`Failed reading sourcemap from ${sourceMapPath} - trying to fetch it from ${sourceMapUrl}`);
				}
			}

			if (!rawSourceMap) {
				const sourceMapString = await getUri(sourceMapUrl);
				log.debug('Received sourcemap');
				rawSourceMap = JSON.parse(sourceMapString);
				log.debug('Parsed sourcemap');
			}

		} catch(e) {
			log.warn(`Failed fetching sourcemap from ${sourceMapUrl} - giving up`);
			return new SourceMappingInfo([sourceActor], sourceActor);
		}

		let sourceMapConsumer = await new SourceMapConsumer(rawSourceMap!);
		let sourceMappingSourceActors: SourceMappingSourceActorProxy[] = [];
		let sourceRoot = rawSourceMap!.sourceRoot;
		if (!sourceRoot && source.url) {
			sourceRoot = urlDirname(source.url);
		} else if ((sourceRoot !== undefined) && !isAbsoluteUrl(sourceRoot)) {
			sourceRoot = url.resolve(sourceMapUrl, sourceRoot);
		}
		log.debug('Created SourceMapConsumer');

		let sourceMappingInfo = new SourceMappingInfo(
			sourceMappingSourceActors, sourceActor, sourceMapUrl, sourceMapConsumer, sourceRoot);

		for (let origSource of sourceMapConsumer.sources) {

			origSource = sourceMappingInfo.resolveSource(origSource);

			let sourceMappingSource = this.createOriginalSource(source, origSource, sourceMapUrl);

			let sourceMappingSourceActor = new SourceMappingSourceActorProxy(
				sourceMappingSource, sourceMappingInfo);

			sourceMappingSourceActors.push(sourceMappingSourceActor);
		}

		return sourceMappingInfo;
	}

	private getSourceMappingInfo(actor: string): Promise<SourceMappingInfo> {

		if (this.sourceMappingInfos.has(actor)) {

			return this.sourceMappingInfos.get(actor)!;

		} else {

			const promise = new Promise<SourceMappingInfo>((resolve, reject) => {
				this.pendingSources.set(actor, { resolve, reject });
			});

			this.sourceMappingInfos.set(actor, promise);

			return promise;
		}
	}

	public async fetchStackFrames(
		start?: number,
		count?: number
	): Promise<FirefoxDebugProtocol.Frame[]> {

		let stackFrames = await this.underlyingActorProxy.fetchStackFrames(start, count);

		await Promise.all(stackFrames.map((frame) => this.applySourceMapToFrame(frame)));

		return stackFrames;
	}

	private async applySourceMapToFrame(frame: FirefoxDebugProtocol.Frame): Promise<void> {

		let sourceMappingInfo: SourceMappingInfo | undefined;
		const sourceMappingInfoPromise = this.getSourceMappingInfo(frame.where.actor);
		sourceMappingInfo = await sourceMappingInfoPromise;
		const source = sourceMappingInfo.underlyingSource.source;

		if (source && sourceMappingInfo && sourceMappingInfo.hasSourceMap && frame.where.line) {

			let originalLocation = sourceMappingInfo.originalLocationFor({
				line: frame.where.line, column: frame.where.column || 0
			});

			if (originalLocation && originalLocation.url) {

				frame.where = {
					actor: `${source.actor}!${originalLocation.url}`,
					line: originalLocation.line || undefined,
					column: originalLocation.column || undefined
				}
			}
		}
	}

	private createOriginalSource(
		generatedSource: FirefoxDebugProtocol.Source,
		originalSourceUrl: string | null,
		sourceMapUrl: string
	): FirefoxDebugProtocol.Source {

		return <FirefoxDebugProtocol.Source>{
			actor: `${generatedSource.actor}!${originalSourceUrl}`,
			url: originalSourceUrl,
			introductionUrl: generatedSource.introductionUrl,
			introductionType: generatedSource.introductionType,
			generatedUrl: generatedSource.url,
			isBlackBoxed: false,
			isPrettyPrinted: false,
			isSourceMapped: true,
			sourceMapURL: sourceMapUrl
		}
	}

	public async setBreakpoint(location: MappedLocation, sourceActor: ISourceActorProxy, condition?: string, logValue?: string): Promise<void> {
		if (location.generated && (sourceActor instanceof SourceMappingSourceActorProxy)) {
			await this.underlyingActorProxy.setBreakpoint(location.generated, sourceActor.underlyingActor, condition, logValue);
		} else {
			await this.underlyingActorProxy.setBreakpoint(location, sourceActor, condition, logValue);
		}
	}

	public async removeBreakpoint(location: MappedLocation, sourceActor: ISourceActorProxy): Promise<void> {
		if (location.generated && (sourceActor instanceof SourceMappingSourceActorProxy)) {
			await this.underlyingActorProxy.removeBreakpoint(location.generated, sourceActor.underlyingActor);
		} else {
			await this.underlyingActorProxy.removeBreakpoint(location, sourceActor);
		}
	}

	public pauseOnExceptions(pauseOnExceptions: boolean, ignoreCaughtExceptions: boolean): Promise<void> {
		return this.underlyingActorProxy.pauseOnExceptions(pauseOnExceptions, ignoreCaughtExceptions);
	}

	public attach(options: AttachOptions): Promise<void> {
		return this.underlyingActorProxy.attach(options);
	}

	public resume(
		exceptionBreakpoints: ExceptionBreakpoints | undefined,
		resumeLimitType?: "next" | "step" | "finish" | undefined
	): Promise<void> {
		return this.underlyingActorProxy.resume(exceptionBreakpoints, resumeLimitType);
	}

	public interrupt(immediately: boolean = true): Promise<void> {
		return this.underlyingActorProxy.interrupt(immediately);
	}

	public async findOriginalLocation(
		generatedUrl: string,
		line: number,
		column?: number
	): Promise<UrlLocation | undefined> {

		for (const infoPromise of this.sourceMappingInfos.values()) {
			const info = await infoPromise;
			if (generatedUrl === info.underlyingSource.url) {

				const originalLocation = info.originalLocationFor({ line, column: column || 0 });

				if (originalLocation && originalLocation.url && originalLocation.line) {
					return {
						url: originalLocation.url,
						line: originalLocation.line,
						column: originalLocation.column || 0
					};
				}
			}
		}

		return undefined;
	}

	public onPaused(cb: (_event: FirefoxDebugProtocol.ThreadPausedResponse) => void): void {
		this.underlyingActorProxy.onPaused(async (event) => {
			await this.applySourceMapToFrame(event.frame);
			cb(event);
		});
	}

	public onResumed(cb: () => void): void {
		this.underlyingActorProxy.onResumed(cb);
	}

	public onExited(cb: () => void): void {
		this.underlyingActorProxy.onExited(cb);
	}

	public onWrongState(cb: () => void): void {
		this.underlyingActorProxy.onWrongState(cb);
	}

	public onNewSource(cb: (newSource: ISourceActorProxy) => void): void {
		this.on('newSource', cb);
	}

	public onNewGlobal(cb: () => void): void {
		this.underlyingActorProxy.onNewGlobal(cb);
	}

	public dispose(): void {
		this.underlyingActorProxy.dispose();
	}
}
