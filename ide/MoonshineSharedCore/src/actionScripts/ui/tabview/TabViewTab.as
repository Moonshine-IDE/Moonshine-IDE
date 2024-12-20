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
    import flash.display.Sprite;
    import flash.events.ContextMenuEvent;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.DropShadowFilter;
    import flash.filters.GlowFilter;
    import flash.geom.Matrix;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    
    import mx.core.UIComponent;
    
    import spark.components.Label;
    import spark.utils.TextFlowUtil;
    
    import actionScripts.ui.IFileContentWindow;
    import actionScripts.ui.tabNavigator.CloseTabButton;
    import actionScripts.utils.SharedObjectUtil;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.factory.FileLocation;

	public class TabViewTab extends UIComponent
	{	
		public static const EVENT_TAB_CLICK:String = "tabClick";
		public static const EVENT_TAB_CLOSE:String = "tabClose";
		public static const EVENT_TABP_CLOSE_ALL:String = "tabCloseAll";
		public static const EVENT_TAB_CLOSE_ALL_OTHERS:String = "tabCloseAllOthers";
		public static const EVENT_TAB_DOUBLE_CLICKED:String = "tabDoubleClicked";

		protected var closeButton:CloseTabButton;
		protected var background:Sprite;
		protected var labelView:Label;
		protected var labelViewMask:Sprite;
		
		protected var closeButtonWidth:int = 27;
		protected var isCloseButtonAvailable:Boolean = true;
		protected var needsRedrawing:Boolean;
		protected var closeButtonAlpha:Number = 0.8;
		
		public var backgroundColor:uint = 			0x424242;//0x464d55;
		public var selectedBackgroundColor:uint = 	0x812137;
		public var closeButtonColor:uint = 			0xFFFFFF;
		public var textColor:uint = 				0xEEEEEE;
		public var innerGlowColor:uint = 			0xFFFFFF;
		
		public function TabViewTab()
		{
			width = 200;
			height = 25;

			addEventListener(MouseEvent.MOUSE_OVER, onTabViewTabMouseOverOut);
			addEventListener(MouseEvent.MOUSE_OUT, onTabViewTabMouseOverOut);
		}

        private function createContextMenu():ContextMenu
        {
            var tabContextMenu:ContextMenu = new ContextMenu();
            var cutItem:ContextMenuItem = new ContextMenuItem("Close");
            cutItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuItemClose);
            tabContextMenu.customItems.push(cutItem);

            var copyItem:ContextMenuItem = new ContextMenuItem("Close All");
            copyItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuItemCloseAll);
            tabContextMenu.customItems.push(copyItem);

			var closeAllOthersItem:ContextMenuItem = new ContextMenuItem("Close Others");
			closeAllOthersItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onMenuItemCloseAllOthers);
			tabContextMenu.customItems.push(closeAllOthersItem);

            return tabContextMenu;
        }

		public var showCloseButton:Boolean = true;

		override public function set width(value:Number):void
		{
			super.width = value;
			
			needsRedrawing = true;
			invalidateDisplayList();
		}
		
		private var _data:Object;
		
		public function get data():Object
		{
			return _data;	
		}		
		
		public function set data(value:Object):void
		{
			if (_data != value)
			{
				_data = value;
				this.contextMenu = createContextMenu();
				if (value is IFileContentWindow)
				{
					var projectPath:String = value.hasOwnProperty("projectPath") ? value["projectPath"] : null;
					var editor:IFileContentWindow = value as IFileContentWindow;
					if (editor.currentFile)
                    {
                        SharedObjectUtil.saveLocationOfOpenedProjectFile(
								editor.currentFile.name,
                                editor.currentFile.fileBridge.nativePath,
								projectPath);
                    }
				}
			}
		}
		
		protected var _label:String;
		public function set label(value:String):void
		{
			_label = value;
			if (labelView) 
			{
				labelView.text = value;
			}
		}

		public function get label():String
		{
			return _label;
		}

		protected var _selected:Boolean;
		public function get selected():Boolean
		{
			return _selected;
		}

		public function set selected(value:Boolean):void
		{
			if (value == _selected) return;
			_selected = value;
			
			drawButtonState();
		}
	
		override protected function createChildren():void
		{
			background = new Sprite();
			background.filters = [new GlowFilter(innerGlowColor, 0.25, 0, 24, 2, 2, true)];
			background.addEventListener(MouseEvent.CLICK, tabClicked, false, 0, true);
			background.addEventListener(MouseEvent.DOUBLE_CLICK, onTabDoubleClicked, false, 0, true);
			background.doubleClickEnabled = true;
			addChild(background);
			
			labelView = new Label();
			labelView.x = 8;
			labelView.y = 8;
			labelView.width = width;
			labelView.height = height;
			//labelView.maxChars = 50;
			labelView.maxDisplayedLines = 1;
			labelView.mouseEnabled = false;
			labelView.mouseChildren = false;
			labelView.setStyle('color', textColor);
			//labelView.setStyle('fontFamily', 'DejaVuSans');
			labelView.setStyle('fontSize', 11);
			labelView.filters = [new DropShadowFilter(1, 90, 0, 0.1, 0, 0)];
			if (_label) 
			{
				labelView.text = _label;
			}
			if (_data is IFileContentWindow)
			{
				var file:FileLocation = IFileContentWindow(_data).currentFile;
				if (file)
				{
					toolTip = file.fileBridge.nativePath;
				}
				else
				{
					toolTip = null;
				}
			}
			else if (_label && (_label.split(".").length > 1))
			{
				toolTip = _label;
			}
			else
			{
				toolTip = null;
			}
			addChild(labelView);
			
			if (isNaN(getStyle('textPaddingLeft')) == false)
			{
				labelView.x += int(getStyle('textPaddingLeft'));
			}
			
			labelViewMask = new Sprite();
			addChild(labelViewMask);
			labelView.cacheAsBitmap = true;
			labelViewMask.cacheAsBitmap = true;
			labelView.mask = labelViewMask;
			
			// lets not enable close button to tabs which
			// we not want to let close 
			if (ConstantsCoreVO.NON_CLOSEABLE_TABS.indexOf(label) != -1)
			{
				isCloseButtonAvailable = false;
				closeButtonAlpha = 0.2;
			}
			
			closeButton = new CloseTabButton();
			closeButton.visible = false;
			// Vertical line separators
			closeButton.graphics.clear();
			closeButton.graphics.lineStyle(1, 0xFFFFFF, 0.05);
			closeButton.graphics.moveTo(0, 1);
			closeButton.graphics.lineTo(0, 24);
			closeButton.graphics.lineStyle(1, 0x0, 0.05);
			closeButton.graphics.moveTo(1, 1);
			closeButton.graphics.lineTo(1, 24);
			// Circle
			closeButton.graphics.lineStyle(1, closeButtonColor, closeButtonAlpha);
			closeButton.graphics.beginFill(0x0, 0);
			closeButton.graphics.drawCircle(14, 12, 6);
			closeButton.graphics.endFill();
			// X (\)
			closeButton.graphics.lineStyle(2, closeButtonColor, closeButtonAlpha, true);
			closeButton.graphics.moveTo(12, 10);
			closeButton.graphics.lineTo(16, 14);
			// X (/)
			closeButton.graphics.moveTo(16, 10);
			closeButton.graphics.lineTo(12, 14);
			// Hit area
			closeButton.graphics.lineStyle(0, 0x0, 0);
			closeButton.graphics.beginFill(0x0, 0);
			closeButton.graphics.drawRect(0, 0, closeButtonWidth, 25);
			closeButton.graphics.endFill();
			if (isCloseButtonAvailable) closeButton.addEventListener(MouseEvent.CLICK, closeButtonClicked);
			
			addChild(closeButton);
			
			drawButtonState();
		}
		
		protected function drawButtonState():void
		{
			if (!background) return;
			
			closeButton.x = width-closeButtonWidth;
			
			background.graphics.clear();
			
			background.graphics.lineStyle(1, 0x0, 0.5);
			background.graphics.moveTo(0, -1);
			background.graphics.lineTo(width, -1);
			background.graphics.lineStyle(0, 0, 0);
			
			var gradWidth:int = 8;
			var labelMaskWidth:int = width-gradWidth;
			
			if (isNaN(getStyle('textPaddingLeft')) == false)
			{
				labelMaskWidth += int(getStyle('textPaddingLeft'));
			}
			
			if (_selected)
			{
				if (showCloseButton) closeButton.visible = true;
				
				labelMaskWidth -= closeButtonWidth;
				
				background.graphics.beginFill(selectedBackgroundColor);
				background.graphics.drawRect(0, 0, width-1, height);
				background.graphics.endFill();
				
				background.graphics.lineStyle(1, 0xFFFFFF, 0.3, false);
				background.graphics.moveTo(1, height);
				background.graphics.lineTo(1, 0);
				background.graphics.lineTo(width-2, 0);
				background.graphics.lineTo(width-2, height);
			}
			else
			{	
				closeButton.visible = false;				
				
				labelMaskWidth -= 5;
				
				background.graphics.beginFill(backgroundColor);
				background.graphics.drawRect(0, 0, width, height);
				background.graphics.endFill();
				
				background.graphics.lineStyle(1, 0x0, 0.3, false);
				background.graphics.moveTo(0, height);
				background.graphics.lineTo(0, 0);
				background.graphics.moveTo(width-1, 0);
				background.graphics.lineTo(width-1, height);
			}

			labelViewMask.graphics.clear();
			labelViewMask.graphics.beginFill(0x0, 1);
			labelViewMask.graphics.drawRect(0, 0, labelMaskWidth, height);
			labelViewMask.graphics.endFill();
			
			var mtr:Matrix = new Matrix();
			mtr.createGradientBox(gradWidth, height, 0, labelMaskWidth, 0);
			labelViewMask.graphics.beginGradientFill('linear', [0x0, 0x0], [1, 0], [0, 255], mtr);
			labelViewMask.graphics.drawRect(labelMaskWidth, 0, gradWidth, height);
			labelViewMask.graphics.endFill();
		}
		
		protected function closeButtonClicked(event:Event):void
		{
			closeThisTab();
		}
		
		protected function tabClicked(event:Event):void
		{
			dispatchEvent( new Event(EVENT_TAB_CLICK) );
		}
		
		protected function onTabDoubleClicked(event:MouseEvent):void
		{
			dispatchEvent( new Event(EVENT_TAB_DOUBLE_CLICKED) );
		}

        protected function onTabViewTabMouseOverOut(event:MouseEvent):void
        {
			if (!showCloseButton) return;
			if (selected) return;

			closeButton.visible = event.type == MouseEvent.MOUSE_OVER;
        }

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (needsRedrawing)
			{
				drawButtonState();
			}
		}

        private function onMenuItemCloseAll(event:ContextMenuEvent):void
        {
			dispatchEvent(new Event(EVENT_TABP_CLOSE_ALL));
        }

		private function onMenuItemCloseAllOthers(event:ContextMenuEvent):void
		{
			dispatchEvent(new Event(EVENT_TAB_CLOSE_ALL_OTHERS));
		}

        private function onMenuItemClose(event:ContextMenuEvent):void
        {
            closeThisTab();
        }

        private function closeThisTab():void
		{
            dispatchEvent(new Event(EVENT_TAB_CLOSE));
		}
    }
}