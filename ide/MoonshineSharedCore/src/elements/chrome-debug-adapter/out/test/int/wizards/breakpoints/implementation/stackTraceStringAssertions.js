"use strict";
/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/
Object.defineProperty(exports, "__esModule", { value: true });
const assert = require("assert");
const chai_1 = require("chai");
const findPositionOfTextInFile_1 = require("../../../utils/findPositionOfTextInFile");
const printedTestInputl_1 = require("./printedTestInputl");
class StackTraceStringAssertions {
    constructor(_breakpoint) {
        this._breakpoint = _breakpoint;
    }
    assertResponseMatches(stackTraceFrames, expectedString) {
        stackTraceFrames.forEach(frame => {
            // Warning: We don't currently validate frame.source.path
            chai_1.expect(frame.source).not.to.equal(undefined);
            const expectedSourceNameAndLine = ` [${frame.source.name}] Line ${frame.line}`;
            chai_1.expect(frame.name, 'Expected the formatted name to match the source name and line supplied as individual attributes').to.endsWith(expectedSourceNameAndLine);
        });
        const formattedExpectedStackTrace = printedTestInputl_1.trimWhitespaceAndComments(expectedString);
        this.applyIgnores(formattedExpectedStackTrace, stackTraceFrames);
        const actualStackTrace = this.extractStackTrace(stackTraceFrames);
        assert.equal(actualStackTrace, formattedExpectedStackTrace, `Expected the stack trace when hitting ${this._breakpoint} to be:\n${formattedExpectedStackTrace}\nyet it is:\n${actualStackTrace}`);
    }
    applyIgnores(formattedExpectedStackTrace, stackTrace) {
        const ignoreFunctionNameText = '<__IGNORE_FUNCTION_NAME__>';
        const ignoreFunctionName = findPositionOfTextInFile_1.findLineNumber(formattedExpectedStackTrace, formattedExpectedStackTrace.indexOf(ignoreFunctionNameText));
        if (ignoreFunctionName >= 0) {
            chai_1.expect(stackTrace.length).to.be.greaterThan(ignoreFunctionName);
            const ignoredFrame = stackTrace[ignoreFunctionName];
            ignoredFrame.name = `${ignoreFunctionNameText} [${ignoredFrame.source.name}] Line ${ignoredFrame.line}`;
        }
    }
    extractStackTrace(stackTrace) {
        return stackTrace.map(f => this.printStackTraceFrame(f)).join('\n');
    }
    printStackTraceFrame(frame) {
        let frameName = frame.name;
        return `${frameName}:${frame.column}${frame.presentationHint && frame.presentationHint !== 'normal' ? ` (${frame.presentationHint})` : ''}`;
    }
}
exports.StackTraceStringAssertions = StackTraceStringAssertions;

//# sourceMappingURL=stackTraceStringAssertions.js.map
