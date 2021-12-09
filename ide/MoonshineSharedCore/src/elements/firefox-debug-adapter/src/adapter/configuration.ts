import * as os from 'os';
import * as path from 'path';
import * as uuid from 'uuid';
import isAbsoluteUrl from 'is-absolute-url';
import RegExpEscape from 'escape-string-regexp';
import { Log } from './util/log';
import { findAddonId, normalizePath } from './util/misc';
import { isExecutable } from './util/fs';
import { Minimatch } from 'minimatch';
import FirefoxProfile from 'firefox-profile';
import { isWindowsPlatform } from '../common/util';
import { LaunchConfiguration, AttachConfiguration, CommonConfiguration, ReloadConfiguration, DetailedReloadConfiguration, TabFilterConfiguration } from '../common/configuration';
import { urlDirname } from './util/net';

let log = Log.create('ParseConfiguration');

export interface NormalizedReloadConfiguration {
	watch: string[];
	ignore: string[];
	debounce: number;
}

export interface ParsedTabFilterConfiguration {
	include: RegExp[];
	exclude: RegExp[];
}

export interface ParsedConfiguration {
	attach?: ParsedAttachConfiguration;
	launch?: ParsedLaunchConfiguration;
	addon?: ParsedAddonConfiguration;
	pathMappings: PathMappings;
	filesToSkip: RegExp[];
	reloadOnChange?: NormalizedReloadConfiguration,
	tabFilter: ParsedTabFilterConfiguration,
	clearConsoleOnReload: boolean,
	showConsoleCallLocation: boolean;
	liftAccessorsFromPrototypes: number;
	suggestPathMappingWizard: boolean;
	terminate: boolean;
	enableCRAWorkaround: boolean;
}

export interface ParsedAttachConfiguration {
	host: string;
	port: number;
	url?: string;
	firefoxExecutable?: string;
	profileDir?: string;
	reloadTabs: boolean;
}

export interface FirefoxPreferences {
	[key: string]: boolean | number | string;
}

type PathMapping = { url: string | RegExp, path: string | null };
export type PathMappings = PathMapping[];

export interface ParsedLaunchConfiguration {
	firefoxExecutable: string;
	firefoxArgs: string[];
	profileDir: string;
	srcProfileDir?: string;
	preferences: FirefoxPreferences;
	tmpDirs: string[];
	port: number;
	timeout: number;
	detached: boolean;
}

export interface ParsedAddonConfiguration {
	path: string;
	id: string | undefined;
	popupAutohideButton: boolean;
}

/**
 * Reads the configuration that was provided by VS Code, checks that it's consistent,
 * adds default values and returns it in a form that is easier to work with
 */
