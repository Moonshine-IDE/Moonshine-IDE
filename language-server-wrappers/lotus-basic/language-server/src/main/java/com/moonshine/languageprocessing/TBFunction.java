package com.moonshine.languageprocessing;

import java.util.ArrayList;
import java.util.List;

import org.antlr.v4.runtime.CommonToken;

public class TBFunction {
	String name;
	List<TBParameter> parameters;
	List<CommonToken> comments;
	List<TBRange> references;
	
	TBRange location,declaration;
    
    String dataType;

	public TBFunction(String name, List<TBParameter> parameters, List<CommonToken> comments, List<TBRange> references,TBRange location,TBRange declaration) {
		super();
		this.name = name;
		this.parameters = parameters;
		this.comments = comments;
		this.references = references;
		this.location=location;
		this.declaration=declaration;
		this.location=location;
		this.declaration=declaration;
	}
	
	

	
	public TBFunction(String name) {
		super();
		this.name=name;
		
		this.parameters = new ArrayList<TBParameter>();
		this.comments = new ArrayList<>();
				
		this.references = new ArrayList<>();
		this.location=null;
		this.declaration=null;
		this.location=null;
		
	}




	public TBRange getLocation() {
		return location;
	}


	public void setLocation(TBRange location) {
		this.location = location;
	}


	public TBRange getDeclaration() {
		return declaration;
	}


	public void setDeclaration(TBRange declaration) {
		this.declaration = declaration;
	}


	public String getDataType() {
		return dataType;
	}


	public void setDataType(String dataType) {
		this.dataType = dataType;
	}


	public void setName(String name) {
		this.name = name;
	}


	public void setParameters(List<TBParameter> parameters) {
		this.parameters = parameters;
	}


	public void setComments(List<CommonToken> comments) {
		this.comments = comments;
	}


	public void setReferences(List<TBRange> references) {
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
