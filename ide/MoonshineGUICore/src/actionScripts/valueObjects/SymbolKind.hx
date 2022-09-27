/**

Copyright (C) 2016-present Prominic.NET, Inc.
 
This program is free software: you can redistribute it and/or modify
it under the terms of the Server Side Public License, version 1,
as published by MongoDB, Inc.
 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
Server Side Public License for more details.

You should have received a copy of the Server Side Public License
along with this program. If not, see
http://www.mongodb.com/licensing/server-side-public-license.

As a special exception, the copyright holders give permission to link the
code of portions of this program with the OpenSSL library under certain
conditions as described in each individual source file and distribute
linked combinations including the program with the OpenSSL library. You
must comply with the Server Side Public License in all respects for
all of the code used other than as permitted herein. If you modify file(s)
with this exception, you may extend this exception to your version of the
file(s), but you are not obligated to do so. If you do not wish to do so,
delete this exception statement from your version. If you delete this
exception statement from all source files in the program, then also delete
it in the license file.

*/

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
package actionScripts.valueObjects;

/**
 * Implementation of SymbolKind enum from Language Server Protocol
 * 
 * <p><strong>DO NOT</strong> add new values to this class that are specific
 * to Moonshine IDE or to a particular language.</p>
 * 
 * @see https://microsoft.github.io/language-server-protocol/specification#textDocument_documentSymbol
 * @see https://microsoft.github.io/language-server-protocol/specification#workspace_symbol
 */
class SymbolKind {
	public static final FILE:Int = 1;
	public static final MODULE:Int = 2;
	public static final NAMESPACE:Int = 3;
	public static final PACKAGE:Int = 4;
	public static final CLASS:Int = 5;
	public static final METHOD:Int = 6;
	public static final PROPERTY:Int = 7;
	public static final FIELD:Int = 8;
	public static final CONSTRUCTOR:Int = 9;
	public static final ENUM:Int = 10;
	public static final INTERFACE:Int = 11;
	public static final FUNCTION:Int = 12;
	public static final VARIABLE:Int = 13;
	public static final CONSTANT:Int = 14;
	public static final STRING:Int = 15;
	public static final NUMBER:Int = 16;
	public static final BOOLEAN:Int = 17;
	public static final ARRAY:Int = 18;
	public static final OBJECT:Int = 19;
	public static final KEY:Int = 20;
	public static final NULL:Int = 21;
	public static final ENUM_MEMBER:Int = 22;
	public static final STRUCT:Int = 23;
	public static final EVENT:Int = 24;
	public static final OPERATOR:Int = 25;
	public static final TYPE_PARAMETER:Int = 26;
}