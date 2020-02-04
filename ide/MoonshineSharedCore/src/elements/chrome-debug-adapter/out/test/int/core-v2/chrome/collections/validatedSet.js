"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const printing_1 = require("./printing");
const validation_1 = require("../../validation");
/** A set that throws exceptions instead of returning error codes. */
class ValidatedSet {
    constructor(valuesOrIterable) {
        this._wrappedSet = valuesOrIterable
            ? new Set(valuesOrIterable)
            : new Set();
    }
    get size() {
        return this._wrappedSet.size;
    }
    get [Symbol.toStringTag]() {
        return 'ValidatedSet';
    }
    clear() {
        this._wrappedSet.clear();
    }
    delete(key) {
        if (!this._wrappedSet.delete(key)) {
            validation_1.breakWhileDebugging();
            throw new Error(`Couldn't delete element with key ${key} because it wasn't present in the set`);
        }
        return true;
    }
    deleteIfExists(key) {
        return this._wrappedSet.delete(key);
    }
    forEach(callbackfn, thisArg) {
        this._wrappedSet.forEach(callbackfn, thisArg);
    }
    has(key) {
        return this._wrappedSet.has(key);
    }
    add(key) {
        if (this.has(key)) {
            validation_1.breakWhileDebugging();
            throw new Error(`Cannot add key ${key} because it already exists`);
        }
        return this.addOrReplaceIfExists(key);
    }
    addOrReplaceIfExists(key) {
        this._wrappedSet.add(key);
        return this;
    }
    [Symbol.iterator]() {
        return this._wrappedSet[Symbol.iterator]();
    }
    entries() {
        return this._wrappedSet.entries();
    }
    keys() {
        return this._wrappedSet.keys();
    }
    values() {
        return this._wrappedSet.values();
    }
    toString() {
        return printing_1.printSet('ValidatedSet', this);
    }
    toArray() {
        return Array.from(this);
    }
}
exports.ValidatedSet = ValidatedSet;

//# sourceMappingURL=validatedSet.js.map
