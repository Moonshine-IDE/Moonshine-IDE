package com.moonshine.languageprocessing;

public class TBDefine {
	
	   String name;
	   String  value;
	   int line;
	public TBDefine(String name, String value, int line) {
		super();
		this.name = name;
		this.value = value;
		this.line = line;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getValue() {
		return value;
	}
	public void setValue(String value) {
		this.value = value;
	}
	public int getLine() {
		return line;
	}
	public void setLine(int line) {
		this.line = line;
	}
	   
	
}
