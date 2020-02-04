"use strict";
/*---------------------------------------------------------
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *--------------------------------------------------------*/
Object.defineProperty(exports, "__esModule", { value: true });
/** Methods to print the contents of a collection for logging and debugging purposes (This is not intended for the end-user to see) */
function printMap(typeDescription, map) {
    const elementsPrinted = Array.from(map.entries()).map(entry => `${entry[0]}: ${entry[1]}`).join('; ');
    return `${typeDescription} { ${elementsPrinted} }`;
}
exports.printMap = printMap;
function printSet(typeDescription, set) {
    const elementsPrinted = printElements(Array.from(set), '; ');
    return `${typeDescription} { ${elementsPrinted} }`;
}
exports.printSet = printSet;
function printArray(typeDescription, elements) {
    const elementsPrinted = printElements(elements, ', ');
    return typeDescription ? `${typeDescription} [ ${elementsPrinted} ]` : `[ ${elementsPrinted} ]`;
}
exports.printArray = printArray;
function printIterable(typeDescription, iterable) {
    const elementsPrinted = printElements(Array.from(iterable), '; ');
    return `${typeDescription} { ${elementsPrinted} }`;
}
exports.printIterable = printIterable;
function printElements(elements, separator = '; ') {
    return elements.map(element => `${element}`).join(separator);
}

//# sourceMappingURL=printing.js.map