export async function parseConfiguration(
	config: LaunchConfiguration | AttachConfiguration
): Promise<ParsedConfiguration> {

	let attach: ParsedAttachConfiguration | undefined = undefined;
	let launch: ParsedLaunchConfiguration | undefined = undefined;
	let addon: ParsedAddonConfiguration | undefined = undefined;
	let port = config.port || 6000;
	let timeout = 5;
	let pathMappings: PathMappings = [];
	let url: string | undefined = undefined;

	if (config.request === 'launch') {

		let tmpDirs: string[] = [];

		if (config.reAttach) {
			attach = {
				host: 'localhost', port,
				reloadTabs: (config.reloadOnAttach !== false)
			};
		}

		let firefoxExecutable = await findFirefoxExecutable(config.firefoxExecutable);

		let firefoxArgs: string[] = [ '-start-debugger-server', String(port), '-no-remote' ];
		if (config.firefoxArgs) {
			firefoxArgs.push(...config.firefoxArgs);
		}

		let { profileDir, srcProfileDir } = await parseProfileConfiguration(config, tmpDirs);

		firefoxArgs.push('-profile', profileDir);

		let preferences = createFirefoxPreferences(config.preferences);

		if (config.file) {
			if (!path.isAbsolute(config.file)) {
				throw 'The "file" property in the launch configuration has to be an absolute path';
			}

			let fileUrl = config.file;
			if (isWindowsPlatform()) {
				fileUrl = 'file:///' + fileUrl.replace(/\\/g, '/');
			} else {
				fileUrl = 'file://' + fileUrl;
			}
			firefoxArgs.push(fileUrl);
			url = fileUrl;

		} else if (config.url) {
			firefoxArgs.push(config.url);
			url = config.url;
		} else if (config.addonPath) {
			firefoxArgs.push('about:blank');
		} else {
			throw 'You need to set either "file" or "url" in the launch configuration';
		}

		if (typeof config.timeout === 'number') {
			timeout = config.timeout;
		}

		let detached = true;
		if (os.platform() === 'darwin') {
			if (!config.reAttach) {
				detached = false;
				if (config.keepProfileChanges) {
					throw 'On MacOS, "keepProfileChanges" is only allowed with "reAttach" because your profile may get damaged otherwise';
				}
			}
		}

		launch = {
			firefoxExecutable, firefoxArgs, profileDir, srcProfileDir,
			preferences, tmpDirs, port, timeout, detached
		};

	} else { // config.request === 'attach'

		const firefoxExecutable = config.firefoxExecutable ? await findFirefoxExecutable(config.firefoxExecutable) : undefined;

		url = config.url;
		attach = {
			host: config.host || 'localhost', port, url, firefoxExecutable, profileDir: config.profileDir,
			reloadTabs: !!config.reloadOnAttach
		};
	}

	if (config.pathMappings) {
		pathMappings.push(...config.pathMappings.map(harmonizeTrailingSlashes).map(handleWildcards));
	}

	if (config.addonPath) {
		addon = await parseAddonConfiguration(config, pathMappings);
	}

	const webRoot = parseWebRootConfiguration(config, pathMappings);

	if (webRoot) {
		pathMappings.push({ url: 'webpack:///~/', path: webRoot + '/node_modules/' });
		pathMappings.push({ url: 'webpack:///./~/', path: webRoot + '/node_modules/' });
		pathMappings.push({ url: 'webpack:///./', path: webRoot + '/' });
		pathMappings.push({ url: 'webpack:///src/', path: webRoot + '/src/' });
		pathMappings.push({ url: 'webpack:///node_modules/', path: webRoot + '/node_modules/' });
		pathMappings.push({ url: 'webpack:///webpack', path: null });
		pathMappings.push({ url: 'webpack:///(webpack)', path: null });
		pathMappings.push({ url: 'webpack:///pages/', path: webRoot + '/pages/' });
		pathMappings.push({ url: 'webpack://[name]_[chunkhash]/node_modules/', path: webRoot + '/node_modules/' });
		pathMappings.push({ url: 'webpack://[name]_[chunkhash]/', path: null });
	}
	pathMappings.push({ url: (isWindowsPlatform() ? 'webpack:///' : 'webpack://'), path: '' });

	pathMappings.push({ url: (isWindowsPlatform() ? 'file:///' : 'file://'), path: ''});

	let filesToSkip = parseSkipFilesConfiguration(config);

	let reloadOnChange = parseReloadConfiguration(config.reloadOnChange);

	const tabFilter = parseTabFilterConfiguration(config.tabFilter, url);

	const clearConsoleOnReload = !!config.clearConsoleOnReload;

	let showConsoleCallLocation = config.showConsoleCallLocation || false;
	let liftAccessorsFromPrototypes = config.liftAccessorsFromPrototypes || 0;
	let suggestPathMappingWizard = config.suggestPathMappingWizard;
	if (suggestPathMappingWizard === undefined) {
		suggestPathMappingWizard = true;
	}
	const terminate = (config.request === 'launch') && !config.reAttach;
	const enableCRAWorkaround = !!config.enableCRAWorkaround;

	return {
		attach, launch, addon, pathMappings, filesToSkip, reloadOnChange, tabFilter, clearConsoleOnReload,
		showConsoleCallLocation, liftAccessorsFromPrototypes, suggestPathMappingWizard, terminate,
		enableCRAWorkaround
	};
}

