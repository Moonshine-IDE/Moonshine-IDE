"use strict";
/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/
Object.defineProperty(exports, "__esModule", { value: true });
const path = require("path");
const puppeteer = require("puppeteer");
const testSetup_1 = require("../testSetup");
/**
 * Specifies an integration test project (i.e. a project that will be launched and
 * attached to in order to test the debug adapter)
 */
class TestProjectSpec {
    /**
     * @param props Parameters for the project spec. The only required param is "projectRoot", others will be set to sensible defaults
     */
    constructor(props, staticUrl) {
        this.staticUrl = staticUrl;
        const outFiles = props.outFiles || [path.join(props.projectRoot, 'out')];
        const webRoot = props.webRoot || props.projectRoot;
        this._props = {
            projectRoot: props.projectRoot,
            projectSrc: props.projectSrc || path.join(props.projectRoot, 'src'),
            webRoot: webRoot,
            outFiles: outFiles,
            launchConfig: props.launchConfig || {
                outFiles: outFiles,
                sourceMaps: true,
                runtimeExecutable: puppeteer.executablePath(),
                webRoot: webRoot
            }
        };
    }
    get props() { return this._props; }
    /**
     * Specify project by it's location relative to the testdata folder e.g.:
     *    - TestProjectSpec.fromTestPath('react_with_loop/dist')
     *    - TestProjectSpec.fromTestPath('simple')
     *
     * The path *can only* use forward-slahes "/" as separators
     */
    static fromTestPath(reversedSlashesRelativePath, sourceDir = 'src', staticUrl) {
        const pathComponents = reversedSlashesRelativePath.split('/');
        const projectAbsolutePath = path.join(...[testSetup_1.DATA_ROOT].concat(pathComponents));
        const projectSrc = path.join(projectAbsolutePath, sourceDir);
        let props = { projectRoot: projectAbsolutePath, projectSrc };
        return new TestProjectSpec(props, staticUrl);
    }
    /**
     * Returns the full path to a source file
     * @param filename
     */
    src(filename) {
        return path.join(this.props.projectSrc, filename);
    }
}
exports.TestProjectSpec = TestProjectSpec;
class ReassignableFrameworkTestContext {
    constructor() {
        this._wrapped = new NotInitializedFrameworkTestContext();
    }
    get testSpec() {
        return this._wrapped.testSpec;
    }
    get breakpointLabels() {
        return this._wrapped.breakpointLabels;
    }
    get debugClient() {
        return this._wrapped.debugClient;
    }
    reassignTo(newWrapped) {
        this._wrapped = newWrapped;
        return this;
    }
}
exports.ReassignableFrameworkTestContext = ReassignableFrameworkTestContext;
class NotInitializedFrameworkTestContext {
    get testSpec() {
        return this.throwNotInitializedException();
    }
    get breakpointLabels() {
        return this.throwNotInitializedException();
    }
    get debugClient() {
        return this.throwNotInitializedException();
    }
    throwNotInitializedException() {
        throw new Error(`This test context hasn't been initialized yet. This is probably a bug in the tests`);
    }
}
exports.NotInitializedFrameworkTestContext = NotInitializedFrameworkTestContext;

//# sourceMappingURL=frameworkTestSupport.js.map
