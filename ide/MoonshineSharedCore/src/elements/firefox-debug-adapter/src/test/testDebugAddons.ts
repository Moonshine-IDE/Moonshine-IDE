import { DebugClient } from 'vscode-debugadapter-testsupport';
import { DebugProtocol } from 'vscode-debugprotocol';
import * as path from 'path';
import * as util from './util';
import * as assert from 'assert';
import { delay } from '../common/util';

const TESTDATA_PATH = path.join(__dirname, '../../testdata');

describe('Addons: The debugger', function() {

	let dc: DebugClient;

	afterEach(async function() {
		await dc.stop();
	});

	it(`should debug a WebExtension`, async function() {

		dc = await util.initDebugClientForAddon(TESTDATA_PATH);

		await debugWebExtension(dc);
	});

	it(`should show log messages from WebExtensions`, async function() {

		dc = await util.initDebugClientForAddon(TESTDATA_PATH);

		await util.setConsoleThread(dc, await util.findTabThread(dc));
		util.evaluate(dc, 'putMessage("bar")');

		let outputEvent = <DebugProtocol.OutputEvent> await dc.waitForEvent('output');

		assert.equal(outputEvent.body.category, 'stdout');
		assert.equal(outputEvent.body.output.trim(), 'foo: bar');
	});

	it(`should debug a WebExtension without an ID if it is installed using RDP`, async function() {

		dc = await util.initDebugClientForAddon(TESTDATA_PATH, { addonDirectory: 'webExtension2' });

		await debugWebExtension(dc, 'webExtension2');
	});
});

async function debugWebExtension(dc: DebugClient, addonDirectory = 'webExtension') {

	let backgroundScriptPath = path.join(TESTDATA_PATH, addonDirectory, 'addOn/backgroundscript.js');
	await util.setBreakpoints(dc, backgroundScriptPath, [ 2 ]);

	let contentScriptPath = path.join(TESTDATA_PATH, addonDirectory, 'addOn/contentscript.js');
	await util.setBreakpoints(dc, contentScriptPath,  [ 6 ]);
	await delay(500);

	await util.setConsoleThread(dc, await util.findTabThread(dc));
	util.evaluate(dc, 'putMessage("bar")');

	let stoppedEvent = await util.receiveStoppedEvent(dc);
	let contentThreadId = stoppedEvent.body.threadId!;
	let stackTrace = await dc.stackTraceRequest({ threadId: contentThreadId });

	assert.equal(stackTrace.body.stackFrames[0].source!.path, contentScriptPath);

	dc.continueRequest({ threadId: contentThreadId });
	stoppedEvent = await util.receiveStoppedEvent(dc);
	let addOnThreadId = stoppedEvent.body.threadId!;
	stackTrace = await dc.stackTraceRequest({ threadId: addOnThreadId });

	assert.notEqual(contentThreadId, addOnThreadId);
}
