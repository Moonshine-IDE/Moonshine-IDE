"use strict";
/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/
Object.defineProperty(exports, "__esModule", { value: true });
const assert = require("assert");
const path = require("path");
const testSetup = require("../../../testSetup");
const chai_1 = require("chai");
class StackTraceObjectAssertions {
    constructor(breakpointsWizard) {
        this._projectRoot = breakpointsWizard.project.props.projectRoot;
    }
    assertSourceMatches(actual, expected, index) {
        if (actual == null && expected == null) {
            return;
        }
        if (expected == null) {
            assert.fail(`Source was returned for frame ${index} but none was expected`);
            return;
        }
        if (actual == null) {
            assert.fail(`Source was expected for frame ${index} but none was returned`);
            return;
        }
        let expectedName;
        let expectedPath;
        if (expected.fileRelativePath) {
            // Generate the expected path from the relative path and the project root
            expectedPath = path.join(this._projectRoot, expected.fileRelativePath);
            expectedName = path.parse(expectedPath).base;
        }
        else if (expected.url) {
            expectedName = expected.url.host;
            expectedPath = expected.url.toString();
        }
        else if (expected.evalCode === true) {
            // Eval code has source that looks like 'VM123'. Check it by regex instead.
            chai_1.expect(actual.name).to.match(/.*VM.*/, `Frame ${index} source name`);
            chai_1.expect(actual.path).to.match(/.*VM.*/, `Frame ${index} source path`);
            return;
        }
        else {
            assert.fail('Not enough information for expected source: set either "fileRelativePath" or "urlRelativePath" or "eval"');
            return;
        }
        chai_1.expect(actual.name).to.equal(expectedName, `Frame ${index} source name`);
        chai_1.expect(actual.path).to.equal(expectedPath, `Frame ${index} source path`);
    }
    assertFrameMatches(actual, expected, index) {
        if (typeof expected.name === 'string') {
            chai_1.expect(actual.name).to.equal(expected.name, `Frame ${index} name`);
        }
        else if (expected.name instanceof RegExp) {
            chai_1.expect(actual.name).to.match(expected.name, `Frame ${index} name`);
        }
        chai_1.expect(actual.line).to.equal(expected.line, `Frame ${index} line`);
        chai_1.expect(actual.column).to.equal(expected.column, `Frame ${index} column`);
        // Normal V1 stack frames will have no presentationHint, normal V2 stack frames will have presentationHint 'normal'
        if (testSetup.isThisV1 && expected.presentationHint === 'normal') {
            // tslint:disable-next-line:no-unused-expression
            chai_1.expect(actual.presentationHint, `Frame ${index} presentationHint`).to.be.undefined;
        }
        else {
            chai_1.expect(actual.presentationHint).to.equal(expected.presentationHint, `Frame ${index} presentationHint`);
        }
        this.assertSourceMatches(actual.source, expected.source, index);
    }
    assertResponseMatchesFrames(actualFrames, expectedFrames) {
        // Check array length
        chai_1.expect(actualFrames.length).to.equal(expectedFrames.length, 'Number of stack frames');
        // Check each frame
        actualFrames.forEach((actualFrame, i) => {
            this.assertFrameMatches(actualFrame, expectedFrames[i], i);
        });
    }
    assertResponseMatches(stackTraceFrames, expectedFrames) {
        try {
            this.assertResponseMatchesFrames(stackTraceFrames, expectedFrames);
        }
        catch (e) {
            const error = e;
            error.message += '\nActual stack trace response: \n' + JSON.stringify(stackTraceFrames, null, 2);
            throw error;
        }
    }
}
exports.StackTraceObjectAssertions = StackTraceObjectAssertions;

//# sourceMappingURL=stackTraceObjectAssertions.js.map
