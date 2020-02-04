"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
/*---------------------------------------------------------
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *--------------------------------------------------------*/
const testSetup = require("../testSetup");
const puppeteerSuite_1 = require("../puppeteer/puppeteerSuite");
const frameworkTestSupport_1 = require("../framework/frameworkTestSupport");
const frameworkCommonTests_1 = require("../framework/frameworkCommonTests");
const path = require("path");
const vscode_chrome_debug_core_1 = require("vscode-chrome-debug-core");
const SINGLE_INLINE_TEST_SPEC = frameworkTestSupport_1.TestProjectSpec.fromTestPath('inline_scripts', '', vscode_chrome_debug_core_1.utils.pathToFileURL(path.join(testSetup.DATA_ROOT, 'inline_scripts/single.html')));
const MULTIPLE_INLINE_TEST_SPEC = frameworkTestSupport_1.TestProjectSpec.fromTestPath('inline_scripts', '', vscode_chrome_debug_core_1.utils.pathToFileURL(path.join(testSetup.DATA_ROOT, 'inline_scripts/multiple.html')));
suite('Inline Script Tests', () => {
    puppeteerSuite_1.puppeteerSuite('Single inline script', SINGLE_INLINE_TEST_SPEC, (suiteContext) => {
        const frameworkTests = new frameworkCommonTests_1.FrameworkTestSuite('Simple JS', suiteContext);
        frameworkTests.testBreakpointHitsOnPageAction('Should stop on a breakpoint in an in-line script', '#actionButton', 'single.html', 'a + b;', page => page.click('#actionButton'));
    });
    puppeteerSuite_1.puppeteerSuite.skip('Multiple inline scripts', MULTIPLE_INLINE_TEST_SPEC, (suiteContext) => {
        const frameworkTests = new frameworkCommonTests_1.FrameworkTestSuite('Simple JS', suiteContext);
        frameworkTests.testBreakpointHitsOnPageAction('Should stop on a breakpoint in multiple in-line scripts (Skipped, not currently working in V2)', '#actionButton', 'multiple.html', 'inlineScript1', page => page.click('#actionButton'));
    });
});

//# sourceMappingURL=inlineScripts.test.js.map
