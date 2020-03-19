import * as path from 'path';
import * as fs from 'fs-extra';
import stripJsonComments from 'strip-json-comments';
import { isWindowsPlatform } from '../../common/util';
import isAbsoluteUrl from 'is-absolute-url';

/**
 * compare file paths or urls, taking into account whether filenames are case sensitive on the current platform
 */
export function pathsAreEqual(path1: string, path2: string | undefined) {
	if (path2 === undefined) return false;
	if (isWindowsPlatform() && !isAbsoluteUrl(path1)) {
		return path1.toUpperCase() === path2.toUpperCase();
	} else {
		return path1 === path2;
	}
}

/**
 * replace `\` with `/` on windows and remove trailing slashes
 */
export function normalizePath(rawPath: string) {
	let normalized = path.normalize(rawPath);
	if (isWindowsPlatform()) {
		normalized = normalized.replace(/\\/g, '/');
	}
	if (normalized[normalized.length - 1] === '/') {
		normalized = normalized.substr(0, normalized.length - 1);
	}

	return normalized;
}

/**
 * extract an error message from an exception
 * [grip](https://github.com/mozilla/gecko-dev/blob/master/devtools/docs/backend/protocol.md#grips)
 */
export function exceptionGripToString(grip: FirefoxDebugProtocol.Grip | null | undefined) {

	if ((typeof grip === 'object') && (grip !== null) && (grip.type === 'object')) {

		let preview = (<FirefoxDebugProtocol.ObjectGrip>grip).preview;
		if (preview && (preview.kind === 'Error')) {

			if (preview.name === 'ReferenceError') {
				return 'not available';
			}

			let str = (preview.name !== undefined) ? (preview.name + ': ') : '';
			str += (preview.message !== undefined) ? preview.message : '';
			if (str !== '') {
				return str;
			}
		}

	} else if (typeof grip === 'string') {
		return grip;
	}

	return 'unknown error';
}


const identifierExpression = /^[a-zA-Z_$][a-zA-Z_$]*$/;

/**
 * create a javascript expression for accessing a property of an object
 */
export function accessorExpression(objectExpression: string | undefined, propertyName: string): string | undefined {
	if (objectExpression === undefined) {
		return undefined;
	} else if (objectExpression === '') {
		return propertyName;
	} else if (identifierExpression.test(propertyName)) {
		return `${objectExpression}.${propertyName}`;
	} else {
		const escapedPropertyName = propertyName.replace('\\', '\\\\').replace('\'', '\\\'');
		return `${objectExpression}['${escapedPropertyName}']`;
	}
}

/**
 * extract the addon id from a WebExtension's `manifest.json`
 */
export async function findAddonId(addonPath: string): Promise<string | undefined> {
	try {
		const rawManifest = await fs.readFile(path.join(addonPath, 'manifest.json'), { encoding: 'utf8' });
		const manifest = JSON.parse(stripJsonComments(rawManifest));
		const id = ((manifest.applications || {}).gecko || {}).id;
		return id;
	} catch (err) {
		throw `Couldn't parse manifest.json: ${err}`;
	}
}
