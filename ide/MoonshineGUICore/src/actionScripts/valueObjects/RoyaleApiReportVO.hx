package actionScripts.valueObjects;

import actionScripts.factory.FileLocation;
import openfl.Vector;

class RoyaleApiReportVO {
	public function new(royaleSdkPath:String, flexSdkPath:String, libraries:Vector<FileLocation>, mainAppFile:String, reportOutputPath:String,
			reportOutputLogPath:String, workingDirectory:String) {
		_royaleSdkPath = royaleSdkPath;
		_flexSdkPath = flexSdkPath;
		_libraries = libraries;
		_mainAppFile = mainAppFile;
		_reportOutputPath = reportOutputPath;
		_reportOutputLogPath = reportOutputLogPath;
		_workingDirectory = workingDirectory;
	}

	private var _royaleSdkPath:String;

	public var royaleSdkPath(get, never):String;

	private function get_royaleSdkPath():String
		return _royaleSdkPath;

	private var _flexSdkPath:String;

	public var flexSdkPath(get, never):String;

	private function get_flexSdkPath():String
		return _flexSdkPath;

	private var _libraries:Vector<FileLocation>;

	public var libraries(get, never):Vector<FileLocation>;

	private function get_libraries():Vector<FileLocation>
		return _libraries;

	private var _mainAppFile:String;

	public var mainAppFile(get, never):String;

	private function get_mainAppFile():String
		return _mainAppFile;

	private var _reportOutputPath:String;

	public var reportOutputPath(get, never):String;

	private function get_reportOutputPath():String
		return _reportOutputPath;

	private var _reportOutputLogPath:String;

	public var reportOutputLogPath(get, never):String;

	private function get_reportOutputLogPath():String
		return _reportOutputLogPath;

	private var _workingDirectory:String;

	public var workingDirectory(get, never):String;

	private function get_workingDirectory():String
		return _workingDirectory;
}