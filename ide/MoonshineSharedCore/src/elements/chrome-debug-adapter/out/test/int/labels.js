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
const intTestSupport_1 = require("./intTestSupport");
const fs = require("fs");
const util = require("util");
const readline = require("readline");
const path = require("path");
const validatedMap_1 = require("./core-v2/chrome/collections/validatedMap");
/*
 * Contains classes and functions to find and use test breakpoint labels in test project files
 */
const readdirAsync = util.promisify(fs.readdir);
const labelRegex = /(\/\/|\/\*)\s*bpLabel:\s*(.+?)\b/;
const ignoreList = ['node_modules', '.git', path.join('dist', 'out'), path.join('testdata', 'react', 'src')];
/**
 * Load all breakpoint labels that exist in the 'projectRoot' directory
 * @param projectRoot Root directory for the test project
 */
function loadProjectLabels(projectRoot) {
    return __awaiter(this, void 0, void 0, function* () {
        const labelMap = new validatedMap_1.ValidatedMap();
        if (containsIgnores(projectRoot))
            return labelMap;
        const files = yield readdirAsync(projectRoot);
        for (let file of files) {
            let subMap = null;
            const fullPath = path.join(projectRoot, file);
            if (fs.lstatSync(fullPath).isDirectory()) {
                subMap = yield loadProjectLabels(fullPath);
            }
            else {
                subMap = yield loadLabelsFromFile(fullPath);
            }
            for (let entry of subMap.entries()) {
                labelMap.set(entry[0], entry[1]);
            }
        }
        return labelMap;
    });
}
exports.loadProjectLabels = loadProjectLabels;
/**
 * Load breakpoint labels from a specific file
 * @param filePath
 */
function loadLabelsFromFile(filePath) {
    return __awaiter(this, void 0, void 0, function* () {
        const fileStream = fs.createReadStream(filePath);
        const labelMap = new Map();
        let lineNumber = 1; // breakpoint locations start at 1
        const lineReader = readline.createInterface({
            input: fileStream
        });
        lineReader.on('line', (fileLine) => {
            let match = labelRegex.exec(fileLine);
            if (match) {
                labelMap.set(match[2], new intTestSupport_1.BreakpointLocation(filePath, lineNumber));
            }
            lineNumber++;
        });
        const waitForClose = new Promise((accept, _reject) => {
            lineReader.on('close', () => {
                accept();
            });
        });
        yield waitForClose;
        return labelMap;
    });
}
exports.loadLabelsFromFile = loadLabelsFromFile;
/**
 * Check if our filepath contains anything from our ignore list
 * @param filePath
 */
function containsIgnores(filePath) {
    return ignoreList.find(ignoreItem => filePath.includes(ignoreItem));
}

//# sourceMappingURL=labels.js.map
