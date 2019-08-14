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
package actionScripts.utils
{
	import actionScripts.valueObjects.SymbolKind;
	import actionScripts.valueObjects.CompletionItemKind;

	public function symbolKindToCompletionItemKind(symbolKind:int):int
	{
		switch(symbolKind)
		{
			case SymbolKind.ARRAY:
				return CompletionItemKind.VALUE;
			case SymbolKind.BOOLEAN:
				return CompletionItemKind.VALUE;
			case SymbolKind.CLASS:
				return CompletionItemKind.CLASS;
			case SymbolKind.CONSTANT:
				return CompletionItemKind.CONSTANT;
			case SymbolKind.CONSTRUCTOR:
				return CompletionItemKind.CONSTRUCTOR;
			case SymbolKind.ENUM:
				return CompletionItemKind.ENUM;
			case SymbolKind.ENUM_MEMBER:
				return CompletionItemKind.ENUM_MEMBER;
			case SymbolKind.EVENT:
				return CompletionItemKind.EVENT;
			case SymbolKind.FIELD:
				return CompletionItemKind.FIELD;
			case SymbolKind.FILE:
				return CompletionItemKind.FILE;
			case SymbolKind.FUNCTION:
				return CompletionItemKind.FUNCTION;
			case SymbolKind.INTERFACE:
				return CompletionItemKind.INTERFACE;
			case SymbolKind.KEY:
				return CompletionItemKind.VALUE;
			case SymbolKind.METHOD:
				return CompletionItemKind.METHOD;
			case SymbolKind.MODULE:
				return CompletionItemKind.MODULE;
			case SymbolKind.NAMESPACE:
				return CompletionItemKind.MODULE;
			case SymbolKind.NULL:
				return CompletionItemKind.VALUE;
			case SymbolKind.NUMBER:
				return CompletionItemKind.VALUE;
			case SymbolKind.OBJECT:
				return CompletionItemKind.VALUE;
			case SymbolKind.OPERATOR:
				return CompletionItemKind.OPERATOR;
			case SymbolKind.PACKAGE:
				return CompletionItemKind.MODULE;
			case SymbolKind.PROPERTY:
				return CompletionItemKind.PROPERTY;
			case SymbolKind.STRING:
				return CompletionItemKind.VALUE;
			case SymbolKind.STRUCT:
				return CompletionItemKind.STRUCT;
			case SymbolKind.TYPE_PARAMETER:
				return CompletionItemKind.TYPE_PARAMETER;
			case SymbolKind.VARIABLE:
				return CompletionItemKind.VARIABLE;
		}
		return -1;
	}
}