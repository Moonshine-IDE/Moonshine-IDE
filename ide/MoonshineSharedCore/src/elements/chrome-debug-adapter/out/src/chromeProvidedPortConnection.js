"use strict";
/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ChromeProvidedPortConnection = void 0;
const vscode_chrome_debug_core_1 = require("vscode-chrome-debug-core");
const vscode_chrome_debug_core_2 = require("vscode-chrome-debug-core");
const vscode_chrome_debug_core_3 = require("vscode-chrome-debug-core");
const errors = require("./errors");
const nls = require("vscode-nls");
const localize = nls.loadMessageBundle(__filename);
/**
 * Chrome connection class that supports launching with --remote-debugging-port=0 to get a random port for the debug session
 */
class ChromeProvidedPortConnection extends vscode_chrome_debug_core_1.chromeConnection.ChromeConnection {
    constructor() {
        super(...arguments);
        this.userDataDir = undefined;
    }
    setUserDataDir(userDataDir) {
        this.userDataDir = userDataDir;
    }
    /**
     * Attach the websocket to the first available tab in the chrome instance with the given remote debugging port number.
     * If we launched with port = 0, then this method will read the launched port from the user data directory, and wait until the port is open
     * before calling super.attach
     */
    attach(address = '127.0.0.1', port = 9222, targetUrl, timeout = vscode_chrome_debug_core_1.chromeConnection.ChromeConnection.ATTACH_TIMEOUT, extraCRDPChannelPort) {
        if (port === 0 && (this.userDataDir === undefined || this.userDataDir === ''))
            return errors.chromeProvidedPortWithoutUserDataDir();
        return vscode_chrome_debug_core_2.utils.retryAsync(() => __awaiter(this, void 0, void 0, function* () {
            const launchedPort = (port === 0 && this.userDataDir) ? yield this.getLaunchedPort(address, this.userDataDir) : port;
            return launchedPort;
        }), timeout, /*intervalDelay=*/ 200)
            .catch(err => Promise.reject(err))
            .then(launchedPort => {
            return super.attach(address, launchedPort, targetUrl, timeout, extraCRDPChannelPort);
        });
    }
    /**
     * Gets the port on which chrome was launched, and throw error if the port is not open or accepting connections
     * @param host The host address on which to check if the port is listening
     * @param userDataDir Chrome user data directory in which to check for a port file
     */
    getLaunchedPort(host, userDataDir) {
        return __awaiter(this, void 0, void 0, function* () {
            vscode_chrome_debug_core_3.logger.verbose('Looking for DevToolsActivePort file...');
            const launchedPort = yield vscode_chrome_debug_core_2.chromeUtils.getLaunchedPort(userDataDir);
            vscode_chrome_debug_core_3.logger.verbose('Got the port, checking if its ready...');
            const portInUse = yield vscode_chrome_debug_core_2.chromeUtils.isPortInUse(launchedPort, host, 100);
            if (!portInUse) {
                // bail, the port isn't open
                vscode_chrome_debug_core_3.logger.verbose('Port not open yet...');
                return errors.couldNotConnectToPort(host, launchedPort);
            }
            return launchedPort;
        });
    }
}
exports.ChromeProvidedPortConnection = ChromeProvidedPortConnection;

//# sourceMappingURL=chromeProvidedPortConnection.js.map
