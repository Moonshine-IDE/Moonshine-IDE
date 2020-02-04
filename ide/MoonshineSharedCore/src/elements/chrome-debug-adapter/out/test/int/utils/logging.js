"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const path = require("path");
const vscode_debugadapter_1 = require("vscode-debugadapter");
const logger_1 = require("vscode-debugadapter/lib/logger");
const methodsCalledLogger_1 = require("../core-v2/chrome/logging/methodsCalledLogger");
const useDateTimeInLog = false;
function dateTimeForFilePath() {
    return new Date().toISOString().replace(/:/g, '').replace('T', ' ').replace(/\.[0-9]+^/, '');
}
function dateTimeForFilePathIfNeeded() {
    return useDateTimeInLog ? `-${dateTimeForFilePath()}` : '';
}
const logsFolderPath = path.resolve(process.cwd(), 'logs');
function getDebugAdapterLogFilePath(testTitle) {
    return logFilePath(testTitle, 'DA');
}
exports.getDebugAdapterLogFilePath = getDebugAdapterLogFilePath;
/**
 * Transforms a title to an equivalent title that can be used as a filename (We use this to convert the name of our tests into the name of the logfile for that test)
 */
function sanitizeTestTitle(testTitle) {
    return testTitle
        .replace(/[:\/\\]/g, '-')
        // These replacements are needed for the hit count breakpoint tests, which have these characters in their title
        .replace(/ > /g, ' bigger than ')
        .replace(/ < /g, ' smaller than ')
        .replace(/ >= /g, ' bigger than or equal to ')
        .replace(/ <= /g, ' smaller than or equal to ');
}
function logFilePath(testTitle, logType) {
    return path.join(logsFolderPath, `${process.platform}-${sanitizeTestTitle(testTitle)}-${logType}${dateTimeForFilePathIfNeeded()}.log`);
}
vscode_debugadapter_1.logger.init(() => { });
// Dispose the logger on unhandled errors, so it'll flush the remaining contents of the log...
process.on('uncaughtException', () => vscode_debugadapter_1.logger.dispose());
process.on('unhandledRejection', () => vscode_debugadapter_1.logger.dispose());
let currentTestTitle = '';
function setTestLogName(testTitle) {
    // We call setTestLogName in the common setup code. We want to call it earlier in puppeteer tests to get the logs even when the setup fails
    // So we write this code to be able to call it two times, and the second time will get ignored
    if (testTitle !== currentTestTitle) {
        vscode_debugadapter_1.logger.setup(logger_1.LogLevel.Verbose, logFilePath(testTitle, 'TEST'));
        testTitle = currentTestTitle;
    }
}
exports.setTestLogName = setTestLogName;
class PuppeteerMethodsCalledLoggerConfiguration {
    constructor() {
        this._wrapped = new methodsCalledLogger_1.MethodsCalledLoggerConfiguration('', []);
        this.replacements = [];
    }
    customizeResult(methodName, args, result) {
        if (methodName === 'waitForSelector' && typeof result === 'object' && args.length >= 1) {
            return methodsCalledLogger_1.wrapWithMethodLogger(result, args[0]);
        }
        else {
            return result;
        }
    }
    customizeArgumentsBeforeCall(receiverName, methodName, args) {
        this._wrapped.customizeArgumentsBeforeCall(receiverName, methodName, args);
    }
}
function logCallsTo(object, name) {
    return new methodsCalledLogger_1.MethodsCalledLogger(new PuppeteerMethodsCalledLoggerConfiguration(), object, name).wrapped();
}
exports.logCallsTo = logCallsTo;

//# sourceMappingURL=logging.js.map
