import { Log } from '../../util/log';
import { ISourceActorProxy, SourceActorProxy } from '../actorProxy/source';
import { SourceMappingInfo } from './info';
import { getUri } from '../../util/net';
import { MappedLocation, Range } from '../../location';

const log = Log.create('SourceMappingSourceActorProxy');

interface Breakables {
	lines: number[];
	locations: Map<number, MappedLocation[]>;
}

export class SourceMappingSourceActorProxy implements ISourceActorProxy {

	public get name(): string {
		return this.source.actor;
	}

	public get url(): string {
		return this.source.url!;
	}

	public get underlyingActor(): SourceActorProxy { return this.sourceMappingInfo.underlyingSource; }

	private allBreakablesPromise?: Promise<Breakables>;

	public constructor(
		public readonly source: FirefoxDebugProtocol.Source,
		private readonly sourceMappingInfo: SourceMappingInfo
	) {}

	public async getBreakableLines(): Promise<number[]> {

		if (!this.allBreakablesPromise) {
			this.allBreakablesPromise = this.getAllBreakables();
		}

		const allBreakables = await this.allBreakablesPromise;
		return allBreakables.lines;
	}

	public async getBreakableLocations(line: number): Promise<MappedLocation[]> {

		if (!this.allBreakablesPromise) {
			this.allBreakablesPromise = this.getAllBreakables();
		}

		const allBreakableLocations = await this.allBreakablesPromise;
		return allBreakableLocations.locations.get(line) || [];
	}

	private async getAllBreakables(): Promise<Breakables> {

		this.sourceMappingInfo.computeColumnSpans();

		if (log.isDebugEnabled()) log.debug(`Calculating ranges for ${this.url} within its generated source`);
		const unresolvedSource = this.sourceMappingInfo.findUnresolvedSource(this.source.url!);
		const generatedRanges: Range[] = [];
		let currentRange: Range | undefined = undefined;
		this.sourceMappingInfo.eachMapping(mapping => {

			if (mapping.source === unresolvedSource) {

				if (!currentRange) {
					currentRange = {
						start: {
							line: mapping.generatedLine,
							column: mapping.generatedColumn
						},
						end: {
							line: mapping.generatedLine,
							column: mapping.lastGeneratedColumn || 0
						}
					}
				} else {
					const lastGeneratedColumn = (mapping as any).lastGeneratedColumn || mapping.generatedColumn;
					currentRange.end = {
						line: mapping.generatedLine,
						column: lastGeneratedColumn
					}
				}

			} else {

				if (currentRange) {
					generatedRanges.push(currentRange);
					currentRange = undefined;
				}
			}
		});
		if (currentRange) {
			generatedRanges.push(currentRange);
		}

		const mappedBreakableLocations = new Map<number, MappedLocation[]>();
		const originalBreakableColumns = new Map<number, Set<number>>();
		for (const range of generatedRanges) {

			if (log.isDebugEnabled()) log.debug(`Fetching generated breakpoint locations for ${this.url}, ${range.start.line}:${range.start.column} - ${range.end.line}:${range.end.column}`);
			const generatedBreakableLocations =
				await this.sourceMappingInfo.underlyingSource.getBreakpointPositionsForRange(range);

			if (log.isDebugEnabled()) log.debug(`Computing original breakpoint locations for ${Object.keys(generatedBreakableLocations).length} generated lines`);
			for (const generatedLineString in generatedBreakableLocations) {
				for (const generatedColumn of generatedBreakableLocations[generatedLineString]) {

					const generatedLine = +generatedLineString;
					const originalLocation = this.sourceMappingInfo.originalLocationFor({
						line: generatedLine,
						column: generatedColumn
					});
					if ((originalLocation === undefined) ||
						(originalLocation.line === null) ||
						(originalLocation.url !== this.url)) {
						continue;
					}

					if (!mappedBreakableLocations.has(originalLocation.line)) {
						mappedBreakableLocations.set(originalLocation.line, []);
						originalBreakableColumns.set(originalLocation.line, new Set<number>());
					}

					const originalColumn = originalLocation.column || 0;
					if (!originalBreakableColumns.get(originalLocation.line)!.has(originalColumn)) {
						mappedBreakableLocations.get(originalLocation.line)!.push({
							line: originalLocation.line,
							column: originalColumn,
							generated: {
								line: generatedLine,
								column: generatedColumn
							}
						});
						originalBreakableColumns.get(originalLocation.line)!.add(originalColumn);
					}
				}
			}
		}

		const breakableLines: number[] = [];
		for (const line of mappedBreakableLocations.keys()) {
			if (mappedBreakableLocations.get(line)!.length > 0) {
				breakableLines.push(+line);
			}
		}
		breakableLines.sort();

		return {
			lines: breakableLines,
			locations: mappedBreakableLocations
		};
	}

	public async fetchSource(): Promise<FirefoxDebugProtocol.Grip> {
		if (log.isDebugEnabled()) log.debug(`Fetching source for ${this.url}`);
		let embeddedSource = this.sourceMappingInfo.sourceContentFor(this.url);
		if (embeddedSource) {
			if (log.isDebugEnabled()) log.debug(`Got embedded source for ${this.url}`);
			return embeddedSource;
		} else {
			const source = await getUri(this.url);
			if (log.isDebugEnabled()) log.debug(`Got non-embedded source for ${this.url}`);
			return source;
		}
	}

	public async setBlackbox(blackbox: boolean): Promise<void> {
		this.source.isBlackBoxed = blackbox;
		this.sourceMappingInfo.syncBlackboxFlag();
	}

	public dispose(): void {
		this.sourceMappingInfo.disposeSource(this);
	}
}
