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
const methodsCalledLogger_1 = require("../../core-v2/chrome/logging/methodsCalledLogger");
const bpActionWhenHit_1 = require("../../core-v2/chrome/internal/breakpoints/bpActionWhenHit");
class FileBreakpointsWizard {
    constructor(_internal) {
        this._internal = _internal;
    }
    breakpoint(options) {
        return __awaiter(this, void 0, void 0, function* () {
            const wrappedBreakpoint = methodsCalledLogger_1.wrapWithMethodLogger(yield this._internal.breakpoint({
                text: options.text,
                boundText: options.boundText,
                name: `BP @ ${options.text}`
            }));
            return wrappedBreakpoint.setThenWaitForVerifiedThenValidate();
        });
    }
    hitCountBreakpoint(options) {
        return __awaiter(this, void 0, void 0, function* () {
            return (yield (yield this.unsetHitCountBreakpoint(options)).setThenWaitForVerifiedThenValidate());
        });
    }
    unsetHitCountBreakpoint(options) {
        return __awaiter(this, void 0, void 0, function* () {
            return methodsCalledLogger_1.wrapWithMethodLogger(yield this._internal.breakpoint({
                text: options.text,
                boundText: options.boundText,
                actionWhenHit: new bpActionWhenHit_1.PauseOnHitCount(options.hitCountCondition),
                name: `BP @ ${options.text}`
            }));
        });
    }
    batch(batchAction) {
        return this._internal.batch(batchAction);
    }
    toString() {
        return `Breakpoints at ${this._internal.filePath}`;
    }
}
exports.FileBreakpointsWizard = FileBreakpointsWizard;

//# sourceMappingURL=fileBreakpointsWizard.js.map
