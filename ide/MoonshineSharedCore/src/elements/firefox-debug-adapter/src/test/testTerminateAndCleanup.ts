import * as os from 'os';
import * as path from 'path';
import * as fs from 'fs-extra';
import * as assert from 'assert';
import * as uuid from 'uuid';
import * as util from './util';
import { delay } from '../common/util';
import { FirefoxDebugSession } from '../adapter/firefoxDebugSession';
import { parseConfiguration } from '../adapter/configuration';

describe('Terminate and cleanup: The debugger', function() {

	const TESTDATA_PATH = path.join(__dirname, '../../testdata');

	it('should eventually delete the temporary profile after terminating Firefox', async function() {

		const tmpDir = path.join(os.tmpdir(), `vscode-firefox-debug-test-${uuid.v4()}`);
		const dc = await util.initDebugClient(TESTDATA_PATH, true, { tmpDir });

		// check that the temporary profile has been created
		assert.ok((await fs.readdir(tmpDir)).length > 0);

		await dc.stop();

		// check repeatedly if the temporary profile has been deleted and fail after 5 seconds if it hasn't
		var startTime = Date.now();
		while ((Date.now() - startTime) < 5000) {
			await delay(200);
			if ((await fs.readdir(tmpDir)).length === 0) {
				await fs.rmdir(tmpDir);
				return;
			}
		}

		throw new Error("The temporary profile hasn't been deleted after 5 seconds");
	});

	it('should eventually delete the temporary profile after a detached Firefox process was terminated', async function() {

		if (os.platform() === 'darwin') {
			this.skip();
			return;
		}

		const tmpDir = path.join(os.tmpdir(), `vscode-firefox-debug-test-${uuid.v4()}`);
		const dc = await util.initDebugClient(TESTDATA_PATH, true, { tmpDir, reAttach: true });

		// check that the temporary profile has been created
		assert.ok((await fs.readdir(tmpDir)).length > 0);

		await dc.stop();

		// attach to Firefox again and terminate it using the Terminator WebExtension
		const parsedConfig = await parseConfiguration({ request: 'attach' });
		const ds = new FirefoxDebugSession(parsedConfig, () => undefined);
		await ds.start();
		ds.addonsActor!.installAddon(path.resolve(__dirname, '../../dist/terminator'));

		// check repeatedly if the temporary profile has been deleted and fail after 5 seconds if it hasn't
		var startTime = Date.now();
		while ((Date.now() - startTime) < 5000) {
			await delay(200);
			if ((await fs.readdir(tmpDir)).length === 0) {
				await fs.rmdir(tmpDir);
				return;
			}
		}

		throw new Error("The temporary profile hasn't been deleted after 5 seconds");
	});
});
