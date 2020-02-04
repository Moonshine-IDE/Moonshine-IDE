"use strict";
/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const frameworkTestSupport_1 = require("../framework/frameworkTestSupport");
const labels_1 = require("../labels");
const fixture_1 = require("../fixtures/fixture");
const launchProject_1 = require("../fixtures/launchProject");
const vscode_debugadapter_1 = require("vscode-debugadapter");
const logging_1 = require("../utils/logging");
class PuppeteerTestContext extends frameworkTestSupport_1.ReassignableFrameworkTestContext {
    constructor() {
        super();
        this._browser = null;
        this._page = null;
        this._launchProject = null;
    }
    get browser() {
        return this._browser;
    }
    get page() {
        return this._page;
    }
    get launchProject() {
        return this._launchProject;
    }
    reassignTo(newWrapped) {
        super.reassignTo(newWrapped);
        this._page = newWrapped.page;
        this._browser = newWrapped.browser;
        this._launchProject = newWrapped.launchProject;
        return this;
    }
}
exports.PuppeteerTestContext = PuppeteerTestContext;
/**
 * Launch a test with default settings and attach puppeteer. The test will start with the debug adapter
 * and chrome launched, and puppeteer attached.
 *
 * @param description Describe what this test should be testing
 * @param context The test context for this test sutie
 * @param testFunction The inner test function that will run a test using puppeteer
 */
function puppeteerTestFunction(description, context, testFunction, functionToDeclareTest = test) {
    functionToDeclareTest(description, function () {
        return testFunction(context, context.page);
    });
}
puppeteerTestFunction.skip = (description, _context, _testFunction) => test.skip(description, () => { throw new Error(`We don't expect this to be called`); });
puppeteerTestFunction.only = (description, context, testFunction) => puppeteerTestFunction(description, context, testFunction, test.only);
exports.puppeteerTest = puppeteerTestFunction;
/**
 * Defines a custom test suite which will:
 *     1) automatically launch a server from a test project directory,
 *     2) launch the debug adapter (with chrome)
 *
 * From there, consumers can either launch a puppeteer instrumented test, or a normal test (i.e. without puppeteer) using
 * the test methods defined here, and can get access to the relevant variables.
 *
 * @param description Description for the mocha test suite
 * @param testSpec Info about the test project on which this suite will be based
 * @param callback The inner test suite that uses this context
 */
function puppeteerSuiteFunction(description, testSpec, callback, suiteFunctionToUse = suite) {
    return suiteFunctionToUse(description, () => {
        let testContext = new PuppeteerTestContext();
        let fixture = new fixture_1.NullFixture(); // This variable is shared across all test of this suite
        setup(function () {
            return __awaiter(this, void 0, void 0, function* () {
                logging_1.setTestLogName(this.currentTest.fullTitle());
                const breakpointLabels = yield labels_1.loadProjectLabels(testSpec.props.webRoot);
                const launchProject = fixture = yield launchProject_1.LaunchProject.create(this, testSpec);
                testContext.reassignTo({
                    testSpec, debugClient: launchProject.debugClient, breakpointLabels, browser: launchProject.browser, page: launchProject.page, launchProject
                });
            });
        });
        teardown(() => __awaiter(this, void 0, void 0, function* () {
            yield fixture.cleanUp();
            fixture = new fixture_1.NullFixture();
            vscode_debugadapter_1.logger.log(`teardown finished`);
        }));
        callback(testContext);
    });
}
puppeteerSuiteFunction.skip = (description, testSpec, callback) => puppeteerSuiteFunction(description, testSpec, callback, suite.skip);
puppeteerSuiteFunction.only = (description, testSpec, callback) => puppeteerSuiteFunction(description, testSpec, callback, suite.only);
puppeteerSuiteFunction.skip = (description, _testSpec, _callback) => suite.skip(description, () => { });
exports.puppeteerSuite = puppeteerSuiteFunction;

//# sourceMappingURL=puppeteerSuite.js.map
