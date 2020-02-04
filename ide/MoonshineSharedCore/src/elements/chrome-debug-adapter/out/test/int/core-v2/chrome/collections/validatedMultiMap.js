"use strict";
/*---------------------------------------------------------
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *--------------------------------------------------------*/
Object.defineProperty(exports, "__esModule", { value: true });
const validatedMap_1 = require("./validatedMap");
const printing_1 = require("./printing");
const validatedSet_1 = require("./validatedSet");
/** A multi map that throws exceptions instead of returning error codes. */
class ValidatedMultiMap {
    constructor(_wrappedMap) {
        this._wrappedMap = _wrappedMap;
    }
    get keysSize() {
        return this._wrappedMap.size;
    }
    get [Symbol.toStringTag]() {
        return 'ValidatedMultiMap';
    }
    static empty() {
        return this.usingCustomMap(new validatedMap_1.ValidatedMap());
    }
    static withContents(initialContents) {
        const elements = Array.from(initialContents).map(element => [element[0], new validatedSet_1.ValidatedSet(element[1])]);
        return this.usingCustomMap(new validatedMap_1.ValidatedMap(elements));
    }
    static usingCustomMap(wrappedMap) {
        return new ValidatedMultiMap(wrappedMap);
    }
    clear() {
        this._wrappedMap.clear();
    }
    delete(key) {
        return this._wrappedMap.delete(key);
    }
    forEach(callbackfn, thisArg) {
        this._wrappedMap.forEach(callbackfn, thisArg);
    }
    get(key) {
        return this._wrappedMap.get(key);
    }
    getOr(key, elementDoesntExistAction) {
        return this._wrappedMap.getOr(key, () => new validatedSet_1.ValidatedSet(elementDoesntExistAction()));
    }
    has(key) {
        return this._wrappedMap.has(key);
    }
    addKeyIfNotExistant(key) {
        const existingValues = this._wrappedMap.tryGetting(key);
        if (existingValues === undefined) {
            this._wrappedMap.set(key, new validatedSet_1.ValidatedSet());
        }
        return this;
    }
    add(key, value) {
        const existingValues = this._wrappedMap.tryGetting(key);
        if (existingValues !== undefined) {
            existingValues.add(value);
        }
        else {
            this._wrappedMap.set(key, new validatedSet_1.ValidatedSet([value]));
        }
        return this;
    }
    addAndIgnoreDuplicates(key, value) {
        const existingValues = this._wrappedMap.tryGetting(key);
        if (existingValues !== undefined) {
            existingValues.addOrReplaceIfExists(value);
        }
        else {
            this._wrappedMap.set(key, new validatedSet_1.ValidatedSet([value]));
        }
        return this;
    }
    removeValueAndIfLastRemoveKey(key, value) {
        const remainingValues = this.removeValue(key, value);
        if (remainingValues.size === 0) {
            this._wrappedMap.delete(key);
        }
        return this;
    }
    removeValue(key, value) {
        const existingValues = this._wrappedMap.get(key);
        if (!existingValues.delete(value)) {
            throw new Error(`Failed to delete the value ${value} under key ${key} because it wasn't present`);
        }
        return existingValues;
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
    tryGetting(key) {
        return this._wrappedMap.tryGetting(key);
    }
    toString() {
        return printing_1.printMap('ValidatedMultiMap', this);
    }
}
exports.ValidatedMultiMap = ValidatedMultiMap;

//# sourceMappingURL=validatedMultiMap.js.map
