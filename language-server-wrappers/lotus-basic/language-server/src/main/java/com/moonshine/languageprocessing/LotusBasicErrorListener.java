package com.moonshine.languageprocessing;

import java.util.ArrayList;
import java.util.List;

import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;

public class LotusBasicErrorListener extends BaseErrorListener {

	private List<LotusSyntaxError> errors = new ArrayList<>();

	@Override
	public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol, int line, int charPositionInLine,
			String msg, RecognitionException e) {
		errors.add(new LotusSyntaxError(offendingSymbol.toString(), line, charPositionInLine, msg));

	}

	/**
	 * Checks syntax error
	 *
	 * @param {object} recognizer The parsing support code essentially. Most of it
	 *                 is error recovery stuff
	 * @param {object} symbol Offending symbol
	 * @param {number} line Line of offending symbol
	 * @param {number} column Position in line of offending symbol
	 * @param {string} message Error message
	 * @param {string} payload Stack trace
	 */
//		syntaxError(recognizer: object, symbol: CommonToken, line: number, column: number, message: string, payload: string) {
//			// throw new Error(JSON.stringify({ line, column, message }));
//			this.errors.push({ symbol: symbol, line, column, message });
//		}

}
