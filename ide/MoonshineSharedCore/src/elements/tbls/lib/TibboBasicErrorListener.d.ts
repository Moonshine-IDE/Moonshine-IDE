import { CommonToken } from "antlr4";
import { TBSyntaxError } from "./types";
declare const antlr4: any;
/**
 * Custom Error Listener
 *
 * @returns {object}
 */
export declare class TibboBasicErrorListener extends antlr4.error.ErrorListener {
    errors: Array<TBSyntaxError>;
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
    syntaxError(recognizer: object, symbol: CommonToken, line: number, column: number, message: string, payload: string): void;
}
export {};
