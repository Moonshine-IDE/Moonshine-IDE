package com.moonshine.languageprocessing;

public class LotusSyntaxError {
	private String offendingSymbol; 
	private int line; 
	private int charPositionInLine;
	private String msg;
	public LotusSyntaxError(String offendingSymbol, int line, int charPositionInLine, String msg) {
		super();
		this.offendingSymbol = offendingSymbol;
		this.line = line;
		this.charPositionInLine = charPositionInLine;
		this.msg = msg;
	}
	public String getOffendingSymbol() {
		return offendingSymbol;
	}
	public int getLine() {
		return line;
	}
	public int getCharPositionInLine() {
		return charPositionInLine;
	}
	public String getMsg() {
		return msg;
	}
	
}
