"use strict";
/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/
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
const path = require("path");
const http_server_1 = require("http-server");
const testSetup = require("./testSetup");
const testSetup_1 = require("./testSetup");
const puppeteer = require("puppeteer");
const chai_1 = require("chai");
const testUtils_1 = require("../testUtils");
const vscode_chrome_debug_core_1 = require("vscode-chrome-debug-core");
const logging_1 = require("./utils/logging");
const DATA_ROOT = testSetup.DATA_ROOT;
suite('Chrome Debug Adapter etc', () => {
    let dc;
    let server;
    setup(function () {
        return testSetup.setup(this)
            .then(_dc => dc = _dc);
    });
    teardown(() => {
        return testSetup.teardown();
    });
    suite('basic', () => {
        test('unknown request should produce error', done => {
            dc.send('illegal_request').then(() => {
                done(new Error('does not report error on unknown request'));
            }).catch(() => {
                done();
            });
        });
    });
    suite('initialize', () => {
        test('should return supported features', () => {
            return dc.initializeRequest().then(response => {
                assert.notEqual(response.body, undefined);
                assert.equal(response.body.supportsConfigurationDoneRequest, true);
            });
        });
    });
    suite('launch', () => {
        const testProjectRoot = path.join(DATA_ROOT, 'intervalDebugger');
        setup(() => {
            server = http_server_1.createServer({ root: testProjectRoot });
            server.listen(7890);
        });
        teardown(() => {
            if (server) {
                server.close(err => console.log('Error closing server in teardown: ' + (err && err.message)));
                server = null;
            }
        });
        /**
         * On MacOS it fails because: stopped location: path mismatch‌:
         *   ‌+ expected‌: ‌/users/vsts/agent/2.150.0/work/1/s/testdata/intervaldebugger/out/app.js‌
         *   - actual‌:    users/vsts/agent/2.150.0/work/1/s/testdata/intervaldebugger/out/app.js‌
         */
        (testSetup_1.isWindows ? test : test.skip)('should stop on debugger statement in file:///, sourcemaps disabled', () => {
            const launchFile = path.join(testProjectRoot, 'index.html');
            const breakFile = path.join(testProjectRoot, 'out/app.js');
            const DEBUGGER_LINE = 2;
            return Promise.all([
                dc.configurationSequence(),
                dc.launch({ file: launchFile, sourceMaps: false }),
                dc.assertStoppedLocation('debugger_statement', { path: breakFile, line: DEBUGGER_LINE })
            ]);
        });
        test('should stop on debugger statement in http://localhost', () => {
            const breakFile = path.join(testProjectRoot, 'src/app.ts');
            const DEBUGGER_LINE = 2;
            return Promise.all([
                dc.configurationSequence(),
                dc.launch({ url: 'http://localhost:7890', webRoot: testProjectRoot }),
                dc.assertStoppedLocation('debugger_statement', { path: breakFile, line: DEBUGGER_LINE })
            ]);
        });
        const testTitle = 'Should attach to existing instance of chrome and break on debugger statement';
        test(testTitle, () => __awaiter(this, void 0, void 0, function* () {
            const fullTestTitle = `Chrome Debug Adapter etc launch ${testTitle}`;
            const breakFile = path.join(testProjectRoot, 'src/app.ts');
            const DEBUGGER_LINE = 2;
            const remoteDebuggingPort = 7777;
            const browser = yield puppeteer.launch({ headless: false, args: ['http://localhost:7890', `--remote-debugging-port=${remoteDebuggingPort}`] });
            try {
                yield Promise.all([
                    dc.configurationSequence(),
                    dc.initializeRequest().then(_ => {
                        return dc.attachRequest({
                            url: 'http://localhost:7890', port: remoteDebuggingPort, webRoot: testProjectRoot,
                            logFilePath: logging_1.getDebugAdapterLogFilePath(fullTestTitle), logTimestamps: true
                        });
                    }),
                    dc.assertStoppedLocation('debugger_statement', { path: breakFile, line: DEBUGGER_LINE })
                ]);
            }
            finally {
                yield browser.close();
            }
        }));
        test('Should hit breakpoint even if webRoot has unexpected case all lowercase for VisualStudio', () => __awaiter(this, void 0, void 0, function* () {
            const breakFile = path.join(testProjectRoot, 'src/app.ts');
            const DEBUGGER_LINE = 2;
            yield dc.initializeRequest({
                adapterID: 'chrome',
                clientID: 'visualstudio',
                linesStartAt1: true,
                columnsStartAt1: true,
                pathFormat: 'path'
            });
            yield dc.launchRequest({ url: 'http://localhost:7890', webRoot: testProjectRoot.toLowerCase(), runtimeExecutable: puppeteer.executablePath() });
            yield dc.setBreakpointsRequest({ source: { path: breakFile }, breakpoints: [{ line: DEBUGGER_LINE }] });
            yield dc.configurationDoneRequest();
            yield dc.assertStoppedLocation('debugger_statement', { path: breakFile, line: DEBUGGER_LINE });
        }));
        test('Should hit breakpoint even if webRoot has unexpected case all uppercase for VisualStudio', () => __awaiter(this, void 0, void 0, function* () {
            const breakFile = path.join(testProjectRoot, 'src/app.ts');
            const DEBUGGER_LINE = 2;
            yield dc.initializeRequest({
                adapterID: 'chrome',
                clientID: 'visualstudio',
                linesStartAt1: true,
                columnsStartAt1: true,
                pathFormat: 'path'
            });
            yield dc.launchRequest({ url: 'http://localhost:7890', webRoot: testProjectRoot.toUpperCase(), runtimeExecutable: puppeteer.executablePath() });
            yield dc.setBreakpointsRequest({ source: { path: breakFile }, breakpoints: [{ line: DEBUGGER_LINE }] });
            yield dc.configurationDoneRequest();
            yield dc.assertStoppedLocation('debugger_statement', { path: breakFile, line: DEBUGGER_LINE });
        }));
        /**
         * This test is baselining behvaior from V1 around what happens when the adapter tries to launch when
         * there is another running instance of chrome with --remote-debugging-port set to the same port the adapter is trying to use.
         * We expect the debug adapter to throw an exception saying that the connection attempt timed out after N milliseconds.
         * TODO: We don't think is is ideal behavior for the adapter, and want to change it fairly quickly after V2 is ready to launch.
         *   right now this test exists only to verify that we match the behavior of V1
         */
        test('Should throw error when launching if chrome debug port is in use', () => __awaiter(this, void 0, void 0, function* () {
            // browser already launched to the default port, and navigated away from about:blank
            const remoteDebuggingPort = 9222;
            const browser = yield puppeteer.launch({ headless: false, args: ['http://localhost:7890', `--remote-debugging-port=${remoteDebuggingPort}`] });
            try {
                yield Promise.all([
                    dc.configurationSequence(),
                    dc.launch({ url: 'http://localhost:7890', timeout: 2000, webRoot: testProjectRoot, port: remoteDebuggingPort }),
                ]);
                assert.fail('Expected launch to throw a timeout exception, but it didn\'t.');
            }
            catch (err) {
                chai_1.expect(err.message).to.satisfy((x) => x.startsWith('Cannot connect to runtime process, timeout after 2000 ms'));
            }
            finally {
                yield browser.close();
            }
            // force kill chrome here, as it will be left open by the debug adapter (same behavior as v1)
            testUtils_1.killAllChrome();
        }));
        test('Should launch successfully on port 0', () => __awaiter(this, void 0, void 0, function* () {
            // browser already launched to the default port, and navigated away from about:blank
            const remoteDebuggingPort = 0;
            yield Promise.all([
                dc.configurationSequence(),
                dc.launch({ url: 'http://localhost:7890', timeout: 5000, webRoot: testProjectRoot, port: remoteDebuggingPort }),
            ]);
            // wait for url to === http://localhost:7890 (launch response can come back before the navigation completes)
            return waitForUrl(dc, 'http://localhost:7890/');
        }));
        test('Should launch successfully on port 0, even when a browser instance is already running', () => __awaiter(this, void 0, void 0, function* () {
            // browser already launched to the default port, and navigated away from about:blank
            const remoteDebuggingPort = 0;
            const dataDir = path.join(__dirname, 'testDataDir');
            const browser = yield puppeteer.launch({ headless: false, args: ['https://bing.com', `--user-data-dir=${dataDir}`, `--remote-debugging-port=${remoteDebuggingPort}`] });
            try {
                yield Promise.all([
                    dc.configurationSequence(),
                    dc.launch({ url: 'http://localhost:7890', timeout: 5000, webRoot: testProjectRoot, port: remoteDebuggingPort, userDataDir: dataDir }),
                ]);
                yield waitForUrl(dc, 'http://localhost:7890/');
            }
            finally {
                yield browser.close();
            }
        }));
    });
});
function waitForUrl(dc, url) {
    return __awaiter(this, void 0, void 0, function* () {
        const timeoutMs = 5000;
        const intervalDelayMs = 50;
        return yield vscode_chrome_debug_core_1.utils.retryAsync(() => __awaiter(this, void 0, void 0, function* () {
            const response = yield dc.evaluateRequest({
                context: 'repl',
                expression: 'window.location.href'
            });
            chai_1.expect(response.body.result).to.equal(`"${url}"`);
            return url;
        }), timeoutMs, intervalDelayMs).catch(err => { throw err; });
    });
}

//# sourceMappingURL=adapter.test.js.map
