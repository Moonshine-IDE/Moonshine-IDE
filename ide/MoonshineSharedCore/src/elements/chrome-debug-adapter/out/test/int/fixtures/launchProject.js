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
const defaultFixture_1 = require("./defaultFixture");
const launchWebServer_1 = require("./launchWebServer");
const launchPuppeteer_1 = require("../puppeteer/launchPuppeteer");
const url_1 = require("url");
const pausedWizard_1 = require("../wizards/pausedWizard");
const testSetup_1 = require("../testSetup");
/** Perform all the steps neccesary to launch a particular project such as:
 *    - Default fixture/setup
 *    - Launch web-server
 *    - Connect puppeteer to Chrome
 */
class LaunchProject {
    constructor(_defaultFixture, _launchWebServer, pausedWizard, _launchPuppeteer) {
        this._defaultFixture = _defaultFixture;
        this._launchWebServer = _launchWebServer;
        this.pausedWizard = pausedWizard;
        this._launchPuppeteer = _launchPuppeteer;
    }
    static create(testContext, testSpec) {
        return __awaiter(this, void 0, void 0, function* () {
            const launchWebServer = (testSpec.staticUrl) ?
                new launchWebServer_1.ProvideStaticUrl(new url_1.URL(testSpec.staticUrl), testSpec) :
                yield launchWebServer_1.LaunchWebServer.launch(testSpec);
            const defaultFixture = yield defaultFixture_1.DefaultFixture.create(testContext);
            // We need to create the PausedWizard before launching the debuggee to listen to all events and avoid race conditions
            const pausedWizard = pausedWizard_1.PausedWizard.forClient(defaultFixture.debugClient);
            const launchPuppeteer = yield launchPuppeteer_1.LaunchPuppeteer.create(defaultFixture.debugClient, launchWebServer.launchConfig);
            return new LaunchProject(defaultFixture, launchWebServer, pausedWizard, launchPuppeteer);
        });
    }
    /** Client for the debug adapter being used for this test */
    get debugClient() {
        return this._defaultFixture.debugClient;
    }
    /** Object to control the debugged browser via puppeteer */
    get browser() {
        return this._launchPuppeteer.browser;
    }
    /** Object to control the debugged page via puppeteer */
    get page() {
        return this._launchPuppeteer.page;
    }
    get url() {
        return this._launchWebServer.url;
    }
    cleanUp() {
        return __awaiter(this, void 0, void 0, function* () {
            if (testSetup_1.isThisV2) {
                yield this.pausedWizard.waitAndAssertNoMoreEvents();
            }
            yield this._defaultFixture.cleanUp(); // Disconnect the debug-adapter first
            yield this._launchPuppeteer.cleanUp(); // Then disconnect puppeteer and close chrome
            yield this._launchWebServer.cleanUp(); // Finally disconnect the web-server
        });
    }
}
exports.LaunchProject = LaunchProject;

//# sourceMappingURL=launchProject.js.map
