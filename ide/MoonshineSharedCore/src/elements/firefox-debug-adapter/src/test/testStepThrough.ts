import { DebugClient } from 'vscode-debugadapter-testsupport';
import * as path from 'path';
import * as util from './util';
import * as assert from 'assert';

describe('Stepping: The debugger', function() {

	let dc: DebugClient;
	const TESTDATA_PATH = path.join(__dirname, '../../testdata');

	beforeEach(async function() {
		dc = await util.initDebugClient(TESTDATA_PATH, true);
	});

	afterEach(async function() {
		await dc.stop();
	});

	it('should step over', async function() {

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 11 ]);

		util.evaluateDelayed(dc, 'vars()', 0);
		let stoppedEvent = await util.receiveStoppedEvent(dc);
		let threadId = stoppedEvent.body.threadId!;

		let stackTrace = await dc.stackTraceRequest({ threadId });
		assert.equal(stackTrace.body.stackFrames[0].source!.path, sourcePath);
		assert.equal(stackTrace.body.stackFrames[0].line, 11);

		dc.nextRequest({ threadId });
		await util.receiveStoppedEvent(dc);

		stackTrace = await dc.stackTraceRequest({ threadId });
		assert.equal(stackTrace.body.stackFrames[0].source!.path, sourcePath);
		assert.equal(stackTrace.body.stackFrames[0].line, 12);
	});

	it('should step in', async function() {

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 27 ]);

		util.evaluate(dc, 'factorial(3)');
		let stoppedEvent = await util.receiveStoppedEvent(dc);
		let threadId = stoppedEvent.body.threadId!;

		let stackTrace = await dc.stackTraceRequest({ threadId });
		assert.equal(stackTrace.body.stackFrames[0].source!.path, sourcePath);
		assert.equal(stackTrace.body.stackFrames[0].line, 27);

		dc.stepInRequest({ threadId });
		await util.receiveStoppedEvent(dc);

		stackTrace = await dc.stackTraceRequest({ threadId });
		assert.equal(stackTrace.body.stackFrames[0].source!.path, sourcePath);
		assert.equal(stackTrace.body.stackFrames[0].line, 24);
	});

	it('should step out', async function() {

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 3 ]);

		util.evaluate(dc, 'vars()');
		let stoppedEvent = await util.receiveStoppedEvent(dc);
		let threadId = stoppedEvent.body.threadId!;

		let stackTrace = await dc.stackTraceRequest({ threadId });
		assert.equal(stackTrace.body.stackFrames[0].source!.path, sourcePath);
		assert.equal(stackTrace.body.stackFrames[0].line, 3);

		dc.stepOutRequest({ threadId });
		await util.receiveStoppedEvent(dc);

		stackTrace = await dc.stackTraceRequest({ threadId });
		assert.equal(stackTrace.body.stackFrames[0].source!.path, sourcePath);
		assert.equal(stackTrace.body.stackFrames[0].line, 21);
	});

	it('should step into an eval()', async function() {

		let evalExpr = 'factorial(5)';

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 71 ]);

		dc.evaluateRequest({ expression: `doEval('${evalExpr}')`, context: 'repl' });
		let stoppedEvent = await util.receiveStoppedEvent(dc);

		dc.stepInRequest({ threadId: stoppedEvent.body.threadId! });
		await util.receiveStoppedEvent(dc);

		let stackTrace = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId! });
		let source = await dc.sourceRequest({
			sourceReference: stackTrace.body.stackFrames[0].source!.sourceReference!
		});
		assert.equal(source.body.content, evalExpr);
	});

	it('should fetch long eval() expressions', async function() {

		let evalExpr = 'factorial(1);';
		for (let i = 0; i < 12; i++) {
			evalExpr = evalExpr + evalExpr;
		}

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 71 ]);

		dc.evaluateRequest({ expression: `doEval('${evalExpr}')`, context: 'repl' });
		let stoppedEvent = await util.receiveStoppedEvent(dc);

		dc.stepInRequest({ threadId: stoppedEvent.body.threadId! });
		await util.receiveStoppedEvent(dc);

		let stackTrace = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId! });
		let source = await dc.sourceRequest({
			sourceReference: stackTrace.body.stackFrames[0].source!.sourceReference!
		});
		assert.equal(source.body.content, evalExpr);
	});
});
