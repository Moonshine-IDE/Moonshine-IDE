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
const http_server_1 = require("http-server");
const testSetup = require("./testSetup");
suite('Stepping', () => {
    const DATA_ROOT = testSetup.DATA_ROOT;
    let dc;
    setup(function () {
        return testSetup.setup(this)
            .then(_dc => dc = _dc);
    });
    let server;
    teardown(() => __awaiter(this, void 0, void 0, function* () {
        if (server) {
            server.close(err => console.log('Error closing server in teardown: ' + (err && err.message)));
            server = null;
        }
        yield testSetup.teardown();
    }));
    suite.skip('skipFiles', () => {
        test('when generated script is skipped via regex, the source can be un-skipped', () => __awaiter(this, void 0, void 0, function* () {
            const testProjectRoot = path.join(DATA_ROOT, 'calls-between-merged-files');
            const sourceA = path.join(testProjectRoot, 'sourceA.ts');
            const sourceB2 = path.join(testProjectRoot, 'sourceB2.ts');
            server = http_server_1.createServer({ root: testProjectRoot });
            server.listen(7890);
            const url = 'http://localhost:7890/index.html';
            // Skip the full B generated script via launch config
            const bpLineA = 6;
            const skipFiles = ['b.js'];
            yield dc.hitBreakpointUnverified({ url, skipFiles, webRoot: testProjectRoot }, { path: sourceA, line: bpLineA });
            // Step in, verify B sources are skipped
            yield dc.stepInRequest();
            yield dc.assertStoppedLocation('step', { path: sourceA, line: 2 });
            yield dc.send('toggleSkipFileStatus', { path: sourceB2 });
            // Continue back to sourceA, step in, should skip B1 and land on B2
            yield dc.continueRequest();
            yield dc.assertStoppedLocation('breakpoint', { path: sourceA, line: bpLineA });
            yield dc.stepInRequest();
            yield dc.assertStoppedLocation('step', { path: sourceB2, line: 2 });
        }));
        test('when a non-sourcemapped script is skipped via regex, it can be unskipped', () => __awaiter(this, void 0, void 0, function* () {
            // Using this program, but run with sourcemaps disabled
            const testProjectRoot = path.join(DATA_ROOT, 'calls-between-sourcemapped-files');
            const sourceA = path.join(testProjectRoot, 'out/sourceA.js');
            const sourceB = path.join(testProjectRoot, 'out/sourceB.js');
            server = http_server_1.createServer({ root: testProjectRoot });
            server.listen(7890);
            const url = 'http://localhost:7890/index.html';
            // Skip the full B generated script via launch config
            const skipFiles = ['sourceB.js'];
            const bpLineA = 5;
            yield dc.hitBreakpointUnverified({ url, sourceMaps: false, skipFiles, webRoot: testProjectRoot }, { path: sourceA, line: bpLineA });
            // Step in, verify B sources are skipped
            yield dc.stepInRequest();
            yield dc.assertStoppedLocation('step', { path: sourceA, line: 2 });
            yield dc.send('toggleSkipFileStatus', { path: sourceB });
            // Continue back to A, step in, should land in B
            yield dc.continueRequest();
            yield dc.assertStoppedLocation('breakpoint', { path: sourceA, line: bpLineA });
            yield dc.stepInRequest();
            yield dc.assertStoppedLocation('step', { path: sourceB, line: 2 });
        }));
        test('skip statuses for sourcemapped files are persisted across page reload', () => __awaiter(this, void 0, void 0, function* () {
            const testProjectRoot = path.join(DATA_ROOT, 'calls-between-merged-files');
            const sourceA = path.join(testProjectRoot, 'sourceA.ts');
            const sourceB2 = path.join(testProjectRoot, 'sourceB2.ts');
            server = http_server_1.createServer({ root: testProjectRoot });
            server.listen(7890);
            const url = 'http://localhost:7890/index.html';
            // Skip the full B generated script via launch config
            const bpLineA = 6;
            const skipFiles = ['b.js'];
            yield dc.hitBreakpointUnverified({ url, skipFiles, webRoot: testProjectRoot }, { path: sourceA, line: bpLineA });
            yield Promise.all([
                dc.stepInRequest(),
                dc.waitForEvent('stopped')
            ]);
            // Un-skip b2 and refresh the page
            yield Promise.all([
                // Wait for extra pause event sent after toggling skip status
                dc.waitForEvent('stopped'),
                dc.send('toggleSkipFileStatus', { path: sourceB2 })
            ]);
            yield Promise.all([
                dc.send('restart'),
                dc.assertStoppedLocation('breakpoint', { path: sourceA, line: bpLineA })
            ]);
            // Persisted bp should be hit. Step in, and assert we stepped through B1 into B2
            yield Promise.all([
                dc.stepInRequest(),
                dc.assertStoppedLocation('step', { path: sourceB2, line: 2 })
            ]);
        }));
    });
});

//# sourceMappingURL=stepping.test.js.map
