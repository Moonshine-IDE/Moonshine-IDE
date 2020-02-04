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
/*
 * Integration tests for the React framework
 */
const path = require("path");
const testSetup = require("../testSetup");
const intTestSupport_1 = require("../intTestSupport");
const puppeteerSuite_1 = require("../puppeteer/puppeteerSuite");
const frameworkCommonTests_1 = require("./frameworkCommonTests");
const frameworkTestSupport_1 = require("./frameworkTestSupport");
const DATA_ROOT = testSetup.DATA_ROOT;
const REACT_PROJECT_ROOT = path.join(DATA_ROOT, 'react', 'dist');
const TEST_SPEC = new frameworkTestSupport_1.TestProjectSpec({ projectRoot: REACT_PROJECT_ROOT });
// This test doesn't use puppeteer, so we leave it outside the suite
frameworkCommonTests_1.testBreakOnLoad('React', TEST_SPEC, 'react_App_render');
puppeteerSuite_1.puppeteerSuite('React Framework Tests', TEST_SPEC, (suiteContext) => {
    suite('Common Framework Tests', () => {
        const frameworkTests = new frameworkCommonTests_1.FrameworkTestSuite('React', suiteContext);
        frameworkTests.testPageReloadBreakpoint('react_App_render');
        frameworkTests.testPauseExecution();
        frameworkTests.testStepOver('react_Counter_increment');
        frameworkTests.testStepOut('react_Counter_increment', 'react_Counter_stepOut');
        frameworkTests.testStepIn('react_Counter_stepInStop', 'react_Counter_stepIn');
    });
    suite('React specific tests', () => {
        puppeteerSuite_1.puppeteerTest('Should hit breakpoint in .jsx file', suiteContext, (_context, page) => __awaiter(this, void 0, void 0, function* () {
            const pausedWizard = suiteContext.launchProject.pausedWizard;
            const location = suiteContext.breakpointLabels.get('react_Counter_increment');
            const incBtn = yield page.waitForSelector('#incrementBtn');
            yield intTestSupport_1.setBreakpoint(suiteContext.debugClient, location);
            const clicked = incBtn.click();
            yield suiteContext.debugClient.assertStoppedLocation('breakpoint', location);
            yield pausedWizard.waitAndConsumePausedEvent(() => { });
            yield pausedWizard.resume();
            yield clicked;
        }));
        puppeteerSuite_1.puppeteerTest('Should hit conditional breakpoint in .jsx file', suiteContext, (_context, page) => __awaiter(this, void 0, void 0, function* () {
            const pausedWizard = suiteContext.launchProject.pausedWizard;
            const location = suiteContext.breakpointLabels.get('react_Counter_increment');
            const incBtn = yield page.waitForSelector('#incrementBtn');
            yield intTestSupport_1.setConditionalBreakpoint(suiteContext.debugClient, location, 'this.state.count == 2');
            // click 3 times, state will be = 2 on the third click
            yield incBtn.click();
            yield incBtn.click();
            // don't await the last click, as the stopped debugger will deadlock it
            const clicked = incBtn.click();
            yield suiteContext.debugClient.assertStoppedLocation('breakpoint', location);
            yield pausedWizard.waitAndConsumePausedEvent(() => { });
            // Be sure to await the continue request, otherwise sometimes the last click promise will
            // be rejected because the chrome instance is closed before it completes.
            yield pausedWizard.resume();
            yield clicked;
        }));
    });
});

//# sourceMappingURL=framework.react.test.js.map
