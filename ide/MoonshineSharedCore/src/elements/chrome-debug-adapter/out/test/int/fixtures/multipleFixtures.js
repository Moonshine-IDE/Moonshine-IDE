"use strict";
/*---------------------------------------------------------
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *--------------------------------------------------------*/
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const async_1 = require("../core-v2/chrome/collections/async");
/** Combine multiple fixtures into a single fixture, for easier management (e.g. you just need to call a single cleanUp method) */
class MultipleFixtures {
    constructor(...fixtures) {
        this._fixtures = fixtures;
    }
    cleanUp() {
        return __awaiter(this, void 0, void 0, function* () {
            yield async_1.asyncMap(this._fixtures, fixture => fixture.cleanUp());
        });
    }
}
exports.MultipleFixtures = MultipleFixtures;

//# sourceMappingURL=multipleFixtures.js.map
