import { DebugProtocol } from 'vscode-debugprotocol';
import { DebugClient } from 'vscode-debugadapter-testsupport';
import * as path from 'path';
import * as assert from 'assert';
import * as util from './util';

describe('Data breakpoints: The debug adapter', function() {

	let dc: DebugClient;
	const TESTDATA_PATH = path.join(__dirname, '../../testdata');

	afterEach(async function() {
		await dc.stop();
	});

	it('should add a data breakpoint and hit it', async function() {

		if (process.env['WATCHPOINTS'] !== 'true') {
			this.skip();
			if (process.env['WATCHPOINTS'] !== 'true') {
				this.skip();
			}
	
			return;
		}

		dc = await util.initDebugClient(TESTDATA_PATH, false);
		const sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		await setupDataBreakpoint(sourcePath);

		// check that we hit the data breakpoint
		const stoppedEvent = await util.receiveStoppedEvent(dc);
		const stackTraceResponse = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId! });
		assert.strictEqual(stackTraceResponse.body.stackFrames[0].source!.path, sourcePath);
		assert.strictEqual(stackTraceResponse.body.stackFrames[0].line, 121);
	});

	it('should remove and re-add a data breakpoint and hit it', async function() {

		if (process.env['WATCHPOINTS'] !== 'true') {
			this.skip();
			return;
		}

		dc = await util.initDebugClient(TESTDATA_PATH, false);
		const sourcePath = path.join(TESTDATA_PATH, 'web/main.js');
		const dataId = await setupDataBreakpoint(sourcePath);
		let stoppedEvent = await util.receiveStoppedEvent(dc);
		await dc.continueRequest({ threadId: stoppedEvent.body.threadId });

		// set a regular breakpoint after the data breakpoint and remove the data breakpoint
		await util.setBreakpoints(dc, sourcePath, [ 122 ], true);
		await dc.customRequest(
			'setDataBreakpoints',
			{ breakpoints: [] } as DebugProtocol.SetDataBreakpointsArguments
		);

		// check that we don't hit the data breakpoint anymore
		util.evaluate(dc, 'inc(obj)');
		stoppedEvent = await util.receiveStoppedEvent(dc);
		let stackTraceResponse = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId! });
		assert.strictEqual(stackTraceResponse.body.stackFrames[0].source!.path, sourcePath);
		assert.strictEqual(stackTraceResponse.body.stackFrames[0].line, 122);

		await dc.continueRequest({ threadId: stoppedEvent.body.threadId });

		// re-add the data breakpoint
		await dc.customRequest(
			'setDataBreakpoints',
			{ breakpoints: [ { dataId } ] } as DebugProtocol.SetDataBreakpointsArguments
		);

		// check that we hit the data breakpoint again
		util.evaluate(dc, 'inc(obj)');
		stoppedEvent = await util.receiveStoppedEvent(dc);
		stackTraceResponse = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId! });
		assert.strictEqual(stackTraceResponse.body.stackFrames[0].source!.path, sourcePath);
		assert.strictEqual(stackTraceResponse.body.stackFrames[0].line, 121);
	});

	async function setupDataBreakpoint(sourcePath: string): Promise<string> {

		await util.receivePageLoadedEvent(dc);

		// set a regular breakpoint and hit it
		await util.setBreakpoints(dc, sourcePath, [ 120 ], true);
		util.evaluate(dc, 'inc(obj)');
		const stoppedEvent = await util.receiveStoppedEvent(dc);

		// find the object in the top scope
		const stackTraceResponse = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId! });
		const frameId = stackTraceResponse.body.stackFrames[0].id;
		const scopes = await dc.scopesRequest({ frameId });
		const scopeVariablesReference = scopes.body.scopes[0].variablesReference;
		const variablesResponse = await dc.variablesRequest({ variablesReference: scopeVariablesReference });
		const variable = util.findVariable(variablesResponse.body.variables, 'o');

		// set a data breakpoint on the object's `x` property
		const dbpInfoResponse = (
			await dc.customRequest(
				'dataBreakpointInfo',
				{ variablesReference: variable.variablesReference, name: 'x' } as DebugProtocol.DataBreakpointInfoArguments
			)
		) as DebugProtocol.DataBreakpointInfoResponse;
		assert.strictEqual(dbpInfoResponse.body.description, 'x');
		assert.deepStrictEqual(dbpInfoResponse.body.accessTypes, [ 'read', 'write' ]);
		const dataId = dbpInfoResponse.body.dataId!;
		assert.strictEqual(!!dataId, true);

		await dc.customRequest(
			'setDataBreakpoints',
			{ breakpoints: [ { dataId, accessType: 'write' } ] } as DebugProtocol.SetDataBreakpointsArguments
		);

		dc.continueRequest({ threadId: stoppedEvent.body.threadId });

		return dataId;
	}
});
