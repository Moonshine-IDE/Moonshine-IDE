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
package no.doomsday.console.utilities.controller 
{
	import flash.display.DisplayObject;
	import no.doomsday.console.core.gui.Window;
	import no.doomsday.console.core.text.TextFormats;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class Controller extends Window
	{
		private var targetObj:*; 
		private var paramsField:TextField = new TextField();
		private var controlFields:Vector.<ControlField> = new Vector.<ControlField>();
		private var clickOffset:Point;
		private var dragArea:Sprite;
		private var closeButton:Sprite;
		private var manager:ControllerManager;
		private var bg:Shape = new Shape();
		private var contents:Sprite = new Sprite();
		public function Controller(o:*, params:Array,manager:ControllerManager) 
		{
			cacheAsBitmap = true;
			
			var dragBarHeight:int = 10;
			this.manager = manager;
			
			targetObj = o;
			paramsField.defaultTextFormat = TextFormats.windowDefaultFormat;
			//paramsField.y = 0;
			contents.addChild(paramsField);
			paramsField.multiline = true;
			paramsField.selectable = false;
			paramsField.mouseEnabled = false;
			paramsField.autoSize = TextFieldAutoSize.LEFT;
			paramsField.text = o.toString();
			for (var i:int = 0; i < params.length; i++) 
			{
				var cf:ControlField = new ControlField(params[i],typeof targetObj[params[i]]);
				cf.addEventListener(ControllerEvent.VALUE_CHANGE, onCfChange,false,0,true);
				contents.addChild(cf);
				controlFields.push(cf);
				cf.y = paramsField.textHeight;
				cf.x = 110;
				cf.value = o[params[i]];
				paramsField.appendText("\n" + params[i]);
			}
			super("Controller: " + o.name, new Rectangle(0, 0, contents.width, contents.height), contents);
		}
		
		
		override protected function onWindowDrag(e:MouseEvent):void 
		{
			super.onWindowDrag(e);
			update();
		}	
		override protected function onClose(e:MouseEvent):void 
		{
			super.onClose(e);
			close(e);
		}
		
		private function close(e:MouseEvent):void 
		{
			manager.removeController(this);
		}
		
		private function onCfChange(e:Event):void 
		{
			var t:ControlField = e.currentTarget as ControlField;
			targetObj[t.targetProperty] = t.value;
			refresh();
		}
		
		private function refresh():void
		{
			for (var i:int = 0; i < controlFields.length; i++) 
			{
				if (controlFields[i].hasFocus) continue;
				controlFields[i].value = targetObj[controlFields[i].targetProperty];
				if (controlFields[i].targetProperty == "name") {
					setTitle("Controller: "+targetObj[controlFields[i].targetProperty]);
				}
			}
			
		}
		public function update():void {
			if(targetObj is DisplayObject){
				graphics.clear();
				graphics.lineStyle(0,0,.2);
				var p:Point = new Point(targetObj.x, targetObj.y);
				p = DisplayObject(targetObj).parent.localToGlobal(p);
				p = this.globalToLocal(p);
				graphics.lineTo(p.x, p.y);
				graphics.drawCircle(p.x, p.y, 3);
			}
			refresh();
		}
		
	}

}