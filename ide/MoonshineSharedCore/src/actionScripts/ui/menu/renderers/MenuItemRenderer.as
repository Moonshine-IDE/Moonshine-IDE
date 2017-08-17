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
package actionScripts.ui.menu.renderers
{
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.containers.HBox;
	import mx.controls.ToolTip;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.managers.ToolTipManager;
	
	import spark.components.Label;
	
	import actionScripts.ui.menu.MenuModel;
	import actionScripts.ui.menu.interfaces.ICustomMenuItem;
	import actionScripts.ui.menu.vo.CustomMenuItem;
	import actionScripts.utils.moonshine_internal;


	use namespace moonshine_internal;

	public class MenuItemRenderer extends UIComponent
	{


		private var shortcutView:Label
		private var myTip:ToolTip
		private var labelView:Label
		private var arrowClip:UIComponent

		private var checkBoxGap:UIComponent
		private var container:HBox
		private var rollOverShape:Shape

		private var verticalLine:Shape

		private var updateShortcut:Boolean
		private var needsRedrawing:Boolean = false;
		private var separatorLine:Shape


		private const RENDERER_AS_SPERATOR_HEIGHT:int = 10;
		private const RENDERER_HEIGHT:int = 22;

		private const MIN_WIDTH:int = 160;


		private const LABEL_PADDING:int = 5;

		private const SUBMENU_ARROW_SECTION_WIDTH:int = 10;

		private const SUBMENU_ARROW_WIDTH:int = 4;
		private const SUBMENU_ARROW_HEIGHT:int = 7;

		private const EDGE_PADDING:int = 2;


		private var _label:String;
		
		private var _tooltip:String

		private var updateChildrenLayoutFlag:Boolean = false;

		public function set label(v:String):void
		{
			_label = v;
			if (labelView)
				labelView.text = v;
		}

		public function get label():String
		{
			return _label;
		}
		
		public function set tooltip(v:String):void
		{
			_tooltip = v;
		}

		public function get tooltip():String
		{
			return _tooltip;
		}

		private var _data:ICustomMenuItem

		public function set data(v:ICustomMenuItem):void
		{
			_data = v;
		}

		public function get data():ICustomMenuItem
		{
			return _data;
		}

		private var _separator:Boolean

		public function get separator():Boolean
		{
			return _separator;
		}

		public function set separator(v:Boolean):void
		{
			if (_separator != v)
			{
				_separator = v;
				needsRedrawing = true;
				invalidateProperties();
			}

		}

		private var _submenu:Boolean

		public function get submenu():Boolean
		{
			return _submenu;
		}

		public function set submenu(v:Boolean):void
		{
			if (_submenu != v)
			{
				_submenu = v;
				if (arrowClip)
					arrowClip.visible = v;
			}

		}

		private var _shortcut:String

		public function set shortcut(v:String):void
		{
			if (_shortcut != v)
			{
				_shortcut = v.toUpperCase();

				if (shortcutView)
					shortcutView.text = v.toUpperCase();
			}
		}

		public function get shortcut():String
		{
			return _shortcut;
		}

		private var _model:MenuModel;

		public function set model(v:MenuModel):void
		{
			_model = v;
		}

		public function MenuItemRenderer()
		{
			super();
			width = MIN_WIDTH;
			minWidth = MIN_WIDTH;
			height = RENDERER_HEIGHT;

		}

		moonshine_internal function resizeLabels(
			labelWidth:Number=NaN, shortcutWidth:Number=NaN):void
		{
			var newWidth:Number = 0;
			var oldLabelWidth:Number

			oldLabelWidth = labelView.width || labelView.measuredWidth;
			labelWidth = labelWidth != oldLabelWidth ? labelWidth : oldLabelWidth;


			labelView.width = labelWidth;
			newWidth += labelWidth;

			oldLabelWidth = shortcutView.width || shortcutView.measuredWidth;
			shortcutWidth = shortcutWidth != oldLabelWidth ? shortcutWidth : oldLabelWidth;

			shortcutView.width = shortcutWidth;
			newWidth += shortcutWidth;

			newWidth += checkBoxGap.width;
			newWidth += arrowClip.width
			newWidth += EDGE_PADDING * 2 // container left/right padding

			newWidth = Math.round(newWidth);

			if (width != newWidth)
			{
				needsRedrawing = true;
				width = container.width = newWidth;
			}

		}


		private function getPaddingWidth(target:UIComponent):Number
		{
			var total:Number = 0;
			total += target.getStyle("paddingLeft") || 0;
			total += target.getStyle("paddingRight") || 0;
			return total;
		}

		moonshine_internal function getLabelWidth():Number
		{
			return getLabelWidth(labelView);
		}

		moonshine_internal function getShortcutLabelWidth():Number
		{
			if (!_shortcut)
				return 0;
			return getLabelWidth(shortcutView)
		}

		private function getLabelWidth(label:Label):Number
		{
			if (!label)
				return 0;
			use namespace mx_internal;
			return label.bounds.width;
		}


		private function drawItemState():void
		{

			height = _separator ? RENDERER_AS_SPERATOR_HEIGHT : RENDERER_HEIGHT
			shortcutView.visible = shortcutView.includeInLayout = !_separator;
			labelView.includeInLayout = labelView.visible = !_separator;
			arrowClip.visible = !_separator && _submenu;
			separatorLine.visible = _separator;
			needsRedrawing = false; 
			// add hitarea
			var g:Graphics = container.graphics;
			g.clear();
			g = container.graphics;
			g.beginFill(0xFF0000,0);
			g.drawRect(0,0,container.width,container.height);
			g.endFill();
		}




		override protected function createChildren():void
		{
			super.createChildren();

			var g:Graphics;

			rollOverShape = new Shape();

			addChild(rollOverShape);
			
			separatorLine = new Shape();
			addChild(separatorLine);

			container = new HBox();
			setProps(container, {
					verticalGap:0,
					horizontalGap:0,
					paddingLeft:EDGE_PADDING,
					paddingRight:EDGE_PADDING
				});

			container.horizontalScrollPolicy = "none";
			container.percentWidth = 100;
			container.minWidth = width;
			container.width = width;

			container.height = RENDERER_HEIGHT;
			container.mouseChildren = false;
			container.mouseEnabled = false;


			addChild(container);

			checkBoxGap = new UIComponent();
			checkBoxGap.width = 28;
			g = checkBoxGap.graphics;
			g.beginFill(0xe2e3e3);
			g.drawRect(checkBoxGap.width - 2, 0, 2, RENDERER_HEIGHT);
			g.beginFill(0xffffff);
			g.drawRect(checkBoxGap.width - 1, 0, 1, RENDERER_HEIGHT);
			g.endFill();
			container.addChild(checkBoxGap);

			labelView = createLabel(_label);
			labelView.setStyle("paddingRight", 25);
			if (data && !data.enabled) labelView.setStyle("color", 0x999999);
			container.addChild(labelView);
			
			shortcutView = createLabel(_shortcut);
			shortcutView.setStyle("paddingRight", 5);
			shortcutView.setStyle("textAlign", "right");
			container.addChild(shortcutView);

			
			arrowClip = new UIComponent();
			arrowClip.width = 13;


			var yStartPos:Number = height / 2 - SUBMENU_ARROW_HEIGHT / 2;
			g = arrowClip.graphics;
			g.beginFill(0x333333);
			g.moveTo(0, yStartPos);
			g.lineTo(SUBMENU_ARROW_WIDTH, yStartPos + (SUBMENU_ARROW_HEIGHT / 2));
			g.lineTo(0, yStartPos + SUBMENU_ARROW_HEIGHT)
			g.lineTo(0, yStartPos);
			g.endFill();

			arrowClip.visible = _submenu;

			container.addChild(arrowClip);

			drawItemState();
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
		
		}

		private function setProps(target:UIComponent, props:Object):void
		{
			var prop:String
			for (prop in props)
				target.setStyle(prop, props[prop]);
		}

		private function createLabel(text:String):Label
		{
			var label:Label = new Label();
			label.text = text;
			label.height = RENDERER_HEIGHT;
			label.minWidth = 50;
			label.mouseChildren = false;
			label.mouseEnabled = false;
			setProps(label, {
					paddingLeft:6,
					lineHeight:12,
					lineBreak:"explicit",
					color:0x333333,
					paddingTop:(RENDERER_HEIGHT / 2 - 12 / 2) + 1

				});

			return label;
		}

		override protected function commitProperties():void
		{
			super.commitProperties();
			if (needsRedrawing)
			{
				needsRedrawing = false;
				drawItemState();
			}
		}


		private var _explictActive:Boolean

		public function set explictActive(value:Boolean):void
		{
			if (_explictActive == value)
				return

					_explictActive = value;
			invalidateDisplayList();
		}

		public function get explictActive():Boolean
		{
			return _explictActive;
		}

		private var _active:Boolean

		public function set active(value:Boolean):void
		{
			if (_active == value)
				return;
			_active = value;
			invalidateDisplayList();
		}

		public function get active():Boolean
		{
			return _active;
		}

		private function rollOutHandler(e:MouseEvent):void
		{
			if (!_separator)
			{
				active = false;
				if(!submenu && myTip)
				{
					ToolTipManager.destroyToolTip(myTip);
				}
			}
		}

		private function rollOverHandler(e:MouseEvent):void
		{
			if (!_separator)
				active = true;
			
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			var g:Graphics = rollOverShape.graphics;
			g.clear();
			if (active || explictActive)
			{
				g.beginFill(0xddecf3, .7);
				g.lineStyle(1, 0xa8d8eb, .7, true, "normal", "round");
				g.drawRoundRect(2, 0, unscaledWidth - 4, height, 6, 6);
				g.endFill();
				if(!submenu && _tooltip!=null)
				{
					var p:Point = new Point(labelView.x,labelView.y);
					var p1:Point = localToGlobal(p);
					myTip = ToolTipManager.createToolTip(_tooltip,p1.x+10,p1.y+labelView.height) as ToolTip;
					myTip.height = this.container.height;
					myTip.setStyle("backgroundColor",0XFFCC00);
					myTip.setStyle("paddingRight", 25);
				}
			}

			var sepOffset:Number = EDGE_PADDING + checkBoxGap.width;
			var sepWidth:Number = unscaledWidth - sepOffset - 2;
			var sepXOffset:Number = (unscaledHeight / 2 - 2 / 2) + 1;
			g = separatorLine.graphics;
			g.clear();
			g.beginFill(0xe2e3e3);
			g.drawRect(sepOffset, sepXOffset, sepWidth, 2);
			g.beginFill(0xffffff);
			g.drawRect(sepOffset, sepXOffset + 1, sepWidth, 1);
			g.endFill();

		}

	}
}