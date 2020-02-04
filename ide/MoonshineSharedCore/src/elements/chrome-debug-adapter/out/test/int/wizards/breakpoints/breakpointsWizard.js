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
const internalFileBreakpointsWizard_1 = require("./implementation/internalFileBreakpointsWizard");
const validatedMap_1 = require("../../core-v2/chrome/collections/validatedMap");
const methodsCalledLogger_1 = require("../../core-v2/chrome/logging/methodsCalledLogger");
const fileBreakpointsWizard_1 = require("./fileBreakpointsWizard");
const chai_1 = require("chai");
const pausedWizard_1 = require("../pausedWizard");
class BreakpointsWizard {
    constructor(_client, _project) {
        this._client = _client;
        this._project = _project;
        this._pausedWizard = pausedWizard_1.PausedWizard.forClient(this._client);
        this._pathToFileWizard = new validatedMap_1.ValidatedMap();
        this._client.on('breakpoint', breakpointStatusChange => this.onBreakpointStatusChange(breakpointStatusChange.body));
    }
    get project() {
        return this._project;
    }
    static create(debugClient, testProjectSpecification) {
        return methodsCalledLogger_1.wrapWithMethodLogger(new this(debugClient, testProjectSpecification));
    }
    at(filePath) {
        return methodsCalledLogger_1.wrapWithMethodLogger(new fileBreakpointsWizard_1.FileBreakpointsWizard(this._pathToFileWizard.getOrAdd(filePath, () => new internalFileBreakpointsWizard_1.InternalFileBreakpointsWizard(methodsCalledLogger_1.wrapWithMethodLogger(this), this._client, this._project.src(filePath)))));
    }
    waitAndConsumePausedEvent(_breakpoint) {
        return __awaiter(this, void 0, void 0, function* () {
            // TODO: Should we validate the stack trace is on breakpoint here?
            yield this._pausedWizard.waitAndConsumePausedEvent(pausedInfo => {
                chai_1.expect(pausedInfo.reason).to.equal('breakpoint');
            });
        });
    }
    /**
     * Instruct the debuggee to resume, and verify that the Debug-Adapter sends the proper notification after that happens
     */
    resume() {
        return __awaiter(this, void 0, void 0, function* () {
            return this._pausedWizard.resume();
        });
    }
    waitAndConsumeResumedEvent() {
        return __awaiter(this, void 0, void 0, function* () {
            return this._pausedWizard.waitAndConsumeResumedEvent();
        });
    }
    waitAndAssertNoMoreEvents() {
        return __awaiter(this, void 0, void 0, function* () {
            return this._pausedWizard.waitAndAssertNoMoreEvents();
        });
    }
    toString() {
        return 'Breakpoints';
    }
    onBreakpointStatusChange(breakpointStatusChanged) {
        if (this.isBreakpointStatusChangedWithId(breakpointStatusChanged)) {
            // TODO: Update this code to only send the breakpoint to the file that owns it
            for (const fileWizard of this._pathToFileWizard.values()) {
                fileWizard.onBreakpointStatusChange(breakpointStatusChanged);
            }
        }
    }
    isBreakpointStatusChangedWithId(statusChanged) {
        return statusChanged.breakpoint.id !== undefined;
    }
}
exports.BreakpointsWizard = BreakpointsWizard;

//# sourceMappingURL=breakpointsWizard.js.map
