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
const labels_1 = require("../labels");
const chai_1 = require("chai");
const path = require("path");
suite('Test framework tests', () => {
    test('Should correctly find breakpoint labels in test source files', () => __awaiter(this, void 0, void 0, function* () {
        let labels = yield labels_1.loadProjectLabels('./testdata');
        let worldLabel = labels.get('WorldLabel');
        chai_1.expect(worldLabel.path).to.eql(path.join('testdata', 'labelTest.ts'));
        chai_1.expect(worldLabel.line).to.eql(9);
    }));
    test('Should correctly find block comment breakpoint labels in test source files', () => __awaiter(this, void 0, void 0, function* () {
        let labels = yield labels_1.loadProjectLabels('./testdata');
        let blockLabel = labels.get('blockLabel');
        chai_1.expect(blockLabel.path).to.eql(path.join('testdata', 'labelTest.ts'));
        chai_1.expect(blockLabel.line).to.eql(10);
    }));
});

//# sourceMappingURL=framework.support.test.js.map
