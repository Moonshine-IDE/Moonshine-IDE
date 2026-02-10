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
package actionScripts.plugins.externalEditors.importer
{
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	
	import actionScripts.plugins.externalEditors.vo.ExternalEditorVO;
	import actionScripts.utils.FileUtils;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;

	public class ExternalEditorsImporter
	{
		public static const WINDOWS_INSTALL_DIRECTORIES:Array = ["Program files", "Program Files (x86)"];

		public static function get lastUpdateDate():Date
		{
			var listFile:File = File.applicationDirectory.resolvePath("elements/data/DefaultExternalEditors.xml");
			if (!listFile.exists) return null;

			return listFile.modificationDate;
		}
		
		public static function getDefaultEditors():ArrayCollection
		{
			var listFile:File = File.applicationDirectory.resolvePath("elements/data/DefaultExternalEditors.xml");
			if (!listFile.exists) return null;
			
			var tmpCollection:ArrayCollection = new ArrayCollection();
			var listFileXML:XML = XML(FileUtils.readFromFile(listFile));
			var tmpEditor:ExternalEditorVO;
			var isWindows:Boolean;
			var isMac:Boolean;
			for each (var editor:XML in listFileXML..editor)
			{
				isWindows = String(editor.@isWindows) == "true" ? true : false;
				isMac = String(editor.@isMac) == "true" ? true : false;
				 
				if (ConstantsCoreVO.IS_MACOS && !isMac)
				{
					continue;
				}
				else if (ConstantsCoreVO.IS_WINDOWS && !isWindows)
				{
					continue;
				} 
				else if (!ConstantsCoreVO.IS_MACOS && !ConstantsCoreVO.IS_WINDOWS)
				{
					continue;
				}
				
				tmpEditor = new ExternalEditorVO(String(editor.@id));
				tmpEditor.title = String(editor.title);
				tmpEditor.website = String(editor.website);
				tmpEditor.fileTypes = (String(editor.fileTypes) != "") ? String(editor.fileTypes).split(",") : [];
				
				var installPath:String = checkPath(
					String(editor.defaultLocation[ConstantsCoreVO.IS_MACOS ? "macos" : "windows"].valueOf())
				);
				if (editor.hasOwnProperty("defaultArguments"))
				{
					tmpEditor.extraArguments = String(editor.defaultArguments[ConstantsCoreVO.IS_MACOS ? "macos" : "windows"].valueOf());
				}
				
				tmpEditor.installPath = new File(installPath);
				tmpEditor.defaultInstallPath = installPath;
				tmpEditor.isEnabled = tmpEditor.isValid == true;
				tmpEditor.isMoonshineDefault = true;
				
				tmpCollection.addItem(tmpEditor);
			}
			
			if (tmpCollection)
			{
				UtilsCore.sortCollection(tmpCollection, ["title"]);
			}
			
			return tmpCollection;
		}
		
		private static function checkPath(path:String):String
		{
			if (path.indexOf("$userDirectory") != -1)
			{
				return (path.replace("$userDirectory", File.userDirectory.nativePath));
			}
			
			if (ConstantsCoreVO.IS_WINDOWS)
			{
				return validateWindowsInstallation(path);
			}
			
			return path;
		}
		
		private static function validateWindowsInstallation(path:String):String
		{
			var tmpPath:String;
			path = path.replace("$programFiles", "");
			if (ConstantsCoreVO.is64BitSupport)
			{
				for each(var i:String in WINDOWS_INSTALL_DIRECTORIES)
				{
					tmpPath = "C:/"+ i +"/"+ path;
					if (FileUtils.isPathExists(tmpPath))
					{
						return tmpPath;
					}
				}
			}
			
			return "C:/"+ WINDOWS_INSTALL_DIRECTORIES[0] +"/"+ path;
		}
	}
}