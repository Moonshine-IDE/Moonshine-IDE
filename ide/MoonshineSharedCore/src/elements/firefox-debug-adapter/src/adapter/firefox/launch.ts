import * as path from 'path';
import * as fs from 'fs-extra';
import { spawn, fork, ChildProcess } from 'child_process';
import FirefoxProfile from 'firefox-profile';
import { ParsedLaunchConfiguration, ParsedAttachConfiguration, getExecutableCandidates } from '../configuration';
import { isExecutable } from '../util/fs';

/**
 * Launches Firefox after preparing the debug profile.
 * If Firefox is launched "detached" (the default unless we are on MacOS and the `reAttach` flag
 * in the launch configuration is set to `false`), it creates one or even two intermediate
 * child processes for launching Firefox:
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

	// workaround for an issue with the snap version of VS Code
	// (see e.g. https://github.com/microsoft/vscode/issues/85344)
	const env = { ...process.env };
	if (env.SNAP) {
		delete env['GDK_PIXBUF_MODULE_FILE'];
		delete env['GDK_PIXBUF_MODULEDIR'];
	}

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
					'forkDetached', forkedLauncherPath,
					'spawnAndRemove', launch.tmpDirs[0], launch.firefoxExecutable, ...launch.firefoxArgs
				];
				break;

			default:
				forkArgs = [
					'forkDetached', forkedLauncherPath,
					'spawnAndRemove2', launch.tmpDirs[0], launch.tmpDirs[1], launch.firefoxExecutable, ...launch.firefoxArgs
				];
				break;
		}

		fork(forkedLauncherPath, forkArgs, { env, execArgv: [] });

	} else {

		childProc = spawn(launch.firefoxExecutable, launch.firefoxArgs, { env, detached: true });

		childProc.stdout.on('data', () => undefined);
		childProc.stderr.on('data', () => undefined);

		childProc.unref();
	}

	return childProc;
}

export async function openNewTab(
	config: ParsedAttachConfiguration,
	description: FirefoxDebugProtocol.DeviceDescription
): Promise<boolean> {

	if (!config.url) return true;

	let firefoxExecutable = config.firefoxExecutable;
	if (!firefoxExecutable) {

		let firefoxEdition: 'stable' | 'developer' | 'nightly' | undefined;
		if (description.channel === 'release') {
			firefoxEdition = 'stable';
		} else if (description.channel === 'aurora') {
			firefoxEdition = 'developer';
		} else if (description.channel === 'nightly') {
			firefoxEdition = 'nightly';
		}

		if (firefoxEdition) {
			const candidates = getExecutableCandidates(firefoxEdition);
			for (let i = 0; i < candidates.length; i++) {
				if (await isExecutable(candidates[i])) {
					firefoxExecutable = candidates[i];
					break;
				}
			}
		}

		if (!firefoxExecutable) return false;
	}

	const firefoxArgs = config.profileDir ? [ '--profile', config.profileDir ] : [ '-P', description.profile ];
	firefoxArgs.push(config.url);

	spawn(firefoxExecutable, firefoxArgs);

	return true;
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
