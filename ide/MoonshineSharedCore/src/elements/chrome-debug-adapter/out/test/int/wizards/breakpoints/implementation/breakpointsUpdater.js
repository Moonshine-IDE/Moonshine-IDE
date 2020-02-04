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
const performChangesImmediatelyState_1 = require("./performChangesImmediatelyState");
const validatedMap_1 = require("../../../core-v2/chrome/collections/validatedMap");
const bpActionWhenHit_1 = require("../../../core-v2/chrome/internal/breakpoints/bpActionWhenHit");
class BreakpointsUpdater {
    constructor(_breakpointsWizard, _internal, _client, _changeState) {
        this._breakpointsWizard = _breakpointsWizard;
        this._internal = _internal;
        this._client = _client;
        this._changeState = _changeState;
    }
    update(update) {
        return __awaiter(this, void 0, void 0, function* () {
            const updatedBreakpoints = update.toKeepAsIs.concat(update.toAdd);
            const vsCodeBps = updatedBreakpoints.map(bp => this.toVSCodeProtocol(bp));
            const response = yield this._client.setBreakpointsRequest({ breakpoints: vsCodeBps, source: { path: this._internal.filePath } });
            this.validateResponse(response, vsCodeBps);
            const responseWithIds = response;
            const breakpointToStatus = new validatedMap_1.ValidatedMap(_.zip(updatedBreakpoints, responseWithIds.body.breakpoints));
            this._changeState(new performChangesImmediatelyState_1.PerformChangesImmediatelyState(this._breakpointsWizard, this._internal, breakpointToStatus));
        });
    }
    toVSCodeProtocol(breakpoint) {
        // VS Code protocol is 1-based so we add one to the line and colum numbers
        const commonInformation = { line: breakpoint.position.lineNumber + 1, column: breakpoint.position.columnNumber + 1 };
        const actionWhenHitInformation = this.actionWhenHitToVSCodeProtocol(breakpoint);
        return Object.assign({}, commonInformation, actionWhenHitInformation);
    }
    actionWhenHitToVSCodeProtocol(breakpoint) {
        if (breakpoint.actionWhenHit instanceof bpActionWhenHit_1.AlwaysPause) {
            return {};
        }
        else if (breakpoint.actionWhenHit instanceof bpActionWhenHit_1.PauseOnHitCount) {
            return { hitCondition: breakpoint.actionWhenHit.pauseOnHitCondition };
        }
        else {
            throw new Error('Not yet implemented');
        }
    }
    validateResponse(response, vsCodeBps) {
        if (!response.success) {
            throw new Error(`Failed to set the breakpoints for: ${this._internal.filePath}`);
        }
        const expected = vsCodeBps.length;
        const actual = response.body.breakpoints.length;
        if (actual !== expected) {
            throw new Error(`Expected to receive ${expected} breakpoints yet we got ${actual}. Received breakpoints: ${JSON.stringify(response.body.breakpoints)}`);
        }
        const bpsWithoutId = response.body.breakpoints.filter(bp => bp.id === undefined);
        if (bpsWithoutId.length !== 0) {
            throw new Error(`Expected to receive all breakpoints with id yet we got some without ${JSON.stringify(response.body.breakpoints)}`);
        }
    }
}
exports.BreakpointsUpdater = BreakpointsUpdater;

//# sourceMappingURL=breakpointsUpdater.js.map
