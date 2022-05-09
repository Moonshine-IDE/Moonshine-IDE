package com.moonshine.languageprocessing;

public class TBParameter {

	String name;
	boolean byref;
	String dataType;
	public TBParameter(String name, boolean byref, String dataType) {
		super();
		this.name = name;
		this.byref = byref;
		this.dataType = dataType;
	}
	
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public boolean isByref() {
		return byref;
	}
	public void setByref(boolean byref) {
		this.byref = byref;
	}
	public String getDataType() {
		return dataType;
	}
	public void setDataType(String dataType) {
		this.dataType = dataType;
	}
	

}
