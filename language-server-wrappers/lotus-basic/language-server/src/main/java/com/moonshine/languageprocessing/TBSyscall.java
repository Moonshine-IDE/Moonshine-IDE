package com.moonshine.languageprocessing;

import java.util.List;

import org.antlr.v4.runtime.CommonToken;

public class TBSyscall {
	String name;
	int syscallNumber;
	String tdl;
	List<TBParameter> parameters;
	String dataType;
	TBRange location;
	List<CommonToken> comments;
	public TBSyscall(String name, int syscallNumber, String tdl, List<TBParameter> parameters, String dataType,
			TBRange location, List<CommonToken> comments) {
		super();
		this.name = name;
		this.syscallNumber = syscallNumber;
		this.tdl = tdl;
		this.parameters = parameters;
		this.dataType = dataType;
		this.location = location;
		this.comments = comments;
	}
	public String getName() {
		return name;
	}
	public int getSyscallNumber() {
		return syscallNumber;
	}
	public String getTdl() {
		return tdl;
	}
	public List<TBParameter> getParameters() {
		return parameters;
	}
	public String getDataType() {
		return dataType;
	}
	public TBRange getLocation() {
		return location;
	}
	public List<CommonToken> getComments() {
		return comments;
	}
	
	
}
