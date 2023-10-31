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
package actionScripts.plugins.ondiskproj.crud.exporter.pages
{
	import actionScripts.plugins.ondiskproj.crud.exporter.utils.RoyaleCRUDUtils;
	import actionScripts.plugins.ondiskproj.crud.exporter.vo.PageImportReferenceVO;

	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.plugins.ondiskproj.crud.exporter.settings.RoyaleCRUDClassReferenceSettings;
	import actionScripts.utils.FileUtils;
	import actionScripts.valueObjects.ProjectVO;

	import flash.net.registerClassAlias;

	import mx.utils.ObjectUtil;

	import view.dominoFormBuilder.vo.DominoFormVO;

	public class RoyalePageGeneratorBase extends EventDispatcher
	{
		protected var pagePath:FileLocation;
		protected var form:DominoFormVO;
		protected var project:ProjectVO;
		protected var classReferenceSettings:RoyaleCRUDClassReferenceSettings;
		protected var onCompleteHandler:Function;
		protected var pageImportReferences:Vector.<PageImportReferenceVO>;

		private var _queuedImportReferences:Vector.<PageImportReferenceVO>;
		
		protected function get pageRelativePathString():String		{	return null;	}

		protected function get importPathStatements():Array
		{
			var paths:Array = [];
			for each (var item:PageImportReferenceVO in pageImportReferences)
			{
				if (classReferenceSettings[(item.name + RoyaleCRUDClassReferenceSettings.IMPORT)] != undefined)
				{
					paths.push("import "+ classReferenceSettings[(item.name + RoyaleCRUDClassReferenceSettings.IMPORT)] +";");
				}
			}
			return paths;
		}

		protected function get namespacePathStatements():Array
		{
			var paths:Array = [];
			for each (var item:PageImportReferenceVO in pageImportReferences)
			{
				paths.push('xmlns:'+ item.name +'="'+ classReferenceSettings[(item.name + RoyaleCRUDClassReferenceSettings.NAMESPACE)] +'" ');
			}
			return paths;
		}
		
		public function RoyalePageGeneratorBase(project:ProjectVO, form:DominoFormVO, classReferenceSettings:RoyaleCRUDClassReferenceSettings, onComplete:Function=null)
		{
			this.project = project;
			this.form = form;
			this.classReferenceSettings = classReferenceSettings;
			this.onCompleteHandler = onComplete;
			
			if (pageRelativePathString) 
				pagePath = project.sourceFolder.fileBridge.resolvePath(pageRelativePathString);
		}
		
		public function generate():void
		{
			
		}
		
		public function loadPageFile():String
		{
			if (pagePath && pagePath.fileBridge.exists)
			{
				return (pagePath.fileBridge.read() as String);
			}
			
			return null;
		}
		
		protected function saveFile(content:String):void
		{
			FileUtils.writeToFileAsync(pagePath.fileBridge.getFile as File, content, onSuccessWriting, onFailWriting);
			
			/*
			 * @local
			 */
			function onSuccessWriting():void
			{
				
			}
			function onFailWriting(message:String):void
			{
				
			}
		}

		protected function dispatchCompletion():void
		{
			if (onCompleteHandler != null)
			{
				onCompleteHandler(this);
				onCompleteHandler = null;
			}
		}

		protected function generateClassReferences(onReferenceCollected:Function):void
		{
			registerClassAlias("actionScripts.plugins.ondiskproj.crud.exporter.vo.PageImportReferenceVO", PageImportReferenceVO);
			_queuedImportReferences = ObjectUtil.copy(pageImportReferences) as Vector.<PageImportReferenceVO>;
			startReferenceCollecting(onReferenceCollected);
		}

		private function startReferenceCollecting(onReferenceCollected:Function):void
		{
			var refObj:PageImportReferenceVO;
			if (_queuedImportReferences && _queuedImportReferences.length != 0)
			{
				refObj = _queuedImportReferences.shift();
				RoyaleCRUDUtils.getImportReferenceFor(refObj.name +"."+ refObj.extension, project, onImportCompletes, [refObj.extension]);
			}
			else
			{
				onReferenceCollected();
			}

			/*
			 * @local
			 */
			function onImportCompletes(importPath:String):void
			{
				if (importPath != null)
				{
					classReferenceSettings[(refObj.name + RoyaleCRUDClassReferenceSettings.IMPORT)] = importPath;

					var splitPath:Array = importPath.split(".");
					splitPath[splitPath.length - 1] = "*";
					classReferenceSettings[(refObj.name + RoyaleCRUDClassReferenceSettings.NAMESPACE)] = splitPath.join(".");
				}

				startReferenceCollecting(onReferenceCollected);
			}
		}
	}


}