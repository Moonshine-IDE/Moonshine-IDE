"use strict";
/*---------------------------------------------------------
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *--------------------------------------------------------*/
Object.defineProperty(exports, "__esModule", { value: true });
class AlwaysPause {
    isEquivalentTo(bpActionWhenHit) {
        return bpActionWhenHit instanceof AlwaysPause;
    }
    toString() {
        return 'always pause';
    }
}
exports.AlwaysPause = AlwaysPause;
class ConditionalPause {
    constructor(expressionOfWhenToPause) {
        this.expressionOfWhenToPause = expressionOfWhenToPause;
    }
    isEquivalentTo(bpActionWhenHit) {
        return (bpActionWhenHit instanceof ConditionalPause)
            && this.expressionOfWhenToPause === bpActionWhenHit.expressionOfWhenToPause;
    }
    toString() {
        return `pause if: ${this.expressionOfWhenToPause}`;
    }
}
exports.ConditionalPause = ConditionalPause;
class PauseOnHitCount {
    constructor(pauseOnHitCondition) {
        this.pauseOnHitCondition = pauseOnHitCondition;
    }
    isEquivalentTo(bpActionWhenHit) {
        return (bpActionWhenHit instanceof PauseOnHitCount)
            && this.pauseOnHitCondition === bpActionWhenHit.pauseOnHitCondition;
    }
    toString() {
        return `pause when hits: ${this.pauseOnHitCondition}`;
    }
}
exports.PauseOnHitCount = PauseOnHitCount;
class LogMessage {
    constructor(expressionToLog) {
        this.expressionToLog = expressionToLog;
    }
    isEquivalentTo(bpActionWhenHit) {
        return (bpActionWhenHit instanceof LogMessage)
            && this.expressionToLog === bpActionWhenHit.expressionToLog;
    }
    toString() {
        return `log: ${this.expressionToLog}`;
    }
}
exports.LogMessage = LogMessage;

//# sourceMappingURL=bpActionWhenHit.js.map
