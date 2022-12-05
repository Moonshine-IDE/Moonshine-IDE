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
package actionScripts.plugin.core.importer
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.utils.OSXBookmarkerNotifiers;
	import actionScripts.valueObjects.ProjectVO;
	
	public class FlashBuilderImporterBase extends EventDispatcher
	{
		private static const SEARCH_BACK_COUNT:int = 5;
		
		public function FlashBuilderImporterBase(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		protected static function parsePaths(paths:XMLList, v:Vector.<FileLocation>, p:ProjectVO, attrName:String="path", documentPath:String=null):void 
		{
			for each (var pathXML:XML in paths)
			{
				var path:String = pathXML.attribute(attrName);
				var f:FileLocation;
				if (documentPath && (path.indexOf("${DOCUMENTS}") != -1)) 
				{
					path = path.replace("${DOCUMENTS}", "");
					path = documentPath + path;
					f = p.folderLocation.resolvePath(path);
				}
				else if (path.indexOf("${DOCUMENTS}") != -1)
				{
					// since we didn't found {DOCUMENTS} path in
					// FlashBuilderImporter.readActionScriptSettings(), we take
					// {DOCUMENTS} as p.folderWrapper.parent to make the
					// fileLocation valid, else it'll throw error
					var isParentPathAvailable:Boolean = true;
					CONFIG::OSX
					{
						isParentPathAvailable = checkOSXBookmarked(p.folderLocation.fileBridge.parent.fileBridge.nativePath);
					}
					
					if (isParentPathAvailable)
					{
						path = path.replace("${DOCUMENTS}", "");
						path = p.folderLocation.fileBridge.parent.fileBridge.nativePath + path;
						f = p.folderLocation.resolvePath(path);
					}
					else
					{
						f = p.folderLocation.resolvePath(path);
					}
				}
				else
				{
					f = p.folderLocation.resolvePath(path);
				}
				
				if (f && f.fileBridge.exists) f.fileBridge.canonicalize();
				if (f) v.push(f);
			}
		}
		
		public static function checkOSXBookmarked(pathValue:String):Boolean
		{
			var tmpBList: Array = (OSXBookmarkerNotifiers.availableBookmarkedPaths) ? OSXBookmarkerNotifiers.availableBookmarkedPaths.split(",") : [];
			if (tmpBList.length >= 1)
			{
				if (tmpBList[0] == "") tmpBList.shift(); // [0] will always blank
				if (tmpBList[0] == "INITIALIZED") tmpBList.shift(); // very first time initialization after Moonshine installation
			}
			
			if (tmpBList.indexOf(pathValue) != -1) return true;
			else
			{
				for each(var j:String in tmpBList)
				{
					if (pathValue.indexOf(j) != -1)	return true;
				}
			}
			
			return false;
		}
	}
}