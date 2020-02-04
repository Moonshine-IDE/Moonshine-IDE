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
suite('Breakpoints', () => {
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
    suite('Column BPs', () => {
        test('Column BP is hit on correct column', () => __awaiter(this, void 0, void 0, function* () {
            const testProjectRoot = path.join(DATA_ROOT, 'columns');
            const scriptPath = path.join(testProjectRoot, 'src/script.ts');
            server = http_server_1.createServer({ root: testProjectRoot });
            server.listen(7890);
            const url = 'http://localhost:7890/index.html';
            const bpLine = 4;
            const bpCol = 16;
            yield dc.hitBreakpointUnverified({ url, webRoot: testProjectRoot }, { path: scriptPath, line: bpLine, column: bpCol });
        }));
        test('Multiple column BPs are hit on correct columns', () => __awaiter(this, void 0, void 0, function* () {
            const testProjectRoot = path.join(DATA_ROOT, 'columns');
            const scriptPath = path.join(testProjectRoot, 'src/script.ts');
            server = http_server_1.createServer({ root: testProjectRoot });
            server.listen(7890);
            const url = 'http://localhost:7890/index.html';
            const bpLine = 4;
            const bpCol1 = 16;
            const bpCol2 = 24;
            yield dc.hitBreakpointUnverified({ url, webRoot: testProjectRoot }, { path: scriptPath, line: bpLine, column: bpCol1 });
            yield dc.setBreakpointsRequest({ source: { path: scriptPath }, breakpoints: [{ line: bpLine, column: bpCol2 }] });
            yield dc.continueTo('breakpoint', { line: bpLine, column: bpCol2 });
        }));
        test('BP col is adjusted to correct col', () => __awaiter(this, void 0, void 0, function* () {
            const testProjectRoot = path.join(DATA_ROOT, 'columns');
            const scriptPath = path.join(testProjectRoot, 'src/script.ts');
            server = http_server_1.createServer({ root: testProjectRoot });
            server.listen(7890);
            const url = 'http://localhost:7890/index.html';
            const bpLine = 4;
            const bpCol1 = 19;
            const correctBpCol1 = 16;
            const expectedLocation = { path: scriptPath, line: bpLine, column: correctBpCol1 };
            yield dc.hitBreakpointUnverified({ url, webRoot: testProjectRoot }, { path: scriptPath, line: bpLine, column: bpCol1 }, expectedLocation);
        }));
    });
});

//# sourceMappingURL=breakpoints.test.js.map
