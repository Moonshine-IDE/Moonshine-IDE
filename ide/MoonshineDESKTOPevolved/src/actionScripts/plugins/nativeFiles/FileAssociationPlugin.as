////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
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
	
	import actionScripts.events.OpenFileEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.PluginBase;

	public class FileAssociationPlugin extends PluginBase
	{
		override public function get name():String			{ return "FileAssociationPlugin"; }
		override public function get author():String		{ return "Moonshine Project Team"; }
		override public function get description():String	{ return "File Association Plugin. Esc exits."; }
		
		override public function activate():void
		{
			super.activate();
			
			// open-with listener
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, onAppInvokeEvent, false, 0, true);
			
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
			for each (var i:String in paths)
			{
				var tmpOpenEvent:OpenFileEvent = new OpenFileEvent(OpenFileEvent.OPEN_FILE, new FileLocation(i));
				tmpOpenEvent.independentOpenFile = true;
				
				dispatcher.dispatchEvent(tmpOpenEvent);
			}
		}
	}
}