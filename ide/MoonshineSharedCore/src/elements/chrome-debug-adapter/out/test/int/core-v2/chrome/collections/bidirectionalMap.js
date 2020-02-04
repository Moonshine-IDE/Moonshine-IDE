"use strict";
/*---------------------------------------------------------
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *--------------------------------------------------------*/
Object.defineProperty(exports, "__esModule", { value: true });
const assert = require("assert");
const validatedMap_1 = require("./validatedMap");
const printing_1 = require("./printing");
const validation_1 = require("../../validation");
/** A map where we can efficiently get the key from the value or the value from the key */
class BidirectionalMap {
    constructor(initialContents) {
        this._leftToRight = new validatedMap_1.ValidatedMap();
        this._rightToLeft = new validatedMap_1.ValidatedMap();
        this._leftToRight = initialContents ? new validatedMap_1.ValidatedMap(initialContents) : new validatedMap_1.ValidatedMap();
        const reversed = Array.from(this._leftToRight.entries()).map(e => [e[1], e[0]]);
        this._rightToLeft = new validatedMap_1.ValidatedMap(reversed);
    }
    clear() {
        this._leftToRight.clear();
        this._rightToLeft.clear();
    }
    deleteByLeft(left) {
        const right = this._leftToRight.get(left);
        if (right !== undefined) {
            this.delete(left, right);
            return true;
        }
        else {
            return false;
        }
    }
    deleteByRight(right) {
        const left = this._rightToLeft.get(right);
        if (left !== undefined) {
            this.delete(left, right);
            return true;
        }
        else {
            return false;
        }
    }
    delete(left, right) {
        assert.ok(this._leftToRight.delete(left), `Expected left (${left}) associated with right (${right}) to exist on the left to right internal map`);
        assert.ok(this._rightToLeft.delete(right), `Expected right (${right}) associated with left (${left}) to exist on the right to left internal map`);
    }
    forEach(callbackfn, thisArg) {
        return this._leftToRight.forEach(callbackfn, thisArg);
    }
    getByLeft(left) {
        return this._leftToRight.get(left);
    }
    getByRight(right) {
        return this._rightToLeft.get(right);
    }
    tryGettingByLeft(left) {
        return this._leftToRight.tryGetting(left);
    }
    tryGettingByRight(right) {
        return this._rightToLeft.tryGetting(right);
    }
    hasLeft(left) {
        return this._leftToRight.has(left);
    }
    hasRight(right) {
        return this._rightToLeft.has(right);
    }
    set(left, right) {
        const existingRightForLeft = this._leftToRight.tryGetting(left);
        const existingLeftForRight = this._rightToLeft.tryGetting(right);
        if (existingRightForLeft !== undefined) {
            validation_1.breakWhileDebugging();
            throw new Error(`Can't set the pair left (${left}) and right (${right}) because there is already a right element (${existingRightForLeft}) associated with the left element`);
        }
        if (existingLeftForRight !== undefined) {
            validation_1.breakWhileDebugging();
            throw new Error(`Can't set the pair left (${left}) and right (${right}) because there is already a left element (${existingLeftForRight}) associated with the right element`);
        }
        this._leftToRight.set(left, right);
        this._rightToLeft.set(right, left);
        return this;
    }
    size() {
        return this._leftToRight.size;
    }
    lefts() {
        return this._leftToRight.keys();
    }
    rights() {
        return this._rightToLeft.keys();
    }
    toString() {
        return printing_1.printMap('BidirectionalMap', this._leftToRight);
    }
}
exports.BidirectionalMap = BidirectionalMap;

//# sourceMappingURL=bidirectionalMap.js.map
