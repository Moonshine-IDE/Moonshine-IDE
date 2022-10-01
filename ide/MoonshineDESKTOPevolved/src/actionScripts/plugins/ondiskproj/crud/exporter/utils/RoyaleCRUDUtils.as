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
package actionScripts.plugins.ondiskproj.crud.exporter.utils
{
	import actionScripts.factory.FileLocation;

	import mx.collections.ArrayCollection;
	
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ProjectVO;

	public class RoyaleCRUDUtils
	{
		private static var fileName:String;
		
		public static function getImportReferenceFor(fileNameWithExtension:String, project:ProjectVO, onComplete:Function, extensions:Array=null):void
		{
			var files:ArrayCollection = new ArrayCollection();
			UtilsCore.parseFilesList(files, null, project, extensions, true, onFilesListParseCompletes);

			/*
			 * @local
			 */
			function onFilesListParseCompletes():void
			{
				fileName = fileNameWithExtension;
				files.filterFunction = resourceFilterFunction;
				files.refresh();

				if (files.length > 0)
				{
					var path:String =  project.sourceFolder.fileBridge.getRelativePath(
							new FileLocation(files[0].resourcePath),
							/*(files[0] as ResourceVO).sourceWrapper.file,*/
							true
					);
					if (path.indexOf("/") != -1) path = path.replace(/\//gi, ".");
					onComplete(path.substr(0, path.length - (files[0].extension.length + 1)));
				}
				else
				{
					onComplete(null);
				}
			}
		}
		
		private static function resourceFilterFunction(item:Object):Boolean
		{
			var itemName:String = item.name.toLowerCase();
			return (itemName == fileName.toLowerCase());
		}
	}
}