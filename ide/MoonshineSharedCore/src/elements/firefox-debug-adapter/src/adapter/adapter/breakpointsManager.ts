import { Log } from '../util/log';
import { isWindowsPlatform as detectWindowsPlatform } from '../../common/util';
import { SourceAdapter } from './source';
import { ThreadAdapter } from './thread';
import { Registry } from './registry';
import { BreakpointInfo } from './breakpoint';
import { DebugProtocol } from 'vscode-debugprotocol';
import { Breakpoint, BreakpointEvent, Event } from 'vscode-debugadapter';

let log = Log.create('BreakpointsManager');

const isWindowsPlatform = detectWindowsPlatform();
const windowsAbsolutePathRegEx = /^[a-zA-Z]:\\/;

/**
 * This class holds all breakpoints that have been set in VS Code and synchronizes them with all
 * sources in all threads in Firefox using [`SourceAdapter#updateBreakpoints()`](./source.ts).
 */
export class BreakpointsManager {

	private nextBreakpointId = 1;
	private readonly breakpointsBySourcePathOrUrl = new Map<string, BreakpointInfo[]>();

	constructor(
		private readonly threads: Registry<ThreadAdapter>,
		private readonly suggestPathMappingWizard: boolean,
		private readonly sendEvent: (ev: DebugProtocol.Event) => void
	) {}

	/**
	 * called by [`FirefoxDebugAdapter#setBreakpoints()`](../firefoxDebugAdapter.ts) whenever the
	 * breakpoints have been changed by the user in VS Code
	 */
	public setBreakpoints(
		breakpoints: DebugProtocol.SourceBreakpoint[],
		sourcePathOrUrl: string
	): BreakpointInfo[] {

		log.debug(`Setting ${breakpoints.length} breakpoints for ${sourcePathOrUrl}`);

		const key = this.createBreakpointInfoKey(sourcePathOrUrl);
		const oldBreakpointInfos = this.breakpointsBySourcePathOrUrl.get(key);
		const breakpointInfos = breakpoints.map(
			breakpoint => this.getOrCreateBreakpointInfo(breakpoint, oldBreakpointInfos)
		);

		this.breakpointsBySourcePathOrUrl.set(key, breakpointInfos);

		let sourceAdapterFound = false;
		for (const [, threadAdapter] of this.threads) {
			const sourceAdapters = threadAdapter.findSourceAdaptersForPathOrUrl(sourcePathOrUrl);
			for (const sourceAdapter of sourceAdapters) {
				sourceAdapterFound = true;
				sourceAdapter.updateBreakpoints(breakpointInfos);
			}
		}

		if (!sourceAdapterFound && this.suggestPathMappingWizard) {
			this.sendEvent(new Event('unknownSource', sourcePathOrUrl));
		}

		return breakpointInfos;
	}

	/** 
	 * called by [`SourceAdapter#syncBreakpoints()`](./source.ts) whenever a breakpoint has been set
	 * in Firefox
	 */
	public verifyBreakpoint(breakpointInfo: BreakpointInfo): void {

		if (!breakpointInfo.actualLocation) return;

		let breakpoint: DebugProtocol.Breakpoint = new Breakpoint(
			true, breakpointInfo.actualLocation.line, breakpointInfo.actualLocation.column + 1);
		breakpoint.id = breakpointInfo.id;
		this.sendEvent(new BreakpointEvent('changed', breakpoint));

		breakpointInfo.verified = true;
	}

	/**
	 * called by [`FirefoxDebugSession#attachSource()`](../firefoxDebugSession.ts) whenever a new
	 * javascript source was attached
	 */
	public onNewSource(sourceAdapter: SourceAdapter) {
		const sourcePath = sourceAdapter.sourcePath;
		if (sourcePath !== undefined) {
			const key = this.createBreakpointInfoKey(sourcePath);
			const breakpointInfos = this.breakpointsBySourcePathOrUrl.get(key);
			if (breakpointInfos !== undefined) {
				sourceAdapter.updateBreakpoints(breakpointInfos);
			}
		}
	}

	private createBreakpointInfoKey(sourcePathOrUrl: string): string {
		if (isWindowsPlatform && windowsAbsolutePathRegEx.test(sourcePathOrUrl)) {
			return sourcePathOrUrl.toLowerCase();
		} else {
			return sourcePathOrUrl;
		}
	}

	private getOrCreateBreakpointInfo(
		requestedBreakpoint: DebugProtocol.SourceBreakpoint,
		oldBreakpointInfos: BreakpointInfo[] | undefined
	): BreakpointInfo {

		if (oldBreakpointInfos) {

			const oldBreakpointInfo = oldBreakpointInfos.find(
				breakpointInfo => breakpointInfo.isEquivalent(requestedBreakpoint)
			);

			if (oldBreakpointInfo) {
				return oldBreakpointInfo;
			}
		}

		return new BreakpointInfo(this.nextBreakpointId++, requestedBreakpoint);
	}
}
