"use strict";
/*---------------------------------------------------------
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *--------------------------------------------------------*/
Object.defineProperty(exports, "__esModule", { value: true });
function zeroOrPositive(name, value) {
    if (value < 0) {
        breakWhileDebugging();
        throw new Error(`Expected ${name} to be either zero or a positive number and instead it was ${value}`);
    }
}
exports.zeroOrPositive = zeroOrPositive;
/** Used for debugging while developing to automatically break when something unexpected happened */
function breakWhileDebugging() {
    if (process.env.BREAK_WHILE_DEBUGGING === 'true') {
        // tslint:disable-next-line:no-debugger
        debugger;
    }
}
exports.breakWhileDebugging = breakWhileDebugging;
function notNullNorUndefinedElements(name, array) {
    const index = array.findIndex(element => element === null || element === undefined);
    if (index >= 0) {
        breakWhileDebugging();
        throw new Error(`Expected ${name} to not have any null or undefined elements, yet the element at #${index} was ${array[index]}`);
    }
}
exports.notNullNorUndefinedElements = notNullNorUndefinedElements;

//# sourceMappingURL=validation.js.map
