import * as url from 'url';
import { Log } from '../../util/log';
import { isWindowsPlatform as detectWindowsPlatform } from '../../../common/util';
import { ISourceActorProxy, SourceActorProxy } from '../actorProxy/source';
import { SourceMapConsumer, BasicSourceMapConsumer, MappingItem } from 'source-map';
import { UrlLocation, LocationWithColumn } from '../../location';

let GREATEST_LOWER_BOUND = SourceMapConsumer.GREATEST_LOWER_BOUND;
let LEAST_UPPER_BOUND = SourceMapConsumer.LEAST_UPPER_BOUND;

const isWindowsPlatform = detectWindowsPlatform();
const windowsAbsolutePathRegEx = /^[a-zA-Z]:[\/\\]/;

declare module "source-map" {
	interface MappingItem {
		lastGeneratedColumn?: number | null;
	}
}

const log = Log.create('SourceMappingInfo');

export class SourceMappingInfo {

	private columnSpansComputed = false;

	public get hasSourceMap(): boolean { return !!this.sourceMapConsumer; }

	public constructor(
		public readonly sources: ISourceActorProxy[],
		public readonly underlyingSource: SourceActorProxy,
		public readonly sourceMapUri?: string,
		private readonly sourceMapConsumer?: BasicSourceMapConsumer,
		private readonly sourceRoot?: string
	) {}

	public computeColumnSpans(): void {
		if (this.sourceMapConsumer && !this.columnSpansComputed) {
			this.sourceMapConsumer.computeColumnSpans();
			this.columnSpansComputed = true;
		}
	}

	public originalLocationFor(generatedLocation: LocationWithColumn): UrlLocation | undefined {

		if (!this.sourceMapConsumer) {
			return { ...generatedLocation, url: this.sources[0].url || undefined };
		}

		let consumerArgs = {
			line: generatedLocation.line,
			column: generatedLocation.column || 0,
			bias: GREATEST_LOWER_BOUND
		};

		if (this.underlyingSource.source.introductionType === 'wasm') {
			consumerArgs.column = consumerArgs.line;
			consumerArgs.line = 1;
		}

		let originalLocation = this.sourceMapConsumer.originalPositionFor(consumerArgs);

		if (originalLocation.source === null) {
			consumerArgs.bias = LEAST_UPPER_BOUND;
			originalLocation = this.sourceMapConsumer.originalPositionFor(consumerArgs);
		}

		if (originalLocation.source === null) {
			log.warn(`Got original location ${JSON.stringify(originalLocation)} for generated location ${JSON.stringify(generatedLocation)}`);
			return undefined;
		}

		originalLocation.source = this.resolveSource(originalLocation.source);

		if ((this.underlyingSource.source.introductionType === 'wasm') && originalLocation.line) {
			originalLocation.line--;
		}

		if (originalLocation.line !== null) {
			return {
				url: originalLocation.source,
				line: originalLocation.line,
				column: (originalLocation.column !== null) ? originalLocation.column : undefined
			};
		} else {
			return undefined;
		}
	}

	public eachMapping(callback: (mapping: MappingItem) => void): void {
		if (this.sourceMapConsumer) {
			this.sourceMapConsumer.eachMapping(mappingItem => {
				const lastGeneratedColumn = (mappingItem.lastGeneratedColumn !== undefined) ? (mappingItem.lastGeneratedColumn || mappingItem.generatedColumn) : undefined;
				callback({
					...mappingItem,
					originalColumn: mappingItem.originalColumn,
					generatedColumn: mappingItem.generatedColumn,
					lastGeneratedColumn
				});
			}, undefined, SourceMapConsumer.GENERATED_ORDER);
		}
	}

	public sourceContentFor(source: string): string | undefined {
		if (this.sourceMapConsumer) {
			return this.sourceMapConsumer.sourceContentFor(source) || undefined;
		}
		return undefined;
	}

	public syncBlackboxFlag(): void {

		if ((this.sources.length === 1) && (this.sources[0] === this.underlyingSource)) {
			return;
		}

		let blackboxUnderlyingSource = this.sources.every((source) => source.source.isBlackBoxed);
		if (this.underlyingSource.source.isBlackBoxed !== blackboxUnderlyingSource) {
			this.underlyingSource.setBlackbox(blackboxUnderlyingSource);
		}
	}

	public disposeSource(source: ISourceActorProxy): void {

		let sourceIndex = this.sources.indexOf(source);
		if (sourceIndex >= 0) {

			this.sources.splice(sourceIndex, 1);

			if (this.sources.length === 0) {
				this.underlyingSource.dispose();
			}
		}
	}

	public resolveSource(sourceUrl: string): string {

			// some tools (e.g. create-react-app) use absolute _paths_ instead of _urls_ here,
			// we work around this bug by converting anything that looks like an absolute path
			// into a url
			if (isWindowsPlatform)
			{
				if (windowsAbsolutePathRegEx.test(sourceUrl)) {
					sourceUrl = encodeURI('file:///' + sourceUrl.replace(/\\/g, '/'));
				}
			} else {
				if (sourceUrl.startsWith('/')) {
					sourceUrl = encodeURI('file://' + sourceUrl);
				}
			}

			if (this.sourceRoot) {
				sourceUrl = url.resolve(this.sourceRoot, sourceUrl);
			}

			return sourceUrl;
	}

	public findUnresolvedSource(resolvedSource: string): string | undefined {
		if (!this.sourceMapConsumer) return undefined;

		for (const source of this.sourceMapConsumer.sources) {

			if ((source === resolvedSource) ||
				(this.resolveSource(source) === resolvedSource)) {

				return source;
			}
		}

		return undefined;
	}
}
