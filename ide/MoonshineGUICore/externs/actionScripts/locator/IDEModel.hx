////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
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
package actionScripts.locator;

import actionScripts.interfaces.IProjectBridge;
import actionScripts.factory.FileLocation;
import actionScripts.interfaces.IClipboardBridge;
import actionScripts.interfaces.IFileBridge;
import actionScripts.ui.IContentWindow;
import mx.collections.ArrayCollection;

extern class IDEModel {
	public static function getInstance():IDEModel;

	public var activeEditor:IContentWindow;
	public var antHomePath:FileLocation;
	public var clipboardCore:IClipboardBridge;
	public var defaultSDK:FileLocation;
	public var editors:ArrayCollection;
	public var fileCore:IFileBridge;
	public var projectCore:IProjectBridge;
	public var gitPath:String;
	public var gradlePath:String;
	public var grailsPath:String;
	public var haxePath:String;
	public var java8Path:FileLocation;
	public var javaPathForTypeAhead:FileLocation;
	public var macportsPath:String;
	public var mavenPath:String;
	public var nekoPath:String;
	public var nodePath:String;
	public var notesPath:String;
	public var projects:ArrayCollection;
	public var svnPath:String;
	public var userSavedSDKs:ArrayCollection;
	public var vagrantPath:String;
    public var virtualBoxPath:String;

	public function getVersionWithBuildNumber():String;
}