import * as path from 'path';
import * as fs from 'fs-extra';
import { Stream } from 'stream';
import * as assert from 'assert';
import { DebugClient } from 'vscode-debugadapter-testsupport';
import * as util from './util';

export async function testSourcemaps(
	dc: DebugClient,
	srcDir: string,
	stepInRepeat = 1
): Promise<void> {

	let fPath = path.join(srcDir, 'f.js');
	let gPath = path.join(srcDir, 'g.js');

	await util.setBreakpoints(dc, fPath, [ 7 ]);

	let stoppedEvent = await util.runCommandAndReceiveStoppedEvent(dc, () =>
		util.evaluateDelayed(dc, 'f()', 0));
	let threadId = stoppedEvent.body.threadId!;

	await checkDebuggeeState(dc, threadId, fPath, 7, 'x', '2');

	for (let i = 0; i < stepInRepeat; i++) {
		await util.runCommandAndReceiveStoppedEvent(dc, () => dc.stepInRequest({ threadId }));
	}

	await checkDebuggeeState(dc, threadId, gPath, 5, 'y', '2');

	await util.runCommandAndReceiveStoppedEvent(dc, () => dc.stepOutRequest({ threadId }));

	await checkDebuggeeState(dc, threadId, fPath, 8, 'x', '4');

	await util.setBreakpoints(dc, gPath, [ 5 ]);

	await util.runCommandAndReceiveStoppedEvent(dc, () => dc.continueRequest({ threadId }));

	await checkDebuggeeState(dc, threadId, gPath, 5, 'y', '4');
}

async function checkDebuggeeState(
	dc: DebugClient,
	threadId: number,
	sourcePath: string,
	line: number,
	variable: string,
	value: string
): Promise<void> {

	let stackTrace = await dc.stackTraceRequest({ threadId });
	assert.equal(stackTrace.body.stackFrames[0].source!.path, sourcePath);
	assert.equal(stackTrace.body.stackFrames[0].line, line);

	let scopes = await dc.scopesRequest({ 
		frameId: stackTrace.body.stackFrames[0].id
	});
	let variables = await dc.variablesRequest({ 
		variablesReference: scopes.body.scopes[0].variablesReference
	});
	assert.equal(util.findVariable(variables.body.variables, variable).value, value);
}

export async function copyFiles(sourceDir: string, targetDir: string, files: string[]): Promise<void> {
	await Promise.all(files.map(
		(file) => fs.copy(path.join(sourceDir, file), path.join(targetDir, file))));
}

export async function injectScriptTags(targetDir: string, scripts: string[]): Promise<void> {
	let file = path.join(targetDir, 'index.html');
	let content = await fs.readFile(file, 'utf8');
	let scriptTags = scripts.map((script) => `<script src="${script}"></script>`);
	content = content.replace('__SCRIPTS__', scriptTags.join(''));
	await fs.writeFile(file, content);
}

export function waitForStreamEnd(s: Stream): Promise<void> {
	return new Promise<void>((resolve) => {
		s.on('end', () => resolve());
	})
}
