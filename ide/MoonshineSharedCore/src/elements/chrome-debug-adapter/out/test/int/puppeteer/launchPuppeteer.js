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
const getPort = require("get-port");
const intTestSupport_1 = require("../intTestSupport");
const puppeteerSupport_1 = require("./puppeteerSupport");
const logging_1 = require("../utils/logging");
const testSetup_1 = require("../testSetup");
const vscode_debugadapter_1 = require("vscode-debugadapter");
/**
 * Launch the debug adapter using the Puppeteer version of chrome, and then connect to it
 *
 * The fixture offers access to both the browser, and page objects of puppeteer
 */
class LaunchPuppeteer {
    constructor(browser, page) {
        this.browser = browser;
        this.page = page;
    }
    static create(debugClient, launchConfig /* TODO: investigate why launch config types differ between V1 and V2 */) {
        return __awaiter(this, void 0, void 0, function* () {
            const daPort = yield getPort();
            vscode_debugadapter_1.logger.log(`About to launch debug-adapter at port: ${daPort}`);
            yield intTestSupport_1.launchTestAdapter(debugClient, Object.assign({}, launchConfig, { port: daPort }));
            const browser = yield puppeteerSupport_1.connectPuppeteer(daPort);
            const page = logging_1.logCallsTo(yield puppeteerSupport_1.getPageByUrl(browser, launchConfig.url), 'PuppeteerPage');
            // This short wait appears to be necessary to completely avoid a race condition in V1 (tried several other
            // strategies to wait deterministically for all scripts to be loaded and parsed, but have been unsuccessful so far)
            // If we don't wait here, there's always a possibility that we can send the set breakpoint request
            // for a subsequent test after the scripts have started being parsed/run by Chrome, yet before
            // the target script is parsed, in which case the adapter will try to use breakOnLoad, but
            // the instrumentation BP will never be hit, leaving our breakpoint in limbo
            if (testSetup_1.isThisV1) {
                yield new Promise(a => setTimeout(a, 500));
            }
            return new LaunchPuppeteer(browser, page);
        });
    }
    cleanUp() {
        return __awaiter(this, void 0, void 0, function* () {
            vscode_debugadapter_1.logger.log(`Closing puppeteer and chrome`);
            try {
                yield this.browser.close();
                vscode_debugadapter_1.logger.log(`Scucesfully closed puppeteer and chrome`);
            }
            catch (exception) {
                vscode_debugadapter_1.logger.log(`Failed to close puppeteer: ${exception}`);
            }
        });
    }
    toString() {
        return `LaunchPuppeteer`;
    }
}
exports.LaunchPuppeteer = LaunchPuppeteer;

//# sourceMappingURL=launchPuppeteer.js.map
