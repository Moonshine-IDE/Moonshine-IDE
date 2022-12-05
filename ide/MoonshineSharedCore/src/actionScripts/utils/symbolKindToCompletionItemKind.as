////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
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