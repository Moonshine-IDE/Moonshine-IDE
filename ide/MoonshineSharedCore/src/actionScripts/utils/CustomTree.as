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
    import mx.controls.Tree;
    import mx.events.CollectionEventKind;
    import mx.events.TreeEvent;
    
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
            var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT);
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