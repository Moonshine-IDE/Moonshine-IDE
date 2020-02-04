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
const EXPECTED_REASON = testSetup.isThisV1 ? 'debugger_statement' : 'breakpoint';
function runCommonTests(breakOnLoadStrategy) {
    const DATA_ROOT = testSetup.DATA_ROOT;
    let dc;
    setup(function () {
        return testSetup.setup(this, undefined, { breakOnLoadStrategy: breakOnLoadStrategy })
            .then(_dc => dc = _dc);
    });
    let server;
    teardown(() => {
        if (server) {
            server.close(err => console.log('Error closing server in teardown: ' + (err && err.message)));
            server = null;
        }
        return testSetup.teardown();
    });
    // this function is to help when launching and setting a breakpoint
    // currently, the chrome debug adapter, when launching in instrument mode and setting a breakpoint at (1, 1)
    // the breakpoint is not yet 'hit' so the reason is given as 'debugger_statement'
    // https://github.com/Microsoft/vscode-chrome-debug-core/blob/90797bc4a3599b0a7c0f197efe10ef7fab8442fd/src/chrome/chromeDebugAdapter.ts#L692
    // so we don't want to use hitBreakpointUnverified function because it specifically checks for 'breakpoint' as the reason
    function launchWithUrlAndSetBreakpoints(url, projectRoot, scriptPath, lineNum, colNum) {
        const waitForInitialized = dc.waitForEvent('initialized');
        return Promise.all([
            dc.launch({ url: url, webRoot: projectRoot }),
            waitForInitialized.then(_event => {
                return dc.setBreakpointsRequest({
                    lines: [lineNum],
                    breakpoints: [{ line: lineNum, column: colNum }],
                    source: { path: scriptPath }
                });
            }).then(_response => {
                return dc.configurationDoneRequest();
            })
        ]);
    }
    suite('TypeScript Project with SourceMaps', () => {
        test('Hits a single breakpoint in a file on load', () => __awaiter(this, void 0, void 0, function* () {
            const testProjectRoot = path.join(DATA_ROOT, 'breakOnLoad_sourceMaps');
            const scriptPath = path.join(testProjectRoot, 'src/script.ts');
            server = http_server_1.createServer({ root: testProjectRoot });
            server.listen(7890);
            const url = 'http://localhost:7890/index.html';
            const bpLine = 3;
            const bpCol = 12;
            yield dc.hitBreakpointUnverified({ url, webRoot: testProjectRoot }, { path: scriptPath, line: bpLine, column: bpCol });
        }));
        test('Hits multiple breakpoints in a file on load', () => __awaiter(this, void 0, void 0, function* () {
            const testProjectRoot = path.join(DATA_ROOT, 'breakOnLoad_sourceMaps');
            const scriptPath = path.join(testProjectRoot, 'src/script.ts');
            server = http_server_1.createServer({ root: testProjectRoot });
            server.listen(7890);
            const url = 'http://localhost:7890/index.html';
            const bp1Line = 3;
            const bp1Col = 12;
            const bp2Line = 6;
            yield dc.hitBreakpointUnverified({ url, webRoot: testProjectRoot }, { path: scriptPath, line: bp1Line, column: bp1Col });
            yield dc.setBreakpointsRequest({ source: { path: scriptPath }, breakpoints: [{ line: bp2Line }] });
            yield dc.continueTo('breakpoint', { line: bp2Line });
        }));
        test('Hits a breakpoint at (1,1) in a file on load', () => __awaiter(this, void 0, void 0, function* () {
            const testProjectRoot = path.join(DATA_ROOT, 'breakOnLoad_sourceMaps');
            const scriptPath = path.join(testProjectRoot, 'src/script.ts');
            server = http_server_1.createServer({ root: testProjectRoot });
            server.listen(7890);
            const url = 'http://localhost:7890/index.html';
            const bpLine = 1;
            const bpCol = 1;
            if (breakOnLoadStrategy === 'instrument') {
                yield launchWithUrlAndSetBreakpoints(url, testProjectRoot, scriptPath, bpLine, bpCol);
                yield dc.assertStoppedLocation(EXPECTED_REASON, { path: scriptPath, line: bpLine, column: bpCol });
            }
            else {
                yield dc.hitBreakpointUnverified({ url, webRoot: testProjectRoot }, { path: scriptPath, line: bpLine, column: bpCol });
            }
        }));
        test('Hits a breakpoint in the first line in a file on load', () => __awaiter(this, void 0, void 0, function* () {
            const testProjectRoot = path.join(DATA_ROOT, 'breakOnLoad_sourceMaps');
            const scriptPath = path.join(testProjectRoot, 'src/script.ts');
            server = http_server_1.createServer({ root: testProjectRoot });
            server.listen(7890);
            const url = 'http://localhost:7890/index.html';
            const bpLine = 1;
            const bpCol = 35;
            yield dc.hitBreakpointUnverified({ url, webRoot: testProjectRoot }, { path: scriptPath, line: bpLine, column: bpCol });
        }));
    });
    suite('Simple JavaScript Project', () => {
        test('Hits a single breakpoint in a file on load', () => __awaiter(this, void 0, void 0, function* () {
            const testProjectRoot = path.join(DATA_ROOT, 'breakOnLoad_javaScript');
            const scriptPath = path.join(testProjectRoot, 'src/script.js');
            server = http_server_1.createServer({ root: testProjectRoot });
            server.listen(7890);
            const url = 'http://localhost:7890/index.html';
            const bpLine = 3;
            const bpCol = 12;
            yield dc.hitBreakpointUnverified({ url, webRoot: testProjectRoot }, { path: scriptPath, line: bpLine, column: bpCol });
        }));
        test('Hits multiple breakpoints in a file on load', () => __awaiter(this, void 0, void 0, function* () {
            const testProjectRoot = path.join(DATA_ROOT, 'breakOnLoad_javaScript');
            const scriptPath = path.join(testProjectRoot, 'src/script.js');
            server = http_server_1.createServer({ root: testProjectRoot });
            server.listen(7890);
            const url = 'http://localhost:7890/index.html';
            const bp1Line = 3;
            const bp1Col = 12;
            const bp2Line = 6;
            yield dc.hitBreakpointUnverified({ url, webRoot: testProjectRoot }, { path: scriptPath, line: bp1Line, column: bp1Col });
            yield dc.setBreakpointsRequest({ source: { path: scriptPath }, breakpoints: [{ line: bp2Line }] });
            yield dc.continueTo('breakpoint', { line: bp2Line });
        }));
        test('Hits a breakpoint at (1,1) in a file on load', () => __awaiter(this, void 0, void 0, function* () {
            const testProjectRoot = path.join(DATA_ROOT, 'breakOnLoad_javaScript');
            const scriptPath = path.join(testProjectRoot, 'src/script.js');
            server = http_server_1.createServer({ root: testProjectRoot });
            server.listen(7890);
            const url = 'http://localhost:7890/index.html';
            const bpLine = 1;
            const bpCol = 1;
            if (breakOnLoadStrategy === 'instrument') {
                yield launchWithUrlAndSetBreakpoints(url, testProjectRoot, scriptPath, bpLine, bpCol);
                yield dc.assertStoppedLocation(EXPECTED_REASON, { path: scriptPath, line: bpLine, column: bpCol });
            }
            else {
                yield dc.hitBreakpointUnverified({ url, webRoot: testProjectRoot }, { path: scriptPath, line: bpLine, column: bpCol });
            }
        }));
        test('Hits a breakpoint in the first line in a file on load', () => __awaiter(this, void 0, void 0, function* () {
            const testProjectRoot = path.join(DATA_ROOT, 'breakOnLoad_javaScript');
            const scriptPath = path.join(testProjectRoot, 'src/script.js');
            server = http_server_1.createServer({ root: testProjectRoot });
            server.listen(7890);
            const url = 'http://localhost:7890/index.html';
            const bpLine = 1;
            const bpCol = 35;
            yield dc.hitBreakpointUnverified({ url, webRoot: testProjectRoot }, { path: scriptPath, line: bpLine, column: bpCol });
        }));
        test('Hits breakpoints on the first line of two scripts', () => __awaiter(this, void 0, void 0, function* () {
            const testProjectRoot = path.join(DATA_ROOT, 'breakOnLoad_javaScript');
            const scriptPath = path.join(testProjectRoot, 'src/script.js');
            const script2Path = path.join(testProjectRoot, 'src/script2.js');
            server = http_server_1.createServer({ root: testProjectRoot });
            server.listen(7890);
            const url = 'http://localhost:7890/index.html';
            const bpLine = 1;
            const bpCol = 1;
            if (breakOnLoadStrategy === 'instrument') {
                yield launchWithUrlAndSetBreakpoints(url, testProjectRoot, scriptPath, bpLine, bpCol);
                yield dc.assertStoppedLocation(EXPECTED_REASON, { path: scriptPath, line: bpLine, column: bpCol });
                yield dc.setBreakpointsRequest({
                    lines: [bpLine],
                    breakpoints: [{ line: bpLine, column: bpCol }],
                    source: { path: script2Path }
                });
                yield dc.continueRequest();
                yield dc.assertStoppedLocation(EXPECTED_REASON, { path: script2Path, line: bpLine, column: bpCol });
            }
            else {
                yield dc.hitBreakpointUnverified({ url, webRoot: testProjectRoot }, { path: scriptPath, line: bpLine, column: bpCol });
                yield dc.setBreakpointsRequest({
                    lines: [bpLine],
                    breakpoints: [{ line: bpLine, column: bpCol }],
                    source: { path: script2Path }
                });
                yield dc.continueRequest();
                yield dc.assertStoppedLocation('breakpoint', { path: script2Path, line: bpLine, column: bpCol });
            }
        }));
    });
}
suite('BreakOnLoad', () => {
    const DATA_ROOT = testSetup.DATA_ROOT;
    suite('Regex Common Tests', () => {
        runCommonTests('regex');
    });
    suite('Instrument Common Tests', () => {
        runCommonTests('instrument');
    });
    suite('Instrument Webpack Project', () => {
        let dc;
        setup(function () {
            return testSetup.setup(this, undefined, { breakOnLoadStrategy: 'instrument' })
                .then(_dc => dc = _dc);
        });
        let server;
        teardown(() => {
            if (server) {
                server.close();
                server = null;
            }
            return testSetup.teardown();
        });
        test('Hits a single breakpoint in a file on load', () => __awaiter(this, void 0, void 0, function* () {
            const testProjectRoot = path.join(DATA_ROOT, 'breakOnLoad_webpack');
            const scriptPath = path.join(testProjectRoot, 'src/script.js');
            server = http_server_1.createServer({ root: testProjectRoot });
            server.listen(7890);
            const url = 'http://localhost:7890/dist/index.html';
            const bpLine = 3;
            const bpCol = 1;
            yield dc.hitBreakpointUnverified({ url, webRoot: testProjectRoot }, { path: scriptPath, line: bpLine, column: bpCol });
        }));
        test('Hits multiple breakpoints in a file on load', () => __awaiter(this, void 0, void 0, function* () {
            const testProjectRoot = path.join(DATA_ROOT, 'breakOnLoad_webpack');
            const scriptPath = path.join(testProjectRoot, 'src/script.js');
            server = http_server_1.createServer({ root: testProjectRoot });
            server.listen(7890);
            const url = 'http://localhost:7890/dist/index.html';
            // For some reason, column numbers > don't work perfectly with webpack
            const bp1Line = 3;
            const bp1Col = 1;
            const bp2Line = 5;
            const bp2Col = 1;
            yield dc.hitBreakpointUnverified({ url, webRoot: testProjectRoot }, { path: scriptPath, line: bp1Line, column: bp1Col });
            yield dc.setBreakpointsRequest({ source: { path: scriptPath }, breakpoints: [{ line: bp2Line, column: bp2Col }] });
            yield dc.continueTo('breakpoint', { line: bp2Line, column: bp2Col });
        }));
        test('Hits a breakpoint at (1,1) in a file on load', () => __awaiter(this, void 0, void 0, function* () {
            const testProjectRoot = path.join(DATA_ROOT, 'breakOnLoad_webpack');
            const scriptPath = path.join(testProjectRoot, 'src/script.js');
            server = http_server_1.createServer({ root: testProjectRoot });
            server.listen(7890);
            const url = 'http://localhost:7890/dist/index.html';
            const bpLine = 1;
            const bpCol = 1;
            yield dc.hitBreakpointUnverified({ url, webRoot: testProjectRoot }, { path: scriptPath, line: bpLine, column: bpCol });
        }));
    });
    suite('BreakOnLoad Disabled (strategy: off)', () => {
        let dc;
        setup(function () {
            return testSetup.setup(this, undefined, { breakOnLoadStrategy: 'off' })
                .then(_dc => dc = _dc);
        });
        let server;
        teardown(() => {
            if (server) {
                server.close();
                server = null;
            }
            return testSetup.teardown();
        });
        test('Does not hit a breakpoint in a file on load', () => __awaiter(this, void 0, void 0, function* () {
            const testProjectRoot = path.join(DATA_ROOT, 'breakOnLoad_sourceMaps');
            const scriptPath = path.join(testProjectRoot, 'src/script.ts');
            server = http_server_1.createServer({ root: testProjectRoot });
            server.listen(7890);
            // We try to put a breakpoint at (1,1). If this doesn't get hit, the console.log statement in the script should be executed
            const bpLine = 1;
            const bpCol = 1;
            return new Promise((resolve, _reject) => {
                // Add an event listener for the output event to capture the console.log statement
                dc.addListener('output', function (event) {
                    // If console.log event statement is executed, pass the test
                    if (event.body.category === 'stdout' && event.body.output === 'Hi\n') {
                        resolve();
                    }
                }),
                    Promise.all([
                        dc.waitForEvent('initialized').then(_event => {
                            return dc.setBreakpointsRequest({
                                lines: [bpLine],
                                breakpoints: [{ line: bpLine, column: bpCol }],
                                source: { path: scriptPath }
                            });
                        }).then(_response => {
                            return dc.configurationDoneRequest();
                        }),
                        dc.launch({ url: 'http://localhost:7890/index.html', webRoot: testProjectRoot })
                    ]);
            });
        }));
    });
});

//# sourceMappingURL=breakOnLoad.test.js.map
