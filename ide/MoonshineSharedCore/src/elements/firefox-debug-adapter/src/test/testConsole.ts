import { DebugClient } from 'vscode-debugadapter-testsupport';
import { DebugProtocol } from 'vscode-debugprotocol';
import * as path from 'path';
import * as util from './util';
import * as assert from 'assert';
import { isWindowsPlatform } from '../common/util';

describe('Debug console: The debugger', function() {

	let dc: DebugClient;
	const TESTDATA_PATH = path.join(__dirname, '../../testdata');

	afterEach(async function() {
		await dc.stop();
	});

	it('should forward messages from the browser console to vscode', async function() {

		dc = await util.initDebugClient(TESTDATA_PATH, true);

		util.evaluate(dc, 'console.log("log")');
		let outputEvent = <DebugProtocol.OutputEvent> await dc.waitForEvent('output');

		assert.equal(outputEvent.body.category, 'stdout');
		assert.equal(outputEvent.body.output.trim(), 'log');

		util.evaluate(dc, 'console.debug("debug")');
		outputEvent = <DebugProtocol.OutputEvent> await dc.waitForEvent('output');

		assert.equal(outputEvent.body.category, 'stdout');
		assert.equal(outputEvent.body.output.trim(), 'debug');

		util.evaluate(dc, 'console.info("info")');
		outputEvent = <DebugProtocol.OutputEvent> await dc.waitForEvent('output');

		assert.equal(outputEvent.body.category, 'stdout');
		assert.equal(outputEvent.body.output.trim(), 'info');

		util.evaluate(dc, 'console.warn("warn")');
		outputEvent = <DebugProtocol.OutputEvent> await dc.waitForEvent('output');

		assert.equal(outputEvent.body.category, 'console');
		assert.equal(outputEvent.body.output.trim(), 'warn');

		util.evaluate(dc, 'console.error("error")');
		outputEvent = <DebugProtocol.OutputEvent> await dc.waitForEvent('output');

		assert.equal(outputEvent.body.category, 'stderr');
		assert.equal(outputEvent.body.output.trim(), 'error');

		util.evaluate(dc, 'console.log("foo",2)');
		outputEvent = <DebugProtocol.OutputEvent> await dc.waitForEvent('output');

		assert.equal(outputEvent.body.category, 'stdout');
		assert.notEqual(outputEvent.body.variablesReference, undefined);

		let vars = await dc.variablesRequest({ variablesReference: outputEvent.body.variablesReference! });

		assert.equal(vars.body.variables.length, 2);
		assert.equal(util.findVariable(vars.body.variables, '0').value, 'foo');
		assert.equal(util.findVariable(vars.body.variables, '1').value, '2');

		util.evaluate(dc, 'console.log({"foo":"bar"})');
		outputEvent = <DebugProtocol.OutputEvent> await dc.waitForEvent('output');

		assert.equal(outputEvent.body.category, 'stdout');
		assert.notEqual(outputEvent.body.variablesReference, undefined);

		vars = await dc.variablesRequest({ variablesReference: outputEvent.body.variablesReference! });

		assert.equal(vars.body.variables.length, 1);

		vars = await dc.variablesRequest({ variablesReference: vars.body.variables[0].variablesReference });

		assert.equal(vars.body.variables.length, 2);
		assert.equal(util.findVariable(vars.body.variables, 'foo').value, '"bar"');
	});

	it('should send error messages from the browser to vscode', async function() {

		dc = await util.initDebugClient(TESTDATA_PATH, true);

		dc.setExceptionBreakpointsRequest({ filters: [] });

		util.evaluateDelayed(dc, 'foo.bar', 0);
		let outputEvent = <DebugProtocol.OutputEvent> await dc.waitForEvent('output');

		assert.equal(outputEvent.body.category, 'stderr');
		assert.equal(outputEvent.body.output.trim(), 'ReferenceError: foo is not defined');

		util.evaluateDelayed(dc, 'eval("foo(")', 0);
		outputEvent = <DebugProtocol.OutputEvent> await dc.waitForEvent('output');

		assert.equal(outputEvent.body.category, 'stderr');
		assert.equal(outputEvent.body.output.trim(), 'SyntaxError: expected expression, got end of script');

		util.evaluateDelayed(dc, 'throw new Error("Something went wrong")', 0);
		outputEvent = <DebugProtocol.OutputEvent> await dc.waitForEvent('output');

		assert.equal(outputEvent.body.category, 'stderr');
		assert.equal(outputEvent.body.output.trim(), 'Error: Something went wrong');
	});

	it('should append the console call location to console messages', async function() {

		dc = await util.initDebugClient(TESTDATA_PATH, true, {
			showConsoleCallLocation: true
		});

		let expectedMessageEnding = 'testdata/web/main.js:80:10)';
		if (isWindowsPlatform()) {
			expectedMessageEnding = expectedMessageEnding.replace(/\//g, '\\');
		}

		util.evaluate(dc, 'log("foo")');
		let outputEvent = <DebugProtocol.OutputEvent> await dc.waitForEvent('output');

		assert.equal(outputEvent.body.output.substr(0, 5), 'foo (');
		assert.ok(outputEvent.body.output.endsWith(expectedMessageEnding + '\n'));

		util.evaluate(dc, 'log("foo","bar")');
		outputEvent = <DebugProtocol.OutputEvent> await dc.waitForEvent('output');

		assert.notEqual(outputEvent.body.variablesReference, undefined);

		let vars = await dc.variablesRequest({ variablesReference: outputEvent.body.variablesReference! });

		assert.equal(vars.body.variables.length, 3);
		assert.ok(util.findVariable(vars.body.variables, 'location').value.endsWith(expectedMessageEnding));

		util.evaluate(dc, 'log({"foo":"bar"})');
		outputEvent = <DebugProtocol.OutputEvent> await dc.waitForEvent('output');

		assert.notEqual(outputEvent.body.variablesReference, undefined);

		vars = await dc.variablesRequest({ variablesReference: outputEvent.body.variablesReference! });

		assert.equal(vars.body.variables.length, 2);
		assert.ok(util.findVariable(vars.body.variables, 'location').value.endsWith(expectedMessageEnding));
	});

	it('should offer code completions in the debugging console', async function() {

		dc = await util.initDebugClient(TESTDATA_PATH, true);

		let completionsResult = await dc.completionsRequest({ text: 'v', column: 2 });
		let completions = completionsResult.body.targets.map(item => item.label);

		assert.ok(completions.length >= 3);
		assert.ok(completions.indexOf('valueOf') >= 0);
		assert.ok(completions.indexOf('values') >= 0);
		assert.ok(completions.indexOf('vars') >= 0);

		let sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, sourcePath, [ 12 ]);
		let stoppedEvent = await util.runCommandAndReceiveStoppedEvent(dc, () => util.evaluate(dc, 'vars()'));
		let stackTrace = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId });
		let frameId = stackTrace.body.stackFrames[0].id;
		completionsResult = await dc.completionsRequest({ frameId, text: 'n', column: 2 });
		completions = completionsResult.body.targets.map(item => item.label);

		assert.ok(completions.length >= 6);
		assert.ok(completions.indexOf('name') >= 0);
		assert.ok(completions.indexOf('navigator') >= 0);
		assert.ok(completions.indexOf('netscape') >= 0);
		assert.ok(completions.indexOf('noop') >= 0);
		assert.ok(completions.indexOf('num1') >= 0);
		assert.ok(completions.indexOf('num2') >= 0);
	});
});
