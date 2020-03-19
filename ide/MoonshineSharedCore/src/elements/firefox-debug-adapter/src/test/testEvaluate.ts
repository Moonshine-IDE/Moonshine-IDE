import { DebugClient } from 'vscode-debugadapter-testsupport';
import * as path from 'path';
import * as util from './util';
import * as assert from 'assert';

describe('Evaluate: The debugger', function() {

	let dc: DebugClient;
	const TESTDATA_PATH = path.join(__dirname, '../../testdata');

	beforeEach(async function() {
		dc = await util.initDebugClient(TESTDATA_PATH, true);
	});

	afterEach(async function() {
		await dc.stop();
	});

	it('should evaluate watches while running', async function() {

		let evalResult = await dc.evaluateRequest({ expression: 'obj.x + 7', context: 'watch' });
		assert.equal(evalResult.body.result, '24');
	});

	it('should evaluate watches on different stackframes', async function() {

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 25 ]);

		util.evaluate(dc, 'factorial(3)');
		let stoppedEvent = await util.receiveStoppedEvent(dc);
		let stackTrace = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId! });

		let evalResult = await dc.evaluateRequest({ expression: 'n*2', context: 'watch',
			frameId: stackTrace.body.stackFrames[0].id });
		assert.equal(evalResult.body.result, '2');

		evalResult = await dc.evaluateRequest({ expression: 'n*2', context: 'watch',
			frameId: stackTrace.body.stackFrames[1].id });
		assert.equal(evalResult.body.result, '4');
	});

	it('should skip over breakpoints when evaluating watches while running', async function() {

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 8, 25 ]);

		dc.evaluateRequest({ expression: 'factorial(3)', context: 'watch' });
		await util.assertPromiseTimeout(util.receiveStoppedEvent(dc), 200);
	});

	it('should skip over breakpoints when evaluating watches while paused', async function() {

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 8, 25 ]);

		util.evaluate(dc, 'vars()');
		let stoppedEvent = await util.receiveStoppedEvent(dc);
		let stackTrace = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId! });

		dc.evaluateRequest({ expression: 'factorial(3)', context: 'watch',
			frameId: stackTrace.body.stackFrames[0].id });
		await util.assertPromiseTimeout(util.receiveStoppedEvent(dc), 200);
	});

	it('should inspect watches evaluated while running', async function() {

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 25 ]);

		let evalResult = await dc.evaluateRequest({ expression: 'obj', context: 'watch' });
		let inspectResult = await dc.variablesRequest({ 
			variablesReference: evalResult.body.variablesReference
		});
		assert.equal(util.findVariable(inspectResult.body.variables, 'x').value, '17');
	});

	it('should inspect watches evaluated while paused', async function() {

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 25 ]);

		util.evaluate(dc, 'factorial(3)');
		let stoppedEvent = await util.receiveStoppedEvent(dc);
		let stackTrace = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId! });

		let evalResult = await dc.evaluateRequest({ expression: 'obj', context: 'watch',
			frameId: stackTrace.body.stackFrames[0].id });
		let inspectResult = await dc.variablesRequest({ 
			variablesReference: evalResult.body.variablesReference
		});
		assert.equal(util.findVariable(inspectResult.body.variables, 'x').value, '17');
	});

	it('should inspect watches (evaluated while running) after running other evaluations', async function() {

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 25 ]);

		let evalResult = await dc.evaluateRequest({ expression: 'obj', context: 'watch' });

		await dc.evaluateRequest({ expression: 'obj.x', context: 'watch' });
		await dc.evaluateRequest({ expression: 'obj.y', context: 'repl' });

		let inspectResult = await dc.variablesRequest({ 
			variablesReference: evalResult.body.variablesReference
		});
		assert.equal(util.findVariable(inspectResult.body.variables, 'x').value, '17');
	});

	it('should inspect watches (evaluated while paused) after running other evaluations', async function() {

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 25 ]);

		util.evaluate(dc, 'factorial(3)');
		let stoppedEvent = await util.receiveStoppedEvent(dc);
		let stackTrace = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId! });

		let evalResult = await dc.evaluateRequest({ expression: 'obj', context: 'watch',
			frameId: stackTrace.body.stackFrames[0].id });

		await dc.evaluateRequest({ expression: 'n', context: 'watch',
			frameId: stackTrace.body.stackFrames[0].id });
		await dc.evaluateRequest({ expression: 'obj.y', context: 'repl',
			frameId: stackTrace.body.stackFrames[0].id });

		let inspectResult = await dc.variablesRequest({ 
			variablesReference: evalResult.body.variablesReference
		});
		assert.equal(util.findVariable(inspectResult.body.variables, 'x').value, '17');
	});

	it('should evaluate console expressions on different stackframes', async function() {

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 25 ]);

		util.evaluate(dc, 'factorial(3)');
		let stoppedEvent = await util.receiveStoppedEvent(dc);
		let stackTrace = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId! });

		let evalResult = await dc.evaluateRequest({ expression: 'n*2', context: 'repl',
			frameId: stackTrace.body.stackFrames[0].id });
		assert.equal(evalResult.body.result, '2');

		evalResult = await dc.evaluateRequest({ expression: 'n*2', context: 'repl',
			frameId: stackTrace.body.stackFrames[1].id });
		assert.equal(evalResult.body.result, '4');
	});

	it('should evaluate console expressions while the thread is running', async function() {

		let evalResult = await dc.evaluateRequest({ expression: 'obj.x', context: 'repl' });
		assert.equal(evalResult.body.result, '17');
	});

	it('should hit breakpoints when evaluating console expressions while running', async function() {

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 8, 25 ]);

		dc.evaluateRequest({ expression: 'factorial(3)', context: 'repl' });
		await util.receiveStoppedEvent(dc);
	});

	it('should inspect console evaluation results after breaking', async function() {

		let evalResult = await dc.evaluateRequest({ expression: 'obj', context: 'repl' });

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 25 ]);

		util.evaluate(dc, 'factorial(3)');
		await util.receiveStoppedEvent(dc);

		let inspectResult = await dc.variablesRequest({ 
			variablesReference: evalResult.body.variablesReference
		});
		assert.equal(util.findVariable(inspectResult.body.variables, 'x').value, '17');
	});

	it('should inspect console evaluation results after running other evaluations', async function() {

		let evalResult = await dc.evaluateRequest({ expression: 'obj', context: 'repl' });

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 25 ]);

		util.evaluate(dc, 'factorial(3)');
		let stoppedEvent = await util.receiveStoppedEvent(dc);
		let stackTrace = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId! });
		await dc.evaluateRequest({ expression: 'n*2', context: 'watch',
			frameId: stackTrace.body.stackFrames[0].id });
		await dc.evaluateRequest({ expression: 'obj.y', context: 'repl',
			frameId: stackTrace.body.stackFrames[0].id });

		let inspectResult = await dc.variablesRequest({ 
			variablesReference: evalResult.body.variablesReference
		});
		assert.equal(util.findVariable(inspectResult.body.variables, 'x').value, '17');
	});

	it('should inspect console evaluation results after stepping', async function() {

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 25 ]);

		util.evaluate(dc, 'factorial(3)');
		let stoppedEvent = await util.receiveStoppedEvent(dc);
		let stackTrace = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId! });

		let evalResult = await dc.evaluateRequest({ expression: 'obj', context: 'repl',
			frameId: stackTrace.body.stackFrames[0].id });

		dc.stepOutRequest({ threadId: stoppedEvent.body.threadId! });
		await util.receiveStoppedEvent(dc);
		dc.stepOutRequest({ threadId: stoppedEvent.body.threadId! });
		await util.receiveStoppedEvent(dc);

		let inspectResult = await dc.variablesRequest({ 
			variablesReference: evalResult.body.variablesReference
		});
		assert.equal(util.findVariable(inspectResult.body.variables, 'x').value, '17');
	});

	it('should inspect console evaluation results after resuming', async function() {

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 25 ]);

		util.evaluate(dc, 'factorial(3)');
		let stoppedEvent = await util.receiveStoppedEvent(dc);
		let stackTrace = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId! });

		let evalResult = await dc.evaluateRequest({ expression: 'obj', context: 'repl',
			frameId: stackTrace.body.stackFrames[0].id });

		await dc.continueRequest({ threadId: stoppedEvent.body.threadId! });

		let inspectResult = await dc.variablesRequest({ 
			variablesReference: evalResult.body.variablesReference
		});
		assert.equal(util.findVariable(inspectResult.body.variables, 'x').value, '17');
	});
});
