"use strict";
/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const puppeteerSuite_1 = require("../puppeteer/puppeteerSuite");
const resourceProjects_1 = require("../resources/resourceProjects");
const breakpointsWizard_1 = require("../wizards/breakpoints/breakpointsWizard");
const repeat_1 = require("../utils/repeat");
puppeteerSuite_1.puppeteerSuite('Hit count breakpoints on a React project', resourceProjects_1.reactTestSpecification, (suiteContext) => {
    puppeteerSuite_1.puppeteerTest("Hit count breakpoint = 3 pauses on the button's 3rd click", suiteContext, (_context, page) => __awaiter(this, void 0, void 0, function* () {
        const incBtn = yield page.waitForSelector('#incrementBtn');
        const breakpoints = breakpointsWizard_1.BreakpointsWizard.create(suiteContext.debugClient, resourceProjects_1.reactTestSpecification);
        const counterBreakpoints = breakpoints.at('Counter.jsx');
        const setStateBreakpoint = yield counterBreakpoints.hitCountBreakpoint({
            text: 'this.setState({ count: newval });',
            boundText: 'setState({ count: newval })',
            hitCountCondition: '% 3'
        });
        yield repeat_1.asyncRepeatSerially(2, () => incBtn.click());
        yield setStateBreakpoint.assertIsHitThenResumeWhen(() => incBtn.click());
        yield incBtn.click();
        yield breakpoints.waitAndAssertNoMoreEvents();
        yield setStateBreakpoint.unset();
    }));
    puppeteerSuite_1.puppeteerTest("Hit count breakpoints = 3, = 4 and = 5 pause on the button's 3rd, 4th and 5th clicks", suiteContext, (_context, page) => __awaiter(this, void 0, void 0, function* () {
        const incBtn = yield page.waitForSelector('#incrementBtn');
        const breakpoints = breakpointsWizard_1.BreakpointsWizard.create(suiteContext.debugClient, resourceProjects_1.reactTestSpecification);
        const counterBreakpoints = breakpoints.at('Counter.jsx');
        const setStateBreakpoint = yield counterBreakpoints.hitCountBreakpoint({
            text: 'this.setState({ count: newval })',
            boundText: 'setState({ count: newval })',
            hitCountCondition: '= 3'
        });
        const setNewValBreakpoint = yield counterBreakpoints.hitCountBreakpoint({
            text: 'const newval = this.state.count + 1',
            boundText: 'state.count + 1',
            hitCountCondition: '= 5'
        });
        const stepInBreakpoint = yield counterBreakpoints.hitCountBreakpoint({
            text: 'this.stepIn()',
            boundText: 'stepIn()',
            hitCountCondition: '= 4'
        });
        yield repeat_1.asyncRepeatSerially(2, () => incBtn.click());
        yield setStateBreakpoint.assertIsHitThenResumeWhen(() => incBtn.click());
        yield stepInBreakpoint.assertIsHitThenResumeWhen(() => incBtn.click());
        yield setNewValBreakpoint.assertIsHitThenResumeWhen(() => incBtn.click());
        yield incBtn.click();
        yield breakpoints.waitAndAssertNoMoreEvents();
        yield setStateBreakpoint.unset();
        yield setNewValBreakpoint.unset();
        yield stepInBreakpoint.unset();
    }));
    puppeteerSuite_1.puppeteerTest("Hit count breakpoints = 3, = 4 and = 5 set in batch pause on the button's 3rd, 4th and 5th clicks", suiteContext, (_context, page) => __awaiter(this, void 0, void 0, function* () {
        const incBtn = yield page.waitForSelector('#incrementBtn');
        const breakpoints = breakpointsWizard_1.BreakpointsWizard.create(suiteContext.debugClient, resourceProjects_1.reactTestSpecification);
        const counterBreakpoints = breakpoints.at('Counter.jsx');
        const { setStateBreakpoint, stepInBreakpoint, setNewValBreakpoint } = yield counterBreakpoints.batch(() => __awaiter(this, void 0, void 0, function* () {
            return ({
                setStateBreakpoint: yield counterBreakpoints.hitCountBreakpoint({
                    text: 'this.setState({ count: newval });',
                    boundText: 'setState({ count: newval })',
                    hitCountCondition: '= 3'
                }),
                setNewValBreakpoint: yield counterBreakpoints.hitCountBreakpoint({
                    text: 'const newval = this.state.count + 1',
                    boundText: 'state.count + 1',
                    hitCountCondition: '= 5'
                }),
                stepInBreakpoint: yield counterBreakpoints.hitCountBreakpoint({
                    text: 'this.stepIn();',
                    boundText: 'stepIn()',
                    hitCountCondition: '= 4'
                })
            });
        }));
        yield repeat_1.asyncRepeatSerially(2, () => incBtn.click());
        yield setStateBreakpoint.assertIsHitThenResumeWhen(() => incBtn.click());
        yield stepInBreakpoint.assertIsHitThenResumeWhen(() => incBtn.click());
        yield setNewValBreakpoint.assertIsHitThenResumeWhen(() => incBtn.click());
        yield incBtn.click();
        yield breakpoints.waitAndAssertNoMoreEvents();
        yield counterBreakpoints.batch(() => __awaiter(this, void 0, void 0, function* () {
            yield setStateBreakpoint.unset();
            yield setNewValBreakpoint.unset();
            yield stepInBreakpoint.unset();
        }));
    }));
});

//# sourceMappingURL=hitCountBreakpointTests.test.js.map