function harmonizeTrailingSlashes(pathMapping: PathMapping): PathMapping {

	if ((typeof pathMapping.url === 'string') && (typeof pathMapping.path === 'string') &&
		(pathMapping.path.length > 0)) {

		if (pathMapping.url.endsWith('/')) {
			if (pathMapping.path.endsWith('/')) {
				return pathMapping;
			} else {
				return { url: pathMapping.url, path: pathMapping.path + '/' };
			}
		} else {
			if (pathMapping.path.endsWith('/')) {
				return { url: pathMapping.url + '/', path: pathMapping.path };
			} else {
				return pathMapping;
			}
		}

	} else {
		return pathMapping;
	}
}

function handleWildcards(pathMapping: PathMapping): PathMapping {

	if ((typeof pathMapping.url === 'string') && (pathMapping.url.indexOf('*') >= 0)) {

		const regexp = '^' + pathMapping.url.split('*').map(RegExpEscape).join('[^/]*') + '(.*)$';

		return {
			url: new RegExp(regexp),
			path: pathMapping.path
		};

	} else {
		return pathMapping;
	}
}

async function findFirefoxExecutable(configuredPath?: string): Promise<string> {

	let candidates: string[];
	if (configuredPath) {
		if ([ 'stable', 'developer', 'nightly' ].indexOf(configuredPath) >= 0) {
			candidates = getExecutableCandidates(configuredPath as any);
		} else if (await isExecutable(configuredPath)) {
			return configuredPath;
		} else {
			throw 'Couldn\'t find the Firefox executable. Please correct the path given in your launch configuration.';
		}
	} else {
		candidates = getExecutableCandidates();
	}

	for (let i = 0; i < candidates.length; i++) {
		if (await isExecutable(candidates[i])) {
			return candidates[i];
		}
	}

	throw 'Couldn\'t find the Firefox executable. Please specify the path by setting "firefoxExecutable" in your launch configuration.';
}

export function getExecutableCandidates(edition?: 'stable' | 'developer' | 'nightly'): string[] {

	if (edition === undefined) {
		return [ ...getExecutableCandidates('developer'), ...getExecutableCandidates('stable') ];
	}

	const platform = os.platform();

	if ([ 'linux', 'freebsd', 'sunos' ].indexOf(platform) >= 0) {
		const paths = process.env.PATH!.split(':');
		switch (edition) {

			case 'stable':
				return [
					...paths.map(dir => path.join(dir, 'firefox'))
				];

			case 'developer':
				return [
					...paths.map(dir => path.join(dir, 'firefox-developer-edition')),
					...paths.map(dir => path.join(dir, 'firefox-developer')),
				];

			case 'nightly':
				return [
					...paths.map(dir => path.join(dir, 'firefox-nightly')),
				];
		}
	}

	switch (edition) {

		case 'stable':
			if (platform === 'darwin') {
				return [ '/Applications/Firefox.app/Contents/MacOS/firefox' ];
			} else if (platform === 'win32') {
				return [
					'C:\\Program Files\\Mozilla Firefox\\firefox.exe',
					'C:\\Program Files (x86)\\Mozilla Firefox\\firefox.exe'
				];
			}
			break;

		case 'developer':
			if (platform === 'darwin') {
				return [
					'/Applications/Firefox Developer Edition.app/Contents/MacOS/firefox',
					'/Applications/FirefoxDeveloperEdition.app/Contents/MacOS/firefox'
				];
			} else if (platform === 'win32') {
				return [
					'C:\\Program Files\\Firefox Developer Edition\\firefox.exe',
					'C:\\Program Files (x86)\\Firefox Developer Edition\\firefox.exe'
				];
			}
			break;

		case 'nightly':
			if (platform === 'darwin') {
				return [ '/Applications/Firefox Nightly.app/Contents/MacOS/firefox' ]
			} else if (platform === 'win32') {
				return [
					'C:\\Program Files\\Firefox Nightly\\firefox.exe',
					'C:\\Program Files (x86)\\Firefox Nightly\\firefox.exe'
				];
			}
			break;
	}

	return [];
}

