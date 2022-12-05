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

package actionScripts.valueObjects;

class URLDescriptorVO {
	public static var BASE_URL:String = "";

	@:meta(Bindable("change"))
	public static var BASE_URL_MIRROR:String;
	public static var BASE_URL_PROTOCOL:String = "";
	public static var FILE_OPEN:String;
	public static var FILE_MODIFY:String;
	public static var FILE_REMOVE:String;
	public static var FILE_NEW:String;
	public static var FILE_RENAME:String;
	public static var PROJECT_DIR:String;
	public static var PROJECT_REMOVE:String;
	public static var PROJECT_COMPILE:String;
	public static var LOGIN_TEST:String;
	public static var LOGIN_USER:String;
	public static var CREATE_NEW_PROJECT:String;
	public static var CONFIG:String;
	public static var LOGIN_USER_FIELD_2SEND2_SERVER:String = "username";
	public static var LOGIN_PASSWORD_FIELD_2SEND2_SERVER:String = "password";

	public static function updateURLs():Void {
		FILE_OPEN = BASE_URL + "MoonShineServer/doFileGet";
		FILE_MODIFY = BASE_URL + "MoonShineServer/doFilePut";
		FILE_REMOVE = BASE_URL + "MoonShineServer/doFileDelete";
		FILE_NEW = BASE_URL + "MoonShineServer/doFilePost";
		FILE_RENAME = BASE_URL + "MoonShineServer/doFileReName";
		PROJECT_DIR = BASE_URL + "MoonShineServer/listAllFile?path=/";
		PROJECT_REMOVE = BASE_URL + "MoonShineServer/deleteProject";
		PROJECT_COMPILE = BASE_URL + "MoonShineServer/executeFlex";
		CONFIG = BASE_URL + "MoonShineServer/config";
		LOGIN_TEST = BASE_URL + "admin/status"; // "Grails4NotesBroker/login/status"
		LOGIN_USER = BASE_URL + "admin/auth";
		CREATE_NEW_PROJECT = BASE_URL + "MoonShineServer/doProjectCreate";
	}
}