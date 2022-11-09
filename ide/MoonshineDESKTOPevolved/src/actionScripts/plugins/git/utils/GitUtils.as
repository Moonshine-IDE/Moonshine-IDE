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
package actionScripts.plugins.git.utils
{
	import actionScripts.utils.FileUtils;

	import flash.filesystem.File;

	public class GitUtils
	{
		public static const GIT_EXPECT		: XML = <root><![CDATA[
			#!/bin/sh

			log_user 0
			puts -nonewline "Enter password (exp): "
			flush stdout
			gets stdin password
			set newPromptA ".*password:"
			set newPromptB "Password.*:"

			log_user 1
			spawn %GIT_COMMAND%

			expect {
				-re $newPromptA {
					send "$password\r"
					interact
				} -re $newPromptB {
					send "$password\r"
					interact
				}
			}

			]]></root>

		public static function getCalculatedRemotePathWithAuth(initialPath:String, username:String, password:String=null):String
		{
			var calculatedURL:String = initialPath;
			if (calculatedURL.indexOf("@") != -1)
			{
				calculatedURL = calculatedURL.replace(
						calculatedURL.substring(0, calculatedURL.indexOf("@") + 1),
						""
				);
			}

			return (calculatedURL = "https://"+ username + (password ? ":"+ password : "") +"@"+ calculatedURL);
		}

		public static function getCalculatedRemotePathWithoutPassword(initialPath:String, username:String):String
		{
			var calculatedURL:String = initialPath;
			if (calculatedURL.indexOf("@") != -1)
			{
				calculatedURL = calculatedURL.replace(
						calculatedURL.substring(0, calculatedURL.indexOf("@") + 1),
						""
				);
			}

			return (calculatedURL = "https://"+ username +"@"+ calculatedURL);
		}

		public static function writeExpOnMacAuthentication(withCommand:String):String
		{
			var tmpExp:String = GIT_EXPECT.valueOf().toString();
			tmpExp = tmpExp.replace("%GIT_COMMAND%", withCommand);

			var tmpExpFile:File = File.applicationStorageDirectory.resolvePath("spawn/connectgit.exp");
			FileUtils.writeToFile(tmpExpFile, tmpExp);

			return tmpExpFile.nativePath;
		}
	}
}
