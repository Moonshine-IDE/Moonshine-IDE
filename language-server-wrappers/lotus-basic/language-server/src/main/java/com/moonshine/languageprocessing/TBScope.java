package com.moonshine.languageprocessing;

import org.antlr.v4.runtime.CommonToken;
import org.antlr.v4.runtime.Token;

public class TBScope {
	String file;
	Token start;
	Token end;
	TBScope parentScope = null;

	public TBScope(String file, Token start, Token end, TBScope parentScope) {
		super();
		this.file = file;
		this.start = start;
		this.end = end;
		this.parentScope = parentScope;
	}

	public TBScope(String file, Token start, Token end) {
		super();
		this.file = file;
		this.start = start;
		this.end = end;
		this.parentScope=null;
	}

}
