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
const http_server_1 = require("http-server");
const vscode_debugadapter_1 = require("vscode-debugadapter");
const url_1 = require("url");
function createServerAsync(root) {
    return __awaiter(this, void 0, void 0, function* () {
        const server = http_server_1.createServer({ root });
        return yield new Promise((resolve, reject) => {
            vscode_debugadapter_1.logger.log(`About to launch web-server`);
            server.listen(0, '127.0.0.1', function (error) {
                if (error) {
                    reject(error);
                }
                else {
                    resolve(this); // We return the this pointer which is the internal server object, which has access to the .address() method
                }
            });
        });
    });
}
function closeServer(server) {
    return __awaiter(this, void 0, void 0, function* () {
        vscode_debugadapter_1.logger.log(`Closing web-server`);
        yield new Promise((resolve, reject) => {
            server.close((error) => {
                if (error) {
                    vscode_debugadapter_1.logger.log('Error closing server in teardown: ' + (error && error.message));
                    reject(error);
                }
                else {
                    resolve();
                }
            });
        });
        vscode_debugadapter_1.logger.log(`Web-server closed`);
    });
}
/**
 * Launch a web-server for the test project listening on the default port
 */
class LaunchWebServer {
    constructor(_server, _testSpec) {
        this._server = _server;
        this._testSpec = _testSpec;
    }
    static launch(testSpec) {
        return __awaiter(this, void 0, void 0, function* () {
            return new LaunchWebServer(yield createServerAsync(testSpec.props.webRoot), testSpec);
        });
    }
    get url() {
        const address = this._server.address();
        return new url_1.URL(`http://localhost:${address.port}/`);
    }
    get launchConfig() {
        return Object.assign({}, this._testSpec.props.launchConfig, { url: this.url.toString() });
    }
    get port() {
        return this._server.address().port;
    }
    cleanUp() {
        return __awaiter(this, void 0, void 0, function* () {
            yield closeServer(this._server);
        });
    }
    toString() {
        return `LaunchWebServer`;
    }
}
exports.LaunchWebServer = LaunchWebServer;
class ProvideStaticUrl {
    constructor(url, testSpec) {
        this.url = url;
        this.testSpec = testSpec;
    }
    get launchConfig() {
        return Object.assign({}, this.testSpec.props.launchConfig, { url: this.url.href });
    }
    cleanUp() { }
}
exports.ProvideStaticUrl = ProvideStaticUrl;

//# sourceMappingURL=launchWebServer.js.map
