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
package actionScripts.utils
{
	import actionScripts.events.StatusBarEvent;
	import actionScripts.plugins.build.ConsoleBuildPluginBase;
	import actionScripts.valueObjects.ConstantsCoreVO;

	import flash.events.Event;

	import flash.events.IOErrorEvent;

	import flash.events.NativeProcessExitEvent;

	import flash.filesystem.File;

	import spark.components.Alert;

	public class ZipUsingNP extends ConsoleBuildPluginBase
	{
		public static const EVENT_ZIP_COMPLETES:String = "eventZipProcessCompletes";
		public static const EVENT_ZIP_FAILED:String = "eventZipProcessFailed";

		private var _errorText:String;
		public function get errorText():String
		{
			return _errorText;
		}

		public function ZipUsingNP()
		{
			super();
			activate();
		}

		public function zip(source:File, destination:File):void
		{
			if (running)
			{
				Alert.show("A zip process is already running.", "Error!");
				return;
			}

			_errorText = null;
			var command:String;
			if (ConstantsCoreVO.IS_MACOS)
			{
				if (source.isDirectory)
				{
					command = 'cd "'+ source.nativePath +'";zip -r "'+ destination.nativePath +'" *';
				}
				else
				{
					command = 'zip "'+ destination.nativePath +'" "'+ source.nativePath +'"';
				}
			}
			else
			{
				var powerShellPath:String = UtilsCore.getPowerShellExecutablePath();
				if (powerShellPath)
				{
					if (source.isDirectory)
					{
						command = '"'+ powerShellPath +'" Compress-Archive "'+ source.nativePath +'/* "'+ destination.nativePath +'"';
					}
					else
					{
						command = '"'+ powerShellPath +'" Compress-Archive "'+ source.nativePath +' "'+ destination.nativePath +'"';
					}
				}
				else
				{
					error("Failed to locate PowerShell during execution.");
					return;
				}
			}

			//warning("%s", command);
			this.start(
					new <String>[command]
			);
		}

		override protected function onNativeProcessIOError(event:IOErrorEvent):void
		{
			_errorText = event.text;
			dispatchEvent(new Event(EVENT_ZIP_FAILED));
		}

		override protected function onNativeProcessExit(event:NativeProcessExitEvent):void
		{
			super.onNativeProcessExit(event);
			if (!_errorText)
			{
				dispatchEvent(new Event(EVENT_ZIP_COMPLETES));
			}
		}
	}
}
