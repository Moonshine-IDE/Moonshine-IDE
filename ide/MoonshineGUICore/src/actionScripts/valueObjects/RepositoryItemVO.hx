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

class RepositoryItemVO {
	public var type:String; // VersionControlTypes
	public var isRoot:Bool;
	public var isDownloadable:Bool;
	public var isDefault:Bool;

	// this will help access to top level object from anywhere deep
	// in-tree objects to gain top level properties
	// ideally to get/update user authentication
	public var udid:String;

	public function new() {}

	private var _url:String;

	public var url(get, set):String;

	private function get_url():String {
		return _url;
	}

	private function set_url(value:String):String {
		_url = value;
		return _url;
	}

	private var _label:String;

	public var label(get, set):String;

	private function get_label():String {
		return _label;
	}

	private function set_label(value:String):String {
		_label = value;
		return _label;
	}

	private var _notes:String;

	public var notes(get, set):String;

	private function get_notes():String {
		return _notes;
	}

	private function set_notes(value:String):String {
		_notes = value;
		return _notes;
	}

	private var _userName:String;

	public var userName(get, set):String;

	private function get_userName():String {
		return _userName;
	}

	private function set_userName(value:String):String {
		_userName = value;
		return _userName;
	}

	private var _userPassword:String;

	public var userPassword(get, set):String;

	private function get_userPassword():String {
		return _userPassword;
	}

	private function set_userPassword(value:String):String {
		_userPassword = value;
		return _userPassword;
	}

	private var _isRequireAuthentication:Bool;

	public var isRequireAuthentication(get, set):Bool;

	private function get_isRequireAuthentication():Bool {
		return _isRequireAuthentication;
	}

	private function set_isRequireAuthentication(value:Bool):Bool {
		_isRequireAuthentication = value;
		return _isRequireAuthentication;
	}

	private var _isTrustCertificate:Bool;

	public var isTrustCertificate(get, set):Bool;

	private function get_isTrustCertificate():Bool {
		return _isTrustCertificate;
	}

	private function set_isTrustCertificate(value:Bool):Bool {
		_isTrustCertificate = value;
		return _isTrustCertificate;
	}

	private var _children:Array<Dynamic>;

	public var children(get, set):Array<Dynamic>;

	private function get_children():Array<Dynamic> {
		return _children;
	}

	private function set_children(value:Array<Dynamic>):Array<Dynamic> {
		_children = value;
		return _children;
	}

	private var _isUpdating:Bool;

	public var isUpdating(get, set):Bool;

	private function get_isUpdating():Bool {
		return _isUpdating;
	}

	private function set_isUpdating(value:Bool):Bool {
		_isUpdating = value;
		return _isUpdating;
	}

	private var _pathToDownloaded:String;

	public var pathToDownloaded(get, set):String;

	private function get_pathToDownloaded():String {
		return _pathToDownloaded;
	}

	private function set_pathToDownloaded(value:String):String {
		_pathToDownloaded = value;
		return _pathToDownloaded;
	}
}