////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.valueObjects
{
	/**
	 * Implementation of TextEdit interface from Language Server Protocol
	 * 
	 * <p><strong>DO NOT</strong> add new properties or methods to this class
	 * that are specific to Moonshine IDE or to a particular language. Create a
	 * subclass for new properties or create a utility function for methods.</p>
	 * 
	 * @see https://microsoft.github.io/language-server-protocol/specification#textedit
	 */
	public class TextEdit
	{
		public var range: Range;
		
		/**
		 * The string to be inserted. For delete operations use an
		 * empty string.
		 */
		public var newText: String ="";

		public function TextEdit()
		{
		}

		public static function parse(original:Object):TextEdit
		{
			var vo:TextEdit = new TextEdit();
			vo.range = Range.parse(original.range);
			vo.newText = original.newText;
			return vo;
		}
	}
}