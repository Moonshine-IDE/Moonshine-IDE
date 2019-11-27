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
package actionScripts.utils
{
	import actionScripts.valueObjects.Range;

	public class LSPUtil
	{
		public static function rangesIntersect(r1:Range, r2:Range):Boolean
		{
			var resultStartLine:int = r1.start.line;
			var resultStartChar:int = r1.start.character;
			var resultEndLine:int = r1.end.line;
			var resultEndChar:int = r1.end.character;
			var otherStartLine:int = r2.start.line;
			var otherStartChar:int = r2.start.character;
			var otherEndLine:int = r2.end.line;
			var otherEndChar:int = r2.end.character;
			if (resultStartLine < otherStartLine)
			{
				resultStartLine = otherStartLine;
				resultStartChar = otherStartChar;
			}
			else if(resultStartLine == otherStartLine && resultStartChar < otherStartChar)
			{
				resultStartChar = otherStartChar;
			}
			if (resultEndLine > otherEndLine)
			{
				resultEndLine = otherEndLine;
				resultEndChar = otherEndChar;
			}
			else if(resultEndLine == otherEndLine && resultEndChar < otherEndChar)
			{
				resultEndChar = otherEndChar;
			}
			if(resultStartLine > resultEndLine)
			{
				return false;
			}
			if(resultStartLine == resultEndLine && resultStartChar > resultEndChar)
			{
				return false;
			}
			return true;
		}
	}
}