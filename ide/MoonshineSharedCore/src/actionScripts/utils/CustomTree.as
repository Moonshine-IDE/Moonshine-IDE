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

    public class CustomTree extends Tree
	{
        public var itemKeyForSave:String;
		private var cookie:SharedObject;

		public function CustomTree():void
		{
			super();

            cookie = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_PROJECT_TREE);
		}

		public var keyNav:Boolean = true;

		public function saveItemForOpen(item:Object):void
		{
			if (!cookie.data.projectTree)
			{
				cookie.data.projectTree = [];
			}

			if (item && item.hasOwnProperty(itemKeyForSave))
            {
                var hasItemForOpen:Boolean = cookie.data.projectTree.some(
						function hasSomeItemForOpen(itemForOpen:Object, index:int, arr:Array):Boolean
						{
                    		return itemForOpen.hasOwnProperty(item[itemKeyForSave]);
                		});

                if (itemKeyForSave && !hasItemForOpen)
                {
                    var itemForSave:Object = {};
                    itemForSave[item[itemKeyForSave]] = item[itemKeyForSave];
                    cookie.data.projectTree.push(itemForSave);

                    cookie.flush();
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
			if (event["kind"] == CollectionEventKind.RESET || event["kind"] == CollectionEventKind.ADD)
			{
				setItemsAsOpen(event["items"]);
			}
        }

        private function setItemsAsOpen(items:Array):void
		{
			var projectTree:Array = cookie.data.projectTree;
            var itemsCount:int = items.length;
			if (itemsCount == 0)
			{
				items = dataProvider.source;
				itemsCount = items.length;
			}

			if (projectTree && itemsCount > 0)
			{
				for (var i:int = 0; i < itemsCount; i++)
                {
					var item:Object = items[i];
                    var hasItemForOpen:Boolean = projectTree.some(function hasSomeItemForOpen(itemForOpen:Object, index:int, arr:Array):Boolean {
                        return itemForOpen.hasOwnProperty(item[itemKeyForSave]);
                    });

                    if (hasItemForOpen)
                    {
                        if (!isItemOpen(item))
                        {
                            expandItem(item, true);
                        }
                    }
                }
			}
		}
    }
}