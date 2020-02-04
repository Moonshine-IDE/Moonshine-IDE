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
const _ = require("lodash");
const stackFrameWizard_1 = require("./stackFrameWizard");
const variablesVerifier_1 = require("./variablesVerifier");
const validatedMap_1 = require("../../core-v2/chrome/collections/validatedMap");
const printedTestInputl_1 = require("../breakpoints/implementation/printedTestInputl");
const chai_1 = require("chai");
const variablesPrinting_1 = require("./variablesPrinting");
class VariablesWizard {
    constructor(_client) {
        this._client = _client;
    }
    /** Verify that the global variables have the expected values, ignoring the variables in <namesOfGlobalsToIgnore> */
    assertNewGlobalVariariablesAre(actionThatAddsNewVariables, expectedGlobals) {
        return __awaiter(this, void 0, void 0, function* () {
            // Store pre-existing global variables' names
            const namesOfGlobalsToIgnore = yield (yield this.topStackFrameHelper()).globalVariableNames();
            // Perform an action that adds new global variables
            yield actionThatAddsNewVariables();
            const globalsOnFrame = yield (yield this.topStackFrameHelper()).variablesOfScope('global');
            const nonIgnoredGlobals = globalsOnFrame.filter(global => !namesOfGlobalsToIgnore.has(global.name));
            const expectedGlobalsTrimmed = printedTestInputl_1.trimWhitespaceAndComments(expectedGlobals);
            chai_1.expect(variablesPrinting_1.printVariables(nonIgnoredGlobals)).to.equal(expectedGlobalsTrimmed);
        });
    }
    /**
     * Verify that the stackFrame contains some variables with a specific value
     */
    assertTopFrameVariablesAre(verifications) {
        return __awaiter(this, void 0, void 0, function* () {
            yield this.assertStackFrameVariablesAre(yield this.topStackFrameHelper(), verifications);
        });
    }
    assertStackFrameVariablesAre(stackFrame, verifications) {
        return __awaiter(this, void 0, void 0, function* () {
            const scopesWithModifiers = Object.keys(verifications);
            const scopesWithoutModifiers = scopesWithModifiers.map(s => this.splitIntoScopeNameAndModifier(s)[0]);
            const withoutModifiersToWith = new validatedMap_1.ValidatedMap(_.zip(scopesWithoutModifiers, scopesWithModifiers));
            const manyScopes = yield (stackFrame).variablesOfScopes(scopesWithoutModifiers);
            for (const scope of manyScopes) {
                const scopeNameWithModifier = withoutModifiersToWith.get(scope.scopeName);
                const [, modifier] = this.splitIntoScopeNameAndModifier(scopeNameWithModifier);
                switch (modifier) {
                    case '':
                        this.verificator.assertVariablesAre(scope.variables, verifications[scopeNameWithModifier]);
                        break;
                    case 'contains':
                        this.verificator.assertVariablesValuesContain(scope.variables, verifications[scopeNameWithModifier]);
                        break;
                    default:
                        throw new Error(`Unknown modified used for variables verification: ${modifier} in ${scopeNameWithModifier}`);
                }
            }
        });
    }
    splitIntoScopeNameAndModifier(modifiedScopeName) {
        const components = modifiedScopeName.split('_');
        if (components.length > 2) {
            throw new Error(`Invalid modified scope name: ${modifiedScopeName}`);
        }
        return [components[0], _.defaultTo(components[1], '')];
    }
    get verificator() {
        return new variablesVerifier_1.VariablesVerifier();
    }
    topStackFrameHelper() {
        return __awaiter(this, void 0, void 0, function* () {
            return yield stackFrameWizard_1.StackFrameWizard.topStackFrame(this._client);
        });
    }
}
exports.VariablesWizard = VariablesWizard;

//# sourceMappingURL=variablesWizard.js.map
