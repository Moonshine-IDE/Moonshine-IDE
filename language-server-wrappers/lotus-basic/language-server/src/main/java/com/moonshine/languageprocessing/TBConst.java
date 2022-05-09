package com.moonshine.languageprocessing;

import java.util.List;

import org.antlr.v4.runtime.Token;

public class TBConst {
	String name;
	String value = null;
	TBRange location = null;
	 List<Token> comments = null;

	public TBConst(String name, String value, TBRange location, List<Token> comments) {
		super();
		this.name = name;
		this.value = value;
		this.location = location;
		this.comments = comments;
	}

	public TBConst(String name) {
		super();
		this.name = name;
	}

}
