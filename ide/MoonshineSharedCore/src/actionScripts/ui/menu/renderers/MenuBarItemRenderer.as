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
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import mx.core.UIComponent;

	import spark.components.Label;

	public class MenuBarItemRenderer extends Label
	{
		private var labelView:Label
		private var needsRedrawing:Boolean
		private var itemContainer:UIComponent
		private var background:Sprite
		private var _active:Boolean

		public function MenuBarItemRenderer()
		{
			minWidth = 10;

			minHeight=13;

			setStyle("paddingTop", 5);
			setStyle("paddingBottom",4);
			setStyle("lineBreak", "explicit");
			setStyle("lineHeight",13);
			setStyle("fontSize",12);
			setStyle("textAlign","center");
			setStyle("backgroundColor", 0xB3B6BD);
			setStyle("backgroundAlpha", 0);
			setStyle("paddingLeft", 6); // for some reason we need to +1 to have even sides 
			setStyle("paddingRight", 5);
			setStyle("color",0x333333);

			addEventListener(MouseEvent.ROLL_OVER, rollOverHandler)
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);

		}

		


		private function drawBackground(show:Boolean):void
		{
			graphics.clear();
			if (show)
			{
				graphics.beginFill(0xB3B6BD, .8);
				graphics.drawRect(0, 0, width, height-1);
				graphics.endFill();
			}
		}

		public function set active(v:Boolean):void
		{
			_active = v;
			drawBackground(v);
		}

		private function rollOverHandler(e:MouseEvent):void
		{			
			drawBackground(true);
		}

		private function rollOutHandler(e:MouseEvent):void
		{
			if (!_active)
				drawBackground(false);
		}



	}
}