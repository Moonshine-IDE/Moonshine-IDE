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
package actionScripts.ui.editor.text.vo
{
	public class SearchResult
	{
		public var startLineIndex:int = -1;
		public var startCharIndex:int = -1;
		
		public var endLineIndex:int = -1;
		public var endCharIndex:int = -1;
		
		public var totalMatches:int = 0;
		public var totalReplaces:int = 0;
		
		// Which occurance is selected now? 
		public var selectedIndex:int = 0;
		
		public var didWrap:Boolean;
		
		public function SearchResult()
		{
		}

	}
}