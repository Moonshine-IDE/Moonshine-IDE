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
package actionScripts.ui.tabview
{
	import actionScripts.ui.tabview.TabEvent;
	import actionScripts.ui.tabview.TabViewTab;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;
	
	import mx.containers.Canvas;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.ResizeEvent;
	

	/*
		TODO: 
			Make it clearer what selectedIndex means
			Use skins instead of drawing in TabViewTab
	*/

	public class TabView extends Canvas
	{
		private var tabContainer:Canvas;
		private var itemContainer:Canvas;
		private var shadow:UIComponent;
		
		private var othersButton:TabViewTab;
		private var othersMenu:VBox;
		
		private var tabLookup:Dictionary = new Dictionary(true); // child:tab
		
		private var tabSizeDefault:int = 200;
		private var tabSizeMin:int = 100; 
		
		protected var needsTabLayout:Boolean;
		protected var needsNewSelectedTab:Boolean = false;
		
		private var _selectedIndex:int = 0;
		public function get selectedIndex():int
		{
			return _selectedIndex;
		}
		public function set selectedIndex(v:int):void
		{
			if (itemContainer.numChildren == 0) return;
			if (v < 0) v = 0;
			_selectedIndex = v;
			
			// Explicitly set new, so no automagic needed.
			needsNewSelectedTab = false;
			
			// Select correct tab
			for (var i:int = 0; i < tabContainer.numChildren; i++)
			{
				if (i == v)
				{
					TabViewTab(tabContainer.getChildAt(i)).selected = true;	
				}
				else
				{
					TabViewTab(tabContainer.getChildAt(i)).selected = false;
				}
			}
			
			var itemToDisplay:DisplayObject;
			
			if (v >= tabContainer.numChildren)
			{
				// Reparent tab so it's not in the others menu.
				// We let invalidateTabs move another tab out to that menu again later.
				var tab:TabViewTab = othersMenu.getChildAt(v-tabContainer.numChildren) as TabViewTab;
				tabContainer.addChild(tab);
				tab.selected = true;
				invalidateTabs();
				_selectedIndex = tabContainer.getChildIndex(tab);
				itemToDisplay = tab.data as DisplayObject;
			}
			else
			{
				itemToDisplay = TabViewTab(tabContainer.getChildAt(v)).data as DisplayObject;
			}
			
			// Display or hide content
			for (i = 0; i < itemContainer.numChildren; i++) 
			{	
				var child:DisplayObject = itemContainer.getChildAt(i);
				if (child == itemToDisplay)
				{
					child.visible = true;
					UIComponent(child).setFocus();
					dispatchEvent( new TabEvent(TabEvent.EVENT_TAB_SELECT, child) );
				} 
				else 
				{
					child.visible = false;
				}
			}
			
			invalidateTabs();
		}
		
		public function TabView()
		{
			super();
			addEventListener(ResizeEvent.RESIZE, handleResize);
		}
		
		private function handleResize(event:Event):void
		{
			invalidateTabs();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			tabContainer = new Canvas();
			tabContainer.styleName = "tabView";
			tabContainer.horizontalScrollPolicy = 'off';
			tabContainer.height = 25;
			tabContainer.percentWidth = 100;
			super.addChild(tabContainer);
			
			itemContainer = new Canvas();
			itemContainer.percentWidth = 100;
			itemContainer.percentHeight = 100;
			itemContainer.y = 25;
			super.addChild(itemContainer);
			
			shadow = new UIComponent();
			shadow.percentWidth = 200;
			shadow.height = 25;
			shadow.mouseEnabled = false;
			super.addChild(shadow);
			
			othersButton = new TabViewTab();
			othersButton.setStyle('textPaddingLeft', 2);
			othersButton.showCloseButton = false;
			othersButton.width = 25;
			othersButton.right = 0;
			othersButton.visible = false;
			othersButton.addEventListener(MouseEvent.MOUSE_OVER, showOthersMenu);
			othersButton.addEventListener(MouseEvent.MOUSE_OUT, hideOthersMenu);
			super.addChild(othersButton);
			
			othersMenu = new VBox();
			othersMenu.setStyle('verticalGap', 0);
			othersMenu.right = 0;
			othersMenu.top = 25;
			othersMenu.visible = false;
			othersMenu.filters = [new DropShadowFilter(3, 90, 0x0, .3, 4, 4, 1)];
			othersButton.addEventListener(MouseEvent.MOUSE_OUT, hideOthersMenu);
			super.addChild(othersMenu); 
		}
		
		private function addTabFor(child:DisplayObject):void
		{
			var tab:TabViewTab = new TabViewTab();
			tab.data = child;
			tabLookup[child] = tab;
			if (child.hasOwnProperty('label')) 
			{
				tab.label = child['label'];
				child.addEventListener('labelChanged', updateTabLabel);
			}
			tabContainer.addChildAt(tab,0);
			tab.addEventListener(TabViewTab.EVENT_TAB_CLICK, focusTab);
			tab.addEventListener(TabViewTab.EVENT_TAB_CLOSE, closeTab);
			callLater(invalidateTabs);
		}
		
		private function removeTabFor(child:DisplayObject):void
		{
			var tab:DisplayObject = tabLookup[child];
			tabLookup[child] = null;
			child.removeEventListener('labelChanged', updateTabLabel);
			tab.parent.removeChild(tab);
			
			invalidateTabs();
		}
		
		private function closeTab(event:Event):void
		{
			var childIndex:int = tabContainer.getChildIndex(event.target as DisplayObject);
			var child:DisplayObject = TabViewTab(event.target).data as DisplayObject;
			
			var te:TabEvent = new TabEvent(TabEvent.EVENT_TAB_CLOSE, child);
			dispatchEvent(te);
			if (te.isDefaultPrevented()) return;
			 
			removeChild(child);
			
			invalidateTabs();
		}
		
		private function updateTabLabel(event:Event):void
		{
			var child:DisplayObject = event.target as DisplayObject;
			var tab:TabViewTab = tabLookup[child];
			
			tab.label = child['label'];
		}
		
		private function focusTab(event:Event):void
		{
			if (event.target.parent == tabContainer)
			{ 
				selectedIndex = tabContainer.getChildIndex(event.target as DisplayObject);
			} 
			else
			{
				var tab:TabViewTab = event.target as TabViewTab;
				othersMenu.removeChild(tab);
				tabContainer.addChild(tab);
				tab.selected = true;
				selectedIndex = tabContainer.numChildren-1;
				
				othersMenu.visible = false;
			}
		}
		
		private function showOthersMenu(event:Event):void
		{
			othersMenu.visible = true;	
		}
		
		private function hideOthersMenu(event:Event):void
		{
			if (othersMenu.hitTestPoint(mouseX, mouseY, true)) return;
			
			othersMenu.visible = false;
		}
		
		
		
		public function invalidateTabs():void
		{
			needsTabLayout = true;
			invalidateDisplayList();
		}
		
		override public function getChildIndex(child:DisplayObject):int
		{
			var tab:DisplayObject = tabLookup[child];
			if (tab.parent == tabContainer)
			{
				return tabContainer.getChildIndex(tab);
			} 
			else
			{
				return othersMenu.getChildIndex(tab) + tabContainer.numChildren;
			}
		}
		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			addTabFor(child);
			selectedIndex = tabContainer.numChildren-1;
			return itemContainer.addChild(child);
		}
		
		override public function removeChildAt(index:int):DisplayObject
		{
			needsNewSelectedTab = true;
			invalidateDisplayList();
			
			removeTabFor(itemContainer.getChildAt(index));
			return itemContainer.removeChildAt(index);
		}
		
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			needsNewSelectedTab = true;
			invalidateDisplayList();
			
			removeTabFor(child);
			
			return itemContainer.removeChild(child);
		}
		
		protected function focusNewTab():void
		{
			if (selectedIndex-1 < tabContainer.numChildren)
				selectedIndex = _selectedIndex-1;
			else
				selectedIndex = 0;
		}
		
		
		protected function updateTabLayout():void
		{	
			if (othersMenu.numChildren > 0)
			{ 
				othersButton.visible = true;
				othersButton.label = othersMenu.numChildren.toString();
			}
			else
			{
				othersButton.visible = false;	
			} 
			
			// Each item draws vertical separators on both sides, overlap by 1 px to not have duplicate lines.
			var avalibleWidth:int = width+1;
			if (othersButton.visible) avalibleWidth -= othersButton.width;
			
			var numTabs:int = tabContainer.numChildren;
			var tabWidth:int = int(avalibleWidth/numTabs);
			
			tabWidth = Math.max(tabWidth, tabSizeMin);
			tabWidth = Math.min(tabWidth, tabSizeDefault); 
			tabWidth += 2;
			
			var pos:int = -2;
			for (var i:int = tabContainer.numChildren-1; i > -1; i--)
			{
				var tab:TabViewTab = tabContainer.getChildAt(i) as TabViewTab;
				tab.x = pos;
				tab.y = 0;
				tab.width = tabWidth;
				pos += tabWidth-1;
			}
		}
		
		protected function fitTabs():void
		{
			var availableWidth:int = Math.max(0, width-othersButton.width);
			var numTabs:int = tabContainer.numChildren + othersMenu.numChildren;
			var tabsWeCanFit:int = Math.floor(availableWidth/tabSizeMin);
			
			if (tabContainer.numChildren < tabsWeCanFit)
			{ 	
				// Move tabs to tab bar
				var tabsToMove:int = Math.min(tabsWeCanFit-tabContainer.numChildren, othersMenu.numChildren);
				for (var i:int = 0; i < tabsToMove; i++)
				{
					var tab:TabViewTab = othersMenu.getChildAt(0) as TabViewTab;
					tab.removeEventListener(MouseEvent.MOUSE_OUT, hideOthersMenu);
					othersMenu.removeChild(tab);
					tabContainer.addChildAt(tab, 0);
				}
			}
			else if (tabContainer.numChildren > tabsWeCanFit)
			{ 	
				// Move tabs to menu (but never the last tab)
				for (i = tabContainer.numChildren-tabsWeCanFit-1; i >= 0; i--)
				{
					tab = tabContainer.getChildAt(i) as TabViewTab;
					if (tab.selected)
					{ 
						// Don't move selected tab
						if (i+1 >= tabContainer.numChildren) break;
						tab = tabContainer.getChildAt(i+1) as TabViewTab;
					}
					
					tab.addEventListener(MouseEvent.MOUSE_OUT, hideOthersMenu);
					tab.width = tabSizeDefault;
					othersMenu.addChildAt(tab, 0);
				}
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var mtr:Matrix = new Matrix();
			mtr.createGradientBox(unscaledWidth, 8, Math.PI/2, 0, 18);
			
			shadow.graphics.clear();
			shadow.graphics.beginGradientFill('linear', [0x000000, 0x000000], [0, 0.1], [0, 255], mtr);
			shadow.graphics.drawRect(0, 17, unscaledWidth, 8);
			shadow.graphics.endFill();
			
			shadow.graphics.lineStyle(1, 0x0, 0.4);
			shadow.graphics.moveTo(0, 24);
			shadow.graphics.lineTo(unscaledWidth, 24);
			
			if (needsNewSelectedTab)
			{
				focusNewTab();
				needsNewSelectedTab = false;
			} 
			
			if (needsTabLayout)
			{
				fitTabs();
				updateTabLayout();
				needsTabLayout = false;
			}
		}
		
	}
}