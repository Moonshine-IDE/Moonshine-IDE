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
	import actionScripts.ui.editor.text.TextLineModel;

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

		override public function apply(targetLines:Vector.<TextLineModel>):void
		{
			var targetStartLine:TextLineModel = targetLines[startLine];
			var targetEndLine:TextLineModel = targetLines[endLine];
			var textLines:Vector.<String> = new Vector.<String>(endLine - startLine + 1);
			
			if (endLine > startLine)
			{
				// Remove any lines after the first
				var remLines:Vector.<TextLineModel> = targetLines.splice(startLine + 1, endLine - startLine);
				// Store each removed line's text
				textLines[0] = targetStartLine.text.slice(startChar);
				for (var i:int = 0; i < remLines.length - 1; i++)
				{
					textLines[i+1] = remLines[i].text;
				}
				textLines[remLines.length] = remLines[remLines.length - 1].text.slice(0, endChar);
			}
			else {
				// Store removed text
				textLines[0] = targetStartLine.text.slice(startChar, endChar);
			}
			
			// Remove from first line, and append trailing from end line
			targetStartLine.text = targetStartLine.text.slice(0, startChar) + targetEndLine.text.slice(endChar);
			
			// Store removed lines in change
			setTextLines(textLines);
		}
		
	}

}