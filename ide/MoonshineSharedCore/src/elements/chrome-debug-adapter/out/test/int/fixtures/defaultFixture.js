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
const testSetup = require("../testSetup");
const vscode_debugadapter_1 = require("vscode-debugadapter");
/**
 * Default set up for all our tests. We expect all our tests to need to do this setup
 * which includes configure the debug adapter, logging, etc...
 */
class DefaultFixture {
    constructor(debugClient) {
        this.debugClient = debugClient;
        // Running tests on CI can time out at the default 5s, so we up this to 15s
        debugClient.defaultTimeout = 15000;
    }
    /** Create a new fixture using the provided setup context */
    static create(context) {
        return __awaiter(this, void 0, void 0, function* () {
            return new DefaultFixture(yield testSetup.setup(context));
        });
    }
    /** Create a new fixture using the full title of the test case currently running */
    static createWithTitle(testTitle) {
        return __awaiter(this, void 0, void 0, function* () {
            return new DefaultFixture(yield testSetup.setupWithTitle(testTitle));
        });
    }
    cleanUp() {
        return __awaiter(this, void 0, void 0, function* () {
            vscode_debugadapter_1.logger.log(`Default test clean-up`);
            yield testSetup.teardown();
            vscode_debugadapter_1.logger.log(`Default test clean-up finished`);
        });
    }
    toString() {
        return `DefaultFixture`;
    }
}
exports.DefaultFixture = DefaultFixture;

//# sourceMappingURL=defaultFixture.js.map
