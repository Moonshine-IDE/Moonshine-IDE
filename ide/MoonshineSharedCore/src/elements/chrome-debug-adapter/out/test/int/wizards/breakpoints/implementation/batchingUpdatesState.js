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
const _ = require("lodash");
const validatedSet_1 = require("../../../core-v2/chrome/collections/validatedSet");
const internalFileBreakpointsWizard_1 = require("./internalFileBreakpointsWizard");
class BatchingUpdatesState {
    constructor(_internal, currentBreakpointsMapping) {
        this._internal = _internal;
        this.currentBreakpointsMapping = currentBreakpointsMapping;
        this._breakpointsToSet = new validatedSet_1.ValidatedSet();
        this._breakpointsToUnset = new validatedSet_1.ValidatedSet();
        this._actionsToCompleteAfterBatch = [];
    }
    set(breakpointWizard) {
        this._breakpointsToSet.add(breakpointWizard);
        this._breakpointsToUnset.deleteIfExists(breakpointWizard);
    }
    unset(breakpointWizard) {
        this._breakpointsToUnset.add(breakpointWizard);
        this._breakpointsToSet.deleteIfExists(breakpointWizard);
    }
    assertIsVerified(breakpoint) {
        this._actionsToCompleteAfterBatch.push(() => this._internal.assertIsVerified(breakpoint));
    }
    waitUntilVerified(breakpoint) {
        return __awaiter(this, void 0, void 0, function* () {
            this._actionsToCompleteAfterBatch.push(() => this._internal.waitUntilVerified(breakpoint));
        });
    }
    onBreakpointStatusChange(_breakpointStatusChanged) {
        throw new Error(`Breakpoint status shouldn't be updated while doing a batch update. Is this happening due to a product or test bug?`);
    }
    assertIsHitThenResumeWhen(_breakpoint, _lastActionToMakeBreakpointHit, _verifications) {
        return __awaiter(this, void 0, void 0, function* () {
            throw new Error(`Breakpoint shouldn't be verified while doing a batch update. Is this happening due to a product or test bug?`);
        });
    }
    assertIsHitThenResume(_breakpoint, _verifications) {
        return __awaiter(this, void 0, void 0, function* () {
            throw new Error(`Breakpoint shouldn't be verified while doing a batch update. Is this happening due to a product or test bug?`);
        });
    }
    processBatch() {
        return __awaiter(this, void 0, void 0, function* () {
            const breakpointsToKeepAsIs = _.difference(Array.from(this.currentBreakpointsMapping.keys()), this._breakpointsToSet.toArray(), this._breakpointsToUnset.toArray());
            yield this._internal.sendBreakpointsToClient(new internalFileBreakpointsWizard_1.BreakpointsUpdate(Array.from(this._breakpointsToSet), Array.from(this._breakpointsToUnset), breakpointsToKeepAsIs));
            // this._internal.sendBreakpointsToClient changed the state to PerformChangesImmediatelyState so we can now execute the actions we had pending
            yield this.executeActionsToCompleteAfterBatch();
        });
    }
    executeActionsToCompleteAfterBatch() {
        return __awaiter(this, void 0, void 0, function* () {
            // Validate with the originalSize that the actionsToCompleteAfterBatch aren't re-scheduled in a recursive way forever...
            const originalSize = this._actionsToCompleteAfterBatch.length;
            for (const actionToComplete of this._actionsToCompleteAfterBatch) {
                yield actionToComplete();
            }
            if (this._actionsToCompleteAfterBatch.length > originalSize) {
                throw new Error(`The list of actions to complete increased while performing the actions to complete.`
                    + ` The actions to complete probably ended up recursively scheduling more actions which is a bug`);
            }
        });
    }
}
exports.BatchingUpdatesState = BatchingUpdatesState;

//# sourceMappingURL=batchingUpdatesState.js.map
