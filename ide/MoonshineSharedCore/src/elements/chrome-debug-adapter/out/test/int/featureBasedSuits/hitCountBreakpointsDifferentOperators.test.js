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
const chai_1 = require("chai");
const vscode_debugadapter_1 = require("vscode-debugadapter");
puppeteerSuite_1.puppeteerSuite('Hit count breakpoints combinations', resourceProjects_1.reactWithLoopTestSpecification, (suiteContext) => {
    // * Hit count breakpoint syntax: (>|>=|=|<|<=|%)?\s*([0-9]+)
    const manyConditionsConfigurations = [
        { condition: '=     0', iterationsExpectedToPause: [], noMorePausesAfterwards: true },
        { condition: '= 1', iterationsExpectedToPause: [1], noMorePausesAfterwards: true },
        { condition: '= 2', iterationsExpectedToPause: [2], noMorePausesAfterwards: true },
        { condition: '= 12', iterationsExpectedToPause: [12], noMorePausesAfterwards: true },
        { condition: '> 0', iterationsExpectedToPause: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], noMorePausesAfterwards: false },
        { condition: '> 1', iterationsExpectedToPause: [2, 3, 4, 5, 6, 7, 8, 9, 10], noMorePausesAfterwards: false },
        { condition: '>\t2', iterationsExpectedToPause: [3, 4, 5, 6, 7, 8, 9, 10], noMorePausesAfterwards: false },
        { condition: '> 187', iterationsExpectedToPause: [188, 189, 190, 191], noMorePausesAfterwards: false },
        { condition: '>=   0', iterationsExpectedToPause: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], noMorePausesAfterwards: false },
        { condition: '>= 1', iterationsExpectedToPause: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10], noMorePausesAfterwards: false },
        { condition: '>= 2', iterationsExpectedToPause: [2, 3, 4, 5, 6, 7, 8, 9, 10], noMorePausesAfterwards: false },
        { condition: '>= 37', iterationsExpectedToPause: [37, 38, 39], noMorePausesAfterwards: false },
        { condition: '< 0', iterationsExpectedToPause: [], noMorePausesAfterwards: true },
        { condition: '<  \t  \t     1', iterationsExpectedToPause: [], noMorePausesAfterwards: true },
        { condition: '< 2', iterationsExpectedToPause: [1], noMorePausesAfterwards: true },
        { condition: '<        \t13', iterationsExpectedToPause: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], noMorePausesAfterwards: true },
        { condition: '<=\t    0', iterationsExpectedToPause: [], noMorePausesAfterwards: true },
        { condition: '<= 1', iterationsExpectedToPause: [1], noMorePausesAfterwards: true },
        { condition: '<=            15', iterationsExpectedToPause: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], noMorePausesAfterwards: true },
        { condition: '% 0', iterationsExpectedToPause: [], noMorePausesAfterwards: true },
        { condition: '% 1', iterationsExpectedToPause: [1, 2, 3, 4, 5, 6], noMorePausesAfterwards: false },
        { condition: '% 2', iterationsExpectedToPause: [2, 4, 6, 8, 10], noMorePausesAfterwards: false },
        { condition: '%\t3', iterationsExpectedToPause: [3, 6, 9, 12, 15], noMorePausesAfterwards: false },
        { condition: '%   \t    \t   \t  12', iterationsExpectedToPause: [12, 24, 36, 48, 60], noMorePausesAfterwards: false },
        { condition: '%\t\t\t17', iterationsExpectedToPause: [17, 34, 51, 68], noMorePausesAfterwards: false },
        { condition: '% 37', iterationsExpectedToPause: [37, 74, 111, 148], noMorePausesAfterwards: false },
    ];
    manyConditionsConfigurations.forEach(conditionConfiguration => {
        puppeteerSuite_1.puppeteerTest(`condition ${conditionConfiguration.condition}`, suiteContext, (_context, page) => __awaiter(this, void 0, void 0, function* () {
            const incBtn = yield page.waitForSelector('#incrementBtn');
            const breakpoints = breakpointsWizard_1.BreakpointsWizard.create(suiteContext.debugClient, resourceProjects_1.reactWithLoopTestSpecification);
            const counterBreakpoints = breakpoints.at('Counter.jsx');
            const setStateBreakpoint = yield counterBreakpoints.hitCountBreakpoint({
                text: 'iterationNumber * iterationNumber',
                hitCountCondition: conditionConfiguration.condition
            });
            const buttonClicked = incBtn.click();
            for (const nextIterationToPause of conditionConfiguration.iterationsExpectedToPause) {
                /**
                 * The iterationNumber variable counts in the js-debuggee code how many times the loop was executed. We verify
                 * the value of this variable to validate that a bp with = 12 paused on the 12th iteration rather than on the 1st one
                 * (The breakpoint is located in the same place in both iterations, so we need to use state to differenciate between those two cases)
                 */
                yield setStateBreakpoint.assertIsHitThenResume({ variables: { local_contains: { iterationNumber: nextIterationToPause } } });
            }
            vscode_debugadapter_1.logger.log(`No more pauses afterwards = ${conditionConfiguration.noMorePausesAfterwards}`);
            if (conditionConfiguration.noMorePausesAfterwards) {
                yield breakpoints.waitAndAssertNoMoreEvents();
                yield setStateBreakpoint.unset();
            }
            else {
                yield breakpoints.waitAndConsumePausedEvent(setStateBreakpoint);
                yield setStateBreakpoint.unset();
                yield breakpoints.resume();
            }
            yield buttonClicked;
        }));
    });
    // * Hit count breakpoint syntax: (>|>=|=|<|<=|%)?\s*([0-9]+)
    const manyInvalidConditions = [
        '== 3',
        '= -1',
        '> -200',
        '< -24',
        '< 64\t',
        '< 5      ',
        '>= -95',
        '<= -5',
        '\t= 1',
        '< = 4',
        '         <= 4',
        '% -200',
        'stop always',
        '       = 3     ',
        '= 1 + 1',
        '> 3.5',
    ];
    manyInvalidConditions.forEach(invalidCondition => {
        puppeteerSuite_1.puppeteerTest(`invalid condition ${invalidCondition}`, suiteContext, () => __awaiter(this, void 0, void 0, function* () {
            const breakpoints = breakpointsWizard_1.BreakpointsWizard.create(suiteContext.debugClient, resourceProjects_1.reactWithLoopTestSpecification);
            const counterBreakpoints = breakpoints.at('Counter.jsx');
            try {
                yield counterBreakpoints.hitCountBreakpoint({
                    text: 'iterationNumber * iterationNumber',
                    hitCountCondition: invalidCondition
                });
            }
            catch (exception) {
                chai_1.expect(exception.toString()).to.be.equal(`Error: [debugger-for-chrome] Error processing "setBreakpoints": Didn't recognize <${invalidCondition}> as a valid hit count condition`);
            }
        }));
    });
});

//# sourceMappingURL=hitCountBreakpointsDifferentOperators.test.js.map
