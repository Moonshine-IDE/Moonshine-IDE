package com.moonshine.languagepreprocessing;

import java.util.List;
import java.util.Map;

import org.antlr.v4.runtime.tree.TerminalNodeImpl;

import com.moonshine.languageprocessing.TBDefine;

public class TibboBasicPreprocessor {
	String projectPath;
	String    platformType;
	String    platformsPath;
	String    platformVersion;
	Map<String, TBDefine> defines;
	Map<String,List<TerminalNodeImpl>>    codes;
	Map<String,String> files;	
	List<String> filePriorities;
	Map<String,String> originalFiles;
	public String getProjectPath() {
		return projectPath;
	}
	public void setProjectPath(String projectPath) {
		this.projectPath = projectPath;
	}
	public String getPlatformType() {
		return platformType;
	}
	public void setPlatformType(String platformType) {
		this.platformType = platformType;
	}
	public String getPlatformsPath() {
		return platformsPath;
	}
	public void setPlatformsPath(String platformsPath) {
		this.platformsPath = platformsPath;
	}
	public String getPlatformVersion() {
		return platformVersion;
	}
	public void setPlatformVersion(String platformVersion) {
		this.platformVersion = platformVersion;
	}
	public Map<String, TBDefine> getDefines() {
		return defines;
	}
	public void setDefines(Map<String, TBDefine> defines) {
		this.defines = defines;
	}
	public Map<String, List<TerminalNodeImpl>> getCodes() {
		return codes;
	}
	public void setCodes(Map<String, List<TerminalNodeImpl>> codes) {
		this.codes = codes;
	}
	public Map<String, String> getFiles() {
		return files;
	}
	public void setFiles(Map<String, String> files) {
		this.files = files;
	}
	public List<String> getFilePriorities() {
		return filePriorities;
	}
	public void setFilePriorities(List<String> filePriorities) {
		this.filePriorities = filePriorities;
	}
	public Map<String, String> getOriginalFiles() {
		return originalFiles;
	}
	public void setOriginalFiles(Map<String, String> originalFiles) {
		this.originalFiles = originalFiles;
	}

	
	
}
