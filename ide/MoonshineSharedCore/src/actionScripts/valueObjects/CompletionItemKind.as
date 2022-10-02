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
	 * Implementation of CompletionItemKind enum from Language Server Protocol
	 * 
	 * <p><strong>DO NOT</strong> add new values to this class that are specific
	 * to Moonshine IDE or to a particular language.</p>
	 * 
	 * @see https://microsoft.github.io/language-server-protocol/specification#textDocument_completion
	 * @see https://microsoft.github.io/language-server-protocol/specification#completionItem_resolve
	 */
	public class CompletionItemKind
	{
		public static const TEXT:int = 1;
		public static const METHOD:int = 2;
		public static const FUNCTION:int = 3;
		public static const CONSTRUCTOR:int = 4;
		public static const FIELD:int = 5;
		public static const VARIABLE:int = 6;
		public static const CLASS:int = 7;
		public static const INTERFACE:int = 8;
		public static const MODULE:int = 9;
		public static const PROPERTY:int = 10;
		public static const UNIT:int = 11;
		public static const VALUE:int = 12;
		public static const ENUM:int = 13;
		public static const KEYWORD:int = 14;
		public static const SNIPPET:int = 15;
		public static const COLOR:int = 16;
		public static const FILE:int = 17;
		public static const REFERENCE:int = 18;
		public static const FOLDER:int = 19;
		public static const ENUM_MEMBER:int = 20;
		public static const CONSTANT:int = 21;
		public static const STRUCT:int = 22;
		public static const EVENT:int = 23;
		public static const OPERATOR:int = 24;
		public static const TYPE_PARAMETER:int = 25;
    }
}