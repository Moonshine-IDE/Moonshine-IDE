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
package actionScripts.plugins.fileAssociation
{
	import flash.desktop.NativeApplication;
	import flash.events.InvokeEvent;
	import flash.events.NativeDragEvent;
	
	import actionScripts.events.OpenFileEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.PluginBase;

	public class FileAssociationPlugin extends PluginBase
	{
		override public function get name():String			{ return "FileAssociation"; }
		override public function get author():String		{ return "Moonshine Project Team"; }
		override public function get description():String	{ return "File Association Plugin. Esc exits."; }
		
		private var openWithCollection:Array;
		
		override public function activate():void
		{
			super.activate();
			
			var topLevel:* = NativeApplication.nativeApplication;
			
			// open-with listener
			topLevel.addEventListener(InvokeEvent.INVOKE, onAppInvokeEvent, false, 0, true);
			
			// drag-drop listeners
			topLevel.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, onNativeItemDragEnter, false, 0, true);
			topLevel.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, onNativeItemDragDrop, false, 0, true);
		}
		
		private function onAppInvokeEvent(event:InvokeEvent):void
		{
			openWithCollection = event.arguments;
			if (openWithCollection.length)
			{
				for each (var i:String in openWithCollection)
				{
					dispatcher.dispatchEvent(new OpenFileEvent(OpenFileEvent.OPEN_FILE, new FileLocation(i)));
				}
			}
		}
		
		private function onNativeItemDragEnter(event:NativeDragEvent):void
		{
			
		}
		
		private function onNativeItemDragDrop(event:NativeDragEvent):void
		{
			
		}
	}
}