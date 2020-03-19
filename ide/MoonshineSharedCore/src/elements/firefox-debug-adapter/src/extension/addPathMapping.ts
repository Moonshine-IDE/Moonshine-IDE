import * as path from 'path';
import * as vscode from 'vscode';
import { TreeNode } from './loadedScripts/treeNode';

interface LaunchConfig {
	type: string;
	name: string;
}

interface LaunchConfigReference {
	workspaceFolder: vscode.WorkspaceFolder;
	launchConfigFile: vscode.WorkspaceConfiguration;
	index: number;
}

export async function addPathMapping(treeNode: TreeNode): Promise<void> {

	const launchConfigReference = _findLaunchConfig();
	if (!launchConfigReference) return;

	const openDialogResult = await vscode.window.showOpenDialog({
		canSelectFiles: (treeNode.treeItem.contextValue === 'file'),
		canSelectFolders: (treeNode.treeItem.contextValue === 'directory'),
		canSelectMany: false,
		defaultUri: launchConfigReference.workspaceFolder.uri,
		openLabel: 'Map to this ' + treeNode.treeItem.contextValue
	});
	if (!openDialogResult || (openDialogResult.length === 0)) {
		return;
	}

	let path = (openDialogResult[0].scheme === 'file') ? openDialogResult[0].fsPath : openDialogResult[0].toString();
	if (treeNode.treeItem.contextValue === 'directory') {
		path += '/';
	}
	addPathMappingToLaunchConfig(launchConfigReference, treeNode.getFullPath(), path);

	await showLaunchConfig(launchConfigReference.workspaceFolder);

	vscode.window.showWarningMessage('Configuration was modified - please restart your debug session for the changes to take effect');
}

export async function addNullPathMapping(treeNode: TreeNode): Promise<void> {

	const launchConfigReference = _findLaunchConfig();
	if (!launchConfigReference) return;

	addPathMappingToLaunchConfig(launchConfigReference, treeNode.getFullPath(), null);

	await showLaunchConfig(launchConfigReference.workspaceFolder);

	vscode.window.showWarningMessage('Configuration was modified - please restart your debug session for the changes to take effect');
}

function _findLaunchConfig(): LaunchConfigReference | undefined {

	const debugSession = vscode.debug.activeDebugSession;
	if (!debugSession) {
		vscode.window.showErrorMessage('No active debug session');
		return undefined;
	}

	const workspaceFolders = vscode.workspace.workspaceFolders;
	if (!workspaceFolders) {
		vscode.window.showErrorMessage('No open folder');
		return undefined;
	}

	const launchConfigReference = findLaunchConfig(workspaceFolders, debugSession);

	if (!launchConfigReference) {
		vscode.window.showErrorMessage(`Couldn't find configuration for active debug session '${debugSession.name}'`);
	}

	return launchConfigReference;
}

export function findLaunchConfig(
	workspaceFolders: vscode.WorkspaceFolder[],
	activeDebugSession: vscode.DebugSession
): LaunchConfigReference | undefined {

	for (const workspaceFolder of workspaceFolders) {
		const launchConfigFile = vscode.workspace.getConfiguration('launch', workspaceFolder.uri);
		const launchConfigs: LaunchConfig[] | undefined = launchConfigFile.get('configurations');
		if (launchConfigs) {
			for (let index = 0; index < launchConfigs.length; index++) {
				if ((launchConfigs[index].type === activeDebugSession.type) && 
					(launchConfigs[index].name === activeDebugSession.name)) {
					return { workspaceFolder, launchConfigFile, index };
				}
			}
		}
	}

	return undefined;
}

export function addPathMappingToLaunchConfig(
	launchConfigReference: LaunchConfigReference,
	url: string,
	path: string | null
): void {

	const configurations = <any[]>launchConfigReference.launchConfigFile.get('configurations');
	const configuration = configurations[launchConfigReference.index];

	if (!configuration.pathMappings) {
		configuration.pathMappings = [];
	}

	const workspacePath = launchConfigReference.workspaceFolder.uri.fsPath;
	if (path && path.startsWith(workspacePath)) {
		path = '${workspaceFolder}' + path.substr(workspacePath.length);
	}

	const pathMappings: any[] = configuration.pathMappings;
	pathMappings.unshift({ url, path });

	launchConfigReference.launchConfigFile.update('configurations', configurations, vscode.ConfigurationTarget.WorkspaceFolder);
}

export async function showLaunchConfig(workspaceFolder: vscode.WorkspaceFolder): Promise<void> {
	const uri = workspaceFolder.uri.with({ path: path.posix.join(workspaceFolder.uri.path, '.vscode/launch.json') });
	const document = await vscode.workspace.openTextDocument(uri);
	await vscode.window.showTextDocument(document);
}
