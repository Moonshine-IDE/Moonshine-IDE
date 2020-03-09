import { spawn } from 'child_process';
import * as fs from 'fs-extra';

/**
 * This script is used by the [launchFirefox()](../firefox/launch.ts) function when `reAttach` is
 * set to true in the launch configuration.
 */

let args = process.argv.splice(2);

let cmd = args.shift();

if (cmd === 'spawnDetached') {

	let exe = args.shift();

	let childProc = spawn(exe!, args, { detached: true, stdio: 'ignore' });

	childProc.unref();

} else if (cmd === 'spawnAndRemove') {

	let pathToRemove = args.shift();
	let exe = args.shift();

	let childProc = spawn(exe!, args);

	childProc.stdout.on('data', () => undefined);
	childProc.stderr.on('data', () => undefined);

	childProc.once('close', () => setTimeout(() => fs.remove(pathToRemove!), 500));

} else if (cmd === 'spawnAndRemove2') {

	let pathToRemove = args.shift();
	let pathToRemove2 = args.shift();
	let exe = args.shift();

	let childProc = spawn(exe!, args);

	childProc.stdout.on('data', () => undefined);
	childProc.stderr.on('data', () => undefined);

	childProc.once('close', () => setTimeout(() => fs.remove(pathToRemove!, () => fs.remove(pathToRemove2!)), 500));

}
