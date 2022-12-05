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
package actionScripts.utils {
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.net.SharedObject;
    
    import mx.collections.ICollectionView;
    import mx.collections.IViewCursor;
    import mx.controls.Tree;
    import mx.core.mx_internal;
    import mx.events.CollectionEventKind;
    import mx.events.TreeEvent;
    
    import actionScripts.valueObjects.FileWrapper;

    use namespace mx_internal;

    public class CustomTree extends Tree
	{
		public var propertyNameKey:String;
        public var propertyNameKeyValue:String;
        public var keyNav:Boolean = true;
		private var isItemOpening:Boolean;
        
		public function CustomTree():void
		{
			super();

            addEventListener(TreeEvent.ITEM_OPENING, onCustomTreeItemEventHandler);
            addEventListener(TreeEvent.ITEM_OPEN, onCustomTreeItemEventHandler);
            addEventListener(TreeEvent.ITEM_CLOSE, onCustomTreeItemEventHandler);
		}

		public function saveItemForOpen(item:Object):void
		{
			SharedObjectUtil.saveProjectTreeItemForOpen(item, propertyNameKey, propertyNameKeyValue);
		}

        public function removeFromOpenedItems(item:Object):void
        {
			SharedObjectUtil.removeProjectTreeItemFromOpenedItems(item, propertyNameKey, propertyNameKeyValue);
        }

        public function expandChildrenByName(itemPropertyName:String, childrenForOpen:Array):void
        {
            var childrenForOpenCount:int = childrenForOpen.length;
            for (var i:int = 0; i < childrenForOpenCount; i++)
            {
                var item:Object = childrenForOpen[i];
                for each (var childForOpen:Object in dataProvider)
                {
                    var folderLastSeparator:int = childForOpen.nativePath.lastIndexOf(childForOpen.file.fileBridge.separator);
                    var folder:String = childForOpen.nativePath.substring(folderLastSeparator + 1);

                    if ((childForOpen.hasOwnProperty(itemPropertyName) && childForOpen[itemPropertyName] == item) || folder == item)
                    {
                        if (!isItemOpen(childForOpen))
                        {
                            saveItemForOpen(childrenForOpen);
                            expandItem(childForOpen, true);
                        }

                        childrenForOpen = childrenForOpen.slice(i + 1, childrenForOpenCount);
                        expandChildrenOfByName(getChildren(childForOpen, iterator.view), itemPropertyName, childrenForOpen);
                        break;
                    }
                }
            }
        }

        private function expandChildrenOfByName(children:ICollectionView, itemPropertyName:String, childrenForOpen:Array):void
        {
			if (children)
			{
				var firstItem:String = childrenForOpen.shift();
				var cursor:IViewCursor = children.createCursor();
				var currentItem:Object;
				
				if (childrenForOpen.length == 0)
				{
					while (!cursor.afterLast)
					{
						currentItem = cursor.current;
						if (currentItem[itemPropertyName] == firstItem)
						{
							selectedItem = currentItem;
							scrollToIndex(getItemIndex(currentItem));
							break;
						}
						cursor.moveNext();
					}
				}
				else
				{
					var itemForOpenFound:Boolean = false;
					while (!cursor.afterLast)
					{
						currentItem = cursor.current;
						if (dataDescriptor.isBranch(currentItem) && currentItem[itemPropertyName] == firstItem)
						{
							if (!isItemOpen(currentItem))
							{
								updateItemChildren(currentItem as FileWrapper);
								expandItem(currentItem, true);
								(currentItem as FileWrapper).sortChildren();
								saveItemForOpen(currentItem);
							}
							
							expandChildrenOfByName(getChildren(currentItem, iterator.view), itemPropertyName, childrenForOpen);
							itemForOpenFound = true;
							break;
						}
						else
						{
							cursor.moveNext();
						}
					}
				}
			}
        }
        
        override protected function keyDownHandler(event:KeyboardEvent):void
		{
			if (keyNav) super.keyDownHandler(event);
		}

        override protected function collectionChangeHandler(event:Event):void
        {
            super.collectionChangeHandler(event);

            reopenPreviouslyClosedItems(event["kind"], event["items"]);
        }

        private function onCustomTreeItemEventHandler(event:TreeEvent):void
        {
            isItemOpening = event.type == TreeEvent.ITEM_OPENING;
            updateItemChildren(event.item as FileWrapper);
        }

        private function reopenPreviouslyClosedItems(eventKind:String, items:Array):void
        {
            if (!this.dataProvider || isItemOpening)
            {
                return;
            }

            var itemsCount:int = this.dataProvider.length;
            if (itemsCount > 0)
            {
                if (eventKind == CollectionEventKind.ADD || eventKind == CollectionEventKind.RESET)
                {
                    itemsCount = items.length;
                    if (eventKind == CollectionEventKind.RESET)
                    {
                        if (itemsCount == 0)
                        {
                            items = this.dataProvider.source.slice();
                            itemsCount = items.length;
                        }
                    }

                    if (itemsCount > 0)
                    {
                        setItemsAsOpen(items);
                    }
                }
            }
        }

        private function setItemsAsOpen(items:Array):void
		{
            var cookie:SharedObject = SharedObjectUtil.getMoonshineIDEProjectSO("projectTree");
            if (!cookie) return;

            var projectTree:Array = cookie.data.projectTree;
			if (projectTree && items.length > 0)
			{
                var item:Object = items.shift();
                if (!isItemOpen(item))
                {
                    var hasItemForOpen:Boolean = projectTree.some(
                            function hasSomeItemForOpen(itemForOpen:Object, index:int, arr:Array):Boolean {
                                return itemForOpen.hasOwnProperty(item[propertyNameKey]) &&
                                        itemForOpen[item[propertyNameKey]] == item[propertyNameKeyValue];
                            });
                    if (hasItemForOpen)
                    {
                        updateItemChildren(item as FileWrapper);
						expandItem(item, true);
						(item as FileWrapper).sortChildren();
                    }
                }
				
				setItemsAsOpen(items);
			}
		}

        private function updateItemChildren(item:FileWrapper):void
        {
            item.updateChildren();
        }
    }
}