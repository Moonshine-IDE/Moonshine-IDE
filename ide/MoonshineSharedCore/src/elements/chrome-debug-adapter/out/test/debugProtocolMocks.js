"use strict";
/*---------------------------------------------------------
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *--------------------------------------------------------*/
/* tslint:disable:typedef */
// Copied from -core because I don't want to include test stuff in the npm package
Object.defineProperty(exports, "__esModule", { value: true });
const events_1 = require("events");
const typemoq_1 = require("typemoq");
function getBrowserStubs() {
    return {
        getVersion() { return Promise.resolve({}); }
    };
}
// See https://github.com/florinn/typemoq/issues/20
function getConsoleStubs() {
    return {
        enable() { },
        on(eventName, handler) { }
    };
}
function getDebuggerStubs(mockEventEmitter) {
    return {
        setBreakpoint() { },
        setBreakpointByUrl() { },
        removeBreakpoint() { },
        enable() { },
        evaluateOnCallFrame() { },
        setBlackboxPatterns() { return Promise.resolve(); },
        setAsyncCallStackDepth() { },
        on(eventName, handler) { mockEventEmitter.on(`Debugger.${eventName}`, handler); }
    };
}
function getNetworkStubs() {
    return {
        enable() { },
        setCacheDisabled() { }
    };
}
function getRuntimeStubs(mockEventEmitter) {
    return {
        enable() { },
        evaluate() { },
        on(eventName, handler) { mockEventEmitter.on(`Runtime.${eventName}`, handler); }
    };
}
function getInspectorStubs(mockEventEmitter) {
    return {
        on(eventName, handler) { mockEventEmitter.on(`Inspector.${eventName}`, handler); }
    };
}
function getPageStubs() {
    return {
        enable() { },
        on(eventName, handler) { }
    };
}
function getLogStubs() {
    return {
        enable() { return Promise.resolve(); },
        on(eventName, handler) { }
    };
}
function getMockChromeConnectionApi() {
    const mockEventEmitter = new events_1.EventEmitter();
    const mockConsole = typemoq_1.Mock.ofInstance(getConsoleStubs());
    mockConsole.callBase = true;
    mockConsole
        .setup(x => x.enable())
        .returns(() => Promise.resolve());
    const mockDebugger = typemoq_1.Mock.ofInstance(getDebuggerStubs(mockEventEmitter));
    mockDebugger.callBase = true;
    mockDebugger
        .setup(x => x.enable())
        .returns(() => Promise.resolve(null));
    const mockNetwork = typemoq_1.Mock.ofInstance(getNetworkStubs());
    mockNetwork.callBase = true;
    mockNetwork
        .setup(x => x.enable(typemoq_1.It.isAny()))
        .returns(() => Promise.resolve());
    const mockRuntime = typemoq_1.Mock.ofInstance(getRuntimeStubs(mockEventEmitter));
    mockRuntime.callBase = true;
    mockRuntime
        .setup(x => x.enable())
        .returns(() => Promise.resolve());
    const mockInspector = typemoq_1.Mock.ofInstance(getInspectorStubs(mockEventEmitter));
    mockInspector.callBase = true;
    const mockPage = typemoq_1.Mock.ofInstance(getPageStubs());
    const mockBrowser = typemoq_1.Mock.ofInstance(getBrowserStubs());
    mockBrowser.callBase = true;
    const mockLog = typemoq_1.Mock.ofInstance(getLogStubs());
    mockLog.callBase = true;
    const chromeConnectionAPI = {
        Browser: mockBrowser.object,
        Console: mockConsole.object,
        Debugger: mockDebugger.object,
        Runtime: mockRuntime.object,
        Inspector: mockInspector.object,
        Network: mockNetwork.object,
        Page: mockPage.object,
        Log: mockLog.object
    };
    return {
        apiObjects: chromeConnectionAPI,
        Browser: mockBrowser,
        Console: mockConsole,
        Debugger: mockDebugger,
        Runtime: mockRuntime,
        Inspector: mockInspector,
        Network: mockNetwork,
        Page: mockPage,
        Log: mockLog,
        mockEventEmitter
    };
}
exports.getMockChromeConnectionApi = getMockChromeConnectionApi;

//# sourceMappingURL=debugProtocolMocks.js.map
