"use strict";
/*---------------------------------------------------------
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *--------------------------------------------------------*/
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const assert = require("assert");
const mockery = require("mockery");
const typemoq_1 = require("typemoq");
const vscode_chrome_debug_core_1 = require("vscode-chrome-debug-core");
const debugProtocolMocks_1 = require("./debugProtocolMocks");
const testUtils = require("./testUtils");
const chromeProvidedPortConnection_1 = require("../src/chromeProvidedPortConnection");
class MockChromeDebugSession {
    sendEvent(event) {
    }
    sendRequest(command, args, timeout, cb) {
    }
}
const MODULE_UNDER_TEST = '../src/chromeDebugAdapter';
suite('ChromeDebugAdapter', () => {
    let mockChromeConnection;
    let mockEventEmitter;
    let mockChrome;
    let mockChromeDebugSession;
    let chromeDebugAdapter;
    setup(() => {
        testUtils.setupUnhandledRejectionListener();
        testUtils.registerLocMocks();
        mockery.enable({ useCleanCache: true, warnOnReplace: false, warnOnUnregistered: false });
        // Create a ChromeConnection mock with .on and .attach. Tests can fire events via mockEventEmitter
        mockChromeConnection = typemoq_1.Mock.ofType(chromeProvidedPortConnection_1.ChromeProvidedPortConnection, typemoq_1.MockBehavior.Strict);
        mockChrome = debugProtocolMocks_1.getMockChromeConnectionApi();
        mockEventEmitter = mockChrome.mockEventEmitter;
        mockChromeDebugSession = typemoq_1.Mock.ofType(MockChromeDebugSession, typemoq_1.MockBehavior.Strict);
        mockChromeDebugSession
            .setup(x => x.sendEvent(typemoq_1.It.isAny()))
            .verifiable(typemoq_1.Times.atLeast(0));
        mockChromeDebugSession
            .setup(x => x.sendRequest(typemoq_1.It.isAnyString(), typemoq_1.It.isAny(), typemoq_1.It.isAnyNumber(), typemoq_1.It.isAny()))
            .verifiable(typemoq_1.Times.atLeast(0));
        mockChromeConnection
            .setup(x => x.setTargetFilter(typemoq_1.It.isAny()))
            .verifiable(typemoq_1.Times.atLeast(0));
        mockChromeConnection
            .setup(x => x.api)
            .returns(() => mockChrome.apiObjects)
            .verifiable(typemoq_1.Times.atLeast(0));
        mockChromeConnection
            .setup(x => x.attach(typemoq_1.It.isValue(undefined), typemoq_1.It.isAnyNumber(), typemoq_1.It.isValue(undefined)))
            .returns(() => Promise.resolve())
            .verifiable(typemoq_1.Times.atLeast(0));
        mockChromeConnection
            .setup(x => x.isAttached)
            .returns(() => false)
            .verifiable(typemoq_1.Times.atLeast(0));
        mockChromeConnection
            .setup(x => x.run())
            .returns(() => Promise.resolve())
            .verifiable(typemoq_1.Times.atLeast(0));
        mockChromeConnection
            .setup(x => x.onClose(typemoq_1.It.isAny()))
            .verifiable(typemoq_1.Times.atLeast(0));
        mockChromeConnection
            .setup(x => x.events)
            .returns(x => null)
            .verifiable(typemoq_1.Times.atLeast(0));
        mockChromeConnection
            .setup(x => x.version)
            .returns(() => Promise.resolve(new vscode_chrome_debug_core_1.TargetVersions(vscode_chrome_debug_core_1.Version.unknownVersion(), vscode_chrome_debug_core_1.Version.unknownVersion())))
            .verifiable(typemoq_1.Times.atLeast(0));
        mockChromeConnection
            .setup(x => x.setUserDataDir(typemoq_1.It.isAnyString()))
            .verifiable(typemoq_1.Times.atLeast(0));
        // Instantiate the ChromeDebugAdapter, injecting the mock ChromeConnection
        const cDAClass = require(MODULE_UNDER_TEST).ChromeDebugAdapter;
        chromeDebugAdapter = new cDAClass({ chromeConnection: function () { return mockChromeConnection.object; } }, mockChromeDebugSession.object);
    });
    teardown(() => {
        testUtils.removeUnhandledRejectionListener();
        mockery.deregisterAll();
        mockery.disable();
        mockChromeConnection.verifyAll();
    });
    suite('launch()', () => {
        let originalFork;
        let originalSpawn;
        let originalStatSync;
        setup(() => {
            mockChromeConnection
                .setup(x => x.attach(typemoq_1.It.isValue(undefined), typemoq_1.It.isAnyNumber(), typemoq_1.It.isAnyString(), typemoq_1.It.isValue(undefined), typemoq_1.It.isValue(undefined)))
                .returns(() => Promise.resolve())
                .verifiable();
            mockChrome.Runtime
                .setup(x => x.evaluate(typemoq_1.It.isAny()))
                .returns(() => Promise.resolve({ result: { type: 'string', value: '123' } }));
            mockChrome.Network
                .setup(x => x.setCacheDisabled(typemoq_1.It.isAny()))
                .returns(() => Promise.resolve());
        });
        teardown(() => {
            // Hacky mock cleanup
            require('child_process').fork = originalFork;
            require('fs').statSync = originalStatSync;
        });
        test('launches with minimal correct args', () => {
            let spawnCalled = false;
            function fork(chromeSpawnHelperPath, [chromePath, ...args]) {
                // Just assert that the chrome path is some string with 'chrome' in the path, and there are >0 args
                assert(chromeSpawnHelperPath.indexOf('chromeSpawnHelper.js') >= 0);
                return spawn(chromePath, args);
            }
            function spawn(chromePath, args) {
                assert(chromePath.toLowerCase().indexOf('chrome') >= 0);
                assert(args.indexOf('--remote-debugging-port=9222') >= 0);
                assert(args.indexOf('about:blank') >= 0); // Now we use the landing page for all scenarios
                assert(args.indexOf('abc') >= 0);
                assert(args.indexOf('def') >= 0);
                spawnCalled = true;
                const stdio = { on: () => { } };
                return { on: () => { }, unref: () => { }, stdout: stdio, stderr: stdio };
            }
            // Mock fork/spawn for chrome process, and 'fs' for finding chrome.exe.
            // These are mocked as empty above - note that it's too late for mockery here.
            originalFork = require('child_process').fork;
            originalSpawn = require('child_process').spawn;
            require('child_process').fork = fork;
            require('child_process').spawn = spawn;
            originalStatSync = require('fs').statSync;
            require('fs').statSync = () => true;
            return chromeDebugAdapter.launch({ file: 'c:\\path with space\\index.html', runtimeArgs: ['abc', 'def'] }, new vscode_chrome_debug_core_1.telemetry.TelemetryPropertyCollector())
                .then(() => assert(spawnCalled));
        });
        test('launches unelevated with client', () => __awaiter(this, void 0, void 0, function* () {
            let telemetryPropertyCollector = new vscode_chrome_debug_core_1.telemetry.TelemetryPropertyCollector();
            chromeDebugAdapter.initialize({
                adapterID: 'test debug adapter',
                pathFormat: 'path',
                supportsLaunchUnelevatedProcessRequest: true
            });
            const originalGetPlatform = require('os').platform;
            require('os').platform = () => { return 'win32'; };
            const originalGetBrowser = require('../src/utils').getBrowserPath;
            require('../src/utils').getBrowserPath = () => { return 'c:\\someplace\\chrome.exe'; };
            const expectedProcessId = 325;
            let collectedLaunchParams;
            mockChromeDebugSession
                .setup(x => x.sendRequest('launchUnelevated', typemoq_1.It.is((param) => {
                collectedLaunchParams = param;
                return true;
            }), 10000, typemoq_1.It.is((callback) => {
                callback({
                    seq: null,
                    type: 'command',
                    request_seq: 100,
                    command: 'launchUnelevated',
                    success: true,
                    body: {
                        processId: expectedProcessId
                    }
                });
                return true;
            })))
                .verifiable(typemoq_1.Times.atLeast(1));
            yield chromeDebugAdapter.launch({
                file: 'c:\\path with space\\index.html',
                runtimeArgs: ['abc', 'def'],
                shouldLaunchChromeUnelevated: true
            }, telemetryPropertyCollector);
            assert.equal(expectedProcessId, chromeDebugAdapter._chromePID, 'Debug Adapter should receive the Chrome process id');
            assert(collectedLaunchParams.process != null);
            assert(collectedLaunchParams.process.match(/chrome/i));
            assert(collectedLaunchParams.args != null);
            assert(collectedLaunchParams.args.filter(arg => arg === '--no-default-browser-check').length !== 0, 'Should have seen the --no-default-browser-check parameter');
            assert(collectedLaunchParams.args.filter(arg => arg === '--no-first-run').length !== 0, 'Should have seen the --no-first-run parameter');
            assert(collectedLaunchParams.args.filter(arg => arg === 'abc').length !== 0, 'Should have seen the abc parameter');
            assert(collectedLaunchParams.args.filter(arg => arg === 'def').length !== 0, 'Should have seen the def parameter');
            assert(collectedLaunchParams.args.filter(arg => arg === 'about:blank').length !== 0, 'Should have seen the about:blank parameter');
            assert(collectedLaunchParams.args.filter(arg => arg.match(/remote-debugging-port/)).length !== 0, 'Should have seen a parameter like remote-debugging-port');
            assert(collectedLaunchParams.args.filter(arg => arg.match(/user-data-dir/)).length !== 0, 'Should have seen a parameter like user-data-dir');
            const telemetryProperties = telemetryPropertyCollector.getProperties();
            assert.equal(telemetryProperties.shouldLaunchChromeUnelevated, 'true', "Should send telemetry that Chrome is requested to be launched unelevated.'");
            assert.equal(telemetryProperties.doesHostSupportLaunchUnelevated, 'true', "Should send telemetry that host supports launcheing Chrome unelevated.'");
            require('os').platform = originalGetPlatform;
            require('../src/utils').getBrowserPath = originalGetBrowser;
        }));
    });
    suite('resolveWebRootPattern', () => {
        const WEBROOT = testUtils.pathResolve('/project/webroot');
        const resolveWebRootPattern = require(MODULE_UNDER_TEST).resolveWebRootPattern;
        test('does nothing when no ${webRoot} present', () => {
            const overrides = { '/src': '/project' };
            assert.deepEqual(resolveWebRootPattern(WEBROOT, overrides), overrides);
        });
        test('resolves the webRoot pattern', () => {
            assert.deepEqual(resolveWebRootPattern(WEBROOT, { '/src': '${webRoot}/app/src' }), { '/src': WEBROOT + '/app/src' });
            assert.deepEqual(resolveWebRootPattern(WEBROOT, { '${webRoot}/src': '${webRoot}/app/src' }), { [WEBROOT + '/src']: WEBROOT + '/app/src' });
        });
        test(`ignores the webRoot pattern when it's not at the beginning of the string`, () => {
            const overrides = { '/another/${webRoot}/src': '/app/${webRoot}/src' };
            assert.deepEqual(resolveWebRootPattern(WEBROOT, overrides), overrides);
        });
        test('works on a set of overrides', () => {
            const overrides = {
                '/src*': '${webRoot}/app',
                '*/app.js': '*/app.js',
                '/src/app.js': '/src/${webRoot}',
                '/app.js': '${webRoot}/app.js',
                '${webRoot}/app1.js': '${webRoot}/app.js'
            };
            const expOverrides = {
                '/src*': WEBROOT + '/app',
                '*/app.js': '*/app.js',
                '/src/app.js': '/src/${webRoot}',
                '/app.js': WEBROOT + '/app.js',
                [WEBROOT + '/app1.js']: WEBROOT + '/app.js'
            };
            assert.deepEqual(resolveWebRootPattern(WEBROOT, overrides), expOverrides);
        });
    });
});

//# sourceMappingURL=chromeDebugAdapter.test.js.map
