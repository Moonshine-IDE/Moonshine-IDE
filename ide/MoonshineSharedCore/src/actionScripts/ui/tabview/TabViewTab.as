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

	public class TabViewTab extends UIComponent
	{	
		public static const EVENT_TAB_CLICK:String = "tabClick";
		public static const EVENT_TAB_CLOSE:String = "tabClose";
		public static const EVENT_TABP_CLOSE_ALL:String = "tabCloseAll";
		public static const EVENT_TAB_CLOSE_ALL_OTHERS:String = "tabCloseAllOthers";

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
			background.addEventListener(MouseEvent.CLICK, tabClicked);
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
				if (_label.split(".").length > 1) toolTip = _label;
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