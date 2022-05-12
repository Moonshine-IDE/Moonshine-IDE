package com.moonshine.languageprocessing;

import java.util.List;

import org.antlr.v4.runtime.Token;

public class TBType {
	String name;
	List<TBVariable> members;
	TBRange location;
	List<Token> comments;

	public TBType(String name, List<TBVariable> members, TBRange location, List<Token> comments) {
		super();
		this.name = name;
		this.members = members;
		this.location = location;
		this.comments = comments;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public List<TBVariable> getMembers() {
		return members;
	}

	public void setMembers(List<TBVariable> members) {
		this.members = members;
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
