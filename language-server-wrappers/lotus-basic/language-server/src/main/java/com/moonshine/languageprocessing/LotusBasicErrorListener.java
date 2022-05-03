package com.moonshine.languageprocessing;

import java.util.ArrayList;
import java.util.List;

import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;
import org.antlr.v4.runtime.tree.ParseTree;

import com.moonshine.basicgrammar.TibboBasicLexer;
import com.moonshine.basicgrammar.TibboBasicParser;

public class LotusBasicErrorListener extends BaseErrorListener {

	private List<LotusSyntaxError> errors = new ArrayList<>();

	@Override
	public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol, int line, int charPositionInLine,
			String msg, RecognitionException e) {
		errors.add(new LotusSyntaxError(offendingSymbol.toString(), line, charPositionInLine, msg));

	}

	public List<LotusSyntaxError> getErrors() {
		return errors;
	}

	public static List<LotusSyntaxError> getFileParsingErrors(String changesText) {
		TibboBasicLexer lexer = new TibboBasicLexer(new ANTLRInputStream(changesText));
		lexer.removeErrorListeners();
		TibboBasicParser parser = new TibboBasicParser(new CommonTokenStream(lexer));
		parser.removeErrorListeners();

		LotusBasicErrorListener listener = new LotusBasicErrorListener();
		lexer.addErrorListener(listener);
		parser.addErrorListener(listener);
		
		ParseTree tree = parser.startRule();
		return listener.getErrors();
	}


}
