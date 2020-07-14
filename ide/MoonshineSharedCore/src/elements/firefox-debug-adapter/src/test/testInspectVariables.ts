import { DebugClient } from 'vscode-debugadapter-testsupport';
import * as path from 'path';
import * as util from './util';
import * as assert from 'assert';

describe('Inspecting variables: The debugger', function() {

	let dc: DebugClient;
	const TESTDATA_PATH = path.join(__dirname, '../../testdata');

	beforeEach(async function() {
		dc = await util.initDebugClient(TESTDATA_PATH, true);
	});

	afterEach(async function() {
		await dc.stop();
	});

	it('should inspect variables of different types in different scopes', async function() {

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 19 ]);

		util.evaluate(dc, 'vars({ key: "value" })');
		let stoppedEvent = await util.receiveStoppedEvent(dc);
		let stackTrace = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId! });
		let scopes = await dc.scopesRequest({ frameId: stackTrace.body.stackFrames[0].id });

		let variablesResponse = await dc.variablesRequest({ variablesReference: scopes.body.scopes[0].variablesReference });
		let variables = variablesResponse.body.variables;
		assert.equal(util.findVariable(variables, 'str2').value, '"foo"');
		assert.equal(util.findVariable(variables, 'undef').value, 'undefined');
		assert.equal(util.findVariable(variables, 'nul').value, 'null');
		assert.equal(util.findVariable(variables, 'sym1').value, 'Symbol(Local Symbol)');
		assert.equal(util.findVariable(variables, 'sym2').value, 'Symbol(Global Symbol)');
		assert.equal(util.findVariable(variables, 'sym3').value, 'Symbol(Symbol.iterator)');
		
		variablesResponse = await dc.variablesRequest({
			variablesReference: util.findVariable(variables, 'this').variablesReference
		});
		variables = variablesResponse.body.variables;
		assert.equal(util.findVariable(variables, 'scrollX').value, '0');

		variablesResponse = await dc.variablesRequest({ variablesReference: scopes.body.scopes[1].variablesReference });
		variables = variablesResponse.body.variables;
		assert.equal(util.findVariable(variables, 'bool1').value, 'false');
		assert.equal(util.findVariable(variables, 'bool2').value, 'true');
		assert.equal(util.findVariable(variables, 'num1').value, '0');
		assert.equal(util.findVariable(variables, 'num2').value, '120');
		assert.equal(util.findVariable(variables, 'str1').value, '""');

		variablesResponse = await dc.variablesRequest({ variablesReference: scopes.body.scopes[2].variablesReference });
		let variable = util.findVariable(variablesResponse.body.variables, 'arg')!;
		assert.equal(variable.value, '{key: "value"}');
		variablesResponse = await dc.variablesRequest({ variablesReference: variable.variablesReference });
		assert.equal(util.findVariable(variablesResponse.body.variables, 'key').value, '"value"');
		assert.equal(util.findVariable(variablesResponse.body.variables, 'Symbol(Local Symbol)').value, '"Symbol-keyed property 1"');
		assert.equal(util.findVariable(variablesResponse.body.variables, 'Symbol(Symbol.iterator)').value, '"Symbol-keyed property 2"');
	});

	it('should inspect variables in different stackframes', async function() {

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 25 ]);

		util.evaluateDelayed(dc, 'factorial(4)', 0);
		let stoppedEvent = await util.receiveStoppedEvent(dc);
		let stackTrace = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId! });

		for (let i = 0; i < 4; i++) {
			let scopes = await dc.scopesRequest({ frameId: stackTrace.body.stackFrames[i].id });
			let variables = await dc.variablesRequest({ variablesReference: scopes.body.scopes[0].variablesReference });
			assert.equal(util.findVariable(variables.body.variables, 'n').value, i + 1);
		}
	});

	it('should inspect return values on stepping out', async function() {

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 71 ]);

		util.evaluate(dc, 'doEval(17)');
		let stoppedEvent = await util.receiveStoppedEvent(dc);
		let threadId = stoppedEvent.body.threadId!;

		await dc.stepOutRequest({ threadId });
		await util.receiveStoppedEvent(dc);
		let stackTrace = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId! });
		let scopes = await dc.scopesRequest({ frameId: stackTrace.body.stackFrames[0].id });
		let variables = await dc.variablesRequest({ variablesReference: scopes.body.scopes[0].variablesReference });
		assert.equal(util.findVariable(variables.body.variables, 'Return value').value, 17);
	});

	it.skip('should inspect return values on stepping out of recursive functions', async function() {

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 25 ]);

		util.evaluate(dc, 'factorial(4)');
		let stoppedEvent = await util.receiveStoppedEvent(dc);
		let threadId = stoppedEvent.body.threadId!;

		for (let i = 0; i < 4; i++) {
			await dc.stepOutRequest({ threadId });
			await util.receiveStoppedEvent(dc);
			let stackTrace = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId! });
			let scopes = await dc.scopesRequest({ frameId: stackTrace.body.stackFrames[0].id });
			let variables = await dc.variablesRequest({ variablesReference: scopes.body.scopes[0].variablesReference });
			assert.equal(util.findVariable(variables.body.variables, 'Return value').value, factorial(i + 1));
		}
	});

	it('should set variables', async function() {

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 11 ]);

		util.evaluate(dc, 'vars()');
		let stoppedEvent = await util.receiveStoppedEvent(dc);
		let stackTrace = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId! });
		let frameId = stackTrace.body.stackFrames[0].id;
		let scopes = await dc.scopesRequest({ frameId });
		let variablesReference = scopes.body.scopes[0].variablesReference;
		let variables = await dc.variablesRequest({ variablesReference });

		assert.equal(util.findVariable(variables.body.variables, 'num1').value, '0');

		let result = await dc.evaluateRequest({ context: 'repl', frameId, expression: 'num1' });
		assert.equal(result.body.result, '0');

		await dc.setVariableRequest({ variablesReference, name: 'num1', value: '7' });

		result = await dc.evaluateRequest({ context: 'repl', frameId, expression: 'num1' });
		assert.equal(result.body.result, '7');
	});

	it('should inspect variables from the stack after running evaluations', async function() {

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 8 ]);

		util.evaluate(dc, 'vars({foo:{bar:"baz"}})');
		let stoppedEvent = await util.receiveStoppedEvent(dc);
		let stackTrace = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId! });
		let frameId = stackTrace.body.stackFrames[0].id;
		let scopes = await dc.scopesRequest({ frameId });

		await dc.evaluateRequest({ expression: 'obj.x', context: 'watch', frameId });
		await dc.evaluateRequest({ expression: 'obj.y', context: 'repl', frameId });

		let variables = await dc.variablesRequest({ variablesReference: scopes.body.scopes[1].variablesReference });
		let arg = util.findVariable(variables.body.variables, 'arg');
		variables = await dc.variablesRequest({ variablesReference: arg.variablesReference });
		let foo = util.findVariable(variables.body.variables, 'foo');
		variables = await dc.variablesRequest({ variablesReference: foo.variablesReference });
		let bar = util.findVariable(variables.body.variables, 'bar');
		assert.equal(bar.value, '"baz"');
	});

	it('should return the same variables if the variablesRequest is issued twice', async function() {

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 112 ]);

		util.evaluate(dc, 'protoGetter().y');
		const stoppedEvent = await util.receiveStoppedEvent(dc);
		const stackTrace = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId! });
		const frameId = stackTrace.body.stackFrames[0].id;
		const scopes = await dc.scopesRequest({ frameId });
		const variablesReference = scopes.body.scopes[0].variablesReference;

		const variables1 = await dc.variablesRequest({ variablesReference });
		const variables2 = await dc.variablesRequest({ variablesReference });
		assert.deepStrictEqual(variables1.body.variables, variables2.body.variables);
	});
});

function factorial(n: number): number {
	if (n <= 1) {
		return 1;
	} else {
		return n * factorial(n - 1);
	}
}
