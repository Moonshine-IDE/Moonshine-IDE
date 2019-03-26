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
	 * Implementation of DocumentSymbol interface from Language Server Protocol
	 * 
	 * <p><strong>DO NOT</strong> add new properties or methods to this class
	 * that are specific to Moonshine IDE or to a particular language. Create a
	 * subclass for new properties or create a utility function for methods.</p>
	 * 
	 * @see https://microsoft.github.io/language-server-protocol/specification#textDocument_documentSymbol
	 */
	public class DocumentSymbol
	{
		public function DocumentSymbol()
		{
		}

		public var name:String;
		public var detail:String;
		public var kind:int;
		public var deprecated:Boolean;
		public var range:Range;
		public var selectionRange:Range;
		public var children:Vector.<DocumentSymbol>;

		public static function parse(original:Object):DocumentSymbol
		{
			var vo:DocumentSymbol = new DocumentSymbol();
			vo.name = original.name;
			vo.detail = original.detail;
			vo.kind = original.kind;
			vo.deprecated = original.deprecated;
			vo.range = Range.parse(original.range);
			vo.selectionRange = Range.parse(original.selectionRange);
			if(original.children && original.children is Array)
			{
				var children:Vector.<DocumentSymbol> = new <DocumentSymbol>[];
				var originalChildren:Array = original.children as Array;
				var childCount:int = originalChildren.length;
				for(var i:int = 0; i < childCount; i++)
				{
					var originalChild:Object = originalChildren[i];
					var child:DocumentSymbol = DocumentSymbol.parse(originalChild);
					children[i] = child;
				}
				vo.children = children;
			}
			return vo;
		}
	}
}
