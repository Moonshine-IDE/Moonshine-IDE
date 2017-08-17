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
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	
	import mx.core.UIComponent;
	
	import spark.components.Label;

	public class TabViewTab extends UIComponent
	{	
		public static const EVENT_TAB_CLICK:String = "tabClick";
		public static const EVENT_TAB_CLOSE:String = "tabClose";
		
		protected var closeButton:Sprite;
		protected var closeButtonSeparator:Sprite;
		protected var background:Sprite;
		protected var labelView:Label;
		protected var labelViewMask:Sprite;
		
		protected var closeButtonWidth:int = 27;
		
		protected var needsRedrawing:Boolean;
		
		public var backgroundColor:uint = 			0x424242;//0x464d55;
		public var selectedBackgroundColor:uint = 	0x812137;
		public var closeButtonColor:uint = 			0xFFFFFF;
		public var textColor:uint = 				0xEEEEEE;
		public var innerGlowColor:uint = 			0xFFFFFF;
		
		public function TabViewTab()
		{
			width = 200;
			height = 25;
		}
		
		public var showCloseButton:Boolean = true;
		public var data:Object;
		
		override public function set width(value:Number):void
		{
			super.width = value;
			
			needsRedrawing = true;
			invalidateDisplayList();
		}
		
		protected var _label:String;
		public function set label(v:String):void
		{
			_label = v;
			if (labelView) labelView.text = v;
		}
		
		protected var _selected:Boolean;
		public function get selected():Boolean
		{
			return _selected;
		}
		public function set selected(v:Boolean):void
		{
			if (v == _selected) return;
			_selected = v;
			
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
			labelView.width = width - 36;
			labelView.height = height;
			labelView.maxDisplayedLines = 1;
			labelView.mouseEnabled = false;
			labelView.mouseChildren = false;
			labelView.setStyle('color', textColor);
			labelView.setStyle('fontFamily', 'DejaVuSans');
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
			
			closeButton = new Sprite();
			closeButton.visible = false;

			// Vertical line separators
			closeButton.graphics.lineStyle(1, 0xFFFFFF, 0.05);
			closeButton.graphics.moveTo(0, 1);
			closeButton.graphics.lineTo(0, 24);
			closeButton.graphics.lineStyle(1, 0x0, 0.05);
			closeButton.graphics.moveTo(1, 1);
			closeButton.graphics.lineTo(1, 24);
			// Circle
			closeButton.graphics.lineStyle(1, closeButtonColor, 0.8);
			closeButton.graphics.beginFill(0x0, 0);
			closeButton.graphics.drawCircle(14, 12, 6);
			closeButton.graphics.endFill();
			// X (\)
			closeButton.graphics.lineStyle(2, closeButtonColor, 0.8, true);
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
			
			closeButton.addEventListener(MouseEvent.CLICK, closeButtonClicked);
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
			dispatchEvent( new Event(EVENT_TAB_CLOSE) );
		}
		
		protected function tabClicked(event:Event):void
		{
			dispatchEvent( new Event(EVENT_TAB_CLICK) );
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (needsRedrawing)
			{
				drawButtonState();
			}
		}
		
	}
}