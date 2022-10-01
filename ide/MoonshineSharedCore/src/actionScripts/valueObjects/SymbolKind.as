////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
package actionScripts.valueObjects
{
	/**
	 * Implementation of SymbolKind enum from Language Server Protocol
	 * 
	 * <p><strong>DO NOT</strong> add new values to this class that are specific
	 * to Moonshine IDE or to a particular language.</p>
	 * 
	 * @see https://microsoft.github.io/language-server-protocol/specification#textDocument_documentSymbol
	 * @see https://microsoft.github.io/language-server-protocol/specification#workspace_symbol
	 */
	public class SymbolKind
	{
		public static const FILE:int = 1;
		public static const MODULE:int = 2;
		public static const NAMESPACE:int = 3;
		public static const PACKAGE:int = 4;
		public static const CLASS:int = 5;
		public static const METHOD:int = 6;
		public static const PROPERTY:int = 7;
		public static const FIELD:int = 8;
		public static const CONSTRUCTOR:int = 9;
		public static const ENUM:int = 10;
		public static const INTERFACE:int = 11;
		public static const FUNCTION:int = 12;
		public static const VARIABLE:int = 13;
		public static const CONSTANT:int = 14;
		public static const STRING:int = 15;
		public static const NUMBER:int = 16;
		public static const BOOLEAN:int = 17;
		public static const ARRAY:int = 18;
		public static const OBJECT:int = 19;
		public static const KEY:int = 20;
		public static const NULL:int = 21;
		public static const ENUM_MEMBER:int = 22;
		public static const STRUCT:int = 23;
		public static const EVENT:int = 24;
		public static const OPERATOR:int = 25;
		public static const TYPE_PARAMETER:int = 26;
    }
}