package com.moonshine.languageprocessing;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TibboBasicProjectParser {

	private Map<String, TBObject> objects = new HashMap<>();
	private Map<String, TBEnum> enums;
	private Map<String, TBSyscall> syscalls;
	private Map<String, TBFunction> functions;
	private List<TBVariable> variables;
	private List<TBScope> scopes;
	private Map<String,TBConst> consts=new HashMap<>();

	public Map<String, TBConst> getConsts() {
		return consts;
	}

	public void setConsts(Map<String, TBConst> consts) {
		this.consts = consts;
	}

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

	public void addVariable(TBVariable variable) {

		// TODO set scope of variable
		boolean found = false;
		for (int i = 0; i < this.variables.size(); i++) {
			if (this.variables.get(i).name == variable.name) {
				if (this.variables.get(i).location.startToken.getLine() == variable.location.startToken.getLine()
						|| Math.abs(variable.location.startToken.getLine()
								- this.variables.get(i).location.startToken.getLine()) < 3) {
					found = true;
				}
			}
		}

		if (!found) {
			this.variables.add(variable);
		}

	}

}
