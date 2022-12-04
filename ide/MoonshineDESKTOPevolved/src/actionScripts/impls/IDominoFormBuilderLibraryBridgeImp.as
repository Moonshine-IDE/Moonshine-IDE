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
package actionScripts.impls
{
	import flash.filesystem.File;
	
	import spark.components.TitleWindow;
	
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugins.ui.editor.dominoFormBuilder.DominoFormBuilderWrapper;
	import actionScripts.ui.resizableTitleWindow.ResizableTitleWindow;
	import actionScripts.utils.FileUtils;
	
	import components.skins.ResizableTitleWindowSkin;
	
	import view.dominoFormBuilder.DominoTabularForm;
	import view.interfaces.IDominoFormBuilderLibraryBridge;

	public class IDominoFormBuilderLibraryBridgeImp extends ConsoleOutputter implements IDominoFormBuilderLibraryBridge
	{
		private var model:IDEModel = IDEModel.getInstance();
		
		//--------------------------------------------------------------------------
		//
		//  INTERFACE API
		//
		//--------------------------------------------------------------------------
		
		public function getTabularEditorInterfaceWrapper():DominoTabularForm
		{
			var editor:DominoFormBuilderWrapper = model.activeEditor as DominoFormBuilderWrapper;
			if (editor)
			{
				return editor.tabularEditorInterface;
			}
			
			return null;
		}
		
		public function getNewMoonshinePopup():TitleWindow
		{
			var tmpPopup:ResizableTitleWindow = new ResizableTitleWindow();
			tmpPopup.setStyle("skinClass", ResizableTitleWindowSkin);
			
			return tmpPopup;
		}
		
		public function getDominoFieldTemplateFile(path:String):File
		{
			return (File.applicationDirectory.resolvePath("elements/templates/domino/"+ path));
		}
		
		public function read(file:File):String
		{
			return (FileUtils.readFromFile(file) as String);
		}
		
		public function readAsync(file:File, onSuccess:Function, onFault:Function=null):void
		{
			FileUtils.readFromFileAsync(file, FileUtils.DATA_FORMAT_STRING, onSuccess, onFault);
		}
	}
}