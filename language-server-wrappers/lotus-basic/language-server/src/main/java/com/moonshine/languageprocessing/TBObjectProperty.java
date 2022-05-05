package com.moonshine.languageprocessing;

import java.util.List;

import org.antlr.v4.runtime.CommonToken;

public class TBObjectProperty {
    public TBObjectProperty(String name, String dataType, TBSyscall get, TBSyscall set, TBRange location,
			List<CommonToken> comments) {
		super();
		this.name = name;
		this.dataType = dataType;
		this.get = get;
		this.set = set;
		this.location = location;
		this.comments = comments;
	}
	String name;
    String dataType;
    TBSyscall get;
    TBSyscall set;
    TBRange location;
    List<CommonToken> comments;
	public String getName() {
		return name;
	}
	public String getDataType() {
		return dataType;
	}
	public TBSyscall getGet() {
		return get;
	}
	public TBSyscall getSet() {
		return set;
	}
	public TBRange getLocation() {
		return location;
	}
	public List<CommonToken> getComments() {
		return comments;
	}
	public void setDataType(String dataType) {
		this.dataType = dataType;
	}
	
	
    
    
}
