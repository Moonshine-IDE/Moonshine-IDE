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
* Functions that make puppeteer testing easier
*/
const request = require("request-promise-native");
const puppeteer = require("puppeteer");
/**
 * Connect puppeteer to a currently running instance of chrome
 * @param port The port on which the chrome debugger is running
 */
function connectPuppeteer(port) {
    return __awaiter(this, void 0, void 0, function* () {
        const resp = yield request(`http://localhost:${port}/json/version`);
        const { webSocketDebuggerUrl } = JSON.parse(resp);
        const browser = yield puppeteer.connect({ browserWSEndpoint: webSocketDebuggerUrl, defaultViewport: null });
        return browser;
    });
}
exports.connectPuppeteer = connectPuppeteer;
/**
 * Get the first (or only) page loaded in chrome
 * @param browser Puppeteer browser object
 */
function firstPage(browser) {
    return __awaiter(this, void 0, void 0, function* () {
        return (yield browser.pages())[0];
    });
}
exports.firstPage = firstPage;
/**
 * Get a page in the browser by the url
 * @param browser Puppeteer browser object
 * @param url The url of the desired page
 * @param timeout Timeout in milliseconds
 */
function getPageByUrl(browser, url, timeout = 5000) {
    return __awaiter(this, void 0, void 0, function* () {
        let before = new Date().getTime();
        let current = before;
        // poll for the desired page url. If we don't find it within the timeout, throw an error
        while ((current - before) < timeout) {
            const pages = yield browser.pages();
            const desiredPage = pages.find(p => p.url().toLowerCase() === url.toLowerCase());
            if (desiredPage) {
                return desiredPage;
            }
            // TODO: yuck, clean up
            yield new Promise((a, _r) => setTimeout(() => a(), timeout / 10));
            current = new Date().getTime();
        }
        throw `Page with url: ${url} could not be found within ${timeout}ms`;
    });
}
exports.getPageByUrl = getPageByUrl;

//# sourceMappingURL=puppeteerSupport.js.map
