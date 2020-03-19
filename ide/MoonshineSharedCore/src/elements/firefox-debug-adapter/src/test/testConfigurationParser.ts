import { LaunchConfiguration, AttachConfiguration } from '../common/configuration';
import { parseConfiguration, NormalizedReloadConfiguration } from '../adapter/configuration';
import * as assert from 'assert';
import * as path from 'path';
import { isWindowsPlatform } from '../common/util';

describe('The configuration parser', function() {

	it('should create default values for a simple launch configuration', async function() {

		let filePath: string;
		let fileUrl: string;
		if (isWindowsPlatform()) {
			filePath = 'c:\\Users\\user\\project\\index.html';
			fileUrl = 'file:///c:/Users/user/project/index.html';
		} else {
			filePath = '/home/user/project/index.html';
			fileUrl = 'file:///home/user/project/index.html';
		}
		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			file: filePath
		});

		assert.equal(parsedConfiguration.attach, undefined);
		assert.equal(parsedConfiguration.addon, undefined);
		assert.deepEqual(parsedConfiguration.filesToSkip, []);
		assert.equal(parsedConfiguration.reloadOnChange, undefined);
		assert.equal(parsedConfiguration.showConsoleCallLocation, false);
		assert.equal(parsedConfiguration.liftAccessorsFromPrototypes, 0);
		assert.equal(parsedConfiguration.suggestPathMappingWizard, true);

		assert.ok(parsedConfiguration.launch!.firefoxExecutable);
		assert.equal([...parsedConfiguration.launch!.firefoxArgs].pop(), fileUrl);
		assert.equal(parsedConfiguration.launch!.port, 6000);
		assert.equal(parsedConfiguration.launch!.timeout, 5);
		assert.equal(parsedConfiguration.launch!.preferences['devtools.debugger.remote-enabled'], true);
		assert.ok(parsedConfiguration.launch!.profileDir);
		assert.equal(parsedConfiguration.launch!.srcProfileDir, undefined);
		assert.equal(parsedConfiguration.launch!.tmpDirs.length, 1);
		assert.equal(parsedConfiguration.launch!.tmpDirs[0], parsedConfiguration.launch!.profileDir);
	});

	it('should create default values for a simple attach configuration', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'attach',
			url: 'https://mozilla.org/',
			webRoot: '/home/user/project'
		});

		assert.equal(parsedConfiguration.launch, undefined);
		assert.equal(parsedConfiguration.addon, undefined);
		assert.deepEqual(parsedConfiguration.filesToSkip, []);
		assert.equal(parsedConfiguration.reloadOnChange, undefined);
		assert.equal(parsedConfiguration.showConsoleCallLocation, false);
		assert.equal(parsedConfiguration.liftAccessorsFromPrototypes, 0);
		assert.equal(parsedConfiguration.suggestPathMappingWizard, true);

		assert.equal(parsedConfiguration.attach!.port, 6000);
		assert.equal(parsedConfiguration.attach!.host, 'localhost');
		assert.equal(parsedConfiguration.attach!.reloadTabs, false);
	});

	it('should require "file" or "url" to be set in a launch configuration', async function() {
		await assertPromiseRejects(parseConfiguration({
			request: 'launch'
		}), 'You need to set either "file" or "url" in the launch configuration');
	});

	it('should require "file" to be an absolute path', async function() {
		await assertPromiseRejects(parseConfiguration({
			request: 'launch',
			file: './index.html'
		}), 'The "file" property in the launch configuration has to be an absolute path');
	});

	for (let request of [ 'launch', 'attach' ]) {
		it(`should require "webRoot" or "pathMappings" if "url" is specified in a ${request} configuration`, async function() {
			await assertPromiseRejects(parseConfiguration(<any>{
				request,
				url: 'https://mozilla.org/'
			}), `If you set "url" you also have to set "webRoot" or "pathMappings" in the ${request} configuration`);
		});

		it(`should require "webRoot" to be an absolute path in a ${request} configuration`, async function() {
			await assertPromiseRejects(parseConfiguration(<any>{
				request,
				url: 'https://mozilla.org/',
				webRoot: './project'
			}), `The "webRoot" property in the ${request} configuration has to be an absolute path`);
		});

		it(`should allow "url" without "webRoot" if "pathMappings" are specified in a ${request} configuration`, async function() {
			await parseConfiguration(<any>{
				request,
				url: 'https://mozilla.org/',
				pathMappings: [{
					url:'https://mozilla.org/',
					path: './project'
				}]
			});
		});
	}

	it('should require "url" if "webRoot" is specified in an attach configuration', async function() {
		await assertPromiseRejects(parseConfiguration(<any>{
			request: 'attach',
			webRoot: '/home/user/project'
		}), 'If you set "webRoot" you also have to set "url" in the attach configuration');
	});

	it('should create a pathMapping for mapping "url" to "webRoot"', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			url: 'https://mozilla.org/',
			webRoot: '/home/user/project'
		});

		assert.equal(parsedConfiguration.pathMappings.find(
			(mapping) => mapping.url === 'https://mozilla.org')!.path, '/home/user/project');
	});

	it('should strip a filename from the url and a trailing slash from the webRoot in the pathMapping', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			url: 'https://mozilla.org/index.html',
			webRoot: '/home/user/project/'
		});

		assert.equal(parsedConfiguration.pathMappings.find(
			(mapping) => mapping.url === 'https://mozilla.org')!.path, '/home/user/project');
	});

	it('should not strip the hostname from the webRoot in the pathMapping', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			url: 'https://mozilla.org',
			webRoot: '/home/user/project'
		});

		assert.equal(parsedConfiguration.pathMappings.find(
			(mapping) => mapping.url === 'https://mozilla.org')!.path, '/home/user/project');
	});

	it('should include a user-specified pathMapping in a launch configuration', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			url: 'https://mozilla.org/index.html',
			webRoot: '/home/user/project/',
			pathMappings: [{
				url: 'https://static.mozilla.org',
				path: '/home/user/project/static'
			}]
		});

		assert.equal(parsedConfiguration.pathMappings.find(
			(mapping) => mapping.url === 'https://static.mozilla.org')!.path, '/home/user/project/static');
	});

	it('should include a user-specified pathMapping in an attach configuration', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'attach',
			pathMappings: [{
				url: 'https://static.mozilla.org',
				path: '/home/user/project/static'
			}]
		});

		assert.equal(parsedConfiguration.pathMappings.find(
			(mapping) => mapping.url === 'https://static.mozilla.org')!.path, '/home/user/project/static');
	});

	it('should replace ${webRoot} in a user-specified pathMapping', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			url: 'https://mozilla.org/index.html',
			webRoot: '/home/user/project/',
			pathMappings: [{
				url: 'https://static.mozilla.org',
				path: '${webRoot}/static'
			}]
		});

		assert.equal(parsedConfiguration.pathMappings.find(
			(mapping) => mapping.url === 'https://static.mozilla.org')!.path, '/home/user/project/static');
	});

	it('should harmonize trailing slashes in user-specified pathMappings', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			url: 'https://mozilla.org/index.html',
			webRoot: '/home/user/project/',
			pathMappings: [{
				url: 'https://static.mozilla.org',
				path: '${webRoot}/static/'
			}, {
				url: 'https://api.mozilla.org/',
				path: '${webRoot}/api'
			}]
		});

		assert.equal(parsedConfiguration.pathMappings.find(
			(mapping) => mapping.url === 'https://static.mozilla.org/')!.path, '/home/user/project/static/');

		assert.equal(parsedConfiguration.pathMappings.find(
			(mapping) => mapping.url === 'https://api.mozilla.org/')!.path, '/home/user/project/api/');
	});

	it('should add default pathMappings for webpack if webRoot is defined', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			url: 'https://mozilla.org/index.html',
			webRoot: '/home/user/project/'
		});

		assert.equal(parsedConfiguration.pathMappings.find(
			(mapping) => mapping.url === 'webpack:///~/')!.path, '/home/user/project/node_modules/');

		assert.equal(parsedConfiguration.pathMappings.find(
			(mapping) => mapping.url === 'webpack:///./~/')!.path, '/home/user/project/node_modules/');

		assert.equal(parsedConfiguration.pathMappings.find(
			(mapping) => mapping.url === 'webpack:///./')!.path, '/home/user/project/');

		assert.equal(parsedConfiguration.pathMappings.find(
			(mapping) => mapping.url === 'webpack:///src/')!.path, '/home/user/project/src/');

		assert.equal(parsedConfiguration.pathMappings.find(
			(mapping) => mapping.url === (isWindowsPlatform() ? 'webpack:///' : 'webpack://'))!.path, '');
	});

	it('should add only one default pathMapping for webpack if webRoot is not defined', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			file: '/home/user/project/index.html',
		});

		assert.equal(parsedConfiguration.pathMappings.find(
			(mapping) => mapping.url === (isWindowsPlatform() ? 'webpack:///' : 'webpack://'))!.path, '');

		assert.equal(parsedConfiguration.pathMappings.find(
			(mapping) => ((typeof mapping.url === 'string') && mapping.url.startsWith('webpack') && (mapping.url.length > 11))),
			undefined);
	});

	it('should create an attach configuration if "reAttach" is set to true', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			file: '/home/user/project/index.html',
			reAttach: true
		});

		assert.ok(parsedConfiguration.attach);
	});

	{
		let launchConfig: LaunchConfiguration = {
			request: 'launch',
			file: '/home/user/project/index.html',
			reAttach: true
		};
		let attachConfig: AttachConfiguration = {
			request: 'attach',
			url: 'https://mozilla.org/',
			webRoot: '/home/user/project'
		};

		for (let config of [ launchConfig, attachConfig ]) {
		for (let reloadOnAttach of [ true, false ]) {
			it(`should set "reloadTabs" to ${reloadOnAttach} if "reloadOnAttach" is set to ${reloadOnAttach} in a ${config.request} configuration`, async function() {

				let parsedConfiguration = await parseConfiguration(
					Object.assign({ reloadOnAttach}, config));

				assert.equal(parsedConfiguration.attach!.reloadTabs, reloadOnAttach);
			});
		}}
	}

	it('should set "reloadTabs" to true if "reloadOnAttach" is not set in a launch configuration with "reAttach" set to true', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			file: '/home/user/project/index.html',
			reAttach: true
		});

		assert.equal(parsedConfiguration.attach!.reloadTabs, true);
	});

	it('should create a corresponding NormalizedReloadConfiguration if "reloadOnChange" is set to a string', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			file: '/home/user/project/index.html',
			reloadOnChange: '/home/user/project'
		});

		assert.deepEqual(parsedConfiguration.reloadOnChange, <NormalizedReloadConfiguration>{
			watch: [ '/home/user/project' ],
			ignore: [],
			debounce: 100
		});
	});

	it('should create a corresponding NormalizedReloadConfiguration if "reloadOnChange" is set to a string array', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			file: '/home/user/project/index.html',
			reloadOnChange: [ '/home/user/project/js', '/home/user/project/css' ]
		});

		assert.deepEqual(parsedConfiguration.reloadOnChange, <NormalizedReloadConfiguration>{
			watch: [ '/home/user/project/js', '/home/user/project/css' ],
			ignore: [],
			debounce: 100
		});
	});

	it('should convert strings to string arrays and "debounce": false to "debounce": 0 in a detailed "reloadOnChange" configuration', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			file: '/home/user/project/index.html',
			reloadOnChange: {
				watch: '/home/user/project/js',
				ignore: '/home/user/project/js/dummy.js',
				debounce: false
			}
		});

		assert.deepEqual(parsedConfiguration.reloadOnChange, <NormalizedReloadConfiguration>{
			watch: [ '/home/user/project/js' ],
			ignore: [ '/home/user/project/js/dummy.js' ],
			debounce: 0
		});
	});

	it('should add defaults to a detailed "reloadOnChange" configuration', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			file: '/home/user/project/index.html',
			reloadOnChange: {
				watch: [ '/home/user/project/js' ],
			}
		});

		assert.deepEqual(parsedConfiguration.reloadOnChange, <NormalizedReloadConfiguration>{
			watch: [ '/home/user/project/js' ],
			ignore: [],
			debounce: 100
		});
	});

	it('should copy a normalized "reloadOnChange" configuration', async function() {

		let reloadOnChange: NormalizedReloadConfiguration = {
			watch: [ '/home/user/project/js', '/home/user/project/css' ],
			ignore: [ '/home/user/project/css/dummy.css' ],
			debounce: 200
		}
		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			file: '/home/user/project/index.html',
			reloadOnChange
		});

		assert.deepEqual(parsedConfiguration.reloadOnChange, reloadOnChange);
	});

	it('should convert windows-style directory separators for all globs provided to "reloadOnChange"', async function () {
		if (isWindowsPlatform()) {
			let reloadOnChangeNormalized: NormalizedReloadConfiguration = {
				watch: ['C:/Users/WinUser/Projects/project/scripts/**/*.js', '!C:/Users/WinUser/Projects/project/scripts/composer.js'],
				ignore: ['C:/Users/WinUser/Projects/project/scripts/cache/**/*.js'],
				debounce: 200
			}

			let parsedConfiguration = await parseConfiguration({
				request: 'launch',
				file: 'C:\\Users\\WinUser\\Projects\\project/index.html',
				reloadOnChange: {
					watch: ['C:\\Users\\WinUser\\Projects\\project/scripts/**/*.js', '!C:\\Users\\WinUser\\Projects\\project/scripts/composer.js'],
					ignore: ['C:\\Users\\WinUser\\Projects\\project/scripts/cache/**/*.js'],
					debounce: 200
				}
			});

			assert.deepEqual(parsedConfiguration.reloadOnChange, reloadOnChangeNormalized);
		} else {
			let reloadOnChangeNormalized: NormalizedReloadConfiguration = {
				watch: ['/home/user/project/scripts/**/*.js', '!/home/user/project/scripts/composer.js'],
				ignore: ['/home/user/project/scripts/cache/**/*.js'],
				debounce: 200
			}

			let parsedConfiguration = await parseConfiguration({
				request: 'launch',
				file: '/home/user/project/index.html',
				reloadOnChange: {
					watch: ['/home/user/project/scripts/**/*.js', '!/home/user/project/scripts/composer.js'],
					ignore: ['/home/user/project/scripts/cache/**/*.js'],
					debounce: 200
				}
			});

			assert.deepEqual(parsedConfiguration.reloadOnChange, reloadOnChangeNormalized);
		}
	});

	it('should convert windows-style directory separators for all globs provided to "reloadOnChange" in an array', async function () {
		if (isWindowsPlatform()) {
			let reloadOnChangeNormalized: NormalizedReloadConfiguration = {
				watch: ['C:/Users/WinUser/Projects/project/scripts/**/*.js', '!C:/Users/WinUser/Projects/project/scripts/composer.js'],
				ignore: [],
				debounce: 100
			}

			let parsedConfiguration = await parseConfiguration({
				request: 'launch',
				file: 'C:\\Users\\WinUser\\Projects\\project/index.html',
				reloadOnChange: ['C:\\Users\\WinUser\\Projects\\project/scripts/**/*.js', '!C:\\Users\\WinUser\\Projects\\project/scripts/composer.js']
			});

			assert.deepEqual(parsedConfiguration.reloadOnChange, reloadOnChangeNormalized);
		} else {
			let reloadOnChangeNormalized: NormalizedReloadConfiguration = {
				watch: ['/home/user/project/scripts/**/*.js', '!/home/user/project/scripts/composer.js'],
				ignore: [],
				debounce: 100
			}

			let parsedConfiguration = await parseConfiguration({
				request: 'launch',
				file: '/home/user/project/index.html',
				reloadOnChange: ['/home/user/project/scripts/**/*.js', '!/home/user/project/scripts/composer.js']
			});

			assert.deepEqual(parsedConfiguration.reloadOnChange, reloadOnChangeNormalized);
		}
	});

	it('should convert windows-style directory separators for the single glob provided to "reloadOnChange"', async function () {
		if (isWindowsPlatform()) {
			let reloadOnChangeNormalized: NormalizedReloadConfiguration = {
				watch: ['C:/Users/WinUser/Projects/project/scripts/**/*.js'],
				ignore: [],
				debounce: 100
			}

			let parsedConfiguration = await parseConfiguration({
				request: 'launch',
				file: 'C:\\Users\\WinUser\\Projects\\project/index.html',
				reloadOnChange: 'C:\\Users\\WinUser\\Projects\\project/scripts/**/*.js'
			});

			assert.deepEqual(parsedConfiguration.reloadOnChange, reloadOnChangeNormalized);
		} else {
			let reloadOnChangeNormalized: NormalizedReloadConfiguration = {
				watch: ['/home/user/project/scripts/**/*.js'],
				ignore: [],
				debounce: 100
			}

			let parsedConfiguration = await parseConfiguration({
				request: 'launch',
				file: '/home/user/project/index.html',
				reloadOnChange: '/home/user/project/scripts/**/*.js'
			});

			assert.deepEqual(parsedConfiguration.reloadOnChange, reloadOnChangeNormalized);
		}
	});

	it('should parse "skipFiles"', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			file: '/home/user/project/index.html',
			skipFiles: [ '/home/user/project/libs/**/*' ]
		});

		assert.equal(parsedConfiguration.filesToSkip.length, 1);
	});

	it('should copy the "showConsoleCallLocation" value', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			file: '/home/user/project/index.html',
			showConsoleCallLocation: true
		});

		assert.equal(parsedConfiguration.showConsoleCallLocation, true);
	});

	it('should copy the "liftAccessorsFromPrototypes" value', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			file: '/home/user/project/index.html',
			liftAccessorsFromPrototypes: 1
		});

		assert.equal(parsedConfiguration.liftAccessorsFromPrototypes, 1);
	});

	it('should copy the "suggestPathMappingWizard" value', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			file: '/home/user/project/index.html',
			suggestPathMappingWizard: false
		});

		assert.equal(parsedConfiguration.suggestPathMappingWizard, false);
	});

	it('should not allow both "profile" and "profileDir" to be specified', async function() {
		await assertPromiseRejects(parseConfiguration(<any>{
			request: 'launch',
			file: '/home/user/project/index.html',
			profile: 'default',
			profileDir: '/home/user/firefoxProfile'
		}), 'You can set either "profile" or "profileDir", but not both');
	});

	it('should not allow "keepProfileChanges" if neither "profile" nor "profileDir" is set', async function() {
		await assertPromiseRejects(parseConfiguration(<any>{
			request: 'launch',
			file: '/home/user/project/index.html',
			keepProfileChanges: true,
		}), 'To enable "keepProfileChanges" you need to set either "profile" or "profileDir"');
	});

	for (let keepProfileChanges of [ undefined, false ]) {
		it(`should copy "profileDir" to "srcProfileDir" if "keepProfileChanges" is ${keepProfileChanges}`, async function() {

			let profileDir = '/home/user/project/ff-profile';
			let parsedConfiguration = await parseConfiguration({
				request: 'launch',
				file: '/home/user/project/index.html',
				profileDir,
				keepProfileChanges
			});

			assert.equal(parsedConfiguration.launch!.srcProfileDir, profileDir);
			assert.ok(parsedConfiguration.launch!.profileDir);
			assert.notEqual(parsedConfiguration.launch!.profileDir, profileDir);
		});
	}

	it('should copy "profileDir" to "profileDir" if "keepProfileChanges" is true', async function() {

		let profileDir = '/home/user/project/ff-profile';
		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			file: '/home/user/project/index.html',
			profileDir,
			keepProfileChanges: true
		});

		assert.equal(parsedConfiguration.launch!.profileDir, profileDir);
		assert.equal(parsedConfiguration.launch!.srcProfileDir, undefined);
	});

	it('should parse user-specified Firefox preferences', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			file: '/home/user/project/index.html',
			preferences: {
				'my.boolean': true,
				'my.number': 17,
				'my.string': 'foo',
				'devtools.debugger.remote-enabled': null
			}
		});
		let parsedPreferences = parsedConfiguration.launch!.preferences;

		assert.equal(parsedPreferences['my.boolean'], true);
		assert.equal(parsedPreferences['my.number'], 17);
		assert.equal(parsedPreferences['my.string'], 'foo');
		assert.equal(parsedPreferences['devtools.debugger.remote-enabled'], undefined);
	});

	it('should copy "port" from a launch configuration', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			file: '/home/user/project/index.html',
			reAttach: true,
			port: 7000
		});

		assert.equal(parsedConfiguration.attach!.port, 7000);
		assert.equal(parsedConfiguration.launch!.port, 7000);
		assert.ok(parsedConfiguration.launch!.firefoxArgs.indexOf('6000') < 0);
		assert.ok(parsedConfiguration.launch!.firefoxArgs.indexOf('7000') >= 0);
	});

	it('should copy "timeout" from a launch configuration', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			file: '/home/user/project/index.html',
			timeout: 10
		});

		assert.equal(parsedConfiguration.launch!.timeout, 10);
	});

	it('should add user-specified "firefoxArgs"', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			file: '/home/user/project/index.html',
			firefoxArgs: [ '-private' ]
		});

		assert.ok(parsedConfiguration.launch!.firefoxArgs.indexOf('-private') >= 0);
	});

	it('should allow installing WebExtensions that don\'t specify an ID in their manifest', async function() {
		await parseConfiguration(<any>{
			request: 'launch',
			addonPath: path.join(__dirname, '../../testdata/webExtension2/addOn')
		});
	});

	it('should add pathMappings for WebExtension debugging', async function() {

		let addonPath = path.join(__dirname, '../../testdata/webExtension/addOn');
		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			addonPath
		});

		assert.equal(parsedConfiguration.pathMappings.find(
			(pathMapping) => (typeof pathMapping.url === 'object') &&
			(pathMapping.url.source === '^moz-extension:\\/\\/[0-9a-f-]*(\\/.*)$'))!.path,
			addonPath);
		assert.equal(parsedConfiguration.pathMappings.find(
			(pathMapping) => (typeof pathMapping.url === 'object') &&
			(pathMapping.url.source === '^jar:file:.*\\/extensions\\/%7B12345678-1234-1234-1234-123456781234%7D.xpi!(\\/.*)$'))!.path,
			addonPath);
	});

	it('should default to "about:blank" as the start page for addon debugging', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			addonPath: path.join(__dirname, '../../testdata/webExtension/addOn')
		});

		assert.equal([...parsedConfiguration.launch!.firefoxArgs].pop(), 'about:blank');
	});

	it('should allow setting "file" to define the start page for addon debugging', async function() {

		let filePath: string;
		let fileUrl: string;
		if (isWindowsPlatform()) {
			filePath = 'c:\\Users\\user\\project\\index.html';
			fileUrl = 'file:///c:/Users/user/project/index.html';
		} else {
			filePath = '/home/user/project/index.html';
			fileUrl = 'file:///home/user/project/index.html';
		}
		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			file: filePath,
			addonPath: path.join(__dirname, '../../testdata/webExtension/addOn')
		});

		assert.equal([...parsedConfiguration.launch!.firefoxArgs].pop(), fileUrl);
	});

	it('should allow setting "url" to define the start page for addon debugging', async function() {

		let parsedConfiguration = await parseConfiguration({
			request: 'launch',
			url: 'https://mozilla.org',
			webRoot: '/home/user/project',
			addonPath: path.join(__dirname, '../../testdata/webExtension/addOn')
		});

		assert.equal([...parsedConfiguration.launch!.firefoxArgs].pop(), 'https://mozilla.org');
	});
});

async function assertPromiseRejects(promise: Promise<any>, reason: string): Promise<void> {
	try {
		await promise;
	} catch(err) {
		assert.equal(err, reason);
		return;
	}
	throw new Error('The promise was resolved but should have been rejected');
}
