import path from 'path';
import vscode from 'vscode';
import { URL } from 'url';
import { LoadedScriptsProvider } from './loadedScripts/provider';
import { findLaunchConfig, addPathMappingToLaunchConfig, showLaunchConfig } from './addPathMapping';

interface PathMapping {
	url: string;
	path: string;
}

export async function createPathMappingForActiveTextEditor(loadedScriptsProvider: LoadedScriptsProvider) {

	const editor = vscode.window.activeTextEditor;
	if (!editor) {
		vscode.window.showErrorMessage("There is no active text editor");
		return;
	}

	const debugSession = vscode.debug.activeDebugSession;
	if (!debugSession) {
		vscode.window.showErrorMessage("There is no active debug session");
		return;
	}
	if (debugSession.type !== 'firefox') {
		vscode.window.showErrorMessage("The active debug session is not of type \"firefox\"");
		return;
	}

	const workspaceFolders = vscode.workspace.workspaceFolders;
	if (!workspaceFolders) {
		vscode.window.showErrorMessage('There is no open folder');
		return;
	}

	const launchConfigReference = findLaunchConfig(workspaceFolders, debugSession);
	if (!launchConfigReference) {
		vscode.window.showErrorMessage(`Couldn't find configuration for active debug session "${debugSession.name}"`);
		return;
	}

	const ffUrls = loadedScriptsProvider.getSourceUrls(debugSession.id);
	if (!ffUrls) {
		vscode.window.showErrorMessage("Couldn't load the sources of the active debug session");
		return;
	}
	if (ffUrls.length === 0) {
		vscode.window.showWarningMessage("Firefox didn't load any sources in the active debug session yet");
		return;
	}

	const vscPath = vscodeUriToPath(editor.document.uri);
	const pathMapping = await createPathMapping(vscPath, ffUrls, debugSession.workspaceFolder);

	if (pathMapping) {

		const success = await addPathMappingToLaunchConfig(launchConfigReference, pathMapping.url, pathMapping.path);

		if (success) {
			await showLaunchConfig(launchConfigReference.workspaceFolder);
			vscode.window.showWarningMessage('Configuration was modified - please restart your debug session for the changes to take effect');
		}

	} else {
		const vscFilename = editor.document.uri.path.split('/').pop()!;
		vscode.window.showWarningMessage(`Firefox hasn't loaded any file named "${vscFilename}"`);
	}
}

export async function createPathMappingForPath(
	vscPath: string,
	debugSession: vscode.DebugSession,
	loadedScriptsProvider: LoadedScriptsProvider
) {

	const workspaceFolders = vscode.workspace.workspaceFolders;
	if (!workspaceFolders) {
		return;
	}

	const launchConfigReference = findLaunchConfig(workspaceFolders, debugSession);
	if (!launchConfigReference) {
		return;
	}

	const ffUrls = loadedScriptsProvider.getSourceUrls(debugSession.id);
	if (!ffUrls || (ffUrls.length === 0)) {
		return;
	}

	const pathMapping = await createPathMapping(vscPath, ffUrls, debugSession.workspaceFolder);

	if (!pathMapping) {
		return;
	}

	const message =
		"This file's path isn't mapped to any url that was loaded by Firefox. " +
		"Either this file hasn't been loaded by Firefox yet or " +
		"your debug configuration needs a pathMapping for this file - " +
		"do you think the file has already been loaded and want to let the " +
		"Path Mapping Wizard try to create a pathMapping for you?";
	const yesOrNo = await vscode.window.showInformationMessage(message, 'Yes', 'No');

	if (yesOrNo === 'Yes') {

		const success = await addPathMappingToLaunchConfig(launchConfigReference, pathMapping.url, pathMapping.path);

		if (success) {
			await showLaunchConfig(launchConfigReference.workspaceFolder);
			vscode.window.showWarningMessage('Configuration was modified - please restart your debug session for the changes to take effect');
		}
	}
}

