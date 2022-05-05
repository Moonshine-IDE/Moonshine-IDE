package com.moonshine.languageprocessing;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TibboBasicProjectParser {

	private Map<String, TBObject> objects = new HashMap<>();
	private Map<String, TBEnum> enums;
	private Map<String, TBSyscall> syscalls;
	private Map<String, TBFunction> functions;
	private List<TBScope> scopes;

	public Map<String, TBObject> getObjects() {
		return this.objects;

	}

	public Map<String, TBEnum> getEnums() {
		return enums;
	}

	public Map<String, TBSyscall> getSyscalls() {
		return syscalls;

	}

	public Map<String, TBFunction> getFunctions() {

		return functions;
	}

	public List<TBScope> getScopes() {

		// TODO Auto-generated method stub
		return this.scopes;
	}

}
