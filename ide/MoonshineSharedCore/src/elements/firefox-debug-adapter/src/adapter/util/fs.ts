import * as fs from 'fs-extra';
import { delay } from '../../common/util';
import { Log } from './log';

let log = Log.create('fs');

export async function isExecutable(path: string): Promise<boolean> {
	try {
		await fs.access(path, fs.constants.X_OK);
		return true;
	} catch (e) {
		return false;
	}
}

/**
 * Sometimes (on Windows) the temporary directories created for debugging can't be deleted immediately
 * after terminating Firefox, so this method keeps retrying for 500ms.
 */
export async function tryRemoveRepeatedly(dir: string): Promise<void> {
	for (var i = 0; i < 5; i++) {
		try {
			await fs.remove(dir);
			log.debug(`Removed ${dir}`);
			return;
		} catch (err) {
			if (i < 4) {
				log.debug(`Attempt to remove ${dir} failed, will retry in 100ms`);
				await delay(100);
			} else {
				log.debug(`Attempt to remove ${dir} failed, giving up`);
				throw err;
			}
		}
	}
}