async function createPathMapping(
	vscPath: string,
	ffUrls: string[],
	workspaceFolder?: vscode.WorkspaceFolder
): Promise<PathMapping | undefined> {

	const parsedFfUrls: URL[] = [];
	for (const ffUrl of ffUrls) {
		try {
			parsedFfUrls.push(new URL(ffUrl));
		} catch {}
	}

	const bestMatch = findBestMatch(vscPath, parsedFfUrls);
	if (!bestMatch) return undefined;

	const pathMapping = await createPathMappingForMatch(vscPath, bestMatch, parsedFfUrls);

	if (workspaceFolder) {
		const workspaceFolderPath = vscodeUriToPath(workspaceFolder.uri);
		if (pathMapping.path.startsWith(workspaceFolderPath)) {
			pathMapping.path = '${workspaceFolder}' + pathMapping.path.substring(workspaceFolderPath.length);
		}
	}

	pathMapping.path = pathMapping.path.replace(/\\/g, '/');

	return pathMapping;
}

function findBestMatch(vscPath: string, ffUrls: URL[]): URL | undefined {

	const vscPathSegments = vscodePathToUri(vscPath).path.split('/');
	const vscFilename = vscPathSegments.pop()!;

	let bestMatch: URL | undefined;
	let bestScore = -1;

	for (const ffUrl of ffUrls) {

		const ffPathSegments = ffUrl.pathname.split('/');
		const ffFilename = ffPathSegments.pop()!;

		if (ffFilename !== vscFilename) continue;

		let score = 0;
		while ((vscPathSegments.length > 0) && (ffPathSegments.length > 0)) {
			if (vscPathSegments.pop() === ffPathSegments.pop()) {
				score++;
			} else {
				break;
			}
		}

		if (score > bestScore) {
			bestMatch = ffUrl;
			bestScore = score;
		}
	}

	return bestMatch;
}

async function createPathMappingForMatch(
	vscPath: string,
	matchingFfUrl: URL,
	allFfUrls: URL[]
): Promise<PathMapping> {

	let pathMapping: PathMapping = {
		url: matchingFfUrl.protocol + '//' + matchingFfUrl.host + matchingFfUrl.pathname,
		path: vscPath
	};

	while (true) {

		const generalizedPathMapping = generalizePathMapping(pathMapping);

		if (!generalizedPathMapping || !await checkPathMapping(generalizedPathMapping, allFfUrls)) {
			return pathMapping;
		}

		pathMapping = generalizedPathMapping;
	}
}

function generalizePathMapping(pathMapping: PathMapping): PathMapping | undefined {

	const lastSegment = pathMapping.url.substring(pathMapping.url.lastIndexOf('/') + 1);
	const pathSep = vscodePathSep(pathMapping.path);

	if ((lastSegment === '') || !pathMapping.path.endsWith(pathSep + lastSegment)) {
		return undefined;
	}

	return {
		url: pathMapping.url.substring(0, pathMapping.url.length - lastSegment.length - 1),
		path: pathMapping.path.substring(0, pathMapping.path.length - lastSegment.length - 1)
	}
}

async function checkPathMapping(pathMapping: PathMapping, ffUrls: URL[]): Promise<boolean> {

	for (let i = 0; i < ffUrls.length;) {

		const ffUrl = ffUrls[i];
		const ffUrlWithoutQuery = ffUrl.protocol + '//' + ffUrl.host + ffUrl.pathname;
		const vscPath = applyPathMapping(ffUrlWithoutQuery, pathMapping);

		if (vscPath) {
			try {

				await vscode.workspace.fs.stat(vscodePathToUri(vscPath));
				ffUrls.splice(i, 1);

			} catch {
				return false;
			}
		} else {
			i++;
		}
	}

	return true;
}

function applyPathMapping(ffUrl: string, pathMapping: PathMapping): string | undefined {

	if (ffUrl.startsWith(pathMapping.url)) {

		let vscPath = pathMapping.path + ffUrl.substring(pathMapping.url.length);
		return isWindowsAbsolutePath(vscPath) ? path.normalize(vscPath) : vscPath;

	} else {
		return undefined;
	}
}

const windowsAbsolutePathRegEx = /^[a-zA-Z]:\\/;

function isWindowsAbsolutePath(path: string): boolean {
	return windowsAbsolutePathRegEx.test(path);
}

function vscodePathToUri(path: string): vscode.Uri {
	if (isWindowsAbsolutePath(path)) {
		return vscode.Uri.file(path);
	} else {
		return vscode.Uri.parse(path);
	}
}

export function vscodeUriToPath(uri: vscode.Uri): string {
	return (uri.scheme === 'file') ? uri.fsPath : uri.toString();
}

function vscodePathSep(path: string): string {
	return isWindowsAbsolutePath(path) ? '\\' : '/';
}
