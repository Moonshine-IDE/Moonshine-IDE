package com.moonshine.languageprocessing;

import java.util.List;

import org.antlr.v4.runtime.Token;

public class TBObjectFunction {
	String name;
	TBSyscall syscall;
	List<TBParameter> parameters;
	String dataType;
	TBRange location;
	List<Token> comments;
	public TBObjectFunction(String name, TBSyscall syscall, List<TBParameter> parameters, String dataType,
			TBRange location, List<Token> comments) {
		super();
		this.name = name;
		this.syscall = syscall;
		this.parameters = parameters;
		this.dataType = dataType;
		this.location = location;
		this.comments = comments;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public TBSyscall getSyscall() {
		return syscall;
	}
	public void setSyscall(TBSyscall syscall) {
		this.syscall = syscall;
	}
	public List<TBParameter> getParameters() {
		return parameters;
	}
	public void setParameters(List<TBParameter> parameters) {
		this.parameters = parameters;
	}
	public String getDataType() {
		return dataType;
	}
	public void setDataType(String dataType) {
		this.dataType = dataType;
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
