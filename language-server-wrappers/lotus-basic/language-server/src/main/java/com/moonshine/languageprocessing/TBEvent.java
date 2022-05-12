package com.moonshine.languageprocessing;

import java.util.List;

import org.antlr.v4.runtime.Token;

public class TBEvent {
	String name;
	int eventNumber;
	List<TBParameter> parameters;
	TBRange location;
	List<Token> comments;
	public TBEvent(String name, int eventNumber, List<TBParameter> parameters, TBRange location, List<Token> comments) {
		super();
		this.name = name;
		this.eventNumber = eventNumber;
		this.parameters = parameters;
		this.location = location;
		this.comments = comments;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public int getEventNumber() {
		return eventNumber;
	}
	public void setEventNumber(int eventNumber) {
		this.eventNumber = eventNumber;
	}
	public List<TBParameter> getParameters() {
		return parameters;
	}
	public void setParameters(List<TBParameter> parameters) {
		this.parameters = parameters;
	}
	public TBRange getLocation() {
		return location;
	}
	public void setLocation(TBRange location) {
		this.location = location;
	}
	public List<Token> getComments() {
		return comments;
	}
	public void setComments(List<Token> comments) {
		this.comments = comments;
	}
	
	
}
