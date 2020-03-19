import * as path from 'path';
import * as fs from 'fs-extra';
import { spawn, fork, ChildProcess } from 'child_process';
import FirefoxProfile from 'firefox-profile';
import { ParsedLaunchConfiguration } from '../configuration';

/**
 * Launches Firefox after preparing the debug profile.
 * If Firefox is launched "detached" (when the `reAttach` flag in the launch configuration is set
 * to `true`), it creates one or even two intermediate child processes for launching Firefox:
 * * one of them will wait for the Firefox process to exit and then remove any temporary directories
 *   created by this debug adapter
 * * the other one is used to work around a bug in the node version that is distributed with VS Code
 *   (and that runs this debug adapter), which fails to properly detach from child processes.
 *   See [this issue](https://github.com/microsoft/vscode/issues/22022) for an explanation of the
 *   bug and how to work around it.
 * 
 * The intermediate child processes execute the [forkedLauncher](../util/forkedLauncher.ts) script.
 */
export async function launchFirefox(launch: ParsedLaunchConfiguration): Promise<ChildProcess | undefined> {

	await prepareDebugProfile(launch);

	let childProc: ChildProcess | undefined = undefined;

	if (launch.detached) {

		let forkedLauncherPath = path.join(__dirname, './launcher.bundle.js');
		let forkArgs: string[];
		switch (launch.tmpDirs.length) {
			case 0:
				forkArgs = [
					'spawnDetached', launch.firefoxExecutable, ...launch.firefoxArgs
				];
				break;

			case 1:
				forkArgs = [
					'spawnDetached', process.execPath, forkedLauncherPath,
					'spawnAndRemove', launch.tmpDirs[0], launch.firefoxExecutable, ...launch.firefoxArgs
				];
				break;

			default:
				forkArgs = [
					'spawnDetached', process.execPath, forkedLauncherPath,
					'spawnAndRemove2', launch.tmpDirs[0], launch.tmpDirs[1], launch.firefoxExecutable, ...launch.firefoxArgs
				];
				break;
		}

		fork(forkedLauncherPath, forkArgs, { execArgv: [] });

	} else {

		childProc = spawn(launch.firefoxExecutable, launch.firefoxArgs, { detached: true });

		childProc.stdout.on('data', () => undefined);
		childProc.stderr.on('data', () => undefined);

		childProc.unref();
	}

	return childProc;
}

async function prepareDebugProfile(config: ParsedLaunchConfiguration): Promise<FirefoxProfile> {

	var profile = await createDebugProfile(config);

	for (let key in config.preferences) {
		profile.setPreference(key, config.preferences[key]);
	}

	profile.updatePreferences();

	return profile;
}

function createDebugProfile(config: ParsedLaunchConfiguration): Promise<FirefoxProfile> {
	return new Promise<FirefoxProfile>(async (resolve, reject) => {

		if (config.srcProfileDir) {

			FirefoxProfile.copy({
				profileDirectory: config.srcProfileDir,
				destinationDirectory: config.profileDir
			}, 
			(err, profile) => {
				if (err || !profile) {
					reject(err);
				} else {
					profile.shouldDeleteOnExit(false);
					resolve(profile);
				}
			});

		} else {

			await fs.ensureDir(config.profileDir);
			let profile = new FirefoxProfile({
				destinationDirectory: config.profileDir
			});
			profile.shouldDeleteOnExit(false);
			resolve(profile);
		}
	});
}
