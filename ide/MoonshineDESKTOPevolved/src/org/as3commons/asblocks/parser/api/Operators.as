////////////////////////////////////////////////////////////////////////////////
// Copyright 2010 Michael Schmalle - Teoti Graphix, LLC
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
// Author: Michael Schmalle, Principal Architect
// mschmalle at teotigraphix dot com
////////////////////////////////////////////////////////////////////////////////

package org.as3commons.asblocks.parser.api
{

/**
 * The <strong>Operators</strong> enumeration of <strong>actionscript3</strong> 
 * operators.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class Operators
{
	//--------------------------------------------------------------------------
	//
	//  Public :: Constants
	//
	//--------------------------------------------------------------------------
	
	/**
	 * The <code>?</code>
	 */
	public static const QUESTION:String = "?";
	
	/**
	 * The <code>(</code>
	 */
	public static const LPAREN:String = "(";
	
	/**
	 * The <code>)</code>
	 */
	public static const RPAREN:String = ")";
	
	/**
	 * The <code>[</code>
	 */
	public static const LBRACK:String = "[";
	
	/**
	 * The <code>]</code>
	 */
	public static const RBRACK:String = "]";
	
	/**
	 * The <code>{</code>
	 */
	public static const LCURLY:String = "{";
	
	/**
	 * The <code>}</code>
	 */
	public static const RCURLY:String = "}";
	
	/**
	 * The <code>:</code>
	 */
	public static const COLON:String = ":";
	
	/**
	 * The <code>::</code>
	 */
	public static const DBL_COLON:String = "::";
	
	/**
	 * The <code>,</code>
	 */
	public static const COMMA:String = ",";
	
	/**
	 * The <code>=</code>
	 */
	public static const ASSIGN:String = "=";
	
	/**
	 * The <code>==</code>
	 */
	public static const EQUAL:String = "==";
	
	/**
	 * The <code>===</code>
	 */
	public static const STRICT_EQUAL:String = "===";
	
	/**
	 * The <code>!</code>
	 */
	public static const LNOT:String = "!";
	
	/**
	 * The <code>~</code>
	 */
	public static const BNOT:String = "~";
	
	/**
	 * The <code>!=</code>
	 */
	public static const NOT_EQUAL:String = "!=";
	
	/**
	 * The <code>!==</code>
	 */
	public static const STRICT_NOT_EQUAL:String = "!==";
	
	/**
	 * The <code>/</code>
	 */
	public static const DIV:String = "/";
	
	/**
	 * The <code>/=</code>
	 */
	public static const DIV_ASSIGN:String = "/=";
	
	/**
	 * The <code>+</code>
	 */
	public static const PLUS:String = "+";
	
	/**
	 * The <code>+=</code>
	 */
	public static const PLUS_ASSIGN:String = "+=";
	
	/**
	 * The <code>++</code>
	 */
	public static const INC:String = "++";
	
	/**
	 * The <code>-</code>
	 */
	public static const MINUS:String = "-";
	
	/**
	 * The <code>-=</code>
	 */
	public static const MINUS_ASSIGN:String = "-=";
	
	/**
	 * The <code>--</code>
	 */
	public static const DEC:String = "--";
	
	/**
	 * The <code>*</code>
	 */
	public static const STAR:String = "*";
	
	/**
	 * The <code>*=</code>
	 */
	public static const STAR_ASSIGN:String = "*=";
	
	/**
	 * The <code>%</code>
	 */
	public static const MOD:String = "%";
	
	/**
	 * The <code>%=</code>
	 */
	public static const MOD_ASSIGN:String = "%=";
	
	/**
	 * The <code>>></code>
	 */
	public static const SR:String = ">>";
	
	/**
	 * The <code>>>=</code>
	 */
	public static const SR_ASSIGN:String = ">>=";
	
	/**
	 * The <code>>>></code>
	 */
	public static const BSR:String = ">>>";
	
	/**
	 * The <code>>>>=</code>
	 */
	public static const BSR_ASSIGN:String = ">>>=";
	
	/**
	 * The <code>>=</code>
	 */
	public static const GE:String = ">=";
	
	/**
	 * The <code>></code>
	 */
	public static const GT:String = ">";
	
	/**
	 * The <code><<</code>
	 */
	public static const SL:String = "<<";
	
	/**
	 * The <code><<=</code>
	 */
	public static const SL_ASSIGN:String = "<<=";
	
	/**
	 * The <code><<<</code>
	 */
	public static const SSL:String = "<<<";
	
	/**
	 * The <code><<<=</code>
	 */
	public static const SSL_ASSIGN:String = "<<<=";
	
	/**
	 * The <code><=</code>
	 */
	public static const LE:String = "<=";
	
	/**
	 * The <code><</code>
	 */
	public static const LT:String = "<";
	
	/**
	 * The <code>^</code>
	 */
	public static const BXOR:String = "^";
	
	/**
	 * The <code>^=</code>
	 */
	public static const BXOR_ASSIGN:String = "^=";
	
	/**
	 * The <code>|</code>
	 */
	public static const BOR:String = "|";
	
	/**
	 * The <code>|=</code>
	 */
	public static const BOR_ASSIGN:String = "|=";
	
	/**
	 * The <code>||</code>
	 */
	public static const LOR:String = "||";
	
	/**
	 * The <code>||=</code>
	 */
	public static const LOR_ASSIGN:String = "||=";
	
	/**
	 * The <code>&</code>
	 */
	public static const BAND:String = "&";
	
	/**
	 * The <code>&=</code>
	 */
	public static const BAND_ASSIGN:String = "&=";
	
	/**
	 * The <code>&&</code>
	 */
	public static const LAND:String = "&&";
	
	/**
	 * The <code>&&=</code>
	 */
	public static const LAND_ASSIGN:String = "&&=";
	
	/**
	 * The <code>at</code>
	 */
	public static const E4X_ATTRI:String = "@";
	
	/**
	 * The <code>;</code>
	 */
	public static const SEMI:String = ";";
	
	
	/**
	 * The <code>.</code>
	 */
	public static const DOT:String = ".";
	
	/**
	 * The <code>..</code>
	 */
	public static const E4X_DESC:String = "..";
	
	/**
	 * The <code>...</code>
	 */
	public static const REST:String = "...";
	
	
	/**
	 * The <code>"</code>
	 */
	public static const QUOTE:String = "\"";
	
	/**
	 * The <code>'</code>
	 */
	public static const SQUOTE:String = "'";
	
	
	/**
	 * The <code>.<</code>
	 */
	public static const VECTOR_START:String = ".<";
}
}