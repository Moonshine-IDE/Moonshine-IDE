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
const ImplementsBreakpointLocation = Symbol();
/**
 * Simple breakpoint location params (based on what the debug test client accepts)
 */
class BreakpointLocation {
    constructor(
    /** The path to the source file in which to set a breakpoint */
    path, 
    /** The line number in the file to set a breakpoint on */
    line, 
    /** Optional breakpoint column */
    column, 
    /** Whether or not we should assert if the bp is verified or not */
    verified) {
        this.path = path;
        this.line = line;
        this.column = column;
        this.verified = verified;
    }
    toString() {
        return `${this.path}:${this.line}:${this.column} verified: ${this.verified}`;
    }
}
exports.BreakpointLocation = BreakpointLocation;
/**
 * Launch an instance of chrome and wait for the debug adapter to initialize and attach
 * @param client Debug Client
 * @param launchConfig The launch config to use
 */
function launchTestAdapter(client, launchConfig) {
    return __awaiter(this, void 0, void 0, function* () {
        let init = client.waitForEvent('initialized');
        yield client.launch(launchConfig);
        yield init;
        yield client.configurationDoneRequest();
    });
}
exports.launchTestAdapter = launchTestAdapter;
/**
 * Easier way to set breakpoints for testing
 * @param client DebugClient
 * @param location Breakpoint location
 */
function setBreakpoint(client, location) {
    return client.setBreakpointsRequest({
        lines: [location.line],
        breakpoints: [{ line: location.line, column: location.column }],
        source: { path: location.path }
    });
}
exports.setBreakpoint = setBreakpoint;
/**
 * Set a conditional breakpoint in a file
 * @param client DebugClient
 * @param location Desired breakpoint location
 * @param condition The condition on which the breakpoint should be hit
 */
function setConditionalBreakpoint(client, location, condition) {
    return client.setBreakpointsRequest({
        lines: [location.line],
        breakpoints: [{ line: location.line, column: location.column, condition }],
        source: { path: location.path }
    });
}
exports.setConditionalBreakpoint = setConditionalBreakpoint;

//# sourceMappingURL=intTestSupport.js.map
