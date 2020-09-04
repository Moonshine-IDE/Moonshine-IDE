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
exports.resolveWebRootPattern = exports.ChromeDebugAdapter = void 0;
const nls = require("vscode-nls");
let localize = nls.loadMessageBundle(__filename);
const os = require("os");
const fs = require("fs");
const path = require("path");
const vscode_chrome_debug_core_1 = require("vscode-chrome-debug-core");
const child_process_1 = require("child_process");
const utils = require("./utils");
const errors = require("./errors");
// Keep in sync with sourceMapPathOverrides package.json default
const DefaultWebSourceMapPathOverrides = {
    'webpack:///./~/*': '${webRoot}/node_modules/*',
    'webpack:///./*': '${webRoot}/*',
    'webpack:///*': '*',
    'webpack:///src/*': '${webRoot}/*',
    'meteor://💻app/*': '${webRoot}/*'
};
class ChromeDebugAdapter extends vscode_chrome_debug_core_1.ChromeDebugAdapter {
    constructor() {
        super(...arguments);
        this._pagePauseMessage = 'Paused in Visual Studio Code';
    }
    initialize(args) {
        this._overlayHelper = new utils.DebounceHelper(/*timeoutMs=*/ 200);
        const capabilities = super.initialize(args);
        capabilities.supportsRestartRequest = true;
        capabilities.supportsSetExpression = true;
        capabilities.supportsLogPoints = true;
        if (args.locale) {
            localize = nls.config({ locale: args.locale, bundleFormat: nls.BundleFormat.standalone })(__filename);
        }
        this._doesHostSupportLaunchUnelevatedProcessRequest = args.supportsLaunchUnelevatedProcessRequest || false;
        return capabilities;
    }
    launch(args, telemetryPropertyCollector, seq) {
        if ((args.breakOnLoad || typeof args.breakOnLoad === 'undefined') && !args.breakOnLoadStrategy) {
            args.breakOnLoadStrategy = 'instrument';
        }
        return super.launch(args, telemetryPropertyCollector).then(() => __awaiter(this, void 0, void 0, function* () {
            let runtimeExecutable;
            if (args.shouldLaunchChromeUnelevated !== undefined) {
                telemetryPropertyCollector.addTelemetryProperty('shouldLaunchChromeUnelevated', args.shouldLaunchChromeUnelevated.toString());
            }
            if (this._doesHostSupportLaunchUnelevatedProcessRequest) {
                telemetryPropertyCollector.addTelemetryProperty('doesHostSupportLaunchUnelevated', 'true');
            }
            if (args.runtimeExecutable) {
                const re = findExecutable(args.runtimeExecutable);
                if (!re) {
                    return errors.getNotExistErrorResponse('runtimeExecutable', args.runtimeExecutable);
                }
                runtimeExecutable = re;
            }
            runtimeExecutable = runtimeExecutable || utils.getBrowserPath();
            if (!runtimeExecutable) {
                return vscode_chrome_debug_core_1.utils.errP(localize(0, null));
            }
            // Start with remote debugging enabled
            // allow port = 0
            let port = (args.port !== undefined) ? args.port : 9222;
            const chromeArgs = [];
            const chromeEnv = args.env || null;
            const chromeWorkingDir = args.cwd || null;
            if (!args.noDebug) {
                chromeArgs.push('--remote-debugging-port=' + port);
            }
            // Also start with extra stuff disabled
            chromeArgs.push(...['--no-first-run', '--no-default-browser-check']);
            if (args.runtimeArgs) {
                telemetryPropertyCollector.addTelemetryProperty('numberOfChromeCmdLineSwitchesBeingUsed', String(args.runtimeArgs.length));
                chromeArgs.push(...args.runtimeArgs);
            }
            // Set a default userDataDir, if the user opted in explicitly with 'true' or if args.userDataDir is not set (only when runtimeExecutable is not set).
            // Can't set it automatically with runtimeExecutable because it may not be desired with Electron, other runtimes, random scripts.
            if (args.userDataDir === true ||
                (typeof args.userDataDir === 'undefined' && !args.runtimeExecutable)) {
                args.userDataDir = path.join(os.tmpdir(), `vscode-chrome-debug-userdatadir_${port}`);
            }
            if (args.userDataDir) {
                chromeArgs.push('--user-data-dir=' + args.userDataDir);
                this._chromeConnection.setUserDataDir(args.userDataDir);
            }
            if (args._clientOverlayPausedMessage) {
                this._pagePauseMessage = args._clientOverlayPausedMessage;
            }
            let launchUrl;
            if (args.file) {
                launchUrl = vscode_chrome_debug_core_1.utils.pathToFileURL(args.file);
            }
            else if (args.url) {
                launchUrl = args.url;
            }
            if (launchUrl && !args.noDebug) {
                // We store the launch file/url provided and temporarily launch and attach to about:blank page. Once we receive configurationDone() event, we redirect the page to this file/url
                // This is done to facilitate hitting breakpoints on load
                this._userRequestedUrl = launchUrl;
                launchUrl = 'about:blank';
            }
            if (launchUrl) {
                chromeArgs.push(launchUrl);
            }
            this._chromeProc = yield this.spawnChrome(runtimeExecutable, chromeArgs, chromeEnv, chromeWorkingDir, !!args.runtimeExecutable, args.shouldLaunchChromeUnelevated);
            if (this._chromeProc) {
                this._chromeProc.on('error', (err) => {
                    const errMsg = 'Chrome error: ' + err;
                    vscode_chrome_debug_core_1.logger.error(errMsg);
                    this.terminateSession(errMsg);
                });
            }
            return args.noDebug ? undefined :
                this.doAttach(port, launchUrl || args.urlFilter, args.address, args.timeout, undefined, args.extraCRDPChannelPort);
        }));
    }
    attach(args) {
        if (args.urlFilter) {
            args.url = args.urlFilter;
        }
        return super.attach(args);
    }
    hookConnectionEvents() {
        super.hookConnectionEvents();
        this.chrome.Page.on('frameNavigated', params => this.onFrameNavigated(params));
    }
    onFrameNavigated(params) {
        if (this._userRequestedUrl) {
            const url = params.frame.url;
            const requestedUrlNoAnchor = this._userRequestedUrl.split('#')[0]; // Frame navigated url doesn't include the anchor
            if (url === requestedUrlNoAnchor || decodeURI(url) === requestedUrlNoAnchor) { // 'http://localhost:1234/test%20page' will use the not decoded version, 'http://localhost:1234/test page' will use the decoded version
                // Chrome started to navigate to the user's requested url
                this.events.emit(vscode_chrome_debug_core_1.ChromeDebugSession.FinishedStartingUpEventName, { requestedContentWasDetected: true });
            }
            else if (url === 'chrome-error://chromewebdata/') {
                // Chrome couldn't retrieve the web-page in the requested url
                this.events.emit(vscode_chrome_debug_core_1.ChromeDebugSession.FinishedStartingUpEventName, { requestedContentWasDetected: false, reasonForNotDetected: 'UnreachableURL' });
            }
            else if (url.startsWith('chrome-error://')) {
                // Uknown chrome error
                this.events.emit(vscode_chrome_debug_core_1.ChromeDebugSession.FinishedStartingUpEventName, { requestedContentWasDetected: false, reasonForNotDetected: 'UnknownChromeError' });
            }
        }
    }
    configurationDone() {
        const _super = Object.create(null, {
            configurationDone: { get: () => super.configurationDone }
        });
        return __awaiter(this, void 0, void 0, function* () {
            if (this._userRequestedUrl) {
                // This means all the setBreakpoints requests have been completed. So we can navigate to the original file/url.
                this.chrome.Page.navigate({ url: this._userRequestedUrl }).then(() => {
                    /* __GDPR__FRAGMENT__
                       "StepNames" : {
                          "RequestedNavigateToUserPage" : { "classification": "SystemMetaData", "purpose": "FeatureInsight" }
                       }
                     */
                    this.events.emitMilestoneReached('RequestedNavigateToUserPage');
                });
            }
            yield _super.configurationDone.call(this);
        });
    }
    commonArgs(args) {
        if (args.webRoot && (!args.pathMapping || !args.pathMapping['/'])) {
            args.pathMapping = args.pathMapping || {};
            args.pathMapping['/'] = args.webRoot;
        }
        args.sourceMaps = typeof args.sourceMaps === 'undefined' || args.sourceMaps;
        args.sourceMapPathOverrides = getSourceMapPathOverrides(args.webRoot, args.sourceMapPathOverrides);
        args.skipFileRegExps = ['^chrome-extension:.*'];
        if (args.targetTypes === undefined) {
            args.targetFilter = utils.defaultTargetFilter;
        }
        else {
            args.targetFilter = utils.getTargetFilter(args.targetTypes);
        }
        args.smartStep = typeof args.smartStep === 'undefined' ? !this._isVSClient : args.smartStep;
        super.commonArgs(args);
    }
    doAttach(port, targetUrl, address, timeout, websocketUrl, extraCRDPChannelPort) {
        return super.doAttach(port, targetUrl, address, timeout, websocketUrl, extraCRDPChannelPort).then(() => __awaiter(this, void 0, void 0, function* () {
            // Don't return this promise, a failure shouldn't fail attach
            this.globalEvaluate({ expression: 'navigator.userAgent', silent: true })
                .then(evalResponse => vscode_chrome_debug_core_1.logger.log('Target userAgent: ' + evalResponse.result.value), err => vscode_chrome_debug_core_1.logger.log('Getting userAgent failed: ' + err.message))
                .then(() => {
                const configDisableNetworkCache = this._launchAttachArgs.disableNetworkCache;
                const cacheDisabled = typeof configDisableNetworkCache === 'boolean' ?
                    configDisableNetworkCache :
                    true;
                this.chrome.Network.setCacheDisabled({ cacheDisabled }).catch(() => {
                    // Ignore failure
                });
            });
            const versionInformationPromise = this.chrome.Browser.getVersion().then(response => {
                const properties = {
                    'Versions.Target.CRDPVersion': response.protocolVersion,
                    'Versions.Target.Revision': response.revision,
                    'Versions.Target.UserAgent': response.userAgent,
                    'Versions.Target.V8': response.jsVersion
                };
                const parts = (response.product || '').split('/');
                if (parts.length === 2) { // Currently response.product looks like "Chrome/65.0.3325.162" so we split the project and the actual version number
                    properties['Versions.Target.Project'] = parts[0];
                    properties['Versions.Target.Version'] = parts[1];
                }
                else { // If for any reason that changes, we submit the entire product as-is
                    properties['Versions.Target.Product'] = response.product;
                }
                return properties;
            }, err => {
                vscode_chrome_debug_core_1.logger.log('Getting userAgent failed: ' + err.message);
                const properties = { 'Versions.Target.NoUserAgentReason': 'Error while retriving target user agent' };
                vscode_chrome_debug_core_1.utils.fillErrorDetails(properties, err);
                return properties;
            });
            // Send the versions information as it's own event so we can easily backfill other events in the user session if needed
            /* __GDPR__FRAGMENT__
               "VersionInformation" : {
                  "Versions.Target.CRDPVersion" : { "classification": "SystemMetaData", "purpose": "FeatureInsight" },
                  "Versions.Target.Revision" : { "classification": "SystemMetaData", "purpose": "FeatureInsight" },
                  "Versions.Target.UserAgent" : { "classification": "SystemMetaData", "purpose": "FeatureInsight" },
                  "Versions.Target.V8" : { "classification": "SystemMetaData", "purpose": "FeatureInsight" },
                  "Versions.Target.V<NUMBER>" : { "classification": "SystemMetaData", "purpose": "FeatureInsight" },
                  "Versions.Target.Project" : { "classification": "SystemMetaData", "purpose": "FeatureInsight" },
                  "Versions.Target.Version" : { "classification": "SystemMetaData", "purpose": "FeatureInsight" },
                  "Versions.Target.Product" : { "classification": "SystemMetaData", "purpose": "FeatureInsight" },
                  "Versions.Target.NoUserAgentReason" : { "classification": "SystemMetaData", "purpose": "FeatureInsight" },
                  "${include}": [ "${IExecutionResultTelemetryProperties}" ]
               }
             */
            /* __GDPR__
               "target-version" : {
                  "${include}": [ "${DebugCommonProperties}" ]
               }
             */
            versionInformationPromise.then(versionInformation => vscode_chrome_debug_core_1.telemetry.telemetry.reportEvent('target-version', versionInformation));
            try {
                if (this._breakOnLoadHelper) {
                    // This is what -core is doing. We only actually care to see if this fails, to see if we need to apply the workaround
                    const browserVersion = (yield this._chromeConnection.version).browser;
                    if (!browserVersion.isAtLeastVersion(0, 1)) { // If this is true it means it's unknown version
                        vscode_chrome_debug_core_1.logger.log(`/json/version failed, attempting workaround to get the version`);
                        // If the original way failed, we try to use versionInformationPromise to get this information
                        const versionInformation = yield versionInformationPromise;
                        const alternativeBrowserVersion = vscode_chrome_debug_core_1.Version.parse(versionInformation['Versions.Target.Version']);
                        this._breakOnLoadHelper.setBrowserVersion(alternativeBrowserVersion);
                    }
                }
            }
            catch (exception) {
                // If something fails we report telemetry and we ignore it
                vscode_chrome_debug_core_1.telemetry.telemetry.reportEvent('break-on-load-target-version-workaround-failed', exception);
            }
            /* __GDPR__FRAGMENT__
                "DebugCommonProperties" : {
                    "${include}": [ "${VersionInformation}" ]
                }
            */
            vscode_chrome_debug_core_1.telemetry.telemetry.addCustomGlobalProperty(versionInformationPromise);
        }));
    }
    runConnection() {
        return [
            ...super.runConnection(),
            this.chrome.Page.enable(),
            this.chrome.Network.enable({})
        ];
    }
    onPaused(notification, expectingStopReason = this._expectingStopReason) {
        const _super = Object.create(null, {
            onPaused: { get: () => super.onPaused }
        });
        return __awaiter(this, void 0, void 0, function* () {
            const result = (yield _super.onPaused.call(this, notification, expectingStopReason));
            if (result.didPause) {
                this._overlayHelper.doAndCancel(() => {
                    return this._domains.has('Overlay') ?
                        this.chrome.Overlay.setPausedInDebuggerMessage({ message: this._pagePauseMessage }).catch(() => { }) :
                        this.chrome.Page.configureOverlay({ message: this._pagePauseMessage }).catch(() => { });
                });
            }
            return result;
        });
    }
    threadName() {
        return 'Chrome';
    }
    onResumed() {
        this._overlayHelper.wait(() => {
            return this._domains.has('Overlay') ?
                this.chrome.Overlay.setPausedInDebuggerMessage({}).catch(() => { }) :
                this.chrome.Page.configureOverlay({}).catch(() => { });
        });
        super.onResumed();
    }
    disconnect(args) {
        const _super = Object.create(null, {
            disconnect: { get: () => super.disconnect }
        });
        return __awaiter(this, void 0, void 0, function* () {
            const hadTerminated = this._hasTerminated;
            // Disconnect before killing Chrome, because running "taskkill" when it's paused sometimes doesn't kill it
            _super.disconnect.call(this, args);
            if ((this._chromeProc || this._chromePID) && !hadTerminated) {
                // Only kill Chrome if the 'disconnect' originated from vscode. If we previously terminated
                // due to Chrome shutting down, or devtools taking over, don't kill Chrome.
                if (vscode_chrome_debug_core_1.utils.getPlatform() === 0 /* Windows */ && this._chromePID) {
                    this.killChromeOnWindows(this._chromePID);
                }
                else if (this._chromeProc) {
                    vscode_chrome_debug_core_1.logger.log('Killing Chrome process');
                    this._chromeProc.kill('SIGINT');
                }
            }
            this._chromeProc = null;
        });
    }
    killChromeOnWindows(chromePID) {
        return __awaiter(this, void 0, void 0, function* () {
            let taskkillCmd = `taskkill /PID ${chromePID}`;
            vscode_chrome_debug_core_1.logger.log(`Killing Chrome process by pid: ${taskkillCmd}`);
            try {
                child_process_1.execSync(taskkillCmd);
            }
            catch (e) {
                // The command will fail if process was not found. This can be safely ignored.
            }
            for (let i = 0; i < 10; i++) {
                // Check to see if the process is still running, with CSV output format
                let tasklistCmd = `tasklist /FI "PID eq ${chromePID}" /FO CSV`;
                vscode_chrome_debug_core_1.logger.log(`Looking up process by pid: ${tasklistCmd}`);
                let tasklistOutput = child_process_1.execSync(tasklistCmd).toString();
                // If the process is found, tasklist will output CSV with one of the values being the PID. Exit code will be 0.
                // If the process is not found, tasklist will give a generic "not found" message instead. Exit code will also be 0.
                // If we see an entry in the CSV for the PID, then we can assume the process was found.
                if (!tasklistOutput.includes(`"${chromePID}"`)) {
                    vscode_chrome_debug_core_1.logger.log(`Chrome process with pid ${chromePID} is not running`);
                    return;
                }
                // Give the process some time to close gracefully
                vscode_chrome_debug_core_1.logger.log(`Chrome process with pid ${chromePID} is still alive, waiting...`);
                yield new Promise((resolve) => {
                    setTimeout(resolve, 200);
                });
            }
            // At this point we can assume the process won't close on its own, so force kill it
            let taskkillForceCmd = `taskkill /F /PID ${chromePID}`;
            vscode_chrome_debug_core_1.logger.log(`Killing Chrome process timed out. Killing again using force: ${taskkillForceCmd}`);
            try {
                child_process_1.execSync(taskkillForceCmd);
            }
            catch (e) { }
        });
    }
    /**
     * Opt-in event called when the 'reload' button in the debug widget is pressed
     */
    restart() {
        return this.chrome ?
            this.chrome.Page.reload({ ignoreCache: true }) :
            Promise.resolve();
    }
    spawnChrome(chromePath, chromeArgs, env, cwd, usingRuntimeExecutable, shouldLaunchUnelevated) {
        return __awaiter(this, void 0, void 0, function* () {
            /* __GDPR__FRAGMENT__
               "StepNames" : {
                  "LaunchTarget.LaunchExe" : { "classification": "SystemMetaData", "purpose": "FeatureInsight" }
               }
             */
            this.events.emitStepStarted('LaunchTarget.LaunchExe');
            const platform = vscode_chrome_debug_core_1.utils.getPlatform();
            if (platform === 0 /* Windows */ && shouldLaunchUnelevated) {
                let chromePid;
                if (this._doesHostSupportLaunchUnelevatedProcessRequest) {
                    chromePid = yield this.spawnChromeUnelevatedWithClient(chromePath, chromeArgs);
                }
                else {
                    chromePid = yield this.spawnChromeUnelevatedWithWindowsScriptHost(chromePath, chromeArgs);
                }
                this._chromePID = chromePid;
                // Cannot get the real Chrome process, so return null.
                return null;
            }
            else if (platform === 0 /* Windows */ && !usingRuntimeExecutable) {
                const options = {
                    execArgv: [],
                    silent: true
                };
                if (env) {
                    options['env'] = this.getFullEnv(env);
                }
                if (cwd) {
                    options['cwd'] = cwd;
                }
                const chromeProc = child_process_1.fork(getChromeSpawnHelperPath(), [chromePath, ...chromeArgs], options);
                chromeProc.unref();
                chromeProc.on('message', data => {
                    const pidStr = data.toString();
                    vscode_chrome_debug_core_1.logger.log('got chrome PID: ' + pidStr);
                    this._chromePID = parseInt(pidStr, 10);
                });
                chromeProc.on('error', (err) => {
                    const errMsg = 'chromeSpawnHelper error: ' + err;
                    vscode_chrome_debug_core_1.logger.error(errMsg);
                });
                chromeProc.stderr.on('data', data => {
                    vscode_chrome_debug_core_1.logger.error('[chromeSpawnHelper] ' + data.toString());
                });
                chromeProc.stdout.on('data', data => {
                    vscode_chrome_debug_core_1.logger.log('[chromeSpawnHelper] ' + data.toString());
                });
                return chromeProc;
            }
            else {
                vscode_chrome_debug_core_1.logger.log(`spawn('${chromePath}', ${JSON.stringify(chromeArgs)})`);
                const options = {
                    detached: true,
                    stdio: ['ignore'],
                };
                if (env) {
                    options['env'] = this.getFullEnv(env);
                }
                if (cwd) {
                    options['cwd'] = cwd;
                }
                const chromeProc = child_process_1.spawn(chromePath, chromeArgs, options);
                chromeProc.unref();
                this._chromePID = chromeProc.pid;
                return chromeProc;
            }
        });
    }
    spawnChromeUnelevatedWithWindowsScriptHost(chromePath, chromeArgs) {
        return __awaiter(this, void 0, void 0, function* () {
            const semaphoreFile = path.join(os.tmpdir(), 'launchedUnelevatedChromeProcess.id');
            if (fs.existsSync(semaphoreFile)) { // remove the previous semaphoreFile if it exists.
                fs.unlinkSync(semaphoreFile);
            }
            const chromeProc = child_process_1.fork(getChromeSpawnHelperPath(), [`${process.env.windir}\\System32\\cscript.exe`, path.join(__dirname, 'launchUnelevated.js'),
                semaphoreFile, chromePath, ...chromeArgs], {});
            chromeProc.unref();
            yield new Promise((resolve, reject) => {
                chromeProc.on('message', resolve);
            });
            const pidStr = yield findNewlyLaunchedChromeProcess(semaphoreFile);
            if (pidStr) {
                vscode_chrome_debug_core_1.logger.log(`Parsed output file and got Chrome PID ${pidStr}`);
                return parseInt(pidStr, 10);
            }
            return null;
        });
    }
    getFullEnv(customEnv) {
        const env = Object.assign(Object.assign({}, process.env), customEnv);
        Object.keys(env).filter(k => env[k] === null).forEach(key => delete env[key]);
        return env;
    }
    spawnChromeUnelevatedWithClient(chromePath, chromeArgs) {
        return __awaiter(this, void 0, void 0, function* () {
            return new Promise((resolve, reject) => {
                this._session.sendRequest('launchUnelevated', {
                    'process': chromePath,
                    'args': chromeArgs
                }, 10000, (response) => {
                    if (!response.success) {
                        reject(new Error(response.message));
                    }
                    else {
                        resolve(response.body.processId);
                    }
                });
            });
        });
    }
    setExpression(args) {
        return __awaiter(this, void 0, void 0, function* () {
            const reconstructedExpression = `${args.expression} = ${args.value}`;
            const evaluateEventArgs = {
                expression: reconstructedExpression,
                frameId: args.frameId,
                format: args.format,
                context: 'repl'
            };
            const evaluateResult = yield this.evaluate(evaluateEventArgs);
            return {
                value: evaluateResult.result
            };
            // Beware that after the expression is changed, the variables on the current stackFrame will not
            // be updated, which means the return value of the Runtime.getProperties request will not contain
            // this change until the breakpoint is released(step over or continue).
            //
            // See also: https://bugs.chromium.org/p/chromium/issues/detail?id=820535
        });
    }
}
exports.ChromeDebugAdapter = ChromeDebugAdapter;
function getSourceMapPathOverrides(webRoot, sourceMapPathOverrides) {
    return sourceMapPathOverrides ? resolveWebRootPattern(webRoot, sourceMapPathOverrides, /*warnOnMissing=*/ true) :
        resolveWebRootPattern(webRoot, DefaultWebSourceMapPathOverrides, /*warnOnMissing=*/ false);
}
/**
 * Returns a copy of sourceMapPathOverrides with the ${webRoot} pattern resolved in all entries.
 *
 * dynamically required by test
 */
