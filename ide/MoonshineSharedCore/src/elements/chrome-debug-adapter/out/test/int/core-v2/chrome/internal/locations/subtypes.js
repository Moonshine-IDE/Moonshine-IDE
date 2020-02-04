"use strict";
/*---------------------------------------------------------
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *--------------------------------------------------------*/
Object.defineProperty(exports, "__esModule", { value: true });
// We use these types to have the compiler check that we are not sending a ColumnNumber where a LineNumber is expected
const lineIndexSymbol = Symbol();
function createLineNumber(numberRepresentation) {
    return numberRepresentation;
}
exports.createLineNumber = createLineNumber;
const columnIndexSymbol = Symbol();
function createColumnNumber(numberRepresentation) {
    return numberRepresentation;
}
exports.createColumnNumber = createColumnNumber;
const URLRegexpSymbol = Symbol();
function createURLRegexp(textRepresentation) {
    return textRepresentation;
}
exports.createURLRegexp = createURLRegexp;

//# sourceMappingURL=subtypes.js.map
