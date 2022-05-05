package com.moonshine.languageprocessing;

import java.util.List;

import org.antlr.v4.runtime.CommonToken;

public class TBFunction {
	String name;
	List<TBParameter> parameters;
	List<CommonToken> comments;
	List<TBRange> references;

	public TBFunction(String name, List<TBParameter> parameters, List<CommonToken> comments, List<TBRange> references) {
		super();
		this.name = name;
		this.parameters = parameters;
		this.comments = comments;
		this.references = references;
	}

	public String getName() {
		return name;
	}

	public List<TBParameter> getParameters() {
		return parameters;
	}

	public List<CommonToken> getComments() {
		return comments;
	}

	public List<TBRange> getReferences() {
		return references;
	}

}
