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
const _ = require("lodash");
const subtypes_1 = require("../core-v2/chrome/internal/locations/subtypes");
const vscode_chrome_debug_core_1 = require("vscode-chrome-debug-core");
const location_1 = require("../core-v2/chrome/internal/locations/location");
function findPositionOfTextInFile(filePath, text) {
    return __awaiter(this, void 0, void 0, function* () {
        const contentsIncludingCarriageReturns = yield vscode_chrome_debug_core_1.utils.readFileP(filePath, 'utf8');
        const contents = contentsIncludingCarriageReturns.replace(/\r/g, '');
        const textStartIndex = contents.indexOf(text);
        if (textStartIndex >= 0) {
            const textLineNumber = findLineNumber(contents, textStartIndex);
            const lastNewLineBeforeTextIndex = contents.lastIndexOf('\n', textStartIndex);
            const textColumNumber = subtypes_1.createColumnNumber(textStartIndex - (lastNewLineBeforeTextIndex + 1));
            return new location_1.Position(textLineNumber, textColumNumber);
        }
        else {
            throw new Error(`Couldn't find ${text} in ${filePath}`);
        }
    });
}
exports.findPositionOfTextInFile = findPositionOfTextInFile;
function findLineNumber(contents, characterIndex) {
    const contentsBeforeCharacter = contents.substr(0, characterIndex);
    const textLineNumber = subtypes_1.createLineNumber(_.countBy(contentsBeforeCharacter, c => c === '\n')['true'] || 0);
    return textLineNumber;
}
exports.findLineNumber = findLineNumber;

//# sourceMappingURL=findPositionOfTextInFile.js.map
