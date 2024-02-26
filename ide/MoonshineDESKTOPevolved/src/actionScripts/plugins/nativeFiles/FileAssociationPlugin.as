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
package actionScripts.plugins.nativeFiles
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeDragManager;
	import flash.display.InteractiveObject;
	import flash.events.InvokeEvent;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	
	import mx.core.FlexGlobals;
	
	import spark.components.Alert;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.PluginBase;
	import actionScripts.valueObjects.ConstantsCoreVO;

	public class FileAssociationPlugin extends PluginBase
	{
		override public function get name():String			{ return "FileAssociationPlugin"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return "File Association Plugin."; }

		override public function activate():void
		{
			super.activate();
			
			// open-with listener
			GlobalEventDispatcher.getInstance().addEventListener(InvokeEvent.INVOKE, onAppInvokeEvent, false, 0, true);
			
			// drag-drop listeners
			FlexGlobals.topLevelApplication.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, onNativeItemDragEnter, false, 0, true);
			FlexGlobals.topLevelApplication.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, onNativeItemDragDrop, false, 0, true);
		}
		
		private function onAppInvokeEvent(event:InvokeEvent):void
		{
			if (event.arguments.length)
			{
				openFilesByPath(event.arguments);
			}
		}
		
		private function onNativeItemDragEnter(event:NativeDragEvent):void
		{
			if (!event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)) return;
			
			var files:Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			for each (var i:File in files)
			{
				if (i.isDirectory) return;
			}
			
			// accept drop
			NativeDragManager.acceptDragDrop(InteractiveObject(event.currentTarget));
		}
		
		private function onNativeItemDragDrop(event:NativeDragEvent):void
		{
			if (!event.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT)) return;
			
			var files:Array = event.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array;
			files = files.map(function(element:*, index:int, arr:Array):String
			{
				return element.nativePath;
			});
			
			openFilesByPath(files);
		}
		
		private function openFilesByPath(paths:Array):void
		{
			// since multi-folder-file selection is not possible
			// to open multiple projects at a time, we don't
			// need the following to be an array; also single
			// folder is suppose to have only configuration than
			// multiple
			var projectFile:FileLocation;
			
			for each (var i:String in paths)
			{
				var tmpFl:FileLocation = new FileLocation(i);
				// separate project-configuration files
				if (ConstantsCoreVO.READABLE_PROJECT_FILES.indexOf(tmpFl.fileBridge.extension) != -1)
				{
					projectFile = tmpFl;
				}
				else if (tmpFl.fileBridge.exists)
				{
					// open to editor any other redable files
					var tmpOpenEvent:OpenFileEvent = new OpenFileEvent(OpenFileEvent.OPEN_FILE, [tmpFl]);
					tmpOpenEvent.independentOpenFile = true;
					
					dispatcher.dispatchEvent(tmpOpenEvent);
				}
			}
				
			// for project-configurations
			if (projectFile && projectFile.fileBridge.exists)
			{
				// considering file is the only configuration file 
				// containing to its parent folder
				GlobalEventDispatcher.getInstance().dispatchEvent(
					new ProjectEvent(ProjectEvent.EVENT_IMPORT_PROJECT_NO_BROWSE_DIALOG, projectFile.fileBridge.parent.fileBridge.getFile)
				);
			}
		}
	}
}