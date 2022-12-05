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

extern class HelperConstants
{
	public static final SUCCESS:String;
	public static final ERROR:String;
	public static final WARNING:String;
	public static final START:String;
	public static final MOONSHINE_NOTIFIER_FILE_NAME:String;
	public static final INSTALLER_COOKIE:String;
	public static final DEFAULT_SDK_FOLDER_NAME:String;
	
	public static var IS_MACOS:Bool;
	public static var IS_RUNNING_IN_MOON:Bool;
	public static var IS_INSTALLER_READY:Bool;
	public static var CONFIG_AIR_VERSION:String;
	public static var WINDOWS_64BIT_DOWNLOAD_DIRECTORY:String;
	public static var INSTALLER_UPDATE_CHECK_URL:String;
	public static var IS_DETECTION_IN_PROCESS:Bool;
	public static var CUSTOM_PATH_SDK_WINDOWS:String;
	public static var IS_CUSTOM_WINDOWS_PATH:Bool;
	public static var IS_ALLOWED_TO_CHOOSE_CUSTOM_PATH:Bool;
}