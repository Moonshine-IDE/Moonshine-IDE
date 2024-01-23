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
package actionScripts.ui.tabview
{
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.geom.Matrix;
    import flash.ui.Keyboard;
    import flash.utils.Dictionary;
    
    import mx.containers.Canvas;
    import mx.controls.Menu;
    import mx.core.UIComponent;
    import mx.events.MenuEvent;
    import mx.events.ResizeEvent;
    
    import spark.events.IndexChangeEvent;
    
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.locator.IDEModel;
    import actionScripts.plugin.fullscreen.events.FullscreenEvent;
    import actionScripts.ui.IContentWindow;
    import actionScripts.ui.IFileContentWindow;
    import actionScripts.ui.ScrollableMenu;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.utils.SharedObjectUtil;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.HamburgerMenuTabsVO;
	
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
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();

        private var hamburgerMenuTabs:HamburgerMenuTabs;
		private var _model:TabsModel;
		
		private var lastSelectedIndex:int = -1;
		private var tabLookup:Dictionary = new Dictionary(true); // child:tab
		private var editorsListMenu:ScrollableMenu;
		private var multiKeys:Array;
		
		private var tabSizeDefault:int = 200;
		private var tabSizeMin:int = 100;
		
		protected var needsTabLayout:Boolean;
		protected var needsNewSelectedTab:Boolean;
		
		private var _selectedIndex:int = 0;
		public function get selectedIndex():int
		{
			return _selectedIndex;
		}

		private var lastSelectedTab:TabViewTab;
		public function set selectedIndex(value:int):void
		{
			if (tabContainer.numChildren == 0) return;
			//if (_selectedIndex == value) return;
			if (value < 0) value = 0;

			_selectedIndex = value;
			this.tabContainer.getChildren().some(function(element:TabViewTab, index:int, arr:Array):Boolean {
				if (element.selected)
				{
					lastSelectedTab = element as TabViewTab;
					lastSelectedIndex = index;
					return true;
				}
				return false;
			});
			
			// Explicitly set new, so no automagic needed.
			needsNewSelectedTab = false;
			
			// Select correct tab
			for (var i:int = 0; i < tabContainer.numChildren; i++)
			{
				if (i == value)
				{
					TabViewTab(tabContainer.getChildAt(i)).selected = true;
				}
				else
				{
					TabViewTab(tabContainer.getChildAt(i)).selected = false;
				}
			}
			
			var itemToDisplay:DisplayObject = TabViewTab(tabContainer.getChildAt(value)).data as DisplayObject;
			itemContainer.removeAllChildren();
			itemContainer.addChild(itemToDisplay);
			
			itemToDisplay.visible = true;
			UIComponent(itemToDisplay).setFocus();
			IDEModel.getInstance().activeEditor = itemToDisplay as IContentWindow;
			dispatcher.dispatchEvent(new TabEvent(TabEvent.EVENT_TAB_SELECT, itemToDisplay));
			
			invalidateLayoutTabs();
		}

		public function get model():TabsModel
		{
			return _model;
		}

		public function TabView()
		{
			super();

			_model = new TabsModel();
			addEventListener(ResizeEvent.RESIZE, handleResize);
			
			dispatcher.addEventListener(TabEvent.EVENT_TAB_NAVIGATE_NEXT_PREVIOUS_HOTKEYS, onNextPreviousTabNavigate, false, 0, true);
			dispatcher.addEventListener(TabEvent.EVENT_TAB_NAVIGATE_EDITORS_LIST_HOTKEYS, onTabListNavigate, false, 0, true);
		}
		
		private function onNextPreviousTabNavigate(event:Event):void
		{
			if (editorsListMenu)
			{
				updateEditorsListMenuOnTabKey();
				return;
			}
			
			if (tabContainer.numChildren <= 1) return;

			if (this.lastSelectedTab.parent == null)
			{
				// suppose to trigger when the last visited tab removed
				if (this.lastSelectedIndex >= this.tabContainer.numChildren)
				{
					if ((this.lastSelectedIndex - 1) != this.selectedIndex) selectedIndex = this.tabContainer.numChildren - 1;
					return;
				}

				this.lastSelectedIndex = (this.lastSelectedIndex == 0) ? 0 : this.lastSelectedIndex++;
				if (this.lastSelectedIndex == this.selectedIndex) this.lastSelectedIndex++;
				selectedIndex = this.lastSelectedIndex;
			}
			else
			{
				selectedIndex = this.tabContainer.getChildIndex(this.lastSelectedTab);
			}
		}
		
		private function onTabListNavigate(event:Event):void
		{
			if (!multiKeys)
			{
				multiKeys = [];
				stage.addEventListener(KeyboardEvent.KEY_UP, onKeysUp, false, 0, true); // need to handle this our own
				addEditorsListMenu();
			}
			else
			{
				updateEditorsListMenuOnTabKey();
			}
		}
		
		private function addEditorsListMenu():void
		{
			var tmpCollection:Array = [];
			var tab:TabViewTab;
			var tabData:DisplayObject;
			var i:int = tabContainer.numChildren - 1;
			while (i != -1)
			{
				tab = tabContainer.getChildAt(i) as TabViewTab;
				tabData = tab.data as DisplayObject;
				if (!tab.selected && tabData)
				{
					tmpCollection.push(new HamburgerMenuTabsVO(tab["label"], tabData, i));
				}
				i--;
			}
			if (_model.hamburgerTabs.length > 0)
			{
				tmpCollection = tmpCollection.concat(_model.hamburgerTabs.source);
			}

			// do not open menu if there's nothing to display
			if (tmpCollection.length == 0)
			{
				stage.removeEventListener(KeyboardEvent.KEY_UP, onKeysUp);
				multiKeys = null;
				return;
			}
			
			editorsListMenu = ScrollableMenu.createMenu(this, tmpCollection, false);
			editorsListMenu.labelField = "label";
			editorsListMenu.rowCount = 1;
			editorsListMenu.width = width * .6;
			editorsListMenu.show(tabContainer.x + ((width - editorsListMenu.width) / 2), 25);
			editorsListMenu.styleName = "multiLineList";
			editorsListMenu.callLater(function():void
			{
				editorsListMenu.selectedIndex = 0;
			});

			editorsListMenu.addEventListener(MenuEvent.MENU_HIDE, onMenuBeingHide, false, 0, true);
			editorsListMenu.addEventListener(MenuEvent.ITEM_CLICK, onItemBeingSelectedOnClick, false, 0, true);
		}

		private function onMenuBeingHide(event:MenuEvent):void
		{
			editorsListMenu.addEventListener(MenuEvent.MENU_HIDE, onMenuBeingHide, false, 0, true);
			stage.removeEventListener(KeyboardEvent.KEY_UP, onKeysUp);

			editorsListMenu.removeEventListener(MenuEvent.MENU_HIDE, onMenuBeingHide);
			editorsListMenu = null;
			multiKeys = null;
		}

		private function onItemBeingSelectedOnClick(event:MenuEvent):void
		{
			var selectedItem:HamburgerMenuTabsVO = event.item as HamburgerMenuTabsVO;
			if (selectedItem.visibleIndex != -1)
			{
				selectedIndex = selectedItem.visibleIndex;
			}
			else
			{
				addTabFromHamburgerMenu(selectedItem);
			}

			this.removeEditorsListMenu();
		}
		
		private function removeEditorsListMenu():void
		{
			stage.removeEventListener(KeyboardEvent.KEY_UP, onKeysUp);
			multiKeys = null;

			if (editorsListMenu)
			{
				editorsListMenu.removeEventListener(MenuEvent.ITEM_CLICK, onItemBeingSelectedOnClick);
				editorsListMenu.hide();
			}
		}
		
		private function onKeysUp(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.ESCAPE)
			{
				return;
			}

			if (event.keyCode == Keyboard.CONTROL || event.keyCode == Keyboard.SHIFT)
			{
				if ((multiKeys.length == 0) || multiKeys[0] != event.keyCode) multiKeys.push(event.keyCode);
				if (multiKeys.length == 2)
				{
					removeEditorsListMenu();
					multiKeys = null;
				}
			}
		}
		
		private function updateEditorsListMenuOnTabKey():void
		{
			editorsListMenu.selectedIndex++;
			editorsListMenu.selectedItem = editorsListMenu.dataProvider[editorsListMenu.selectedIndex];
		}

		public function setSelectedTab(editor:DisplayObject):void
		{
            var childIndex:int = getChildIndex(editor);
            if (childIndex != selectedIndex && childIndex > -1)
            {
                selectedIndex = childIndex;
            }
			else
			{
			    var hamburgerMenuCount:int = _model.hamburgerTabs.length;
				for (var i:int = 0; i < hamburgerMenuCount; i++)
				{
					var hamburgerMenuTabsVO:HamburgerMenuTabsVO = _model.hamburgerTabs.getItemAt(i) as HamburgerMenuTabsVO;
					if (hamburgerMenuTabsVO.tabData == editor)
					{
						addTabFromHamburgerMenu(hamburgerMenuTabsVO);
						break;
					}
				}
			}
		}

		private function handleResize(event:Event):void
		{
			invalidateLayoutTabs();
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

			hamburgerMenuTabs = new HamburgerMenuTabs();
			hamburgerMenuTabs.right = 0;
			hamburgerMenuTabs.top = 0;
			hamburgerMenuTabs.visible = hamburgerMenuTabs.includeInLayout = false;
			hamburgerMenuTabs.model = _model;
			hamburgerMenuTabs.addEventListener(Event.CHANGE, onHamburgerMenuTabsChange);
			
			super.addChild(hamburgerMenuTabs);
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
			tabContainer.addChildAt(tab, 0);

			tab.addEventListener(TabViewTab.EVENT_TAB_CLICK, onTabClick, false, 0, true);
			tab.addEventListener(TabViewTab.EVENT_TAB_CLOSE, onTabClose, false, 0, true);
			tab.addEventListener(TabViewTab.EVENT_TABP_CLOSE_ALL, onTabCloseAll, false, 0, true);
			tab.addEventListener(TabViewTab.EVENT_TAB_CLOSE_ALL_OTHERS, onTabCloseAllOthers, false, 0, true);
			tab.addEventListener(TabViewTab.EVENT_TAB_DOUBLE_CLICKED, onTabDoubleClicked, false, 0, true);

			invalidateLayoutTabs();
        }

		private function removeTabFor(child:DisplayObject):void
		{
			var tab:DisplayObject = tabLookup[child];
			
			delete tabLookup[child];
            tab.parent.removeChild(tab);

            child.removeEventListener('labelChanged', updateTabLabel);
            invalidateLayoutTabs();
		}
		
		private function onTabClose(event:Event):void
		{
			var child:DisplayObject = TabViewTab(event.target).data as DisplayObject;
			
			var te:TabEvent = new TabEvent(TabEvent.EVENT_TAB_CLOSE, child);
			dispatchEvent(te);
			if (te.isDefaultPrevented())
			{
				return;
            }

			removeChild(child);

			invalidateLayoutTabs();
		}

        private function onTabCloseAll(event:Event):void
        {
            removeTabsFromCache();
			UtilsCore.closeAllRelativeEditors(null);
        }

		private function onTabCloseAllOthers(event:Event):void
		{
			var child:DisplayObject = TabViewTab(event.target).data as DisplayObject;
			removeTabsFromCache(child as IContentWindow);
			UtilsCore.closeAllRelativeEditors(
					null, false, null, true,
					child as IContentWindow
					);
		}
		
		private function onTabDoubleClicked(event:Event):void
		{
			dispatcher.dispatchEvent(new FullscreenEvent(FullscreenEvent.EVENT_SECTION_FULLSCREEN, FullscreenEvent.SECTION_EDITOR));
		}

        private function updateTabLabel(event:Event):void
		{
			var child:DisplayObject = event.target as DisplayObject;
			var tab:TabViewTab = tabLookup[child];
			
			tab.label = child['label'];
		}
		
		private function onTabClick(event:Event):void
		{
			if (event.target.parent == tabContainer)
			{ 
				selectedIndex = tabContainer.getChildIndex(event.target as DisplayObject);
			} 
			else
			{
				var tab:TabViewTab = event.target as TabViewTab;
				tabContainer.addChild(tab);
				tab.selected = true;
				selectedIndex = tabContainer.numChildren-1;
			}
		}

		private function onHamburgerMenuTabsChange(event:IndexChangeEvent):void
		{
            addTabFromHamburgerMenu(hamburgerMenuTabs.selectedItem as HamburgerMenuTabsVO);
        }
		
		private function isNonCloseableChild(child:DisplayObject):Boolean
		{
			return ((child.hasOwnProperty("label") && ConstantsCoreVO.NON_CLOSEABLE_TABS.indexOf(child["label"]) != -1));
		}

		override public function getChildIndex(child:DisplayObject):int
		{
			var tab:DisplayObject = tabLookup[child];
			if (tab && tab.parent == tabContainer)
			{
				return tabContainer.getChildIndex(tab);
			}

			return -1;
		}
		
		override public function addChild(child:DisplayObject):DisplayObject
		{
			addTabFor(child);
			//itemContainer.removeAllChildren();
			//var editor:DisplayObject = itemContainer.addChild(child);
            selectedIndex = 0;

			return child;
		}

		public function addChildTab(child:DisplayObject):DisplayObject
		{
            addTabFor(child);
            return child;
		}

		/*override public function removeChildAt(index:int):DisplayObject
		{
			invalidateTabSelection();

			removeTabFor(itemContainer.getChildAt(index));
			return itemContainer.removeChildAt(index);
		}*/
		
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			var tab:TabViewTab = tabLookup[child];
			if (tab)
            {
				if (tab.selected)
				{
					invalidateTabSelection();
				}
                removeTabFor(child);
				if (child.parent != null) 
				{
	                return itemContainer.removeChild(child);
				}
            }

			// due to descending ordered index in tabContainer,
			// removal of any tab at any position also practically updates
			// the current selected tab's index; that needs to get updated
			// for any latter action(s)
			this.tabContainer.getChildren().some(function(element:TabViewTab, index:int, arr:Array):Boolean {
				if (element.selected)
				{
					_selectedIndex = index;
					return true;
				}
				return false;
			});
			return null;
		}

		public function removeTabsFromCache(exceptTab:IContentWindow=null):void
		{
            var numTabs:int = tabContainer.numChildren;
            for (var i:int = numTabs - 2; i > -1; i--)
			{
                var tab:TabViewTab = tabContainer.getChildAt(i) as TabViewTab;
				if (tab.data != exceptTab)
				{
					removeTabFromCache(tab.data as IFileContentWindow);
				}
			}

			for each (var item:HamburgerMenuTabsVO in model.hamburgerTabs)
			{
				if ((item.tabData is BasicTextEditor) && (item.tabData != exceptTab))
				{
                    removeTabFromCache(item.tabData as IFileContentWindow);
				}
			}
		}

        private function addTabFromHamburgerMenu(hamburgerMenuTabsVO:HamburgerMenuTabsVO):void
        {
            _model.hamburgerTabs.removeItem(hamburgerMenuTabsVO);
			
			// in case of non-closeable tabs, add only its tabViewTab considering
			// its view never removed in previous step (updateTabLayout())
			if (isNonCloseableChild(hamburgerMenuTabsVO.tabData))
			{
				addTabFor(hamburgerMenuTabsVO.tabData);
				selectedIndex = 0;
			}
			else
			{
				addChild(hamburgerMenuTabsVO.tabData);
			}
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
			// Each item draws vertical separators on both sides, overlap by 1 px to not have duplicate lines.
			var availableWidth:int = width - hamburgerMenuTabs.width;

			var tab:TabViewTab = null;
            var i:int;
			var numTabs:int = tabContainer.numChildren;
			hamburgerMenuTabs.visible = hamburgerMenuTabs.includeInLayout = isHamburgerMenuWithTabsVisible();

			if (!canAllTabsFitIntoAvailableSpace())
			{
				for (i = numTabs - 2; i > -1; i--)
				{
					tab = tabContainer.getChildAt(i) as TabViewTab;
					var tabData:DisplayObject = tab.data as DisplayObject;
					if (!tab.selected && tabData)
					{
						_model.hamburgerTabs.addItem(new HamburgerMenuTabsVO(tab["label"], tabData));
						
						// do not remove display object in case of non-closeable tabs
						// but let remove its tabViewTab only
						if (isNonCloseableChild(tabData) && tabLookup[tabData] != undefined)
						{
							removeTabFor(tabData);
						}
						else
						{
							removeChild(tabData);
						}
						
						needsNewSelectedTab = false;
                        validateDisplayList();
						break;
					}
				}
			}
			else
			{
                shiftHamburgerMenuTabsIfSpaceAvailable();
			}

            numTabs = tabContainer.numChildren;
			var tabWidth:int = int(availableWidth/numTabs);
			
			tabWidth = Math.max(tabWidth, tabSizeMin);
			tabWidth = Math.min(tabWidth, tabSizeDefault);
			tabWidth += 2;
			
			var pos:int = -2;
			for (i = tabContainer.numChildren-1; i > -1; i--)
			{
				tab = tabContainer.getChildAt(i) as TabViewTab;
				tab.x = pos;
				tab.y = 0;
				pos += tabWidth-1;
			}
		}

		private function shiftHamburgerMenuTabsIfSpaceAvailable():void
		{
			if (!canTabFitIntoAvailableSpace())
			{
                _model.hamburgerTabs.refresh();
                return;
            }

			if (_model.hamburgerTabs.length > 0)
			{
				var hamburgerMenuVO:HamburgerMenuTabsVO = _model.hamburgerTabs.source.shift();
				addChildTab(hamburgerMenuVO.tabData);

				shiftHamburgerMenuTabsIfSpaceAvailable();
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
				updateTabLayout();
				needsTabLayout = false;
			}
		}

		private function isHamburgerMenuWithTabsVisible():Boolean
		{
            var availableWidth:int = width - hamburgerMenuTabs.width;
            var numTabs:int = tabContainer.numChildren;
            var allTabsWidth:Number = (numTabs + _model.hamburgerTabs.length) * tabSizeDefault;

            return allTabsWidth > availableWidth;
        }

		private function canAllTabsFitIntoAvailableSpace():Boolean
		{
            var availableWidth:int = width - hamburgerMenuTabs.width;
            var numTabs:int = tabContainer.numChildren;
            var allTabsWidth:Number = (numTabs + _model.hamburgerTabs.length) * tabSizeDefault;
            var currentTabsWidth:Number = numTabs * tabSizeDefault;

            return !(allTabsWidth > availableWidth && currentTabsWidth > availableWidth);
		}

		private function canTabFitIntoAvailableSpace():Boolean
		{
            var availableWidth:int = width - hamburgerMenuTabs.width;
            var numTabs:int = tabContainer.numChildren;
            var currentTabsWidth:Number = numTabs * tabSizeDefault;

			if (currentTabsWidth < availableWidth)
			{
				var widthOfEmptySpace:Number = availableWidth - currentTabsWidth;
				if (widthOfEmptySpace > 0 && widthOfEmptySpace > tabSizeDefault)
                {
                    return true;
                }
			}

			return false;
		}

		private function invalidateTabSelection():void
		{
            needsNewSelectedTab = true;
            invalidateDisplayList();
		}

        private function invalidateLayoutTabs():void
        {
            needsTabLayout = true;
            invalidateDisplayList();
        }

		private function removeTabFromCache(editor:IFileContentWindow):void
		{
            if (editor)
            {
				var projectPath:String = ("projectPath" in editor) ? editor["projectPath"] : null;
				if (editor.currentFile)
				{
					SharedObjectUtil.removeLocationOfClosingProjectFile(
						editor.currentFile.name,
						editor.currentFile.fileBridge.nativePath,
						projectPath);
				}
            }
		}
    }
}
