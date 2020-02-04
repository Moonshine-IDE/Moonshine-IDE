"use strict";
/*---------------------------------------------------------
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *--------------------------------------------------------*/
Object.defineProperty(exports, "__esModule", { value: true });
const printing_1 = require("./printing");
const validation_1 = require("../../validation");
/** A map that throws exceptions instead of returning error codes. */
class ValidatedMap {
    constructor(initialContents) {
        if (initialContents !== undefined) {
            this._wrappedMap = initialContents instanceof Map
                ? new Map(initialContents.entries())
                : new Map(initialContents);
        }
        else {
            this._wrappedMap = new Map();
        }
    }
    static with(key, value) {
        return new ValidatedMap([[key, value]]);
    }
    get size() {
        return this._wrappedMap.size;
    }
    get [Symbol.toStringTag]() {
        return 'ValidatedMap';
    }
    clear() {
        this._wrappedMap.clear();
    }
    delete(key) {
        if (!this._wrappedMap.delete(key)) {
            validation_1.breakWhileDebugging();
            throw new Error(`Couldn't delete element with key ${key} because it wasn't present in the map`);
        }
        return true;
    }
    forEach(callbackfn, thisArg) {
        this._wrappedMap.forEach(callbackfn, thisArg);
    }
    get(key) {
        const value = this._wrappedMap.get(key);
        if (value === undefined) {
            validation_1.breakWhileDebugging();
            throw new Error(`Couldn't get the element with key '${key}' because it wasn't present in this map <${this}>`);
        }
        return value;
    }
    getOr(key, elementDoesntExistAction) {
        const existingValue = this.tryGetting(key);
        if (existingValue !== undefined) {
            return existingValue;
        }
        else {
            return elementDoesntExistAction();
        }
    }
    getOrAdd(key, obtainValueToAdd) {
        return this.getOr(key, () => {
            const newValue = obtainValueToAdd();
            this.set(key, newValue);
            return newValue;
        });
    }
    has(key) {
        return this._wrappedMap.has(key);
    }
    set(key, value) {
        if (this.has(key)) {
            validation_1.breakWhileDebugging();
            throw new Error(`Cannot set key ${key} because it already exists`);
        }
        return this.setAndReplaceIfExist(key, value);
    }
    setAndReplaceIfExist(key, value) {
        this._wrappedMap.set(key, value);
        return this;
    }
    setAndIgnoreDuplicates(key, value, comparer = (left, right) => left === right) {
        const existingValueOrUndefined = this.tryGetting(key);
        if (existingValueOrUndefined !== undefined && !comparer(existingValueOrUndefined, value)) {
            validation_1.breakWhileDebugging();
            throw new Error(`Cannot set key ${key} for value ${value} because it already exists and it's associated to a different value: ${existingValueOrUndefined}`);
        }
        return this.setAndReplaceIfExist(key, value);
    }
    [Symbol.iterator]() {
        return this._wrappedMap.entries();
    }
    entries() {
        return this._wrappedMap.entries();
    }
    keys() {
        return this._wrappedMap.keys();
    }
    values() {
        return this._wrappedMap.values();
    }
    // TODO: Remove the use of undefined
    tryGetting(key) {
        return this._wrappedMap.get(key) || undefined;
    }
    toString() {
        return printing_1.printMap('ValidatedMap', this);
    }
}
exports.ValidatedMap = ValidatedMap;

//# sourceMappingURL=validatedMap.js.map
