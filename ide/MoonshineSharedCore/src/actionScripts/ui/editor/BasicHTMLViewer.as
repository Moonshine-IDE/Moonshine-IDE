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
package actionScripts.ui.editor
{
	import mx.containers.Canvas;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.ui.IContentWindow;
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	/*
		Simple chrome-less browser, used for binary file viewing (images etc)
		TODO: Make sure it unloads properly!
	*/
	public class BasicHTMLViewer extends Canvas implements IContentWindow
	{
		[Bindable] public var file:FileLocation;
		
		override public function get label():String
		{
			if (file) return file.fileBridge.name;
			return "Image";
		}
		
		public function get longLabel():String
		{
			if (file) return file.fileBridge.nativePath;
			return "Image";
		}
		
		public function save():void
		{
		}
		
		public function isChanged():Boolean
		{
			return false;
		}
		
		public function isEmpty():Boolean
		{
			return true;
		}
		
		public function open(file:FileLocation):void
		{
			this.file = file;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			if (ConstantsCoreVO.IS_AIR) addChild(IDEModel.getInstance().flexCore.getHTMLView(file.fileBridge.url));
		}
	}
}