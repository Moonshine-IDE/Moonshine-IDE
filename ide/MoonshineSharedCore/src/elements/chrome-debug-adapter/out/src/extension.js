"use strict";
/*---------------------------------------------------------
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *--------------------------------------------------------*/
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
exports.ChromeConfigurationProvider = exports.deactivate = exports.activate = void 0;
const vscode = require("vscode");
const Core = require("vscode-chrome-debug-core");
const nls = require("vscode-nls");
const path = require("path");
const utils_1 = require("./utils");
const localize = nls.loadMessageBundle(__filename);
function activate(context) {
    context.subscriptions.push(vscode.commands.registerCommand('extension.chrome-debug.toggleSkippingFile', toggleSkippingFile));
    context.subscriptions.push(vscode.commands.registerCommand('extension.chrome-debug.toggleSmartStep', toggleSmartStep));
    context.subscriptions.push(vscode.debug.registerDebugConfigurationProvider('legacy-chrome', new ChromeConfigurationProvider()));
}
exports.activate = activate;
function deactivate() {
}
exports.deactivate = deactivate;
class ChromeConfigurationProvider {
    /**
     * Try to add all missing attributes to the debug configuration being launched.
     */
    resolveDebugConfiguration(folder, config, token) {
        return __awaiter(this, void 0, void 0, function* () {
            // if launch.json is missing or empty
            if (!config.type && !config.request && !config.name) {
                // Return null so it will create a launch.json and fall back on provideDebugConfigurations - better to point the user towards the config
                // than try to work automagically.
                return null;
            }
            if (config.request === 'attach') {
                const discovery = new Core.chromeTargetDiscoveryStrategy.ChromeTargetDiscovery(new Core.NullLogger(), new Core.telemetry.NullTelemetryReporter());
                let targets;
                try {
                    targets = yield discovery.getAllTargets(config.address || '127.0.0.1', config.port, config.targetTypes === undefined ? utils_1.defaultTargetFilter : utils_1.getTargetFilter(config.targetTypes), config.url || config.urlFilter);
                }
                catch (e) {
                    // Target not running?
                }
                if (targets && targets.length > 1) {
                    const selectedTarget = yield pickTarget(targets);
                    if (!selectedTarget) {
                        // Quickpick canceled, bail
                        return null;
                    }
                    config.websocketUrl = selectedTarget.websocketDebuggerUrl;
                }
            }
            resolveRemoteUris(folder, config);
            return config;
        });
    }
}
exports.ChromeConfigurationProvider = ChromeConfigurationProvider;
// Must match the strings in -core's remoteMapper.ts
const remoteUriScheme = 'vscode-remote';
const remotePathComponent = '__vscode-remote-uri__';
const isWindows = process.platform === 'win32';
function getFsPath(uri) {
    const fsPath = uri.fsPath;
    return isWindows && !fsPath.match(/^[a-zA-Z]:/) ?
        fsPath.replace(/\\/g, '/') : // Hack - undo the slash normalization that URI does when windows is the current platform
        fsPath;
}
function mapRemoteClientUriToInternalPath(remoteUri) {
    const uriPath = getFsPath(remoteUri);
    const driveLetterMatch = uriPath.match(/^[A-Za-z]:/);
    let internalPath;
    if (!!driveLetterMatch) {
        internalPath = path.win32.join(driveLetterMatch[0], remotePathComponent, uriPath.substr(2));
    }
    else {
        internalPath = path.posix.join('/', remotePathComponent, uriPath);
    }
    return internalPath;
}
function rewriteWorkspaceRoot(configObject, internalWorkspaceRootPath) {
    for (const key in configObject) {
        if (typeof configObject[key] === 'string') {
            configObject[key] = configObject[key].replace(/\$\{workspace(Root|Folder)\}/g, internalWorkspaceRootPath);
        }
        else {
            rewriteWorkspaceRoot(configObject[key], internalWorkspaceRootPath);
        }
    }
}
function resolveRemoteUris(folder, config) {
    if (folder && folder.uri.scheme === remoteUriScheme) {
        const internalPath = mapRemoteClientUriToInternalPath(folder.uri);
        rewriteWorkspaceRoot(config, internalPath);
        config.remoteAuthority = folder.uri.authority;
    }
}
function toggleSkippingFile(aPath) {
    if (!aPath) {
        const activeEditor = vscode.window.activeTextEditor;
        aPath = activeEditor && activeEditor.document.fileName;
    }
    if (aPath && vscode.debug.activeDebugSession) {
        const args = typeof aPath === 'string' ? { path: aPath } : { sourceReference: aPath };
        vscode.debug.activeDebugSession.customRequest('toggleSkipFileStatus', args);
    }
}
function toggleSmartStep() {
    if (vscode.debug.activeDebugSession) {
        vscode.debug.activeDebugSession.customRequest('toggleSmartStep');
    }
}
function pickTarget(targets) {
    return __awaiter(this, void 0, void 0, function* () {
        const items = targets.map(target => ({
            label: unescapeTargetTitle(target.title),
            detail: target.url,
            websocketDebuggerUrl: target.webSocketDebuggerUrl
        }));
        const placeHolder = localize(0, null);
        const selected = yield vscode.window.showQuickPick(items, { placeHolder, matchOnDescription: true, matchOnDetail: true });
        return selected;
    });
}
function unescapeTargetTitle(title) {
    return title
        .replace(/&amp;/g, '&')
        .replace(/&lt;/g, '<')
        .replace(/&gt;/g, '>')
        .replace(/&#39;/g, `'`)
        .replace(/&quot;/g, '"');
}

//# sourceMappingURL=extension.js.map
