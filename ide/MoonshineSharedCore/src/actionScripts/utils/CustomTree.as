////////////////////////////////////////////////////////////////////////////////
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
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
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
                var childrenForOpenCount:int = childrenForOpen.length;
                for (var i:int = 0; i < childrenForOpenCount; i++)
                {
                    var cursor:IViewCursor = children.createCursor();
                    var currentItem:Object;

                    if (childrenForOpenCount == 1)
                    {
                        while (!cursor.afterLast)
                        {
                            currentItem = cursor.current;
                            if (currentItem[itemPropertyName] == childrenForOpen[i])
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
                            if (dataDescriptor.isBranch(currentItem) && currentItem[itemPropertyName] == childrenForOpen[i])
                            {
                                if (!isItemOpen(currentItem))
                                {
                                    saveItemForOpen(currentItem);
                                    expandItem(currentItem, true);
                                }
                                childrenForOpen = childrenForOpen.slice(i + 1, childrenForOpen.length);
                                expandChildrenOfByName(getChildren(currentItem, iterator.view), itemPropertyName, childrenForOpen);
                                itemForOpenFound = true;
                                break;
                            }
                            else
                            {
                                cursor.moveNext();
                            }
                        }

                        if (itemForOpenFound)
                        {
                            break;
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
                        expandItem(item, true);
                    }
                }

                setItemsAsOpen(items);
			}
		}
    }
}