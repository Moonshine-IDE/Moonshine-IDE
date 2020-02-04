"use strict";
/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/
Object.defineProperty(exports, "__esModule", { value: true });
const chai_1 = require("chai");
const printedTestInputl_1 = require("../breakpoints/implementation/printedTestInputl");
const variablesPrinting_1 = require("./variablesPrinting");
/** Whether the expected variables should match exactly the actual variables of the debuggee
 * or whether the expected variables should only be a subset of the actual variables of the debuggee
 */
var KindOfVerification;
(function (KindOfVerification) {
    KindOfVerification[KindOfVerification["SameAndExact"] = 0] = "SameAndExact";
    KindOfVerification[KindOfVerification["ProperSubset"] = 1] = "ProperSubset"; /** Expected variables are a subset of the actual variables */
})(KindOfVerification = exports.KindOfVerification || (exports.KindOfVerification = {}));
/**
 * Provide methods to validate that the variables appearing on the stack trace are what we expect
 */
class VariablesVerifier {
    /** Verify that the actual variables are exactly the variables that we expect */
    assertVariablesAre(variables, expectedVariables) {
        if (typeof expectedVariables === 'string') {
            this.assertVariablesPrintedAre(variables, expectedVariables);
        }
        else {
            this.assertVariablesValuesAre(variables, expectedVariables);
        }
    }
    assertVariablesPrintedAre(variables, expectedVariablesPrinted) {
        const trimmedVariables = printedTestInputl_1.trimWhitespaceAndComments(expectedVariablesPrinted);
        chai_1.expect(variablesPrinting_1.printVariables(variables)).to.equal(trimmedVariables);
    }
    assertVariablesValuesAre(manyVariables, expectedVariablesValues) {
        return this.assertVariablesValuesSatisfy(manyVariables, expectedVariablesValues, KindOfVerification.SameAndExact);
    }
    /** Verify that the actual variables include as a proper subset the variables that we expect */
    assertVariablesValuesContain(manyVariables, expectedVariablesValues) {
        return this.assertVariablesValuesSatisfy(manyVariables, expectedVariablesValues, KindOfVerification.ProperSubset);
    }
    /** Verify that the actual variables match the expected variables with the verification specified as a parameter (Same or subset) */
    assertVariablesValuesSatisfy(manyVariables, expectedVariablesValues, kindOfVerification) {
        const actualVariableNames = manyVariables.map(variable => variable.name);
        const expectedVariablesNames = Object.keys(expectedVariablesValues);
        switch (kindOfVerification) {
            case KindOfVerification.ProperSubset:
                chai_1.expect(actualVariableNames).to.contain.members(expectedVariablesNames);
                break;
            case KindOfVerification.SameAndExact:
                chai_1.expect(actualVariableNames).to.have.members(expectedVariablesNames);
                break;
            default:
                throw new Error(`Unexpected comparison algorithm: ${kindOfVerification}`);
        }
        for (const variable of manyVariables) {
            const variableName = variable.name;
            if (expectedVariablesNames.indexOf(variableName) >= 0) {
                const expectedValue = expectedVariablesValues[variableName];
                chai_1.expect(expectedValue).to.not.equal(undefined);
                chai_1.expect(variable.evaluateName).to.be.equal(variable.name); // Is this ever different?
                chai_1.expect(variable.variablesReference).to.be.greaterThan(-1);
                chai_1.expect(variable.value).to.be.equal(`${expectedValue}`);
                // TODO: Validate variable type too
            }
            else {
                chai_1.expect(kindOfVerification).to.equal(KindOfVerification.ProperSubset); // This should not happen for same elements
            }
        }
    }
}
exports.VariablesVerifier = VariablesVerifier;

//# sourceMappingURL=variablesVerifier.js.map
