package com.moonshine.languageprocessing;

import java.util.List;
import java.util.Map;

import org.antlr.v4.runtime.Token;

public class TBEnum {
	String name;
	Map<String, TBEnumEntry> members;
	TBRange location;
	List<Token> comments;

	public TBEnum(String name, Map<String,TBEnumEntry> members, TBRange location, List<Token> comments) {
		this.name = name;
		this.members = members;
		this.location = location;
		this.comments = comments;
	}

	public Map<String,TBEnumEntry> getMembers() {
		// TODO Auto-generated method stub
		return members;
	}
}
