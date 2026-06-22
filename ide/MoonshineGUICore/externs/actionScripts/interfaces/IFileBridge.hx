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

package actionScripts.interfaces;

import actionScripts.factory.FileLocation;

extern interface IFileBridge {
	@:flash.property
	public var url(get, set):String;

	@:flash.property
	public var nativeURL(get, set):String;

	@:flash.property
	public var nativePath(get, set):String;

	@:flash.property
	public var extension(get, never):String;

	@:flash.property
	public var name(get, never):String;

	@:flash.property
	public var nameWithoutExtension(get, never):String;

	@:flash.property
	public var parent(get, never):FileLocation;

	@:flash.property
	public var exists(get, never):Bool;

	@:flash.property
	public var isDirectory(get, never):Bool;

	@:flash.property
	public var isHidden(get, never):Bool;

	@:flash.property
	public var separator(get, never):String;

	public function read():Dynamic;

	public function canonicalize():Void;

	public function resolvePath(path:String, toRelativePath:String = null):FileLocation;

	public function browseForDirectory(title:String, selectListener:(file:Any) -> Void, ?cancelListener:() -> Void, ?startFromLocation:String):Void;

	public function getRelativePath(ref:FileLocation, useDotDot:Bool = false):String;

	public function isPathExists(value:String):Bool;

	public function openWithDefaultApplication():Void;

	function getDirectoryListingAsync(successHandler:(output:Array<FileLocation>) -> Void, ?errorHandler:(error:String) -> Void):Void;

}
