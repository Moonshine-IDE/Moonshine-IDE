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

	public String getFile() {
		return file;
	}

	public void setFile(String file) {
		this.file = file;
	}

	public Token getStart() {
		return start;
	}

	public void setStart(Token start) {
		this.start = start;
	}

	public Token getEnd() {
		return end;
	}

	public void setEnd(Token end) {
		this.end = end;
	}

	public TBScope getParentScope() {
		return parentScope;
	}

	public void setParentScope(TBScope parentScope) {
		this.parentScope = parentScope;
	}
	
	

}