async function parseProfileConfiguration(config: LaunchConfiguration, tmpDirs: string[])
: Promise<{ profileDir: string, srcProfileDir?: string }> {

	let profileDir: string;
	let srcProfileDir: string | undefined;

	if (config.profileDir) {
		if (config.profile) {
			throw 'You can set either "profile" or "profileDir", but not both';
		}
		srcProfileDir = config.profileDir;
	} else if (config.profile) {
		srcProfileDir = await findFirefoxProfileDir(config.profile);
	}

	if (config.keepProfileChanges) {
		if (srcProfileDir) {
			profileDir = srcProfileDir;
			srcProfileDir = undefined;
		} else {
			throw 'To enable "keepProfileChanges" you need to set either "profile" or "profileDir"';
		}
	} else {
		const tmpDir = config.tmpDir || os.tmpdir();
		profileDir = path.join(tmpDir, `vscode-firefox-debug-profile-${uuid.v4()}`);
		tmpDirs.push(profileDir);
	}

	return { profileDir, srcProfileDir };
}

function findFirefoxProfileDir(profileName: string): Promise<string | undefined> {
	return new Promise<string | undefined>((resolve, reject) => {

		let finder = new FirefoxProfile.Finder();

		finder.getPath(profileName, (err, path) => {
			if (err) {
				reject(err);
			} else {
				resolve(path);
			}
		});
	});
}

function createFirefoxPreferences(
	additionalPreferences?: { [key: string]: boolean | number | string | null }
): FirefoxPreferences {

	let preferences: FirefoxPreferences = {};

	// Remote debugging settings
	preferences['devtools.chrome.enabled'] = true;
	preferences['devtools.debugger.prompt-connection'] = false;
	preferences['devtools.debugger.remote-enabled'] = true;
	preferences['extensions.autoDisableScopes'] = 10;
	preferences['xpinstall.signatures.required'] = false;
	preferences['extensions.sdk.console.logLevel'] = 'all';
	// Skip check for default browser on startup
	preferences['browser.shell.checkDefaultBrowser'] = false;
	// Hide the telemetry infobar
	preferences['datareporting.policy.dataSubmissionPolicyBypassNotification'] = true;
	// Do not redirect user when a milestone upgrade of Firefox is detected
	preferences['browser.startup.homepage_override.mstone'] = 'ignore';
	// Disable the UI tour
	preferences['browser.uitour.enabled'] = false;
	// Do not warn on quitting Firefox
	preferences['browser.warnOnQuit'] = false;

	if (additionalPreferences !== undefined) {
		for (let key in additionalPreferences) {
			let value = additionalPreferences[key];
			if (value !== null) {
				preferences[key] = value;
			} else {
				delete preferences[key];
			}
		}
	}

	return preferences;
}

function parseWebRootConfiguration(config: CommonConfiguration, pathMappings: PathMappings): string | undefined {

	if (config.url) {
		if (!config.webRoot) {
			if ((config.request === 'launch') && !config.pathMappings) {
				throw `If you set "url" you also have to set "webRoot" or "pathMappings" in the ${config.request} configuration`;
			}
			return undefined;
		} else if (!path.isAbsolute(config.webRoot) && !isAbsoluteUrl(config.webRoot)) {
			throw `The "webRoot" property in the ${config.request} configuration has to be an absolute path`;
		}

		let webRootUrl = config.url;
		if (webRootUrl.lastIndexOf('/') > 7) {
			webRootUrl = webRootUrl.substr(0, webRootUrl.lastIndexOf('/'));
		}

		let webRoot = isAbsoluteUrl(config.webRoot) ? config.webRoot : normalizePath(config.webRoot);

		pathMappings.forEach((pathMapping) => {
			const to = pathMapping.path;
			if ((typeof to === 'string') && (to.substr(0, 10) === '${webRoot}')) {
				pathMapping.path = webRoot + to.substr(10);
			}
		});

		pathMappings.push({ url: webRootUrl, path: webRoot });

		return webRoot;

	} else if (config.webRoot) {
		throw `If you set "webRoot" you also have to set "url" in the ${config.request} configuration`;
	}

	return undefined;
}

function parseSkipFilesConfiguration(config: CommonConfiguration): RegExp[] {

	let filesToSkip: RegExp[] = [];

	if (config.skipFiles) {
		config.skipFiles.forEach((glob) => {

			let minimatch = new Minimatch(glob);
			let regExp = minimatch.makeRe();

			if (regExp) {
				filesToSkip.push(regExp);
			} else {
				log.warn(`Invalid glob pattern "${glob}" specified in "skipFiles"`);
			}
		})
	}

	return filesToSkip;
}

