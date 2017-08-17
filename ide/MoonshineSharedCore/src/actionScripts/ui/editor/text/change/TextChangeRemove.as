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
package actionScripts.ui.editor.text.change
{
	public class TextChangeRemove extends TextChangeBase
	{
		private var _endLine:int;
		private var _endChar:int;
		private var _textLines:Vector.<String>;
		
		public function get endLine():int	{ return _endLine; }
		public function get endChar():int	{ return _endChar; }
		public function get textLines():Vector.<String>	{ return _textLines; }
		
		public function TextChangeRemove(startLine:int, startChar:int, endLine:int, endChar:int)
		{
			super(TextChangeBase.UNBLOCK);
			
			_startLine = startLine;
			_startChar = startChar;
			_endLine = endLine;
			_endChar = endChar;
		}
		
		public override function getReverse():TextChangeBase
		{
			if (textLines)
			{
				return new TextChangeInsert(startLine, startChar, textLines);
			}
			
			return null;
		}
		
		public function setTextLines(textLines:Vector.<String>):void
		{
			_textLines = textLines;
		}
		
	}

}