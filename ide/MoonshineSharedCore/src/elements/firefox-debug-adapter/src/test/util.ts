import { delay, isWindowsPlatform } from '../common/util';
import { DebugClient } from 'vscode-debugadapter-testsupport';
import { DebugProtocol } from 'vscode-debugprotocol';
import { LaunchConfiguration } from '../common/configuration';
import * as path from 'path';

export async function initDebugClient(
	testDataPath: string,
	waitForPageLoadedEvent: boolean,
	extraLaunchArgs?: {}
): Promise<DebugClient> {

	let dc = new DebugClient('node', './dist/adapter.bundle.js', 'firefox');

	let launchArgs: LaunchConfiguration = {
		request: 'launch',
		file: path.join(testDataPath, 'web/index.html')
	};

	if (process.env['FIREFOX_EXECUTABLE']) {
		launchArgs.firefoxExecutable = process.env['FIREFOX_EXECUTABLE'];
	}

	if (process.env['FIREFOX_PROFILE']) {
		launchArgs.profile = process.env['FIREFOX_PROFILE'];
	}

	if (extraLaunchArgs !== undefined) {
		launchArgs = Object.assign(launchArgs, extraLaunchArgs);
	}

	await dc.start();
	await Promise.all([
		dc.launch(launchArgs),
		dc.configurationSequence()
	]);

	if (waitForPageLoadedEvent) {
		await receivePageLoadedEvent(dc);
	}

	return dc;
}

export async function initDebugClientForAddon(
	testDataPath: string,
	options?: {
		delayedNavigation?: boolean,
		addonDirectory?: string
	}
): Promise<DebugClient> {

	let addonPath: string;
	if (options && options.addonDirectory) {
		addonPath = path.join(testDataPath, `${options.addonDirectory}/addOn`);
	} else {
		addonPath = path.join(testDataPath, `webExtension/addOn`);
	}

	let dcArgs: LaunchConfiguration = { 
		request: 'launch',
		addonPath
	};

	if (options && options.delayedNavigation) {
		dcArgs.file = path.join(testDataPath, `web/index.html`);
	} else {
		dcArgs.file = path.join(testDataPath, `webExtension/index.html`);
	}

	if (process.env['FIREFOX_EXECUTABLE']) {
		dcArgs.firefoxExecutable = process.env['FIREFOX_EXECUTABLE'];
	}

	if (process.env['FIREFOX_PROFILE']) {
		dcArgs.profile = process.env['FIREFOX_PROFILE'];
	}

	let dc = new DebugClient('node', './dist/adapter.bundle.js', 'firefox');

	await dc.start();
	await Promise.all([
		dc.launch(dcArgs),
		dc.waitForEvent('initialized', 20000)
	]);
	dc.setExceptionBreakpointsRequest({ filters: [] });

	await receivePageLoadedEvent(dc);

	if (options && options.delayedNavigation) {
		await setConsoleThread(dc, await findTabThread(dc));
		let filePath = path.join(testDataPath, `webExtension/index.html`);
		let fileUrl = isWindowsPlatform() ? 
			'file:///' + filePath.replace(/\\/g, '/') :
			'file://' + filePath;
		await evaluate(dc, `location="${fileUrl}"`);
		await receivePageLoadedEvent(dc);
	}

	return dc;
}

export async function receivePageLoadedEvent(dc: DebugClient, lenient: boolean = false): Promise<void> {
	let ev = await dc.waitForEvent('output', 10000);
	let outputMsg = ev.body.output.trim();
	if (outputMsg.substr(0, 6) !== 'Loaded') {
		if (lenient) {
			await receivePageLoadedEvent(dc, true);
		} else {
			throw new Error(`Wrong output message '${outputMsg}'`);
		}
	}
}

export async function setBreakpoints(
	dc: DebugClient,
	sourcePath: string,
	breakpoints: number[] | DebugProtocol.SourceBreakpoint[],
	waitForVerification = true
): Promise<DebugProtocol.SetBreakpointsResponse> {

	let sourceBreakpoints: DebugProtocol.SourceBreakpoint[];
	if ((breakpoints.length > 0) && (typeof breakpoints[0] === 'number')) {
		sourceBreakpoints = (<number[]>breakpoints).map(line => { return { line }; })
	} else {
		sourceBreakpoints = <DebugProtocol.SourceBreakpoint[]>breakpoints;
	}

	const result = await dc.setBreakpointsRequest({
		source: { path: sourcePath },
		breakpoints: sourceBreakpoints
	});

	if (waitForVerification) {
		let unverified = result.body.breakpoints.filter(breakpoint => !breakpoint.verified).length;
		while (unverified > 0) {
			await receiveBreakpointEvent(dc);
			unverified--;
		}
	}

	return result;
}

export function receiveBreakpointEvent(dc: DebugClient): Promise<DebugProtocol.Event> {
	return dc.waitForEvent('breakpoint', 10000);
}

export function receiveStoppedEvent(dc: DebugClient): Promise<DebugProtocol.Event> {
	return dc.waitForEvent('stopped', 10000);
}

export function collectOutputEvents(dc: DebugClient, count: number): Promise<DebugProtocol.OutputEvent[]> {
	return new Promise<DebugProtocol.OutputEvent[]>(resolve => {

		const outputEvents: DebugProtocol.OutputEvent[] = [];

		function listener(event: DebugProtocol.OutputEvent) {
			outputEvents.push(event);
			if (outputEvents.length >= count) {
				dc.removeListener('output', listener);
				resolve(outputEvents);
			}
		}

		dc.addListener('output', listener);
	});
}

export async function runCommandAndReceiveStoppedEvent(dc: DebugClient, command: () => void): Promise<DebugProtocol.Event> {
	let stoppedEventPromise = dc.waitForEvent('stopped', 10000);
	command();
	return await stoppedEventPromise;
}

export function evaluate(dc: DebugClient, js: string): Promise<DebugProtocol.EvaluateResponse> {
	return dc.evaluateRequest({ context: 'repl', expression: js });
}

export function evaluateDelayed(dc: DebugClient, js: string, delay: number): Promise<DebugProtocol.EvaluateResponse> {
	js = `setTimeout(function() { ${js} }, ${delay})`;
	return evaluate(dc, js);
}

export function evaluateCloaked(dc: DebugClient, js: string): Promise<DebugProtocol.EvaluateResponse> {
	js = js.replace("'", "\\'");
	js = `eval('setTimeout(function() { ${js} }, 0)')`;
	return dc.evaluateRequest({ context: 'repl', expression: js });
}

export async function assertPromiseTimeout(promise: Promise<any>, timeout: number): Promise<void> {
	let promiseResolved = await Promise.race([
		promise.then(() => true),
		delay(timeout).then(() => false)
	]);
	if (promiseResolved) {
		throw new Error(`The Promise was resolved within ${timeout}ms`);
	}
}

export function findVariable(variables: DebugProtocol.Variable[], varName: string): DebugProtocol.Variable {
	for (var i = 0; i < variables.length; i++) {
		if (variables[i].name === varName) {
			return variables[i];
		}
	}
	throw new Error(`Variable '${varName}' not found`);
}

export async function findTabThread(dc: DebugClient): Promise<number> {
	let threadsPresponse = await dc.threadsRequest();
	for (let thread of threadsPresponse.body.threads) {
		if (thread.name.startsWith('Tab')) {
			return thread.id;
		}
	}
	throw new Error('Couldn\'t find a tab thread');
}

export async function setConsoleThread(dc: DebugClient, threadId: number): Promise<void> {
	try {
		await dc.stackTraceRequest({ threadId });
	} catch(e) {}
}