function parseReloadConfiguration(
	reloadConfig: ReloadConfiguration | undefined
): NormalizedReloadConfiguration | undefined {

	if (reloadConfig === undefined) {
		return undefined;
	}

	const defaultDebounce = 100;

	if (typeof reloadConfig === 'string') {

		return {
			watch: [ normalizePath(reloadConfig) ],
			ignore: [],
			debounce: defaultDebounce
		};

	} else if (Array.isArray(reloadConfig)) {

		return {
			watch: reloadConfig.map(path => normalizePath(path)),
			ignore: [],
			debounce: defaultDebounce
		};

	} else {

		let _config = <DetailedReloadConfiguration>reloadConfig;

		let watch: string[];
		if (typeof _config.watch === 'string') {
			watch = [ _config.watch ];
		} else {
			watch = _config.watch;
		}

		watch = watch.map((path) => normalizePath(path));

		let ignore: string[];
		if (_config.ignore === undefined) {
			ignore = [];
		} else if (typeof _config.ignore === 'string') {
			ignore = [ _config.ignore ];
		} else {
			ignore = _config.ignore;
		}

		ignore = ignore.map((path) => normalizePath(path));

		let debounce: number;
		if (typeof _config.debounce === 'number') {
			debounce = _config.debounce;
		} else {
			debounce = (_config.debounce !== false) ? defaultDebounce : 0;
		}

		return { watch, ignore, debounce };
	}
}

function parseTabFilterConfiguration(
	tabFilterConfig?: TabFilterConfiguration,
	url?: string
): ParsedTabFilterConfiguration {

	if (tabFilterConfig === undefined) {

		if (url) {
			return { include: [ new RegExp(RegExpEscape(urlDirname(url)) + '.*') ], exclude: [] };
		} else {
			return { include: [ /.*/ ], exclude: [] };
		}

	}

	if ((typeof tabFilterConfig === 'string') || Array.isArray(tabFilterConfig)) {

		return { include: parseTabFilter(tabFilterConfig), exclude: [] }

	} else {

		return {
			include: (tabFilterConfig.include !== undefined) ? parseTabFilter(tabFilterConfig.include) : [ /.*/ ],
			exclude: (tabFilterConfig.exclude !== undefined) ? parseTabFilter(tabFilterConfig.exclude) : []
		}
	}
}

function parseTabFilter(tabFilter: string | string[]): RegExp[] {

	if (typeof tabFilter === 'string') {

		const parts = tabFilter.split('*').map(part => RegExpEscape(part));
		const regExp = new RegExp(`^${parts.join('.*')}$`);
		return [ regExp ];

	} else {

		return tabFilter.map(f => parseTabFilter(f)[0]);

	}
}

async function parseAddonConfiguration(
	config: LaunchConfiguration | AttachConfiguration,
	pathMappings: PathMappings
): Promise<ParsedAddonConfiguration> {

	let addonPath = config.addonPath!;
	const popupAutohideButton = (config.popupAutohideButton !== false);

	let addonId = await findAddonId(addonPath);

	let sanitizedAddonPath = addonPath;
	if (sanitizedAddonPath[sanitizedAddonPath.length - 1] === '/') {
		sanitizedAddonPath = sanitizedAddonPath.substr(0, sanitizedAddonPath.length - 1);
	}
	pathMappings.push({
		url: new RegExp('^moz-extension://[0-9a-f-]*(/.*)$'),
		path: sanitizedAddonPath
	});

	if (addonId) {
		// this pathMapping may no longer be necessary, I haven't seen this kind of URL recently...
		let rewrittenAddonId = addonId.replace('{', '%7B').replace('}', '%7D');
		pathMappings.push({
			url: new RegExp(`^jar:file:.*/extensions/${rewrittenAddonId}.xpi!(/.*)$`),
			path: sanitizedAddonPath
		});
	}

	return {
		path: addonPath, id: addonId, popupAutohideButton
	}
}
