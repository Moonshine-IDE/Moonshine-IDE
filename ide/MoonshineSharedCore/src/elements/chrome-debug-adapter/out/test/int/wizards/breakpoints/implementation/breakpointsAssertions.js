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
const chai_1 = require("chai");
const chaiString = require("chai-string");
const waitUntilReadyWithTimeout_1 = require("../../../utils/waitUntilReadyWithTimeout");
const stackTraceObjectAssertions_1 = require("./stackTraceObjectAssertions");
const stackTraceStringAssertions_1 = require("./stackTraceStringAssertions");
const variablesWizard_1 = require("../../variables/variablesWizard");
const stackFrameWizard_1 = require("../../variables/stackFrameWizard");
const testSetup_1 = require("../../../testSetup");
chai_1.use(chaiString);
class BreakpointsAssertions {
    constructor(_breakpointsWizard, _internal, currentBreakpointsMapping) {
        this._breakpointsWizard = _breakpointsWizard;
        this._internal = _internal;
        this.currentBreakpointsMapping = currentBreakpointsMapping;
        this._variablesWizard = new variablesWizard_1.VariablesWizard(this._internal.client);
    }
    assertIsVerified(breakpoint) {
        // Convert to one based to match the VS Code potocol and what VS Code does if you try to open that file at that line number
        const breakpointStatus = this.currentBreakpointsMapping.get(breakpoint);
        this.assertLocationMatchesExpected(breakpointStatus, breakpoint);
        chai_1.expect(breakpointStatus.verified, `Expected ${breakpoint} to be verified yet it wasn't: ${breakpointStatus.message}`).to.equal(true);
    }
    waitUntilVerified(breakpoint) {
        return __awaiter(this, void 0, void 0, function* () {
            yield waitUntilReadyWithTimeout_1.waitUntilReadyWithTimeout(() => this.currentBreakpointsMapping.get(breakpoint).verified);
        });
    }
    assertIsHitThenResumeWhen(breakpoint, lastActionToMakeBreakpointHit, verifications) {
        return __awaiter(this, void 0, void 0, function* () {
            const actionResult = lastActionToMakeBreakpointHit();
            yield this.assertIsHitThenResume(breakpoint, verifications);
            yield actionResult;
        });
    }
    assertIsHitThenResume(breakpoint, verifications) {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._breakpointsWizard.waitAndConsumePausedEvent(breakpoint);
            const stackTraceFrames = (yield stackFrameWizard_1.stackTrace(this._internal.client, verifications.stackFrameFormat)).stackFrames;
            // Validate that the topFrame is locate in the same place as the breakpoint
            this.assertLocationMatchesExpected(stackTraceFrames[0], breakpoint);
            if (typeof verifications.stackTrace === 'string') {
                const assertions = new stackTraceStringAssertions_1.StackTraceStringAssertions(breakpoint);
                assertions.assertResponseMatches(stackTraceFrames, verifications.stackTrace);
            }
            else if (typeof verifications.stackTrace === 'object') {
                const assertions = new stackTraceObjectAssertions_1.StackTraceObjectAssertions(this._breakpointsWizard);
                assertions.assertResponseMatches(stackTraceFrames, verifications.stackTrace);
            }
            if (verifications.variables !== undefined) {
                yield this._variablesWizard.assertStackFrameVariablesAre(new stackFrameWizard_1.StackFrameWizard(this._internal.client, stackTraceFrames[0]), verifications.variables);
            }
            yield this._breakpointsWizard.resume();
        });
    }
    assertLocationMatchesExpected(objectWithLocation, breakpoint) {
        if (testSetup_1.isThisV2) { // Disable this completely for v1
            const expectedFilePath = this._internal.filePath;
            chai_1.expect(objectWithLocation.source).to.not.equal(undefined);
            chai_1.expect(objectWithLocation.source.path.toLowerCase()).to.be.equal(expectedFilePath.toLowerCase());
            chai_1.expect(objectWithLocation.source.name.toLowerCase()).to.be.equal(path.basename(expectedFilePath.toLowerCase()));
            const expectedLineNumber = breakpoint.boundPosition.lineNumber + 1;
            const expectedColumNumber = breakpoint.boundPosition.columnNumber + 1;
            const expectedBPLocationPrinted = `${expectedFilePath}:${expectedLineNumber}:${expectedColumNumber}`;
            const actualBPLocationPrinted = `${objectWithLocation.source.path}:${objectWithLocation.line}:${objectWithLocation.column}`;
            chai_1.expect(actualBPLocationPrinted.toLowerCase()).to.be.equal(expectedBPLocationPrinted.toLowerCase());
        }
    }
}
exports.BreakpointsAssertions = BreakpointsAssertions;

//# sourceMappingURL=breakpointsAssertions.js.map
