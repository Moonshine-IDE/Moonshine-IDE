import { DebugClient } from 'vscode-debugadapter-testsupport';
import * as path from 'path';
import * as util from './util';
import * as assert from 'assert';

describe('Webworkers: The debugger', function() {

	let dc: DebugClient;
	const TESTDATA_PATH = path.join(__dirname, '../../testdata');

	beforeEach(async function() {
		dc = await util.initDebugClient(TESTDATA_PATH, true);
	});

	afterEach(async function() {
		await dc.stop();
	});

	it('should debug a WebWorker', async function() {

		let mainSourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, mainSourcePath, [ 55 ]);

		let workerSourcePath = path.join(TESTDATA_PATH, 'web/worker.js');
		let workerBreakpointsResponse = await util.setBreakpoints(dc, workerSourcePath,  [ 2 ], false);
		let workerBreakpoint = workerBreakpointsResponse.body.breakpoints[0];

		assert.equal(workerBreakpoint.verified, false);

		util.evaluateDelayed(dc, 'startWorker()', 0);
		let breakpointEvent = await util.receiveBreakpointEvent(dc);

		assert.equal(breakpointEvent.body.breakpoint.id, workerBreakpoint.id);
		assert.equal(breakpointEvent.body.breakpoint.verified, true);
		assert.equal(breakpointEvent.body.breakpoint.line, 2);

		util.evaluateDelayed(dc, 'callWorker()', 0);
		let stoppedEvent = await util.receiveStoppedEvent(dc);
		let workerThreadId = stoppedEvent.body.threadId!;
		let stackTrace = await dc.stackTraceRequest({ threadId: workerThreadId });

		assert.equal(stackTrace.body.stackFrames[0].source!.path, workerSourcePath);

		dc.continueRequest({ threadId: workerThreadId });
		stoppedEvent = await util.receiveStoppedEvent(dc);
		let mainThreadId = stoppedEvent.body.threadId!;
		stackTrace = await dc.stackTraceRequest({ threadId: mainThreadId });
		let scopes = await dc.scopesRequest({ frameId: stackTrace.body.stackFrames[0].id });
		let variables = await dc.variablesRequest({ variablesReference: scopes.body.scopes[0].variablesReference });

		assert.notEqual(mainThreadId, workerThreadId);
		assert.equal(stackTrace.body.stackFrames[0].source!.path, mainSourcePath);
		assert.equal(util.findVariable(variables.body.variables, 'received').value, '"bar"');
	});

});
