import * as vscode from 'vscode';
import { LaunchConfiguration, AttachConfiguration } from '../common/configuration';

const folderVar = '${workspaceFolder}';

export class DebugConfigurationProvider implements vscode.DebugConfigurationProvider {

	/**
	 * this method is called by VS Code before a debug session is started and makes modifications
	 * to the debug configuration:
	 * - some values can be overridden by corresponding VS Code settings
	 * - when running in a remote workspace, we resolve `${workspaceFolder}` ourselves because
	 *   VS Code resolves it to a local path in the remote workspace but we need the remote URI instead
	 * - when running in a remote workspace, we check that configuration values that need to point
	 *   to local files don't contain `${workspaceFolder}`
	 */
	resolveDebugConfiguration(
		folder: vscode.WorkspaceFolder | undefined,
		debugConfiguration: vscode.DebugConfiguration & (LaunchConfiguration | AttachConfiguration)
	): vscode.DebugConfiguration {

		debugConfiguration = { ...debugConfiguration };

		this.overrideFromSettings(folder, debugConfiguration);

		if (folder && (folder.uri.scheme === 'vscode-remote')) {

			this.resolveWorkspaceFolder(folder, debugConfiguration);

			this.checkLocal(debugConfiguration);

		}

		return debugConfiguration;
	}

	private overrideFromSettings(
		folder: vscode.WorkspaceFolder | undefined,
		debugConfiguration: vscode.DebugConfiguration & (LaunchConfiguration | AttachConfiguration)
	): void {

		const settings = vscode.workspace.getConfiguration('firefox', folder ? folder.uri : null);

		const executable = this.getSetting<string>(settings, 'executable');
		if (executable) {
			debugConfiguration.firefoxExecutable = executable;
		}

		const args = this.getSetting<string[]>(settings, 'args');
		if (args) {
			debugConfiguration.firefoxArgs = args;
		}

		const profileDir = this.getSetting<string>(settings, 'profileDir');
		if (profileDir) {
			debugConfiguration.profileDir = profileDir;
		}

		const profile = this.getSetting<string>(settings, 'profile');
		if (profile) {
			debugConfiguration.profile = profile;
		}

		const keepProfileChanges = this.getSetting<boolean>(settings, 'keepProfileChanges');
		if (keepProfileChanges !== undefined) {
			debugConfiguration.keepProfileChanges = keepProfileChanges;
		}
	}

	/**
	 * read a value from the user's VS Code settings. If the user hasn't set a value, this
	 * method returns `undefined` (instead of the default value for the given key).
	 */
	private getSetting<T>(settings: vscode.WorkspaceConfiguration, key: string): T | undefined {

		const values = settings.inspect<T>(key);
		if (!values) return undefined;

		if (values.workspaceFolderValue !== undefined) return values.workspaceFolderValue;
		if (values.workspaceValue !== undefined) return values.workspaceValue;
		if (values.globalValue !== undefined) return values.globalValue;
		return undefined;
	}

	private resolveWorkspaceFolder(
		folder: vscode.WorkspaceFolder,
		debugConfiguration: vscode.DebugConfiguration & (LaunchConfiguration | AttachConfiguration)
	): void {

		const uri = folder.uri.toString();
		if (debugConfiguration.webRoot) {
			debugConfiguration.webRoot = debugConfiguration.webRoot.replace(folderVar, uri);
		}

		if (debugConfiguration.pathMappings) {

			const resolvedPathMappings: { url: string, path: string | null }[] = [];

			for (const pathMapping of debugConfiguration.pathMappings) {
				if (pathMapping.path) {

					resolvedPathMappings.push({
						url: pathMapping.url,
						path: pathMapping.path.replace(folderVar, uri)
					});

				} else {
					resolvedPathMappings.push(pathMapping);
				}
			}

			debugConfiguration.pathMappings = resolvedPathMappings;
		}
	}

	private checkLocal(
		debugConfiguration: vscode.DebugConfiguration & (LaunchConfiguration | AttachConfiguration)
	): void {

		function check(errorMsg: string) {
			return function(str: string): void {
				if (str.indexOf(folderVar) >= 0) {
					throw new Error(errorMsg);
				}
			}
		}

		if (debugConfiguration.reloadOnChange) {

			const checkReload = check("The debug adapter can't watch files in a remote workspace for changes");

			if (typeof debugConfiguration.reloadOnChange === 'string') {

				checkReload(debugConfiguration.reloadOnChange);

			} else if (Array.isArray(debugConfiguration.reloadOnChange)) {

				debugConfiguration.reloadOnChange.forEach(checkReload);

			} else {

				if (typeof debugConfiguration.reloadOnChange.watch === 'string') {
					checkReload(debugConfiguration.reloadOnChange.watch);
				} else {
					debugConfiguration.reloadOnChange.watch.forEach(checkReload);
				}

				if (debugConfiguration.reloadOnChange.ignore) {
					if (typeof debugConfiguration.reloadOnChange.ignore === 'string') {
						checkReload(debugConfiguration.reloadOnChange.ignore);
					} else {
						debugConfiguration.reloadOnChange.ignore.forEach(checkReload);
					}
				}
			}
		}

		if (debugConfiguration.log && debugConfiguration.log.fileName) {
			check("The debug adapter can't write a log file in a remote workspace")(debugConfiguration.log.fileName);
		}

		if (debugConfiguration.request === 'launch') {

			if (debugConfiguration.file) {
				check("Firefox can't open a file in a remote workspace")(debugConfiguration.file);
			}

			if (debugConfiguration.profileDir) {
				check("Firefox can't have its profile in a remote workspace")(debugConfiguration.profileDir);
			}
		}
	}
}
