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
const vscode_chrome_debug_core_testsupport_1 = require("vscode-chrome-debug-core-testsupport");
const vscode_debugadapter_1 = require("vscode-debugadapter");
const vscode_chrome_debug_core_1 = require("vscode-chrome-debug-core");
const testSetup_1 = require("../testSetup");
const waitUntilReadyWithTimeout_1 = require("../utils/waitUntilReadyWithTimeout");
const chai_1 = require("chai");
const validatedMap_1 = require("../core-v2/chrome/collections/validatedMap");
const methodsCalledLogger_1 = require("../core-v2/chrome/logging/methodsCalledLogger");
var EventToConsume;
(function (EventToConsume) {
    EventToConsume[EventToConsume["Paused"] = 0] = "Paused";
    EventToConsume[EventToConsume["Resumed"] = 1] = "Resumed";
    EventToConsume[EventToConsume["None"] = 2] = "None";
})(EventToConsume || (EventToConsume = {}));
/** Helper methods to wait and/or verify when the debuggee was paused for any kind of pause.
 *
 * Warning: Needs to be created before the debuggee is launched to capture all events and avoid race conditions
 */
class PausedWizard {
    constructor(_client) {
        this._client = _client;
        this._noMoreEventsExpected = false;
        this._eventsToBeConsumed = [];
        this._client.on('stopped', stopped => this.onEvent(stopped));
        if (testSetup_1.isThisV2) { // Don't bother subscribing on v1, as v1 sends more continues than strictly necessary
            this._client.on('continued', continued => this.onEvent(continued));
        }
    }
    onEvent(continued) {
        this.validateNoMoreEventsIfSet(continued);
        this._eventsToBeConsumed.push(continued);
        this.logState();
    }
    // The PausedWizard logic will break if we create 2 PausedWizards for the same client. So we warranty we only create one
    static forClient(client) {
        return this._clientToPausedWizard.getOrAdd(client, () => methodsCalledLogger_1.wrapWithMethodLogger(new PausedWizard(client)));
    }
    /**
     * Verify that the debuggee is not paused
     *
     * @param millisecondsToWaitForPauses How much time to wait for pauses
     */
    waitAndConsumeResumedEvent() {
        return __awaiter(this, void 0, void 0, function* () {
            if (testSetup_1.isThisV2) {
                yield waitUntilReadyWithTimeout_1.waitUntilReadyWithTimeout(() => this.nextEventToConsume === EventToConsume.Resumed);
                this.markNextEventAsConsumed('continued');
            }
        });
    }
    /** Return whether the debuggee is currently paused */
    isPaused() {
        return this.nextEventToConsume === EventToConsume.Paused;
    }
    /** Wait and block until the debuggee is paused on a debugger statement */
    waitUntilPausedOnDebuggerStatement() {
        return __awaiter(this, void 0, void 0, function* () {
            return this.waitAndConsumePausedEvent(pauseInfo => {
                chai_1.expect(pauseInfo.description).to.equal('Paused on debugger statement');
                chai_1.expect(pauseInfo.reason).to.equal('debugger_statement');
            });
        });
    }
    /** Wait and block until the debuggee is paused, and then perform the specified action with the pause event's body */
    waitAndConsumePausedEvent(actionWithPausedInfo) {
        return __awaiter(this, void 0, void 0, function* () {
            yield waitUntilReadyWithTimeout_1.waitUntilReadyWithTimeout(() => this.nextEventToConsume === EventToConsume.Paused);
            const pausedEvent = this._eventsToBeConsumed[0];
            this.markNextEventAsConsumed('stopped');
            actionWithPausedInfo(pausedEvent.body);
        });
    }
    /** Wait and block until the debuggee has been resumed */
    waitUntilResumed() {
        return __awaiter(this, void 0, void 0, function* () {
            // We assume that nobody is consuming events in parallel, so if we start paused, the wait call won't ever succeed
            chai_1.expect(this.nextEventToConsume).to.not.equal(EventToConsume.Paused);
            yield waitUntilReadyWithTimeout_1.waitUntilReadyWithTimeout(() => this.nextEventToConsume === EventToConsume.Resumed);
            this.markNextEventAsConsumed('continued');
        });
    }
    /**
     * Instruct the debuggee to resume, and verify that the Debug-Adapter sends the proper notification after that happens
     */
    resume() {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._client.continueRequest();
            if (testSetup_1.isThisV2) {
                // TODO: Is getting this event on V2 a bug? See: Continued Event at https://microsoft.github.io/debug-adapter-protocol/specification
                yield this.waitUntilResumed();
            }
        });
    }
    /**
     * Instruct the debuggee to pause, and verify that the Debug-Adapter sends the proper notification after that happens
     */
    pause() {
        return __awaiter(this, void 0, void 0, function* () {
            yield this._client.pauseRequest({ threadId: vscode_chrome_debug_core_testsupport_1.THREAD_ID });
            yield this.waitAndConsumePausedEvent(event => {
                chai_1.expect(event.reason).to.equal('pause');
                chai_1.expect(event.description).to.equal('Paused on user request');
            });
        });
    }
    waitAndAssertNoMoreEvents() {
        return __awaiter(this, void 0, void 0, function* () {
            chai_1.expect(this.nextEventToConsume).to.equal(EventToConsume.None);
            this._noMoreEventsExpected = true;
            // Wait some time, to see if any events appear eventually
            yield vscode_chrome_debug_core_1.utils.promiseTimeout(undefined, 500);
            chai_1.expect(this.nextEventToConsume).to.equal(EventToConsume.None);
        });
    }
    validateNoMoreEventsIfSet(event) {
        if (this._noMoreEventsExpected) {
            if (testSetup_1.isThisV2) {
                throw new Error(`Received an event after it was signaled that no more events were expected: ${JSON.stringify(event)}`);
            } //no-op this for V1
        }
    }
    logState() {
        vscode_debugadapter_1.logger.log(`Resume/Pause #events = ${this._eventsToBeConsumed.length}, state = ${EventToConsume[this.nextEventToConsume]}`);
    }
    get nextEventToConsume() {
        if (this._eventsToBeConsumed.length === 0) {
            return EventToConsume.None;
        }
        else {
            const nextEventToBeConsumed = this._eventsToBeConsumed[0];
            switch (nextEventToBeConsumed.event) {
                case 'stopped':
                    return EventToConsume.Paused;
                case 'continued':
                    return EventToConsume.Resumed;
                default:
                    throw new Error(`Expected the event to be consumed to be either a stopped or continued yet it was: ${JSON.stringify(nextEventToBeConsumed)}`);
            }
        }
    }
    markNextEventAsConsumed(eventName) {
        chai_1.expect(this._eventsToBeConsumed).length.to.be.greaterThan(0);
        chai_1.expect(this._eventsToBeConsumed[0].event).to.equal(eventName);
        this._eventsToBeConsumed.shift();
        this.logState();
    }
    toString() {
        return 'PausedWizard';
    }
}
PausedWizard._clientToPausedWizard = new validatedMap_1.ValidatedMap();
exports.PausedWizard = PausedWizard;

//# sourceMappingURL=pausedWizard.js.map
