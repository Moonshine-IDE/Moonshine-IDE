import { DebugClient } from 'vscode-debugadapter-testsupport';
import { StoppedEvent } from 'vscode-debugadapter';
import * as path from 'path';
import * as util from './util';
import * as assert from 'assert';
import { delay, isWindowsPlatform } from '../common/util';

describe('Skipping files: The debugger', function() {

	let dc: DebugClient;
	const TESTDATA_PATH = path.join(__dirname, '../../testdata');

	afterEach(async function() {
		await dc.stop();
	});

	it('should skip exceptions in blackboxed files', async function() {

		dc = await util.initDebugClient(TESTDATA_PATH, true, {
			skipFiles: [ '**/skip.js' ]
		});

		await dc.setExceptionBreakpointsRequest({filters: [ 'all' ]});
		await delay(100);

		let stoppedEvent = await util.runCommandAndReceiveStoppedEvent(dc,
			() => util.evaluateCloaked(dc, 'try{ testSkipFiles() }catch(e){}'));
		let stacktrace = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId });

		assert.equal(stacktrace.body.stackFrames[0].source!.path, path.join(TESTDATA_PATH, 'web/main.js'));
		assert.equal(stacktrace.body.stackFrames[0].line, 76);
	});

	it('should skip exceptions in blackboxed files thrown immediately after loading', async function() {

		dc = await util.initDebugClient(TESTDATA_PATH, true, {
			skipFiles: [ '**/exception.js' ]
		});

		await dc.setExceptionBreakpointsRequest({filters: [ 'all' ]});
		let mainFilePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, mainFilePath, [ 3 ]);
		await delay(100);

		let stoppedEvent = await util.runCommandAndReceiveStoppedEvent(dc,
			() => util.evaluateCloaked(dc, 'loadScript("exception.js")'));
		let stacktrace = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId });

		assert.equal(stacktrace.body.stackFrames[0].source!.path, path.join(TESTDATA_PATH, 'web/main.js'));
		assert.equal(stacktrace.body.stackFrames[0].line, 3);
	});

	it(`should skip exceptions in blackboxed source-mapped files thrown immediately after loading`, async function() {

		dc = await util.initDebugClient(TESTDATA_PATH, true, {
			skipFiles: [ '**/exception-sourcemap.ts' ]
		});

		await dc.setExceptionBreakpointsRequest({filters: [ 'all' ]});
		let mainFilePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, mainFilePath, [ 3 ]);
		await delay(100);

		let stoppedEvent = await util.runCommandAndReceiveStoppedEvent(dc,
			() => util.evaluateCloaked(dc, 'loadScript("exception-sourcemap.js")'));
		let stacktrace = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId });

		assert.equal(stacktrace.body.stackFrames[0].source!.path, path.join(TESTDATA_PATH, 'web/main.js'));
		assert.equal(stacktrace.body.stackFrames[0].line, 3);
	});

	it('should skip breakpoints in blackboxed files', async function() {

		dc = await util.initDebugClient(TESTDATA_PATH, true, {
			skipFiles: [ '**/skip.js' ]
		});

		await dc.setExceptionBreakpointsRequest({filters: []});
		let skipFilePath = path.join(TESTDATA_PATH, 'web/skip.js');
		await util.setBreakpoints(dc, skipFilePath, [ 2 ]);
		let mainFilePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, mainFilePath, [ 76 ]);

		let stoppedEvent = await util.runCommandAndReceiveStoppedEvent(dc,
			() => util.evaluateCloaked(dc, 'try{ testSkipFiles() }catch(e){}'));
		let stacktrace = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId });

		assert.equal(stacktrace.body.stackFrames[0].source!.path, mainFilePath);
		assert.equal(stacktrace.body.stackFrames[0].line, 76);
	});

	it('should toggle skipping files that were not skipped by the configuration', async function() {

		dc = await util.initDebugClient(TESTDATA_PATH, true);

		await dc.setExceptionBreakpointsRequest({filters: []});
		let skipFilePath = path.join(TESTDATA_PATH, 'web/skip.js');
		await util.setBreakpoints(dc, skipFilePath, [ 2 ]);
		let mainFilePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, mainFilePath, [ 76 ]);

		let skipFileUrl = isWindowsPlatform() ? 
			'file:///' + skipFilePath.replace(/\\/g, '/') :
			'file://' + skipFilePath;
		await dc.customRequest('toggleSkippingFile', skipFileUrl);

		let stoppedEvent = await util.runCommandAndReceiveStoppedEvent(dc,
			() => util.evaluateCloaked(dc, 'try{ testSkipFiles() }catch(e){}'));
		let threadId = stoppedEvent.body.threadId;
		let stacktrace = await dc.stackTraceRequest({ threadId });

		assert.equal(stacktrace.body.stackFrames[0].source!.path, mainFilePath);
		assert.equal(stacktrace.body.stackFrames[0].line, 76);

		await dc.customRequest('toggleSkippingFile', skipFileUrl);
		await dc.continueRequest({ threadId });

		stoppedEvent = await util.runCommandAndReceiveStoppedEvent(dc,
			() => util.evaluateCloaked(dc, 'try{ testSkipFiles() }catch(e){}'));
		stacktrace = await dc.stackTraceRequest({ threadId });

		assert.equal(stacktrace.body.stackFrames[0].source!.path, skipFilePath);
		assert.equal(stacktrace.body.stackFrames[0].line, 2);
	});

	it('should toggle skipping files that were skipped by the configuration', async function() {

		dc = await util.initDebugClient(TESTDATA_PATH, true, {
			skipFiles: [ '**/skip.js' ]
		});

		await dc.setExceptionBreakpointsRequest({filters: []});
		let skipFilePath = path.join(TESTDATA_PATH, 'web/skip.js');
		await util.setBreakpoints(dc, skipFilePath, [ 2 ]);
		let mainFilePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, mainFilePath, [ 76 ]);

		let skipFileUrl = isWindowsPlatform() ? 
			'file:///' + skipFilePath.replace(/\\/g, '/') :
			'file://' + skipFilePath;
		await dc.customRequest('toggleSkippingFile', skipFileUrl);
		
		let stoppedEvent = await util.runCommandAndReceiveStoppedEvent(dc,
			() => util.evaluateCloaked(dc, 'try{ testSkipFiles() }catch(e){}'));
		let threadId = stoppedEvent.body.threadId;
		let stacktrace = await dc.stackTraceRequest({ threadId });

		assert.equal(stacktrace.body.stackFrames[0].source!.path, skipFilePath);
		assert.equal(stacktrace.body.stackFrames[0].line, 2);

		await dc.customRequest('toggleSkippingFile', skipFileUrl);
		await dc.continueRequest({ threadId });

		stoppedEvent = await util.runCommandAndReceiveStoppedEvent(dc,
			() => util.evaluateCloaked(dc, 'try{ testSkipFiles() }catch(e){}'));
		stacktrace = await dc.stackTraceRequest({ threadId });

		assert.equal(stacktrace.body.stackFrames[0].source!.path, mainFilePath);
		assert.equal(stacktrace.body.stackFrames[0].line, 76);
	});

	it('should send a StoppedEvent with the same reason to VSCode after a skipFile toggle', async function() {

		dc = await util.initDebugClient(TESTDATA_PATH, true);

		let skipFilePath = path.join(TESTDATA_PATH, 'web/skip.js');
		let mainFilePath = path.join(TESTDATA_PATH, 'web/main.js');
		await util.setBreakpoints(dc, mainFilePath, [ 75 ]);

		let stoppedEvent = await util.runCommandAndReceiveStoppedEvent(dc,
			() => util.evaluateCloaked(dc, 'try{ testSkipFiles() }catch(e){}'));

		assert.equal((<StoppedEvent>stoppedEvent).body.reason, 'breakpoint');

		let skipFileUrl = isWindowsPlatform() ? 
			'file:///' + skipFilePath.replace(/\\/g, '/') :
			'file://' + skipFilePath;
		stoppedEvent = await util.runCommandAndReceiveStoppedEvent(dc,
			() => dc.customRequest('toggleSkippingFile', skipFileUrl));

		assert.equal((<StoppedEvent>stoppedEvent).body.reason, 'breakpoint');
	})
});
