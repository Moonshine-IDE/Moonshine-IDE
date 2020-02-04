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
const _ = require("lodash");
const vscode_chrome_debug_core_1 = require("vscode-chrome-debug-core");
// The VSTS agents run slower than our machines. Use this value to reduce proportinoally the timeouts in your dev machine
exports.DefaultTimeoutMultiplier = parseFloat(_.defaultTo(process.env['TEST_TIMEOUT_MULTIPLIER'], '1'));
/**
 * Wait until the isReady condition evaluates to true. This method will evaluate it every 50 milliseconds until it returns true. It will time-out after maxWaitTimeInMilliseconds milliseconds
 */
function waitUntilReadyWithTimeout(isReady, maxWaitTimeInMilliseconds = exports.DefaultTimeoutMultiplier * 30000 /* 30 seconds */) {
    return __awaiter(this, void 0, void 0, function* () {
        const maximumDateTimeToWaitUntil = Date.now() + maxWaitTimeInMilliseconds;
        while (!isReady() && Date.now() < maximumDateTimeToWaitUntil) {
            yield vscode_chrome_debug_core_1.utils.promiseTimeout(undefined, 10 /*ms*/);
        }
        if (!isReady()) {
            throw new Error(`Timed-out after waiting for condition to be ready for ${maxWaitTimeInMilliseconds}ms. Condition: ${isReady}`);
        }
    });
}
exports.waitUntilReadyWithTimeout = waitUntilReadyWithTimeout;

//# sourceMappingURL=waitUntilReadyWithTimeout.js.map
