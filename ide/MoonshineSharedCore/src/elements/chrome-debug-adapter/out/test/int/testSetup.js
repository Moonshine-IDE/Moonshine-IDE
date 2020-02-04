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
const path = require("path");
const tmp = require("tmp");
const puppeteer = require("puppeteer");
const _ = require("lodash");
const ts = require("vscode-chrome-debug-core-testsupport");
const logging_1 = require("./utils/logging");
const testUtils_1 = require("../testUtils");
const waitUntilReadyWithTimeout_1 = require("./utils/waitUntilReadyWithTimeout");
const DEBUG_ADAPTER = './out/src/chromeDebug.js';
let testLaunchProps; /* TODO: investigate why launch config types differ between V1 and V2 */
exports.isThisV2 = false;
exports.isThisV1 = !exports.isThisV2;
exports.isWindows = process.platform === 'win32';
// Note: marking launch args as any to avoid conflicts between v1 vs v2 launch arg types
/* TODO: investigate why launch config types differ between V1 and V2 */
function formLaunchArgs(launchArgs, testTitle) {
    launchArgs.trace = 'verbose';
    launchArgs.logTimestamps = true;
    launchArgs.disableNetworkCache = true;
    launchArgs.logFilePath = logging_1.getDebugAdapterLogFilePath(testTitle);
    if (!launchArgs.runtimeExecutable) {
        launchArgs.runtimeExecutable = puppeteer.executablePath();
    }
    const hideWindows = process.env['TEST_DA_HIDE_WINDOWS'] === 'true';
    if (hideWindows) {
        launchArgs.runtimeArgs = ['--headless', '--disable-gpu'];
    }
    // Start with a clean userDataDir for each test run (but only if not specified by the test)
    if (!launchArgs.userDataDir) {
        const tmpDir = tmp.dirSync({ prefix: 'chrome2-' });
        launchArgs.userDataDir = tmpDir.name;
    }
    if (testLaunchProps) {
        for (let key in testLaunchProps) {
            launchArgs[key] = testLaunchProps[key];
        }
        testLaunchProps = undefined;
    }
}
function patchLaunchArgs(launchArgs, testTitle) {
    formLaunchArgs(launchArgs, testTitle);
}
exports.lowercaseDriveLetterDirname = __dirname.charAt(0).toLowerCase() + __dirname.substr(1);
exports.PROJECT_ROOT = path.join(exports.lowercaseDriveLetterDirname, '../../../');
exports.DATA_ROOT = path.join(exports.PROJECT_ROOT, 'testdata/');
/** Default setup for all our tests, using the context of the setup method
 *    - Best practise: The new best practise is to use the DefaultFixture when possible instead of calling this method directly
 */
function setup(context, port, launchProps) {
    return __awaiter(this, void 0, void 0, function* () {
        const currentTest = _.defaultTo(context.currentTest, context.test);
        return setupWithTitle(currentTest.fullTitle(), port, launchProps);
    });
}
exports.setup = setup;
/** Default setup for all our tests, using the test title
 *    - Best practise: The new best practise is to use the DefaultFixture when possible instead of calling this method directly
 */
function setupWithTitle(testTitle, port, launchProps) {
    return __awaiter(this, void 0, void 0, function* () {
        // killAllChromesOnWin32(); // Kill chrome.exe instances before the tests. Killing them after the tests is not as reliable. If setup fails, teardown is not executed.
        logging_1.setTestLogName(testTitle);
        if (!port) {
            const daPort = process.env['TEST_DA_PORT'];
            port = daPort
                ? parseInt(daPort, 10)
                : undefined;
        }
        if (launchProps) {
            testLaunchProps = launchProps;
        }
        const debugClient = yield ts.setup({ entryPoint: DEBUG_ADAPTER, type: 'chrome', patchLaunchArgs: args => patchLaunchArgs(args, testTitle), port: port });
        debugClient.defaultTimeout = waitUntilReadyWithTimeout_1.DefaultTimeoutMultiplier * 10000 /*10 seconds*/;
        if (exports.isThisV2) { // The logging proxy breaks lots of tests in v1, possibly due to some race conditions exposed by the extra delay
            const wrappedDebugClient = logging_1.logCallsTo(debugClient, 'DebugAdapterClient');
            return wrappedDebugClient;
        }
        return debugClient;
    });
}
exports.setupWithTitle = setupWithTitle;
function teardown() {
    return __awaiter(this, void 0, void 0, function* () {
        yield ts.teardown();
    });
}
exports.teardown = teardown;
function killAllChromesOnWin32() {
    if (process.platform === 'win32') {
        // We only need to kill the chrome.exe instances on the Windows agent
        // TODO: Figure out a way to remove this
        testUtils_1.killAllChrome();
    }
}
exports.killAllChromesOnWin32 = killAllChromesOnWin32;

//# sourceMappingURL=testSetup.js.map
