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