package com.moonshine.languageprocessing;

import org.antlr.v4.runtime.CommonToken;
import org.antlr.v4.runtime.Token;

public class TBRange {
	Token startToken;
	Token stopToken;
	public TBRange(Token startToken, Token stopToken) {
		super();
		this.startToken = startToken;
		this.stopToken = stopToken;
	}
	
}
