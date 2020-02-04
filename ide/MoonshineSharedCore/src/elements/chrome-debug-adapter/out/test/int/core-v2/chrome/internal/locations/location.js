"use strict";
/*---------------------------------------------------------
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *--------------------------------------------------------*/
Object.defineProperty(exports, "__esModule", { value: true });
const Validation = require("../../../validation");
const subtypes_1 = require("./subtypes");
const _ = require("lodash");
class Position {
    constructor(lineNumber, columnNumber) {
        this.lineNumber = lineNumber;
        this.columnNumber = columnNumber;
        Validation.zeroOrPositive('Line number', lineNumber);
        if (columnNumber !== undefined) {
            Validation.zeroOrPositive('Column number', columnNumber);
        }
    }
    static appearingLastOf(...positions) {
        const lastPosition = _.reduce(positions, (left, right) => left.doesAppearBefore(right) ? right : left);
        if (lastPosition !== undefined) {
            return lastPosition;
        }
        else {
            throw new Error(`Couldn't find the position appearing last from the list: ${positions}. Is it possible the list was empty?`);
        }
    }
    static appearingFirstOf(...positions) {
        const firstPosition = _.reduce(positions, (left, right) => left.doesAppearBefore(right) ? left : right);
        if (firstPosition !== undefined) {
            return firstPosition;
        }
        else {
            throw new Error(`Couldn't find the position appearing first from the list: ${positions}. Is it possible the list was empty?`);
        }
    }
    static isBetween(start, maybeInBetween, end) {
        return !maybeInBetween.doesAppearBefore(start) && !end.doesAppearBefore(maybeInBetween);
    }
    isEquivalentTo(location) {
        return this.lineNumber === location.lineNumber
            && this.columnNumber === location.columnNumber;
    }
    isOrigin() {
        return this.lineNumber === 0 && (this.columnNumber === undefined || this.columnNumber === 0);
    }
    doesAppearBefore(right) {
        return this.lineNumber < right.lineNumber ||
            (this.lineNumber === right.lineNumber && this.columnNumber < right.columnNumber);
    }
    toString() {
        return this.columnNumber !== undefined
            ? `${this.lineNumber}:${this.columnNumber}`
            : `${this.lineNumber}`;
    }
}
Position.origin = new Position(subtypes_1.createLineNumber(0), subtypes_1.createColumnNumber(0));
exports.Position = Position;

//# sourceMappingURL=location.js.map
