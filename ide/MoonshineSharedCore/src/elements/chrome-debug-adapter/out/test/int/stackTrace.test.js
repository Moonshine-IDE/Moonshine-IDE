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
const path = require("path");
const testSetup = require("./testSetup");
const frameworkTestSupport_1 = require("./framework/frameworkTestSupport");
const puppeteerSuite_1 = require("./puppeteer/puppeteerSuite");
const breakpointsWizard_1 = require("./wizards/breakpoints/breakpointsWizard");
const DATA_ROOT = testSetup.DATA_ROOT;
const SIMPLE_PROJECT_ROOT = path.join(DATA_ROOT, 'stackTrace');
const TEST_SPEC = new frameworkTestSupport_1.TestProjectSpec({ projectRoot: SIMPLE_PROJECT_ROOT, projectSrc: SIMPLE_PROJECT_ROOT });
const EVAL = (testSetup.isThisV2) ? 'eval code' : 'anonymous function';
function validateStackTrace(config) {
    return __awaiter(this, void 0, void 0, function* () {
        const incBtn = yield config.page.waitForSelector(config.buttonIdToClick);
        const breakpoints = breakpointsWizard_1.BreakpointsWizard.create(config.suiteContext.debugClient, TEST_SPEC);
        const breakpointWizard = breakpoints.at('app.js');
        const setStateBreakpoint = yield breakpointWizard.breakpoint({
            text: "console.log('Test stack trace here')"
        });
        yield setStateBreakpoint.assertIsHitThenResumeWhen(() => incBtn.click(), { stackTrace: config.expectedFrames, stackFrameFormat: config.format });
    });
}
puppeteerSuite_1.puppeteerSuite('Stack Traces', TEST_SPEC, (suiteContext) => {
    puppeteerSuite_1.puppeteerTest('Stack trace is generated with no formatting', suiteContext, (_context, page) => __awaiter(this, void 0, void 0, function* () {
        yield validateStackTrace({
            suiteContext: suiteContext,
            page: page,
            breakPointLabel: 'stackTraceBreakpoint',
            buttonIdToClick: '#button',
            format: {},
            expectedFrames: [
                { name: '(anonymous function)', line: 11, column: 9, source: { fileRelativePath: 'app.js' }, presentationHint: 'normal' },
                { name: 'evalCallback', line: 12, column: 7, source: { fileRelativePath: 'app.js' }, presentationHint: 'normal' },
                { name: `(${EVAL})`, line: 1, column: 1, source: { evalCode: true }, presentationHint: 'normal' },
                { name: 'timeoutCallback', line: 6, column: 5, source: { fileRelativePath: 'app.js' }, presentationHint: 'normal' },
                { name: '[ setTimeout ]', presentationHint: 'label' },
                { name: 'buttonClick', line: 2, column: 5, source: { fileRelativePath: 'app.js' }, presentationHint: 'normal' },
                { name: 'onclick', line: 7, column: 49, source: { url: suiteContext.launchProject.url }, presentationHint: 'normal' },
            ]
        });
    }));
    puppeteerSuite_1.puppeteerTest('Stack trace is generated with module formatting', suiteContext, (_context, page) => __awaiter(this, void 0, void 0, function* () {
        const url = suiteContext.launchProject.url;
        yield validateStackTrace({
            suiteContext: suiteContext,
            page: page,
            breakPointLabel: 'stackTraceBreakpoint',
            buttonIdToClick: '#button',
            format: {
                module: true
            },
            expectedFrames: [
                { name: '(anonymous function) [app.js]', line: 11, column: 9, source: { fileRelativePath: 'app.js' }, presentationHint: 'normal' },
                { name: 'evalCallback [app.js]', line: 12, column: 7, source: { fileRelativePath: 'app.js' }, presentationHint: 'normal' },
                { name: new RegExp(`\\(${EVAL}\\) \\[VM\\d+]`), line: 1, column: 1, source: { evalCode: true }, presentationHint: 'normal' },
                { name: 'timeoutCallback [app.js]', line: 6, column: 5, source: { fileRelativePath: 'app.js' }, presentationHint: 'normal' },
                { name: '[ setTimeout ]', presentationHint: 'label' },
                { name: 'buttonClick [app.js]', line: 2, column: 5, source: { fileRelativePath: 'app.js' }, presentationHint: 'normal' },
                { name: `onclick [${url.host}]`, line: 7, column: 49, source: { url }, presentationHint: 'normal' },
            ]
        });
    }));
    puppeteerSuite_1.puppeteerTest('Stack trace is generated with line formatting', suiteContext, (_context, page) => __awaiter(this, void 0, void 0, function* () {
        yield validateStackTrace({
            suiteContext: suiteContext,
            page: page,
            breakPointLabel: 'stackTraceBreakpoint',
            buttonIdToClick: '#button',
            format: {
                line: true,
            },
            expectedFrames: [
                { name: '(anonymous function) Line 11', line: 11, column: 9, source: { fileRelativePath: 'app.js' }, presentationHint: 'normal' },
                { name: 'evalCallback Line 12', line: 12, column: 7, source: { fileRelativePath: 'app.js' }, presentationHint: 'normal' },
                { name: new RegExp(`\\(${EVAL}\\) Line 1`), line: 1, column: 1, source: { evalCode: true }, presentationHint: 'normal' },
                { name: 'timeoutCallback Line 6', line: 6, column: 5, source: { fileRelativePath: 'app.js' }, presentationHint: 'normal' },
                { name: '[ setTimeout ]', presentationHint: 'label' },
                { name: 'buttonClick Line 2', line: 2, column: 5, source: { fileRelativePath: 'app.js' }, presentationHint: 'normal' },
                { name: 'onclick Line 7', line: 7, column: 49, source: { url: suiteContext.launchProject.url }, presentationHint: 'normal' },
            ]
        });
    }));
    puppeteerSuite_1.puppeteerTest('Stack trace is generated with all formatting', suiteContext, (_context, page) => __awaiter(this, void 0, void 0, function* () {
        const url = suiteContext.launchProject.url;
        yield validateStackTrace({
            suiteContext: suiteContext,
            page: page,
            breakPointLabel: 'stackTraceBreakpoint',
            buttonIdToClick: '#button',
            format: {
                parameters: true,
                parameterTypes: true,
                parameterNames: true,
                line: true,
                module: true
            },
            expectedFrames: [
                { name: '(anonymous function) [app.js] Line 11', line: 11, column: 9, source: { fileRelativePath: 'app.js' }, presentationHint: 'normal' },
                { name: 'evalCallback [app.js] Line 12', line: 12, column: 7, source: { fileRelativePath: 'app.js' }, presentationHint: 'normal' },
                { name: new RegExp(`\\(${EVAL}\\) \\[VM\\d+] Line 1`), line: 1, column: 1, source: { evalCode: true }, presentationHint: 'normal' },
                { name: 'timeoutCallback [app.js] Line 6', line: 6, column: 5, source: { fileRelativePath: 'app.js' }, presentationHint: 'normal' },
                { name: '[ setTimeout ]', presentationHint: 'label' },
                { name: 'buttonClick [app.js] Line 2', line: 2, column: 5, source: { fileRelativePath: 'app.js' }, presentationHint: 'normal' },
                { name: `onclick [${url.host}] Line 7`, line: 7, column: 49, source: { url }, presentationHint: 'normal' },
            ]
        });
    }));
});

//# sourceMappingURL=stackTrace.test.js.map
