"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const path = require("path");
const testSetup = require("../testSetup");
const frameworkTestSupport_1 = require("../framework/frameworkTestSupport");
const DATA_ROOT = testSetup.DATA_ROOT;
const REACT_PROJECT_ROOT = path.join(DATA_ROOT, 'react', 'dist');
exports.reactTestSpecification = new frameworkTestSupport_1.TestProjectSpec({ projectRoot: REACT_PROJECT_ROOT });
exports.reactWithLoopTestSpecification = new frameworkTestSupport_1.TestProjectSpec({ projectRoot: path.join(DATA_ROOT, 'react_with_loop', 'dist') });

//# sourceMappingURL=resourceProjects.js.map
