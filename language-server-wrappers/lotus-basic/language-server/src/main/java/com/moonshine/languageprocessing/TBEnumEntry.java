package com.moonshine.languageprocessing;

import java.util.List;

import org.antlr.v4.runtime.CommonToken;

public class TBEnumEntry {
	String name;
	String value;
	TBRange location;
	List<CommonToken> comments;
	public TBEnumEntry(String name, String value, TBRange location, List<CommonToken> comments) {
		super();
		this.name = name;
		this.value = value;
		this.location = location;
		this.comments = comments;
	}
	
	
}
