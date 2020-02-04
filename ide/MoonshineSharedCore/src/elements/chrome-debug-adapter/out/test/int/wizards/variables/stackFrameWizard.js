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
const chai_1 = require("chai");
const _ = require("lodash");
const vscode_chrome_debug_core_testsupport_1 = require("vscode-chrome-debug-core-testsupport");
const validatedSet_1 = require("../../core-v2/chrome/collections/validatedSet");
const utilities_1 = require("../../core-v2/chrome/collections/utilities");
const vscode_debugadapter_1 = require("vscode-debugadapter");
const defaultStackFrameFormat = {
    parameters: true,
    parameterTypes: true,
    parameterNames: true,
    line: true,
    module: true
};
function stackTrace(client, optionalStackFrameFormat) {
    return __awaiter(this, void 0, void 0, function* () {
        const stackFrameFormat = _.defaultTo(optionalStackFrameFormat, defaultStackFrameFormat);
        const stackTraceResponse = yield client.send('stackTrace', { threadId: vscode_chrome_debug_core_testsupport_1.THREAD_ID, format: stackFrameFormat });
        chai_1.expect(stackTraceResponse.success, `Expected the response to the stack trace request to be succesful yet it failed: ${JSON.stringify(stackTraceResponse)}`).to.equal(true);
        // Check totalFrames property
        chai_1.expect(stackTraceResponse.body.totalFrames).to.equal(stackTraceResponse.body.stackFrames.length, 'body.totalFrames');
        return stackTraceResponse.body;
    });
}
exports.stackTrace = stackTrace;
function topStackFrame(client, optionalStackFrameFormat) {
    return __awaiter(this, void 0, void 0, function* () {
        const stackFrames = (yield stackTrace(client, optionalStackFrameFormat)).stackFrames;
        chai_1.expect(stackFrames.length).to.be.greaterThan(0);
        return stackFrames[0];
    });
}
exports.topStackFrame = topStackFrame;
/** Utility functions to operate on the stack straces and stack frames of the debuggee.
 * It also provides utilities to access the scopes available in a particular stack frame.
 */
class StackFrameWizard {
    constructor(_client, _stackFrame) {
        this._client = _client;
        this._stackFrame = _stackFrame;
    }
    /** Return a Wizard to interact with the top stack frame of the debuggee of the client */
    static topStackFrame(client) {
        return __awaiter(this, void 0, void 0, function* () {
            return new StackFrameWizard(client, yield topStackFrame(client));
        });
    }
    /** Return the variables information for the scopes selected by name */
    variablesOfScopes(manyScopeNames) {
        return __awaiter(this, void 0, void 0, function* () {
            const scopes = yield this.scopesByNames(manyScopeNames);
            return Promise.all(scopes.map((scope) => __awaiter(this, void 0, void 0, function* () {
                const variablesResponse = yield this._client.variablesRequest({ variablesReference: scope.variablesReference });
                chai_1.expect(variablesResponse.success).to.equal(true);
                chai_1.expect(variablesResponse.body).not.to.equal(undefined);
                const variables = variablesResponse.body.variables;
                chai_1.expect(variables).not.to.equal(undefined);
                return { scopeName: scope.name.toLowerCase(), variables };
            })));
        });
    }
    scopesByNames(manyScopeNames) {
        return __awaiter(this, void 0, void 0, function* () {
            const scopeNamesSet = new validatedSet_1.ValidatedSet(manyScopeNames.map(name => name.toLowerCase()));
            const requestedScopes = (yield this.scopes()).filter(scope => scopeNamesSet.has(scope.name.toLowerCase()));
            chai_1.expect(requestedScopes).to.have.lengthOf(manyScopeNames.length);
            return requestedScopes;
        });
    }
    /** Return all the scopes available in the underlying stack frame */
    scopes() {
        return __awaiter(this, void 0, void 0, function* () {
            const scopesResponse = yield this._client.scopesRequest({ frameId: this._stackFrame.id });
            vscode_debugadapter_1.logger.log(`Scopes: ${scopesResponse.body.scopes.map(s => s.name).join(', ')}`);
            return scopesResponse.body.scopes;
        });
    }
    /** Return the names of all the global variables in the underlying stack frame */
    globalVariableNames() {
        return __awaiter(this, void 0, void 0, function* () {
            const existingGlobalVariables = yield this.variablesOfScope('global');
            return new validatedSet_1.ValidatedSet(existingGlobalVariables.map(variable => variable.name));
        });
    }
    /** Return the variables information for a particular scope of the underlying stack frame */
    variablesOfScope(scopeName) {
        return __awaiter(this, void 0, void 0, function* () {
            return utilities_1.singleElementOfArray(yield this.variablesOfScopes([scopeName])).variables;
        });
    }
}
exports.StackFrameWizard = StackFrameWizard;

//# sourceMappingURL=stackFrameWizard.js.map
