"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const testSetup_1 = require("../../testSetup");
class BreakpointWizard {
    constructor(_internal, position, actionWhenHit, name, boundPosition) {
        this._internal = _internal;
        this.position = position;
        this.actionWhenHit = actionWhenHit;
        this.name = name;
        this.boundPosition = boundPosition;
        this._state = new BreakpointUnsetState(this, this._internal, this.changeStateFunction());
    }
    setThenWaitForVerifiedThenValidate() {
        return __awaiter(this, void 0, void 0, function* () {
            yield this.setWithoutVerifying();
            if (testSetup_1.isThisV2) { // this will hang indefinetly on V1 in certain cases, particularly hit count bps with invalid condiditions
                yield this.waitUntilVerified();
                this.assertIsVerified();
            }
            return this;
        });
    }
    waitUntilVerified() {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._state.waitUntilVerified();
            return this;
        });
    }
    setWithoutVerifying() {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._state.set();
            return this;
        });
    }
    unset() {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._state.unset();
            return this;
        });
    }
    assertIsHitThenResumeWhen(lastActionToMakeBreakpointHit, verifications = {}) {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._state.assertIsHitThenResumeWhen(lastActionToMakeBreakpointHit, verifications);
            return this;
        });
    }
    assertIsHitThenResume(verifications) {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._state.assertIsHitThenResume(verifications);
            return this;
        });
    }
    assertIsVerified() {
        this._state.assertIsVerified();
        return this;
    }
    changeStateFunction() {
        return newState => this._state = newState;
    }
    toString() {
        return this.name;
    }
}
exports.BreakpointWizard = BreakpointWizard;
class BreakpointSetState {
    constructor(_breakpoint, _internal, _changeState) {
        this._breakpoint = _breakpoint;
        this._internal = _internal;
        this._changeState = _changeState;
    }
    set() {
        throw new Error(`Can't set a breakpoint that is already set`);
    }
    unset() {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._internal.unset(this._breakpoint);
            this._changeState(new BreakpointUnsetState(this._breakpoint, this._internal, this._changeState));
        });
    }
    /**
     * This method is intended to avoid hangs when performing a puppeteer action that will get blocked while the debuggee hits a breakpoint.
     *
     * The method will execute the puppeteer action, verify that the breakpoint is hit, and afterwards verify that the puppeteer action was properly finished.
     *
     * More details:
     * The method will also verify that the pause was in the exact locatio that the breakpoint is located, and any other verifications specified in the verifications parameter
     */
    assertIsHitThenResumeWhen(lastActionToMakeBreakpointHit, verifications) {
        return this._internal.assertIsHitThenResumeWhen(this._breakpoint, lastActionToMakeBreakpointHit, verifications);
    }
    /**
     * Verify that the debuggee is paused due to this breakpoint, and perform a customizable list of extra verifications
     */
    assertIsHitThenResume(verifications) {
        return this._internal.assertIsHitThenResume(this._breakpoint, verifications);
    }
    assertIsVerified() {
        this._internal.assertIsVerified(this._breakpoint);
    }
    waitUntilVerified() {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._internal.waitUntilVerified(this._breakpoint);
        });
    }
}
class BreakpointUnsetState {
    constructor(_breakpoint, _internal, _changeState) {
        this._breakpoint = _breakpoint;
        this._internal = _internal;
        this._changeState = _changeState;
    }
    set() {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._internal.set(this._breakpoint);
            this._changeState(new BreakpointSetState(this._breakpoint, this._internal, this._changeState));
        });
    }
    unset() {
        throw new Error(`Can't unset a breakpoint that is already unset`);
    }
    assertIsHitThenResumeWhen(_lastActionToMakeBreakpointHit, _verifications) {
        throw new Error(`Can't expect to hit a breakpoint that is unset`);
    }
    assertIsHitThenResume(_verifications) {
        throw new Error(`Can't expect to hit a breakpoint that is unset`);
    }
    assertIsVerified() {
        throw new Error(`Can't expect an unset breakpoint to be verified`);
    }
    waitUntilVerified() {
        return __awaiter(this, void 0, void 0, function* () {
            throw new Error(`Can't expect an unset breakpoint to ever become verified`);
        });
    }
}
exports.BreakpointUnsetState = BreakpointUnsetState;

//# sourceMappingURL=breakpointWizard.js.map
