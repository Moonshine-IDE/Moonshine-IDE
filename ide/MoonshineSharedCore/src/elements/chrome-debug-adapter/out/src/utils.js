"use strict";
/*---------------------------------------------------------
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *--------------------------------------------------------*/
Object.defineProperty(exports, "__esModule", { value: true });
exports.defaultTargetFilter = exports.getTargetFilter = exports.DebounceHelper = exports.getBrowserPath = void 0;
const path = require("path");
const vscode_chrome_debug_core_1 = require("vscode-chrome-debug-core");
const WIN_APPDATA = process.env.LOCALAPPDATA || '/';
const DEFAULT_CHROME_PATH = {
    LINUX: '/usr/bin/google-chrome',
    OSX: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    WIN: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    WIN_LOCALAPPDATA: path.join(WIN_APPDATA, 'Google\\Chrome\\Application\\chrome.exe'),
    WINx86: 'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe',
};
function getBrowserPath() {
    const platform = vscode_chrome_debug_core_1.utils.getPlatform();
    if (platform === 1 /* OSX */) {
        return vscode_chrome_debug_core_1.utils.existsSync(DEFAULT_CHROME_PATH.OSX) ? DEFAULT_CHROME_PATH.OSX : null;
    }
    else if (platform === 0 /* Windows */) {
        if (vscode_chrome_debug_core_1.utils.existsSync(DEFAULT_CHROME_PATH.WINx86)) {
            return DEFAULT_CHROME_PATH.WINx86;
        }
        else if (vscode_chrome_debug_core_1.utils.existsSync(DEFAULT_CHROME_PATH.WIN)) {
            return DEFAULT_CHROME_PATH.WIN;
        }
        else if (vscode_chrome_debug_core_1.utils.existsSync(DEFAULT_CHROME_PATH.WIN_LOCALAPPDATA)) {
            return DEFAULT_CHROME_PATH.WIN_LOCALAPPDATA;
        }
        else {
            return null;
        }
    }
    else {
        return vscode_chrome_debug_core_1.utils.existsSync(DEFAULT_CHROME_PATH.LINUX) ? DEFAULT_CHROME_PATH.LINUX : null;
    }
}
exports.getBrowserPath = getBrowserPath;
class DebounceHelper {
    constructor(timeoutMs) {
        this.timeoutMs = timeoutMs;
    }
    /**
     * If not waiting already, call fn after the timeout
     */
    wait(fn) {
        if (!this.waitToken) {
            this.waitToken = setTimeout(() => {
                this.waitToken = null;
                fn();
            }, this.timeoutMs);
        }
    }
    /**
     * If waiting for something, cancel it and call fn immediately
     */
    doAndCancel(fn) {
        if (this.waitToken) {
            clearTimeout(this.waitToken);
            this.waitToken = null;
        }
        fn();
    }
}
exports.DebounceHelper = DebounceHelper;
exports.getTargetFilter = (targetTypes) => {
    if (targetTypes) {
        return target => target && (!target.type || targetTypes.indexOf(target.type) !== -1);
    }
    return () => true;
};
exports.defaultTargetFilter = exports.getTargetFilter(['page']);

//# sourceMappingURL=utils.js.map
