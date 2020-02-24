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
	import actionScripts.utils.TextUtil;

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

		override public function apply(targetLines:Vector.<TextLineModel>):void
		{
			if (textLines && textLines.length > 0)
			{
				var targetStartLine:TextLineModel = targetLines[startLine];
				var tabAndSpaceCount:Object = TextUtil.indentAmountBySpaceAndTab(targetStartLine.text);
				var startIndent:int = tabAndSpaceCount.tab;
				var startIndentBySpace:int = tabAndSpaceCount.space;
				var trailText:String = targetStartLine.text.slice(startChar);
				
				// Break line at change position, and append first text line
				targetStartLine.text = targetStartLine.text.slice(0, startChar) + textLines[0];
				
				// Append any additional lines to the model
				if (textLines.length > 1)
				{
					// Add indentation to last line if it's empty
					if (textLines[textLines.length - 1] == "")
					{
						// Get indentation of trailing text
						var trailIndent:int = TextUtil.indentAmount(trailText);
						// Get indentation of last line of the insert if it's a multi-line insert
						if (textLines.length > 2) 
						{
							startIndent = TextUtil.indentAmount(textLines[textLines.length - 2]);
						}
						// Add required amount of indent to get the trailing text aligned with the last line
						// support both combination of tab and space-key press
						textLines[textLines.length - 1] += TextUtil.repeatStr("\t", Math.max(startIndent - trailIndent, 0));
						textLines[textLines.length - 1] += TextUtil.repeatStr(" ", Math.max(startIndentBySpace - trailIndent, 0));
					}
					
					// Create line models from strings
					var newLines:Array = new Array(textLines.length - 1);
					
					for (var i:int = 0; i < textLines.length; i++)
					{
						newLines[i-1] = new TextLineModel(textLines[i]);
					}
					
					targetLines.splice.apply(targetLines, [startLine + 1, 0].concat(newLines));
				}
				
				// Append trailing text to the last changed line
				targetLines[startLine + textLines.length - 1].text += trailText;
			}
		}
		
		
	}

}