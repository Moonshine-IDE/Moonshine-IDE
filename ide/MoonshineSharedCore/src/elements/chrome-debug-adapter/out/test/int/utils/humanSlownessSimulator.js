"use strict";
/*---------------------------------------------------------
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *--------------------------------------------------------*/
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const vscode_chrome_debug_core_1 = require("vscode-chrome-debug-core");
/**
 * The test normally run very fast, so it's difficult to see what actions they are taking in the browser.
 * We can use the HumanSlownessSimulator to artifically slow some classes like the puppeteer classes, so it's the actions
 * will be taken at a lower speed, and it'll be easier to see and understand what is happening
 */
class HumanSlownessSimulator {
    constructor(_slownessInMillisecondsValueGenerator = () => 500) {
        this._slownessInMillisecondsValueGenerator = _slownessInMillisecondsValueGenerator;
    }
    simulateSlowness() {
        return vscode_chrome_debug_core_1.utils.promiseTimeout(undefined, this._slownessInMillisecondsValueGenerator());
    }
    wrap(object) {
        return new HumanSpeedProxy(this, object).wrapped();
    }
}
exports.HumanSlownessSimulator = HumanSlownessSimulator;
class HumanSpeedProxy {
    constructor(_humanSlownessSimulator, _objectToWrap) {
        this._humanSlownessSimulator = _humanSlownessSimulator;
        this._objectToWrap = _objectToWrap;
    }
    wrapped() {
        const handler = {
            get: (target, propertyKey, _receiver) => {
                this._humanSlownessSimulator.simulateSlowness();
                const originalPropertyValue = target[propertyKey];
                if (typeof originalPropertyValue === 'function') {
                    return (...args) => {
                        const result = originalPropertyValue.apply(target, args);
                        if (result && result.then) {
                            // Currently we only slow down async operations
                            return result.then((promiseResult) => __awaiter(this, void 0, void 0, function* () {
                                yield this._humanSlownessSimulator.simulateSlowness();
                                return typeof promiseResult === 'object'
                                    ? this._humanSlownessSimulator.wrap(promiseResult)
                                    : promiseResult;
                            }), (rejection) => {
                                return rejection;
                            });
                        }
                    };
                }
                else {
                    return originalPropertyValue;
                }
            }
        };
        return new Proxy(this._objectToWrap, handler);
    }
}
exports.HumanSpeedProxy = HumanSpeedProxy;
const humanSlownessSimulator = new HumanSlownessSimulator();
const humanSlownessEnabeld = process.env.RUN_TESTS_SLOWLY === 'true';
function slowToHumanLevel(object) {
    return humanSlownessEnabeld
        ? humanSlownessSimulator.wrap(object)
        : object;
}
exports.slowToHumanLevel = slowToHumanLevel;

//# sourceMappingURL=humanSlownessSimulator.js.map
