"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const antlr4 = require('antlr4');
// const { SyntaxGenericError } = require(path.resolve('error', 'helper'));
/**
 * Custom Error Listener
 *
 * @returns {object}
 */
class TibboBasicErrorListener extends antlr4.error.ErrorListener {
    constructor() {
        super(...arguments);
        this.errors = [];
    }
    /**
     * Checks syntax error
     *
     * @param {object} recognizer The parsing support code essentially. Most of it is error recovery stuff
     * @param {object} symbol Offending symbol
     * @param {number} line Line of offending symbol
     * @param {number} column Position in line of offending symbol
     * @param {string} message Error message
     * @param {string} payload Stack trace
     */
    syntaxError(recognizer, symbol, line, column, message, payload) {
        // throw new Error(JSON.stringify({ line, column, message }));
        this.errors.push({ symbol: symbol, line, column, message });
    }
}
exports.default = TibboBasicErrorListener;
//# sourceMappingURL=TibboBasicErrorListener.js.map