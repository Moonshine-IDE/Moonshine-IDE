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
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import no.doomsday.console.core.text.TextFormats;
	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public final class DropDownOption extends Sprite
	{
		public var title:String;
		private var titleField:TextField;
		public var index:int = -1;
		public function DropDownOption(title:String = "Blah") 
		{
			this.title = title;
			titleField = new TextField();
			addChild(titleField);
			titleField.autoSize = TextFieldAutoSize.LEFT;
			titleField.defaultTextFormat = TextFormats.windowTitleFormat;
			titleField.text = title;
			titleField.mouseEnabled = false;
			titleField.y = -2;
			titleField.backgroundColor = 0;
		}
		public function set background(b:Boolean):void {
			titleField.background = b;
		}
		
	}

}