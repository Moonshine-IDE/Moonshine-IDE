"use strict";
/*---------------------------------------------------------
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *--------------------------------------------------------*/
Object.defineProperty(exports, "__esModule", { value: true });
const validatedMultiMap_1 = require("./validatedMultiMap");
function groupByKey(elements, obtainKey) {
    const grouped = validatedMultiMap_1.ValidatedMultiMap.empty();
    elements.forEach(element => grouped.add(obtainKey(element), element));
    return grouped;
}
exports.groupByKey = groupByKey;
function determineOrderingOfStrings(left, right) {
    if (left < right) {
        return -1;
    }
    else if (left > right) {
        return 1;
    }
    else {
        return 0;
    }
}
exports.determineOrderingOfStrings = determineOrderingOfStrings;
function singleElementOfArray(array) {
    if (array.length === 1) {
        return array[0];
    }
    else {
        throw new Error(`Expected array ${array} to have exactly a single element yet it had ${array.length}`);
    }
}
exports.singleElementOfArray = singleElementOfArray;

//# sourceMappingURL=utilities.js.map
