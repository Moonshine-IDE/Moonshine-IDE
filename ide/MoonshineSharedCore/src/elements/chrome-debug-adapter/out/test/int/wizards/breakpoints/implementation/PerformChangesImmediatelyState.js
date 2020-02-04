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
const validatedMap_1 = require("../../../core-v2/chrome/collections/validatedMap");
const internalFileBreakpointsWizard_1 = require("./internalFileBreakpointsWizard");
const breakpointsAssertions_1 = require("./breakpointsAssertions");
class PerformChangesImmediatelyState {
    constructor(_breakpointsWizard, _internal, currentBreakpointsMapping) {
        this._breakpointsWizard = _breakpointsWizard;
        this._internal = _internal;
        this.currentBreakpointsMapping = currentBreakpointsMapping;
        this._idToBreakpoint = new validatedMap_1.ValidatedMap();
        this._breakpointsAssertions = new breakpointsAssertions_1.BreakpointsAssertions(this._breakpointsWizard, this._internal, this.currentBreakpointsMapping);
        this.currentBreakpointsMapping.forEach((vsCodeStatus, breakpoint) => {
            this._idToBreakpoint.set(vsCodeStatus.id, breakpoint);
        });
    }
    set(breakpointWizard) {
        return __awaiter(this, void 0, void 0, function* () {
            if (this.currentBreakpointsMapping.has(breakpointWizard)) {
                throw new Error(`Can't set the breakpoint: ${breakpointWizard} because it's already set`);
            }
            yield this._internal.sendBreakpointsToClient(new internalFileBreakpointsWizard_1.BreakpointsUpdate([breakpointWizard], [], this.currentBreakpoints()));
        });
    }
    unset(breakpointWizard) {
        return __awaiter(this, void 0, void 0, function* () {
            if (!this.currentBreakpointsMapping.has(breakpointWizard)) {
                throw new Error(`Can't unset the breakpoint: ${breakpointWizard} because it is not set`);
            }
            const remainingBreakpoints = this.currentBreakpoints().filter(bp => bp !== breakpointWizard);
            yield this._internal.sendBreakpointsToClient(new internalFileBreakpointsWizard_1.BreakpointsUpdate([], [breakpointWizard], remainingBreakpoints));
        });
    }
    onBreakpointStatusChange(breakpointStatusChanged) {
        const breakpoint = this._idToBreakpoint.get(breakpointStatusChanged.breakpoint.id);
        this.currentBreakpointsMapping.setAndReplaceIfExist(breakpoint, breakpointStatusChanged.breakpoint);
    }
    assertIsVerified(breakpoint) {
        this._breakpointsAssertions.assertIsVerified(breakpoint);
    }
    waitUntilVerified(breakpoint) {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._breakpointsAssertions.waitUntilVerified(breakpoint);
        });
    }
    assertIsHitThenResumeWhen(breakpoint, lastActionToMakeBreakpointHit, verifications) {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._breakpointsAssertions.assertIsHitThenResumeWhen(breakpoint, lastActionToMakeBreakpointHit, verifications);
        });
    }
    assertIsHitThenResume(breakpoint, verifications) {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._breakpointsAssertions.assertIsHitThenResume(breakpoint, verifications);
        });
    }
    currentBreakpoints() {
        return Array.from(this.currentBreakpointsMapping.keys());
    }
}
exports.PerformChangesImmediatelyState = PerformChangesImmediatelyState;

//# sourceMappingURL=PerformChangesImmediatelyState.js.map
