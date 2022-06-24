"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode_languageserver_1 = require("vscode-languageserver");
const blockStart = [
    'if',
    'enum',
    'sub',
    'function',
    'type',
    'for',
    'select',
    'while',
    '#if',
    '#ifndef',
    '#ifdef'
];
const blockEnd = [
    'end if',
    'end enum',
    'end sub',
    'end function',
    'end type',
    'next',
    'end select',
    'wend',
    '#endif',
    '#endif',
    '#endif'
];
class TibboBasicDocumentFormatter {
    formatDocument(document, formatParams) {
        const edits = [];
        const lines = document.getText().split('\n');
        const tabSize = formatParams.options.tabSize;
        let currentIndent = 0;
        let pos = 0;
        const blockStarts = [];
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const trimmed = line.trim().toLowerCase();
            if (trimmed == '' || trimmed[0] == "'") {
                pos += line.length + 1;
                continue;
            }
            let whiteSpaceLength = 0;
            for (let j = 0; j < blockEnd.length; j++) {
                if (trimmed.indexOf(blockEnd[j]) == 0) {
                    if (blockStarts[blockStarts.length - 1] == j) {
                        currentIndent--;
                        blockStarts.pop();
                        break;
                    }
                }
            }
            let hasTabs = false;
            for (let j = 0; j < line.length; j++) {
                if (line[j] == '\t') {
                    hasTabs = true;
                    whiteSpaceLength++;
                    continue;
                }
                if (line[j] != ' ') {
                    break;
                }
                whiteSpaceLength++;
            }
            if (whiteSpaceLength != currentIndent * tabSize || hasTabs) {
                let replaced = '';
                for (let j = 0; j < currentIndent * tabSize; j++) {
                    replaced += ' ';
                }
                const edit = vscode_languageserver_1.TextEdit.replace({ start: document.positionAt(pos), end: document.positionAt(pos + whiteSpaceLength) }, replaced);
                edits.push(edit);
            }
            pos += line.length + 1;
            for (let j = 0; j < blockStart.length; j++) {
                if (trimmed.indexOf(blockStart[j]) == 0) {
                    const next = trimmed.substr(trimmed.indexOf(blockStart[j]) + blockStart[j].length, 1);
                    if (next != ' ' && next != '\t') {
                        if (i != lines.length - 1) {
                            continue;
                        }
                    }
                    currentIndent++;
                    blockStarts.push(j);
                    if (blockStart[j] == 'if') {
                        if (trimmed.substr(trimmed.length - 4, 4) != 'then') {
                            currentIndent--;
                            blockStarts.pop();
                        }
                    }
                    break;
                }
            }
        }
        // let edit = TextEdit.replace({ start: document.positionAt(19), end: document.positionAt(20) }, '    ');
        // edits.push(edit);
        return Promise.resolve(edits);
    }
}
exports.default = TibboBasicDocumentFormatter;
//# sourceMappingURL=TibboBasicDocumentFormatter.js.map