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
const findPositionOfTextInFile_1 = require("../../../utils/findPositionOfTextInFile");
const bpActionWhenHit_1 = require("../../../core-v2/chrome/internal/breakpoints/bpActionWhenHit");
const breakpointWizard_1 = require("../breakpointWizard");
const validatedMap_1 = require("../../../core-v2/chrome/collections/validatedMap");
const fileBreakpointsWizard_1 = require("../fileBreakpointsWizard");
const batchingUpdatesState_1 = require("./batchingUpdatesState");
const performChangesImmediatelyState_1 = require("./performChangesImmediatelyState");
const breakpointsUpdater_1 = require("./breakpointsUpdater");
class BreakpointsUpdate {
    constructor(toAdd, toRemove, toKeepAsIs) {
        this.toAdd = toAdd;
        this.toRemove = toRemove;
        this.toKeepAsIs = toKeepAsIs;
    }
}
exports.BreakpointsUpdate = BreakpointsUpdate;
class InternalFileBreakpointsWizard {
    constructor(_breakpointsWizard, client, filePath) {
        this._breakpointsWizard = _breakpointsWizard;
        this.client = client;
        this.filePath = filePath;
        this._breakpointsUpdater = new breakpointsUpdater_1.BreakpointsUpdater(this._breakpointsWizard, this, this.client, state => this._state = state);
        this._state = new performChangesImmediatelyState_1.PerformChangesImmediatelyState(this._breakpointsWizard, this, new validatedMap_1.ValidatedMap());
    }
    breakpoint(options) {
        return __awaiter(this, void 0, void 0, function* () {
            const position = yield findPositionOfTextInFile_1.findPositionOfTextInFile(this.filePath, options.text);
            const boundPosition = options.boundText ? yield findPositionOfTextInFile_1.findPositionOfTextInFile(this.filePath, options.boundText) : position;
            const actionWhenHit = options.actionWhenHit || new bpActionWhenHit_1.AlwaysPause();
            return new breakpointWizard_1.BreakpointWizard(this, position, actionWhenHit, options.name, boundPosition);
        });
    }
    set(breakpointWizard) {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._state.set(breakpointWizard);
        });
    }
    unset(breakpointWizard) {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._state.unset(breakpointWizard);
        });
    }
    waitUntilVerified(breakpoint) {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._state.waitUntilVerified(breakpoint);
        });
    }
    assertIsVerified(breakpoint) {
        this._state.assertIsVerified(breakpoint);
    }
    assertIsHitThenResumeWhen(breakpoint, lastActionToMakeBreakpointHit, verifications) {
        return __awaiter(this, void 0, void 0, function* () {
            return this._state.assertIsHitThenResumeWhen(breakpoint, lastActionToMakeBreakpointHit, verifications);
        });
    }
    assertIsHitThenResume(breakpoint, verifications) {
        return __awaiter(this, void 0, void 0, function* () {
            return this._state.assertIsHitThenResume(breakpoint, verifications);
        });
    }
    onBreakpointStatusChange(breakpointStatusChanged) {
        this._state.onBreakpointStatusChange(breakpointStatusChanged);
    }
    batch(batchAction) {
        return __awaiter(this, void 0, void 0, function* () {
            const batchingUpdates = new batchingUpdatesState_1.BatchingUpdatesState(this, this._state.currentBreakpointsMapping);
            this._state = batchingUpdates;
            const result = yield batchAction(new fileBreakpointsWizard_1.FileBreakpointsWizard(this));
            yield batchingUpdates.processBatch(); // processBatch calls sendBreakpointsToClient which will change the state back to PerformChangesImmediatelyState
            return result;
        });
    }
    sendBreakpointsToClient(update) {
        return __awaiter(this, void 0, void 0, function* () {
            return this._breakpointsUpdater.update(update);
        });
    }
}
exports.InternalFileBreakpointsWizard = InternalFileBreakpointsWizard;

//# sourceMappingURL=internalFileBreakpointsWizard.js.map
