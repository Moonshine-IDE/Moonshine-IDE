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