"use strict";
/*---------------------------------------------------------
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *--------------------------------------------------------*/
Object.defineProperty(exports, "__esModule", { value: true });
const nls = require("vscode-nls"); // MUST BE FIRST IMPORT
nls.config({ bundleFormat: nls.BundleFormat.standalone });
const vscode_chrome_debug_core_1 = require("vscode-chrome-debug-core");
const path = require("path");
const os = require("os");
const utils_1 = require("./utils");
const chromeDebugAdapter_1 = require("./chromeDebugAdapter");
const chromeProvidedPortConnection_1 = require("./chromeProvidedPortConnection");
const EXTENSION_NAME = 'debugger-for-chrome';
// Start a ChromeDebugSession configured to only match 'page' targets, which are Chrome tabs.
// Cast because DebugSession is declared twice - in this repo's vscode-debugadapter, and that of -core... TODO
vscode_chrome_debug_core_1.ChromeDebugSession.run(vscode_chrome_debug_core_1.ChromeDebugSession.getSession({
    adapter: chromeDebugAdapter_1.ChromeDebugAdapter,
    extensionName: EXTENSION_NAME,
    logFilePath: path.resolve(os.tmpdir(), 'vscode-chrome-debug.txt'),
    targetFilter: utils_1.defaultTargetFilter,
    chromeConnection: chromeProvidedPortConnection_1.ChromeProvidedPortConnection,
    pathTransformer: vscode_chrome_debug_core_1.UrlPathTransformer,
    sourceMapTransformer: vscode_chrome_debug_core_1.BaseSourceMapTransformer,
}));
/* tslint:disable:no-var-requires */
const debugAdapterVersion = require('../../package.json').version;
vscode_chrome_debug_core_1.logger.log(EXTENSION_NAME + ': ' + debugAdapterVersion);
/* __GDPR__FRAGMENT__
    "DebugCommonProperties" : {
        "Versions.DebugAdapter" : { "classification": "SystemMetaData", "purpose": "FeatureInsight" }
    }
*/
vscode_chrome_debug_core_1.telemetry.telemetry.addCustomGlobalProperty({ 'Versions.DebugAdapter': debugAdapterVersion });

//# sourceMappingURL=chromeDebug.js.map
