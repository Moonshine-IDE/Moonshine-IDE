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
	public class TextChangeInsert extends TextChangeBase
	{
		private var _textLines:Vector.<String>;
		
		public function get textLines():Vector.<String>	{ return _textLines; }
		
		public function TextChangeInsert(startLine:int, startChar:int, textLines:Vector.<String>)
		{
			super(TextChangeBase.UNBLOCK);
			
			_startLine = startLine;
			_startChar = startChar;
			_textLines = textLines;
		}
		
		public override function getReverse():TextChangeBase
		{
			var endLine:int = startLine + textLines.length - 1;
			var endChar:int = (textLines.length == 1 ? startChar : 0) + textLines[textLines.length - 1].length;
			
			return new TextChangeRemove(startLine, startChar, endLine, endChar);
		}
		
	}

}