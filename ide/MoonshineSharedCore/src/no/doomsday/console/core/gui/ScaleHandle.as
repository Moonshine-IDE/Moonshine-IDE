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
	import flash.filters.DropShadowFilter;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ScaleHandle extends Sprite
	{
		
		public function ScaleHandle() 
		{
			buttonMode = true;
			tabEnabled = false;
			alpha = 0;
			graphics.beginFill(0x333333);
			graphics.drawRect(0, 0, 30, 10);
			var dsf:DropShadowFilter = new DropShadowFilter(0, 90, 0, 1, 4, 4, 1, 1, true);
			filters = [dsf];
			addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);
			addEventListener(MouseEvent.MOUSE_DOWN, startScale, false, 0, true);
		}
		
		private function startScale(e:MouseEvent):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, scale,false,0,true);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopScale,false,0,true);
			removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
			removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
		}
		
		private function stopScale(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, scale);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopScale);
			addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
			addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);
			alpha = 0;
		}
		
		private function scale(e:MouseEvent):void 
		{
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		private function onRollOut(e:MouseEvent):void 
		{
			alpha = 0;
		}
		
		private function onRollOver(e:MouseEvent):void 
		{
			alpha = .8;
		}
		
	}

}