////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////

package actionScripts.valueObjects;

import actionScripts.factory.FileLocation;
#if flash
import flash.Vector;
#else
import openfl.Vector;
#end

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