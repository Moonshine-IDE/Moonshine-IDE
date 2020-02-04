"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
/*---------------------------------------------------------
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *--------------------------------------------------------*/
const _ = require("lodash");
const path = require("path");
const printObjectDescription_1 = require("./printObjectDescription");
const vscode_debugadapter_1 = require("vscode-debugadapter");
var Synchronicity;
(function (Synchronicity) {
    Synchronicity[Synchronicity["Sync"] = 0] = "Sync";
    Synchronicity[Synchronicity["Async"] = 1] = "Async";
})(Synchronicity || (Synchronicity = {}));
var Outcome;
(function (Outcome) {
    Outcome[Outcome["Succesful"] = 0] = "Succesful";
    Outcome[Outcome["Failure"] = 1] = "Failure";
})(Outcome || (Outcome = {}));
class ReplacementInstruction {
    constructor(pattern, replacement) {
        this.pattern = pattern;
        this.replacement = replacement;
    }
}
exports.ReplacementInstruction = ReplacementInstruction;
class MethodsCalledLoggerConfiguration {
    constructor(containerName, _replacements) {
        this.containerName = containerName;
        this._replacements = _replacements;
    }
    customizeResult(_methodName, _args, result) {
        return result;
    }
    customizeArgumentsBeforeCall(receiverName, methodName, args) {
        if (methodName === 'on' && args.length >= 2) {
            args[1] = new MethodsCalledLogger(this, args[1], `(${receiverName} emits ${args[0]})`).wrapped();
        }
    }
    get replacements() {
        return this._replacements;
    }
    updateReplacements(replacements) {
        this._replacements = replacements;
    }
}
exports.MethodsCalledLoggerConfiguration = MethodsCalledLoggerConfiguration;
class MethodsCalledLogger {
    constructor(_configuration, _objectToWrap, _objectToWrapName) {
        this._configuration = _configuration;
        this._objectToWrap = _objectToWrap;
        this._objectToWrapName = _objectToWrapName;
    }
    wrapped() {
        const handler = {
            get: (target, propertyKey, receiver) => {
                const originalPropertyValue = target[propertyKey];
                if (typeof originalPropertyValue === 'function') {
                    return (...args) => {
                        const callId = this.generateCallId();
                        try {
                            this.logCallStart(propertyKey, args, callId);
                            this._configuration.customizeArgumentsBeforeCall(this._objectToWrapName, propertyKey, args);
                            const result = originalPropertyValue.apply(target, args);
                            if (!result || !result.then) {
                                this.logCall(propertyKey, Synchronicity.Sync, args, Outcome.Succesful, result, callId);
                                if (result === target) {
                                    return receiver;
                                }
                                else {
                                    return this._configuration.customizeResult(propertyKey, args, result);
                                }
                            }
                            else {
                                this.logSyncPartFinished(propertyKey, args, callId);
                                return result.then((promiseResult) => {
                                    this.logCall(propertyKey, Synchronicity.Async, args, Outcome.Succesful, promiseResult, callId);
                                    if (promiseResult === target) {
                                        return receiver;
                                    }
                                    else {
                                        return this._configuration.customizeResult(propertyKey, args, promiseResult);
                                    }
                                }, (error) => {
                                    this.logCall(propertyKey, Synchronicity.Async, args, Outcome.Failure, error, callId);
                                    return Promise.reject(error);
                                });
                            }
                        }
                        catch (exception) {
                            this.logCall(propertyKey, Synchronicity.Sync, args, Outcome.Failure, exception, callId);
                            throw exception;
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
    generateCallId() {
        return MethodsCalledLogger._nextCallId++;
    }
    printMethodCall(propertyKey, methodCallArguments) {
        return `${this._objectToWrapName}.${String(propertyKey)}(${this.printArguments(methodCallArguments)})`;
    }
    printMethodResponse(outcome, resultOrException) {
        return `${outcome === Outcome.Succesful ? '->' : 'threw'} ${this.printObject(resultOrException)}`;
    }
    printMethodSynchronicity(synchronicity) {
        return `${synchronicity === Synchronicity.Sync ? '' : ' async'}`;
    }
    /** Returns the test file and line that the code is currently executing e.g.:
     *                                           <                                       >
     * [22:23:28.468 UTC] START            10026: hitCountBreakpointTests.test.ts:34:2 | #incrementBtn.click()
     */
    // TODO: Figure out how to integrate this with V2. We don't want to do this for production logging because new Error().stack is slow
    getTestFileAndLine() {
        const stack = new Error().stack;
        if (stack) {
            const stackLines = stack.split('\n');
            const testCaseLine = stackLines.find(line => line.indexOf('test.ts') >= 0);
            if (testCaseLine) {
                const filenameAndLine = testCaseLine.lastIndexOf(path.sep);
                if (filenameAndLine >= 0) {
                    const fileNameAndLineNumber = testCaseLine.substring(filenameAndLine + 1, testCaseLine.length - 2);
                    return `${fileNameAndLineNumber} | `;
                }
            }
        }
        return '';
    }
    logCallStart(propertyKey, methodCallArguments, callId) {
        const getTestFileAndLine = this.getTestFileAndLine();
        const message = `START            ${callId}: ${getTestFileAndLine}${this.printMethodCall(propertyKey, methodCallArguments)}`;
        vscode_debugadapter_1.logger.verbose(message);
    }
    logSyncPartFinished(propertyKey, methodCallArguments, callId) {
        const getTestFileAndLine = this.getTestFileAndLine();
        const message = `PROMISE-RETURNED ${callId}: ${getTestFileAndLine}${this.printMethodCall(propertyKey, methodCallArguments)}`;
        vscode_debugadapter_1.logger.verbose(message);
    }
    logCall(propertyKey, synchronicity, methodCallArguments, outcome, resultOrException, callId) {
        const endPrefix = callId ? `END              ${callId}: ` : '';
        const message = `${endPrefix}${this.printMethodCall(propertyKey, methodCallArguments)} ${this.printMethodSynchronicity(synchronicity)}  ${this.printMethodResponse(outcome, resultOrException)}`;
        vscode_debugadapter_1.logger.verbose(message);
    }
    printArguments(methodCallArguments) {
        return methodCallArguments.map(methodCallArgument => this.printObject(methodCallArgument)).join(', ');
    }
    printObject(objectToPrint) {
        const description = printObjectDescription_1.printTopLevelObjectDescription(objectToPrint);
        const printedReduced = _.reduce(Array.from(this._configuration.replacements), (text, replacement) => text.replace(replacement.pattern, replacement.replacement), description);
        return printedReduced;
    }
}
MethodsCalledLogger._nextCallId = 10000;
exports.MethodsCalledLogger = MethodsCalledLogger;
function wrapWithMethodLogger(objectToWrap, objectToWrapName = `${objectToWrap}`) {
    return new MethodsCalledLogger(new MethodsCalledLoggerConfiguration('no container', []), objectToWrap, objectToWrapName).wrapped();
}
exports.wrapWithMethodLogger = wrapWithMethodLogger;

//# sourceMappingURL=methodsCalledLogger.js.map
