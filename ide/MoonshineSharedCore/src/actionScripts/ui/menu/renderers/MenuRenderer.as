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
package actionScripts.ui.menu.renderers
{
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.utils.getTimer;
	
	import mx.containers.Canvas;
	import mx.containers.VBox;
	import mx.core.FlexGlobals;
	import mx.core.ScrollPolicy;
	
	import actionScripts.ui.menu.CustomMenuBox;
	import actionScripts.ui.menu.MenuModel;
	import actionScripts.ui.menu.interfaces.ICustomMenuItem;
	import actionScripts.utils.moonshine_internal;
	import actionScripts.valueObjects.ConstantsCoreVO;

	public class MenuRenderer extends Canvas
	{
		private var needsRedrawing:Boolean = false;
		private var itemContainer:CustomMenuBox;
		private var needsRendererLayout:Boolean = false;

		public function MenuRenderer()
		{
			super();
		}

		override protected function createChildren():void
		{
			super.createChildren();

			itemContainer = new CustomMenuBox();
			itemContainer.maxHeight = FlexGlobals.topLevelApplication.height - 200;

			addChild(itemContainer);
		}

		private var _model:MenuModel;

		public function set model(v:MenuModel):void
		{
			_model = v;
		}

		private var _items:Vector.<ICustomMenuItem>

		public function set items(v:Vector.<ICustomMenuItem>):void
		{
			if (v == null)
				v = new Vector.<ICustomMenuItem>();
			_items = v;

			needsRedrawing = true;
			invalidateProperties();
		}

		public function get items():Vector.<ICustomMenuItem>
		{
			return _items;
		}

		public function clear():void
		{
			_model.freeMenuItemRenderer(itemContainer, 0);
		}

		public function get numOfRenderers():int
		{
			return _items.length;
		}

		public function getRendererAt(index:int):MenuItemRenderer
		{
			return itemContainer.getChildAt(index) as MenuItemRenderer;
		}

		public function getRendererIndex(rdr:MenuItemRenderer):int
		{
			return itemContainer.getChildIndex(rdr);
		}
		
		private function setTooTip(label:String):String
		{
			for each(var c:Object in ConstantsCoreVO.MENU_TOOLTIP)
			{
				if(label == c.label)
				{
					return c.tooltip;
				}
			}
			return null;
		}
		
		private function drawMenuState():void
		{
			var renderer:MenuItemRenderer;
			var numOfItems:int = _items.length;

			var tmpRenderers:Vector.<MenuItemRenderer> = _model.getMenuItemRenderers(numOfItems);
			var currMenuItem:ICustomMenuItem;

			for (var i:int = 0; i < numOfItems; i++)
			{
				renderer = tmpRenderers[i];

				currMenuItem = _items[i];

				renderer.shortcut = (currMenuItem.shortcut) ? currMenuItem.shortcut.toString() : null;
				renderer.data = currMenuItem;
				renderer.separator = currMenuItem.isSeparator;
				renderer.submenu = currMenuItem.submenu ? true : false;
				renderer.label = currMenuItem.label;
				renderer.checked = currMenuItem.checked;
				renderer.tooltip = setTooTip(currMenuItem.label);
				itemContainer.addChildAt(renderer, i);
			}

			if (itemContainer.numChildren > numOfItems)
			{
				_model.freeMenuItemRenderer(itemContainer, numOfItems);
			}
			
			needsRendererLayout = true;
		}

		override protected function commitProperties():void
		{
			super.commitProperties();

			if (needsRedrawing)
			{
				drawMenuState();
				needsRedrawing = false;

			}
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			// add an hit area to add a hit buffer of 5px in any direction
			if (!hitArea)
			{
				hitArea = new Sprite();
				hitArea.mouseEnabled = false;
				rawChildren.addChild(hitArea)
			}
			hitArea.graphics.clear();
			hitArea.graphics.beginFill(0xFF0000, 0);
			hitArea.graphics.drawRect(-5, -5, unscaledWidth + 5, unscaledHeight + 5);
			hitArea.graphics.endFill();
			if (itemContainer && needsRendererLayout)
			{

				needsRendererLayout = false;
				var rdr:MenuItemRenderer;
				var containerNumOfChildren:int = itemContainer.numChildren;

				var maxRendererLabelWidth:Number = 0;
				var maxRendererShortcutLabelWidth:Number = 0;
				var currentWidth:Number;

				var hasShortcut:Boolean = false;
				const defaultShortcutWidth:Number = 50;



				use namespace moonshine_internal;
				var layoutTime:Number = getTimer();
				
				for (var i:int = 0; i < containerNumOfChildren; i++)
				{
					if (itemContainer.getChildAt(i) is MenuItemRenderer)
					{
						rdr = itemContainer.getChildAt(i) as MenuItemRenderer;
	
						if (rdr.shortcut)
							hasShortcut = true;
	
						currentWidth = rdr.getLabelWidth();
						if (currentWidth > maxRendererLabelWidth)
							maxRendererLabelWidth = currentWidth;
	
						currentWidth = rdr.getShortcutLabelWidth();
	
						if (currentWidth > maxRendererShortcutLabelWidth)
							maxRendererShortcutLabelWidth = currentWidth;
					}


				}
				if (!hasShortcut)
				{
					maxRendererShortcutLabelWidth = 5;
				}
				else if (maxRendererShortcutLabelWidth < defaultShortcutWidth && hasShortcut)
				{
					maxRendererShortcutLabelWidth = defaultShortcutWidth;
				}




				for (i = 0; i < containerNumOfChildren; i++)
				{
					if (itemContainer.getChildAt(i) is MenuItemRenderer)
					{
						rdr = itemContainer.getChildAt(i) as MenuItemRenderer;
						rdr.resizeLabels(maxRendererLabelWidth, maxRendererShortcutLabelWidth);
					}

				}
				

			}


		}


	}
}