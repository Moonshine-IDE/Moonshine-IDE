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