function resolveWebRootPattern(webRoot, sourceMapPathOverrides, warnOnMissing) {
    const resolvedOverrides = {};
    for (let pattern in sourceMapPathOverrides) {
        const replacePattern = replaceWebRootInSourceMapPathOverridesEntry(webRoot, pattern, warnOnMissing);
        const replacePatternValue = replaceWebRootInSourceMapPathOverridesEntry(webRoot, sourceMapPathOverrides[pattern], warnOnMissing);
        resolvedOverrides[replacePattern] = replacePatternValue;
    }
    return resolvedOverrides;
}
exports.resolveWebRootPattern = resolveWebRootPattern;
function replaceWebRootInSourceMapPathOverridesEntry(webRoot, entry, warnOnMissing) {
    const webRootIndex = entry.indexOf('${webRoot}');
    if (webRootIndex === 0) {
        if (webRoot) {
            return entry.replace('${webRoot}', webRoot);
        }
        else if (warnOnMissing) {
            vscode_chrome_debug_core_1.logger.log('Warning: sourceMapPathOverrides entry contains ${webRoot}, but webRoot is not set');
        }
    }
    else if (webRootIndex > 0) {
        vscode_chrome_debug_core_1.logger.log('Warning: in a sourceMapPathOverrides entry, ${webRoot} is only valid at the beginning of the path');
    }
    return entry;
}
function getChromeSpawnHelperPath() {
    return path.join(__dirname, 'chromeSpawnHelper.js');
}
function findExecutable(program) {
    if (process.platform === 'win32' && !path.extname(program)) {
        const PATHEXT = process.env['PATHEXT'];
        if (PATHEXT) {
            const executableExtensions = PATHEXT.split(';');
            for (const extension of executableExtensions) {
                const programPath = program + extension;
                if (fs.existsSync(programPath)) {
                    return programPath;
                }
            }
        }
    }
    if (fs.existsSync(program)) {
        return program;
    }
    return undefined;
}
function findNewlyLaunchedChromeProcess(semaphoreFile) {
    return __awaiter(this, void 0, void 0, function* () {
        const regexPattern = /processid\s+=\s+(\d+)\s*;/i;
        let lastAccessFileContent;
        for (let i = 0; i < 25; i++) {
            if (fs.existsSync(semaphoreFile)) {
                lastAccessFileContent = fs.readFileSync(semaphoreFile, {
                    encoding: 'utf16le'
                }).toString();
                const lines = lastAccessFileContent.split('\n');
                const matchedLines = (lines || []).filter(line => line.match(regexPattern));
                if (matchedLines.length > 1) {
                    throw new Error(`Unexpected semaphore file format ${lines}`);
                }
                if (matchedLines.length === 1) {
                    const match = matchedLines[0].match(regexPattern);
                    return match[1];
                }
                // else == 0, wait for 200 ms delay and try again.
            }
            yield new Promise((resolve) => {
                setTimeout(resolve, 200);
            });
        }
        const error = new Error(`Cannot acquire Chrome process id`);
        let telemetryProperties = {
            semaphoreFileContent: lastAccessFileContent
        };
        vscode_chrome_debug_core_1.utils.fillErrorDetails(telemetryProperties, error);
        /* __GDPR__
           "error" : {
              "semaphoreFileContent" : { "classification": "SystemMetaData", "purpose": "FeatureInsight" },
              "${include}": [
                  "${IExecutionResultTelemetryProperties}",
                  "${DebugCommonProperties}"
                ]
           }
         */
        vscode_chrome_debug_core_1.telemetry.telemetry.reportEvent('error', telemetryProperties);
        return null;
    });
}

//# sourceMappingURL=chromeDebugAdapter.js.map
