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

	public TBVariable(String name, 
			String value, 
			String dataType, 
			String length, 
			TBRange location, 
			TBRange declaration,
			List<Token> comments, 
			TBScope parentScope, 
			List<TBRange> references) {
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

	public void setName(String name) {
		this.name = name;
	}

	public void setValue(String value) {
		this.value = value;
	}

	public void setDataType(String dataType) {
		this.dataType = dataType;
	}

	public void setLength(String length) {
		this.length = length;
	}

	public void setLocation(TBRange location) {
		this.location = location;
	}

	public void setDeclaration(TBRange declaration) {
		this.declaration = declaration;
	}

	public void setComments(List<Token> comments) {
		this.comments = comments;
	}

	public void setReferences(List<TBRange> references) {
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
