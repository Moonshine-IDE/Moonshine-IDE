"use strict";
/*---------------------------------------------------------
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *--------------------------------------------------------*/
Object.defineProperty(exports, "__esModule", { value: true });
exports.couldNotConnectToPort = exports.chromeProvidedPortWithoutUserDataDir = exports.getNotExistErrorResponse = void 0;
const errors_1 = require("vscode-chrome-debug-core/out/src/errors");
const nls = require("vscode-nls");
const localize = nls.loadMessageBundle(__filename);
/**
 * 'Path does not exist' error
 */
function getNotExistErrorResponse(attribute, path) {
    return Promise.reject(new errors_1.ErrorWithMessage({
        id: 2007,
        format: localize(0, null, attribute, '{path}'),
        variables: { path }
    }));
}
exports.getNotExistErrorResponse = getNotExistErrorResponse;
function chromeProvidedPortWithoutUserDataDir() {
    return Promise.reject(new errors_1.ErrorWithMessage({
        id: 2008,
        format: localize(1, null),
        sendTelemetry: true
    }));
}
exports.chromeProvidedPortWithoutUserDataDir = chromeProvidedPortWithoutUserDataDir;
function couldNotConnectToPort(address, port) {
    return Promise.reject(new errors_1.ErrorWithMessage({
        id: 2008,
        format: localize(2, null, '{address}', '{port}'),
        variables: { address, port: port.toString() },
        sendTelemetry: true
    }));
}
exports.couldNotConnectToPort = couldNotConnectToPort;

//# sourceMappingURL=errors.js.map
