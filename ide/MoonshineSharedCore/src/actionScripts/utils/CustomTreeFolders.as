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
package actionScripts.utils {

	import actionScripts.valueObjects.FileWrapper;

	import flash.events.KeyboardEvent;
	
	import mx.controls.Tree;
	import mx.events.TreeEvent;

	public class CustomTreeFolders extends Tree
	{
		public var keyNav:Boolean = true;
		
		/**
		 * This class made specifically to show 
		 * folder items only in it's collective nodes
		 */
		public function CustomTreeFolders()
		{
			super();
			super.dataDescriptor = new DataDescriptorForCustomTree();

			addEventListener(TreeEvent.ITEM_OPENING, onCustomTreeItemEventHandler, false, 0, true);
			addEventListener(TreeEvent.ITEM_OPEN, onCustomTreeItemEventHandler, false, 0, true);
			addEventListener(TreeEvent.ITEM_CLOSE, onCustomTreeItemEventHandler, false, 0, true);
		}
		
		/**
		 * Key press custom management
		 */
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			if (keyNav) super.keyDownHandler(event);
		}

		private function onCustomTreeItemEventHandler(event:TreeEvent):void
		{
			updateItemChildren(event.item as FileWrapper);
		}

		private function updateItemChildren(item:FileWrapper):void
		{
			if (item.children.length == 0) item.updateChildren();
		}
	}
}