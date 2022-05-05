package com.moonshine.languageprocessing;

import java.util.ArrayList;
import java.util.List;

import org.antlr.v4.runtime.CommonToken;

public class TBObject {
	String name;
	List<TBObjectProperty> properties;
	List<TBObjectFunction> functions;
	TBRange location;
	List<CommonToken> comments;
	List<TBEvent> events;

	public TBObject(String name, TBRange location, ArrayList<TBObjectFunction> functions,
			ArrayList<CommonToken> comments, ArrayList<TBEvent> events) {
		this.name = name;
		this.location = location;
		this.functions = functions;
		this.comments = comments;
		this.events = events;

	}

	public String getName() {
		return name;
	}

	public List<TBObjectProperty> getProperties() {
		return properties;
	}

	public List<TBObjectFunction> getFunctions() {
		return functions;
	}

	public TBRange getLocation() {
		return location;
	}

	public List<CommonToken> getComments() {
		return comments;
	}

	public List<TBEvent> getEvents() {
		return events;
	}
	
	

	
	
}
