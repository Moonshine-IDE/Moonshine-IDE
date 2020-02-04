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
const puppeteerSuite_1 = require("../puppeteer/puppeteerSuite");
const intTestSupport_1 = require("../intTestSupport");
const launchWebServer_1 = require("../fixtures/launchWebServer");
const labels_1 = require("../labels");
const defaultFixture_1 = require("../fixtures/defaultFixture");
const multipleFixtures_1 = require("../fixtures/multipleFixtures");
const breakpointsWizard_1 = require("../wizards/breakpoints/breakpointsWizard");
/**
 * A common framework test suite that allows for easy (one-liner) testing of various
 * functionality in different framework projects (note: this isn't a suite in the mocha sense, but rather
 * a collection of functions that return mocha tests)
 */
class FrameworkTestSuite {
    constructor(frameworkName, suiteContext) {
        this.frameworkName = frameworkName;
        this.suiteContext = suiteContext;
    }
    get pausedWizard() {
        return this.suiteContext.launchProject.pausedWizard;
    }
    /**
     * Test that a breakpoint set after the page loads is hit on reload
     * @param bpLabel Label for the breakpoint to set
     */
    testPageReloadBreakpoint(bpLabel) {
        return puppeteerSuite_1.puppeteerTest(`${this.frameworkName} - Should hit breakpoint on page reload`, this.suiteContext, (context, page) => __awaiter(this, void 0, void 0, function* () {
            const debugClient = context.debugClient;
            const bpLocation = context.breakpointLabels.get(bpLabel);
            // wait for something on the page to ensure we're fully loaded, TODO: make this more generic?
            yield page.waitForSelector('#incrementBtn');
            yield intTestSupport_1.setBreakpoint(debugClient, bpLocation);
            const reloaded = page.reload();
            yield debugClient.assertStoppedLocation('breakpoint', bpLocation);
            yield this.pausedWizard.waitAndConsumePausedEvent(() => { });
            yield debugClient.continueRequest();
            yield this.pausedWizard.waitAndConsumeResumedEvent();
            yield reloaded;
        }));
    }
    /**
     * Test that step in command works as expected.
     * @param bpLabelStop Label for the breakpoint to set
     * @param bpLabelStepIn Label for the location where the 'step out' command should land us
     */
    testStepIn(bpLabelStop, bpLabelStepIn) {
        return puppeteerSuite_1.puppeteerTest(`${this.frameworkName} - Should step in correctly`, this.suiteContext, (_context, page) => __awaiter(this, void 0, void 0, function* () {
            const location = this.suiteContext.breakpointLabels.get(bpLabelStop);
            const stepInLocation = this.suiteContext.breakpointLabels.get(bpLabelStepIn);
            // wait for selector **before** setting breakpoint to avoid race conditions against scriptParsed event
            const incBtn = yield page.waitForSelector('#incrementBtn');
            yield intTestSupport_1.setBreakpoint(this.suiteContext.debugClient, location);
            const clicked = incBtn.click();
            yield this.suiteContext.debugClient.assertStoppedLocation('breakpoint', location);
            yield this.pausedWizard.waitAndConsumePausedEvent(() => { });
            const stopOnStep = this.suiteContext.debugClient.assertStoppedLocation('step', stepInLocation);
            yield this.suiteContext.debugClient.stepInAndStop();
            yield this.pausedWizard.waitAndConsumeResumedEvent();
            yield stopOnStep;
            yield this.pausedWizard.waitAndConsumePausedEvent(() => { });
            yield this.pausedWizard.resume();
            yield clicked;
        }));
    }
    /**
     * Test that step over (next) command works as expected.
     * Note: currently this test assumes that next will land us on the very next line in the file.
     * @param bpLabel Label for the breakpoint to set
     */
    testStepOver(bpLabel) {
        return puppeteerSuite_1.puppeteerTest(`${this.frameworkName} - Should step over correctly`, this.suiteContext, (_context, page) => __awaiter(this, void 0, void 0, function* () {
            const location = this.suiteContext.breakpointLabels.get(bpLabel);
            const incBtn = yield page.waitForSelector('#incrementBtn');
            yield intTestSupport_1.setBreakpoint(this.suiteContext.debugClient, location);
            const clicked = incBtn.click();
            yield this.suiteContext.debugClient.assertStoppedLocation('breakpoint', location);
            yield this.pausedWizard.waitAndConsumePausedEvent(() => { });
            const stopOnStep = this.suiteContext.debugClient.assertStoppedLocation('step', Object.assign({}, location, { line: location.line + 1 }));
            yield this.suiteContext.debugClient.nextAndStop();
            yield this.pausedWizard.waitAndConsumeResumedEvent();
            yield stopOnStep;
            yield this.pausedWizard.waitAndConsumePausedEvent(() => { });
            yield this.pausedWizard.resume();
            yield clicked;
        }));
    }
    /**
     * Test that step out command works as expected.
     * @param bpLabelStop Label for the breakpoint to set
     * @param bpLabelStepOut Label for the location where the 'step out' command should land us
     */
    testStepOut(bpLabelStop, bpLabelStepOut) {
        return puppeteerSuite_1.puppeteerTest(`${this.frameworkName} - Should step out correctly`, this.suiteContext, (_context, page) => __awaiter(this, void 0, void 0, function* () {
            const location = this.suiteContext.breakpointLabels.get(bpLabelStop);
            const stepOutLocation = this.suiteContext.breakpointLabels.get(bpLabelStepOut);
            const incBtn = yield page.waitForSelector('#incrementBtn');
            yield intTestSupport_1.setBreakpoint(this.suiteContext.debugClient, location);
            const clicked = incBtn.click();
            yield this.suiteContext.debugClient.assertStoppedLocation('breakpoint', location);
            yield this.pausedWizard.waitAndConsumePausedEvent(() => { });
            const stopOnStep = this.suiteContext.debugClient.assertStoppedLocation('step', stepOutLocation);
            yield this.suiteContext.debugClient.stepOutAndStop();
            yield this.pausedWizard.waitAndConsumeResumedEvent();
            yield stopOnStep;
            yield this.pausedWizard.waitAndConsumePausedEvent(() => { });
            yield this.pausedWizard.resume();
            yield clicked;
        }));
    }
    /**
     * Test that the debug adapter can correctly pause execution
     * @param bpLocation
     */
    testPauseExecution() {
        return puppeteerSuite_1.puppeteerTest(`${this.frameworkName} - Should correctly pause execution on a pause request`, this.suiteContext, (_context, _page) => __awaiter(this, void 0, void 0, function* () {
            yield this.pausedWizard.pause();
            // TODO: Verify we are actually pausing in the expected line
            yield this.pausedWizard.resume();
        }));
    }
    /**
     * A generic breakpoint test. This can be used for many different types of breakpoint tests with the following structure:
     *
     * 1. Wait for the page to load by waiting for the selector: `waitSelectorId`
     * 2. Set a breakpoint at `bpLabel`
     * 3. Execute a trigger event that should cause the breakpoint to be hit using the function `trigger`
     * 4. Assert that the breakpoint is hit on the expected location, and continue
     *
     * @param waitSelector an html selector to identify a resource to wait for for page load
     * @param bpLabel
     * @param trigger
     */
    testBreakpointHitsOnPageAction(description, waitSelector, file, bpLabel, trigger) {
        return puppeteerSuite_1.puppeteerTest(`${this.frameworkName} - ${description}`, this.suiteContext, (context, page) => __awaiter(this, void 0, void 0, function* () {
            yield page.waitForSelector(`${waitSelector}`);
            const breakpoints = breakpointsWizard_1.BreakpointsWizard.create(context.debugClient, context.testSpec);
            const breakpointWizard = breakpoints.at(file);
            const bp = yield breakpointWizard.breakpoint({ text: bpLabel });
            yield bp.assertIsHitThenResumeWhen(() => trigger(page));
        }));
    }
}
exports.FrameworkTestSuite = FrameworkTestSuite;
/**
 * Test that we can stop on a breakpoint set before launch
 * @param bpLabel Label for the breakpoint to set
 */
function testBreakOnLoad(frameworkName, testSpec, bpLabel) {
    const testTitle = `${frameworkName} - Should stop on breakpoint on initial page load`;
    return test(testTitle, () => __awaiter(this, void 0, void 0, function* () {
        const defaultFixture = yield defaultFixture_1.DefaultFixture.createWithTitle(testTitle);
        const launchWebServer = yield launchWebServer_1.LaunchWebServer.launch(testSpec);
        const fixture = new multipleFixtures_1.MultipleFixtures(launchWebServer, defaultFixture);
        try {
            const breakpointLabels = yield labels_1.loadProjectLabels(testSpec.props.webRoot);
            const location = breakpointLabels.get(bpLabel);
            yield defaultFixture.debugClient
                .hitBreakpointUnverified(launchWebServer.launchConfig, location);
        }
        finally {
            yield fixture.cleanUp();
        }
    }));
}
exports.testBreakOnLoad = testBreakOnLoad;

//# sourceMappingURL=frameworkCommonTests.js.map
