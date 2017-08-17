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
package no.doomsday.console.core.gui 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class SimpleScrollbar extends Sprite
	{
		public static const VERTICAL:int = 0;
		public static const HORIZONTAL:int = 1;
		private var orientation:int;
		public var trackWidth:Number = 4;
		public var thumbWidth:Number = 4;
		public var minThumbWidth:Number = thumbWidth;
		private var length:Number = 0;
		public var outValue:Number = 0;
		private var clickOffset:Number = 0;
		private var thumbPos:Number;
		public function SimpleScrollbar(orientation:int) 
		{
			this.orientation = orientation;
			buttonMode = true;
			addEventListener(MouseEvent.MOUSE_DOWN, startDragging);
		}
		
		private function startDragging(e:MouseEvent):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, doScroll);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
			switch(orientation) {
				case VERTICAL:
					clickOffset = mouseY-thumbPos;
				break;
				case HORIZONTAL:
					clickOffset = mouseX-thumbPos;
				break;
			}
			doScroll();
		}
		
		private function stopDragging(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, doScroll);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
		}
		
		private function doScroll(e:MouseEvent = null):void 
		{
			switch(orientation) {
				case VERTICAL:
				outValue = Math.max(0, Math.min(1, (mouseY - clickOffset) / (length - thumbWidth)));
				break;
				case HORIZONTAL:
				outValue = Math.max(0, Math.min(1, (mouseX - clickOffset) / (length - thumbWidth)));
				break;
			}
			dispatchEvent(new Event(Event.CHANGE));
		}
		public function draw(length:Number, viewRect:Rectangle, currentScroll:Number, maxScroll:Number):void { 
			this.length = length;
			graphics.clear();
			graphics.beginFill(0);
					
			switch(orientation) {
				case VERTICAL:
				thumbWidth = Math.max(minThumbWidth, (viewRect.height / maxScroll) * length);
				thumbPos = (currentScroll / maxScroll) * (length);
				graphics.drawRect(0, 0, trackWidth, length);
				graphics.beginFill(0xFFFFFF);
				graphics.drawRect(0, thumbPos, trackWidth, thumbWidth);
				
				break;
				case HORIZONTAL:
				thumbWidth = Math.max(minThumbWidth, (viewRect.width / maxScroll) * length);
				thumbPos = (currentScroll / maxScroll) * (length);
				graphics.drawRect(0, 0, length, trackWidth);
				graphics.beginFill(0xFFFFFF);
				graphics.drawRect(thumbPos,0 , thumbWidth, trackWidth);
				break;
			}
		}
		
	}

}