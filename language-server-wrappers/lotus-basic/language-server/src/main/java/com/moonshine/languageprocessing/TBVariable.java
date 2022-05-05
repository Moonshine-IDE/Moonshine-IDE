package com.moonshine.languageprocessing;

import java.util.List;

import org.antlr.v4.runtime.Token;

public class TBVariable {
	String name;
	String value;
	String dataType;
	String length;
	TBRange location;
	TBRange declaration;
	List<Token> comments;
	TBScope parentScope;
	List<TBRange> references;

	public TBVariable(String name, String value, String dataType, String length, TBRange location, TBRange declaration,
			List<Token> comments, TBScope parentScope, List<TBRange> references) {
		super();
		this.name = name;
		this.value = value;
		this.dataType = dataType;
		this.length = length;
		this.location = location;
		this.declaration = declaration;
		this.comments = comments;
		this.parentScope = parentScope;
		this.references = references;
	}

	public String getName() {
		return name;
	}

	public String getValue() {
		return value;
	}

	public String getDataType() {
		return dataType;
	}

	public String getLength() {
		return length;
	}

	public TBRange getLocation() {
		return location;
	}

	public TBRange getDeclaration() {
		return declaration;
	}

	public List<Token> getComments() {
		return comments;
	}

	public TBScope getParentScope() {
		return parentScope;
	}

	public List<TBRange> getReferences() {
		return references;
	}

	public void setParentScope(TBScope parentScope) {
		this.parentScope = parentScope;
	}
	
	

}
