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
	
}
