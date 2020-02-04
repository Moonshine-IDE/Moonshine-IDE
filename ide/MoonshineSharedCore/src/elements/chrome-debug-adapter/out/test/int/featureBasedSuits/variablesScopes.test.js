"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const frameworkTestSupport_1 = require("../framework/frameworkTestSupport");
const variablesWizard_1 = require("../wizards/variables/variablesWizard");
const launchProject_1 = require("../fixtures/launchProject");
const testUsing_1 = require("../fixtures/testUsing");
// Scopes' kinds: 'global' | 'local' | 'with' | 'closure' | 'catch' | 'block' | 'script' | 'eval' | 'module'
// TODO: Test several scopes at the same time. They can be repeated, and the order does matter
suite('Variables scopes', function () {
    testUsing_1.testUsing('local', context => launchProject_1.LaunchProject.create(context, frameworkTestSupport_1.TestProjectSpec.fromTestPath('variablesScopes/localScope')), (launchProject) => __awaiter(this, void 0, void 0, function* () {
        yield launchProject.pausedWizard.waitUntilPausedOnDebuggerStatement();
        yield new variablesWizard_1.VariablesWizard(launchProject.debugClient).assertTopFrameVariablesAre({
            local: `
                this = Window (Object)
                arguments = Arguments(0) [] (Object)
                b = body {text: "", link: "", vLink: "", …} (Object)
                bool = true (boolean)
                buffer = ArrayBuffer(8) {} (Object)
                buffView = Int32Array(2) [234, 0] (Object)
                consoleDotLog = function consoleDotLog(m) { … } (Function)
                e = Error: hi (Object)
                element = body {text: "", link: "", vLink: "", …} (Object)
                fn = () => { … } (Function)
                fn2 = function () { … } (Function)
                globalCode = "page loaded" (string)
                inf = Infinity (number)
                infStr = "Infinity" (string)
                longStr = "this is a\nstring with\nnewlines" (string)
                m = Map(1) {} (Object)
                manyPropsObj = Object {0: 1, 1: 3, 2: 5, …} (Object)
                myVar = Object {num: 1, str: "Global", obj: Object, …} (Object)
                nan = NaN (number)
                obj = Object {a: 2, thing: <accessor>} (Object)
                qqq = undefined (undefined)
                r = /^asdf.*$/g {lastIndex: 0} (Object)
                s = Symbol(hi) (symbol)
                str = "hello" (string)
                xyz = 4 (number)`
        });
    }));
    testUsing_1.testUsing('globals', context => launchProject_1.LaunchProject.create(context, frameworkTestSupport_1.TestProjectSpec.fromTestPath('variablesScopes/globalScope')), (launchProject) => __awaiter(this, void 0, void 0, function* () {
        yield launchProject.pausedWizard.waitUntilPausedOnDebuggerStatement();
        yield new variablesWizard_1.VariablesWizard(launchProject.debugClient).assertNewGlobalVariariablesAre(() => __awaiter(this, void 0, void 0, function* () {
            yield launchProject.pausedWizard.resume();
            yield launchProject.pausedWizard.waitUntilPausedOnDebuggerStatement();
        }), 
        // The variables declared with const, and let aren't global variables so they won't appear here
        `
            b = body {text: "", link: "", vLink: "", …} (Object)
            bool = true (boolean)
            buffer = ArrayBuffer(8) {} (Object)
            buffView = Int32Array(2) [234, 0] (Object)
            consoleDotLog = function consoleDotLog(m) { … } (Function)
            e = Error: hi (Object)
            element = p {align: "", title: "", lang: "", …} (Object)
            evalVar1 = 16 (number)
            evalVar2 = "sdlfk" (string)
            evalVar3 = Array(3) [1, 2, 3] (Object)
            fn = () => { … } (Function)
            fn2 = function () { … } (Function)
            globalCode = "page loaded" (string)
            i = 101 (number)
            inf = Infinity (number)
            infStr = "Infinity" (string)
            longStr = "this is a\nstring with\nnewlines" (string)
            m = Map(1) {} (Object)
            manyPropsObj = Object {0: 1, 1: 3, 2: 5, …} (Object)
            myVar = Object {num: 1, str: "Global", obj: Object, …} (Object)
            nan = NaN (number)
            obj = Object {a: 2, thing: <accessor>} (Object)
            qqq = undefined (undefined)
            r = /^asdf.*$/g {lastIndex: 0} (Object) // TODO: This and other types seems wrong. Investigate
            s = Symbol(hi) (symbol)
            str = "hello" (string)
            xyz = 4 (number)`);
    }));
    testUsing_1.testUsing('script', context => launchProject_1.LaunchProject.create(context, frameworkTestSupport_1.TestProjectSpec.fromTestPath('variablesScopes/scriptScope')), (launchProject) => __awaiter(this, void 0, void 0, function* () {
        yield launchProject.pausedWizard.waitUntilPausedOnDebuggerStatement();
        yield new variablesWizard_1.VariablesWizard(launchProject.debugClient).assertTopFrameVariablesAre({
            script: `
                this = Window (Object)
                b = body {text: "", link: "", vLink: "", …} (Object)
                bool = true (boolean)
                buffer = ArrayBuffer(8) {} (Object)
                buffView = Int32Array(2) [234, 0] (Object)
                e = Error: hi (Object)
                element = body {text: "", link: "", vLink: "", …} (Object)
                fn = () => { … } (Function)
                fn2 = function () { … } (Function)
                globalCode = "page loaded" (string)
                inf = Infinity (number)
                infStr = "Infinity" (string)
                longStr = "this is a\nstring with\nnewlines" (string)
                m = Map(1) {} (Object)
                manyPropsObj = Object {0: 1, 1: 3, 2: 5, …} (Object)
                myVar = Object {num: 1, str: "Global", obj: Object, …} (Object)
                nan = NaN (number)
                obj = Object {a: 2, thing: <accessor>} (Object)
                qqq = undefined (undefined)
                r = /^asdf.*$/g {lastIndex: 0} (Object)
                s = Symbol(hi) (symbol)
                str = "hello" (string)
                xyz = 4 (number)`
        });
    }));
    testUsing_1.testUsing('block', context => launchProject_1.LaunchProject.create(context, frameworkTestSupport_1.TestProjectSpec.fromTestPath('variablesScopes/blockScope')), (launchProject) => __awaiter(this, void 0, void 0, function* () {
        yield launchProject.pausedWizard.waitUntilPausedOnDebuggerStatement();
        yield new variablesWizard_1.VariablesWizard(launchProject.debugClient).assertTopFrameVariablesAre({
            block: `
                    this = Window (Object)
                    b = body {text: "", link: "", vLink: "", …} (Object)
                    bool = true (boolean)
                    buffer = ArrayBuffer(8) {} (Object)
                    buffView = Int32Array(2) [234, 0] (Object)
                    consoleDotLog = function consoleDotLog(m) { … } (Function)
                    e = Error: hi (Object)
                    element = body {text: "", link: "", vLink: "", …} (Object)
                    fn = () => { … } (Function)
                    fn2 = function () { … } (Function)
                    globalCode = "page loaded" (string)
                    inf = Infinity (number)
                    infStr = "Infinity" (string)
                    longStr = "this is a\nstring with\nnewlines" (string)
                    m = Map(1) {} (Object)
                    manyPropsObj = Object {0: 1, 1: 3, 2: 5, …} (Object)
                    myVar = Object {num: 1, str: "Global", obj: Object, …} (Object)
                    nan = NaN (number)
                    obj = Object {a: 2, thing: <accessor>} (Object)
                    qqq = undefined (undefined)
                    r = /^asdf.*$/g {lastIndex: 0} (Object)
                    s = Symbol(hi) (symbol)
                    str = "hello" (string)
                    xyz = 4 (number)`
        });
    }));
    testUsing_1.testUsing('catch', context => launchProject_1.LaunchProject.create(context, frameworkTestSupport_1.TestProjectSpec.fromTestPath('variablesScopes/catchScope')), (launchProject) => __awaiter(this, void 0, void 0, function* () {
        yield launchProject.pausedWizard.waitUntilPausedOnDebuggerStatement();
        yield new variablesWizard_1.VariablesWizard(launchProject.debugClient).assertTopFrameVariablesAre({
            catch: `
                exception = Error: Something went wrong (Object)`
        });
    }));
    testUsing_1.testUsing('closure', context => launchProject_1.LaunchProject.create(context, frameworkTestSupport_1.TestProjectSpec.fromTestPath('variablesScopes/closureScope')), (launchProject) => __awaiter(this, void 0, void 0, function* () {
        yield launchProject.pausedWizard.waitUntilPausedOnDebuggerStatement();
        yield new variablesWizard_1.VariablesWizard(launchProject.debugClient).assertTopFrameVariablesAre({
            closure: `
                arguments = Arguments(0) [] (Object)
                b = body {text: "", link: "", vLink: "", …} (Object)
                bool = true (boolean)
                buffer = ArrayBuffer(8) {} (Object)
                buffView = Int32Array(2) [234, 0] (Object)
                consoleDotLog = function consoleDotLog(m) { … } (Function)
                e = Error: hi (Object)
                element = body {text: "", link: "", vLink: "", …} (Object)
                fn = () => { … } (Function)
                fn2 = function () { … } (Function)
                globalCode = "page loaded" (string)
                inf = Infinity (number)
                infStr = "Infinity" (string)
                longStr = "this is a\nstring with\nnewlines" (string)
                m = Map(1) {} (Object)
                manyPropsObj = Object {0: 1, 1: 3, 2: 5, …} (Object)
                myVar = Object {num: 1, str: "Global", obj: Object, …} (Object)
                nan = NaN (number)
                obj = Object {a: 2, thing: <accessor>} (Object)
                pauseInside = function pauseInside() { … } (Function)
                qqq = undefined (undefined)
                r = /^asdf.*$/g {lastIndex: 0} (Object)
                s = Symbol(hi) (symbol)
                str = "hello" (string)
                xyz = 4 (number)`
        });
    }));
    testUsing_1.testUsing('eval', context => launchProject_1.LaunchProject.create(context, frameworkTestSupport_1.TestProjectSpec.fromTestPath('variablesScopes/evalScope')), (launchProject) => __awaiter(this, void 0, void 0, function* () {
        yield launchProject.pausedWizard.waitUntilPausedOnDebuggerStatement();
        yield new variablesWizard_1.VariablesWizard(launchProject.debugClient).assertTopFrameVariablesAre({
            eval: `
                this = Window (Object)
                b = body {text: "", link: "", vLink: "", …} (Object)
                bool = true (boolean)
                buffer = ArrayBuffer(8) {} (Object)
                buffView = Int32Array(2) [234, 0] (Object)
                e = Error: hi (Object)
                element = body {text: "", link: "", vLink: "", …} (Object)
                fn = () => { … } (Function)
                fn2 = function () { … } (Function)
                globalCode = "page loaded" (string)
                inf = Infinity (number)
                infStr = "Infinity" (string)
                longStr = "this is a\nstring with\nnewlines" (string)
                m = Map(1) {} (Object)
                manyPropsObj = Object {0: 1, 1: 3, 2: 5, …} (Object)
                myVar = Object {num: 1, str: "Global", obj: Object, …} (Object)
                nan = NaN (number)
                obj = Object {a: 2, thing: <accessor>} (Object)
                qqq = undefined (undefined)
                r = /^asdf.*$/g {lastIndex: 0} (Object)
                s = Symbol(hi) (symbol)
                str = "hello" (string)
                xyz = 4 (number)`
        });
    }));
    testUsing_1.testUsing('with', context => launchProject_1.LaunchProject.create(context, frameworkTestSupport_1.TestProjectSpec.fromTestPath('variablesScopes/withScope')), (launchProject) => __awaiter(this, void 0, void 0, function* () {
        yield launchProject.pausedWizard.waitUntilPausedOnDebuggerStatement();
        yield new variablesWizard_1.VariablesWizard(launchProject.debugClient).assertTopFrameVariablesAre({
            with: `
                this = Window (Object)
                b = body {text: "", link: "", vLink: "", …} (Object)
                bool = true (boolean)
                buffer = ArrayBuffer(8) {} (Object)
                buffView = Int32Array(2) [234, 0] (Object)
                consoleDotLog = function (m) { … } (Function)
                e = Error: hi (Object)
                element = body {text: "", link: "", vLink: "", …} (Object)
                evalVar1 = 16 (number)
                evalVar2 = "sdlfk" (string)
                evalVar3 = Array(3) [1, 2, 3] (Object)
                fn = () => { … } (Function)
                fn2 = function () { … } (Function)
                globalCode = "page loaded" (string)
                i = 101 (number)
                inf = Infinity (number)
                infStr = "Infinity" (string)
                longStr = "this is a
                string with
                newlines" (string)
                m = Map(1) {} (Object)
                manyPropsObj = Object {0: 1, 1: 3, 2: 5, …} (Object)
                myVar = Object {num: 1, str: "Global", obj: Object, …} (Object)
                nan = NaN (number)
                obj = Object {a: 2, thing: <accessor>} (Object)
                r = /^asdf.*$/g {lastIndex: 0} (Object)
                s = Symbol(hi) (symbol)
                str = "hello" (string)
                xyz = 4 (number)
                __proto__ = Object {constructor: , __defineGetter__: , __defineSetter__: , …} (Object)`
        });
    }));
    testUsing_1.testUsing('module', context => launchProject_1.LaunchProject.create(context, frameworkTestSupport_1.TestProjectSpec.fromTestPath('variablesScopes/moduleScope')), (launchProject) => __awaiter(this, void 0, void 0, function* () {
        yield launchProject.pausedWizard.waitUntilPausedOnDebuggerStatement();
        yield new variablesWizard_1.VariablesWizard(launchProject.debugClient).assertTopFrameVariablesAre({
            module: `
                this = undefined (undefined)
                b = body {text: "", link: "", vLink: "", …} (Object)
                bool = true (boolean)
                buffer = ArrayBuffer(8) {} (Object)
                buffView = Int32Array(2) [234, 0] (Object)
                consoleDotLog = function consoleDotLog(m2) { … } (Function)
                e = Error: hi (Object)
                element = body {text: "", link: "", vLink: "", …} (Object)
                fn = () => { … } (Function)
                fn2 = function (param) { … } (Function)
                globalCode = "page loaded" (string)
                inf = Infinity (number)
                infStr = "Infinity" (string)
                longStr = "this is a
                string with
                newlines" (string)
                m = Map(1) {} (Object)
                manyPropsObj = Object {0: 1, 1: 3, 2: 5, …} (Object)
                myVar = Object {num: 1, str: "Global", obj: Object, …} (Object)
                nan = NaN (number)
                obj = Object {a: 2, thing: <accessor>} (Object)
                qqq = undefined (undefined)
                r = /^asdf.*$/g {lastIndex: 0} (Object)
                s = Symbol(hi) (symbol)
                str = "hello" (string)
                xyz = 4 (number)`
        });
    }));
});

//# sourceMappingURL=variablesScopes.test.js.map
