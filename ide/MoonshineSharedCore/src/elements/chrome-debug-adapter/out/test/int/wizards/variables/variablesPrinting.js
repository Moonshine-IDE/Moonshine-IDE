"use strict";
/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/
Object.defineProperty(exports, "__esModule", { value: true });
/**
 * Print a collection of variable informations to make it easier to compare
 * the expected variables of a test, and the actual variables of the debuggee
 */
function printVariables(variables) {
    const variablesPrinted = variables.map(variable => printVariable(variable));
    return variablesPrinted.join('\n');
}
exports.printVariables = printVariables;
function printVariable(variable) {
    return `${variable.name} = ${variable.value} (${(variable.type)})`;
}

//# sourceMappingURL=variablesPrinting.js.map
