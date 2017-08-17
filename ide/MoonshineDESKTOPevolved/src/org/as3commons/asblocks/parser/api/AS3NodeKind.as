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
 * The <strong>AS3NodeKind</strong> enumeration of <strong>.as</strong> 
 * node kinds.
 * 
 * <p>Initial API; Adobe Systems, Incorporated</p>
 * 
 * @author Adobe Systems, Incorporated
 * @author Michael Schmalle
 * @productversion 1.0
 */
public class AS3NodeKind
{
	//--------------------------------------------------------------------------
	//
	//  TOKENS
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  Assignment
	//----------------------------------
	
	/**
	 * <code>=</code>
	 */
	public static const ASSIGN:String = "assign";
	
	/**
	 * <code>*=</code>
	 */
	public static const STAR_ASSIGN:String = "star-assign";
	
	/**
	 * <code>/=</code>
	 */
	public static const DIV_ASSIGN:String = "div-assign";
	
	/**
	 * <code>%=</code>
	 */
	public static const MOD_ASSIGN:String = "mod-assign";
	
	/**
	 * <code>+=</code>
	 */
	public static const PLUS_ASSIGN:String = "plus-assign";
	
	/**
	 * <code>-=</code>
	 */
	public static const MINUS_ASSIGN:String = "minus-assign";
	
	/**
	 * <code><<=</code>
	 */
	public static const SL_ASSIGN:String = "sl-assign";
	
	/**
	 * <code>>>=</code>
	 */
	public static const SR_ASSIGN:String = "sr-assign";
	
	/**
	 * <code>>>=</code>
	 */
	public static const BSR_ASSIGN:String = "bsr-assign";
	
	/**
	 * <code>&=</code>
	 */
	public static const BAND_ASSIGN:String = "band-assign";
	
	/**
	 * <code>^=</code>
	 */
	public static const BXOR_ASSIGN:String = "bxor-assign";
	
	/**
	 * <code>|=</code>
	 */
	public static const BOR_ASSIGN:String = "bor-assign";
	
	/**
	 * <code>&&=</code>
	 */
	public static const LAND_ASSIGN:String = "land-assign";
	
	/**
	 * <code>||=</code>
	 */
	public static const LOR_ASSIGN:String = "lor-assign";
	
	//----------------------------------
	//  Conditional
	//----------------------------------
	
	/**
	 * <code>?</code>
	 */
	public static const QUESTION:String = "question";
	
	/**
	 * <code>:</code>
	 */
	public static const COLON:String = "colon";
	
	//----------------------------------
	//  Or And
	//----------------------------------
	
	/**
	 * <code>||</code>
	 */
	public static const LOR:String = "lor";
	
	/**
	 * <code>&&</code>
	 */
	public static const LAND:String = "land";
	
	/**
	 * <code>|</code>
	 */
	public static const BOR:String = "bor";
	
	/**
	 * <code>^</code>
	 */
	public static const BXOR:String = "bxor";
	
	/**
	 * <code>&</code>
	 */
	public static const BAND:String = "band";
	
	//----------------------------------
	//  Equality
	//----------------------------------
	
	/**
	 * <code>==</code>
	 */
	public static const EQUAL:String = "equal";
	
	/**
	 * <code>!=</code>
	 */
	public static const NOT_EQUAL:String = "not-equal";
	
	/**
	 * <code>===</code>
	 */
	public static const STRICT_EQUAL:String = "strict-equal";
	
	/**
	 * <code>!==</code>
	 */
	public static const STRICT_NOT_EQUAL:String = "strict-not-equal";
	
	//----------------------------------
	//  Relational
	//----------------------------------
	
	/**
	 * <code>in</code>
	 */
	public static const IN:String = "in";
	
	/**
	 * <code><</code>
	 */
	public static const LT:String = "lt";
	
	/**
	 * <code><=</code>
	 */
	public static const LE:String = "le";
	
	/**
	 * <code>></code>
	 */
	public static const GT:String = "gt";
	
	/**
	 * <code>>=</code>
	 */
	public static const GE:String = "ge";
	
	/**
	 * <code>is</code>
	 */
	public static const IS:String = "is";
	
	/**
	 * <code>as</code>
	 */
	public static const AS:String = "as";
	
	/**
	 * <code>instanceof</code>
	 */
	public static const INSTANCE_OF:String = "instance-of";
	
	//----------------------------------
	//  Shift
	//----------------------------------
	
	/**
	 * <code><<</code>
	 */
	public static const SL:String = "sl";
	
	/**
	 * <code>>></code>
	 */
	public static const SR:String = "sr";
	
	/**
	 * <code><<<</code>
	 */
	public static const SSL:String = "ssl";
	
	/**
	 * <code>>>></code>
	 */
	public static const BSR:String = "bsr";
	
	//----------------------------------
	//  Additive
	//----------------------------------
	
	/**
	 * <code>+</code>
	 */
	public static const PLUS:String = "plus";
	
	/**
	 * <code>-</code>
	 */
	public static const MINUS:String = "minus"; 
	
	//----------------------------------
	//  Multiplicative
	//----------------------------------
	
	/**
	 * <code>*</code>
	 */
	public static const STAR:String = "star";
	
	/**
	 * <code>/</code>
	 */
	public static const DIV:String = "div";
	
	/**
	 * <code>%</code>
	 */
	public static const MOD:String = "mod";
	
	//----------------------------------
	//  Unary
	//----------------------------------
	
	/**
	 * <code>--</code>
	 */
	public static const POST_DEC:String = "post-dec";
	
	/**
	 * <code>++</code>
	 */
	public static const POST_INC:String = "post-inc";
	
	/**
	 * <code>--</code>
	 */
	public static const PRE_DEC:String = "pre-dec";
	
	/**
	 * <code>++</code>
	 */
	public static const PRE_INC:String = "pre-inc";
	
	/**
	 * <code>delete</code>
	 */
	public static const DELETE:String = "delete";
	
	/**
	 * <code>void</code>
	 */
	public static const VOID:String = "void";
	
	/**
	 * <code>typeof</code>
	 */
	public static const TYPEOF:String = "typeof";
	
	/**
	 * <code>!</code>
	 */
	public static const NOT:String = "not";
	
	/**
	 * <code>~</code>
	 */
	public static const B_NOT:String = "b-not";
	
	//----------------------------------
	//  Boundaries
	//----------------------------------
	
	public static const COMMA:String = "comma";
	
	public static const CONFIG:String = "config";
	
	public static const NAMESPACE:String = "namespace";
	
	public static const SEMI:String = "semi";
	
	public static const LBRACKET:String = "lbracket";
	
	public static const LCURLY:String = "lcurly";
	
	public static const RBRACKET:String = "rbracket";
	
	public static const RCURLY:String = "rcurly";
	
	public static const RPAREN:String = "rparen";
	
	public static const LPAREN:String = "lparen";
	
	public static const HIDDEN:String = "hidden";
	
	public static const WS:String = "ws";
	
	public static const NL:String = "nl";
	
	public static const SPACE:String = "space";
	
	public static const TAB:String = "tab";
	
	public static const REST_PARM:String = "rest-param";
	
	public static const ELSE:String = "else";
	
	public static const ML_COMMENT:String = "ml-comment";
	
	public static const SL_COMMENT:String = "sl-comment";
	
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	
	public static const COMMENT:String = "comment";
	
	public static const AS_DOC:String = "as-doc"; 
	
	public static const BLOCK_DOC:String = "block-doc";
	
	public static const COMPILATION_UNIT:String = "compilation-unit";
	
	public static const PACKAGE:String = "package";
	
	public static const CONTENT:String = "content";
	
	public static const INTERNAL_CONTENT:String = "internal-content";
	
	public static const CLASS:String = "class";
	
	public static const INTERFACE:String = "interface";
	
	public static const EXTENDS:String = "extends";
	
	public static const IMPLEMENTS:String = "implements";
	
	public static const IMPORT:String = "import";
	
	public static const INCLUDE:String = "include";
	
	public static const USE:String = "use";
	
	public static const META:String = "meta";
	
	public static const META_LIST:String = "meta-list";
	
	//----------------------------------
	//  Expression
	//----------------------------------
	
	public static const ASSIGNMENT:String = "assignment";
	
	public static const CONDITIONAL:String = "conditional";
	
	public static const OR:String = "or";
	
	public static const AND:String = "and";
	
	public static const EQUALITY:String = "equality";
	
	public static const RELATIONAL:String = "relational";
	
	public static const SHIFT:String = "shift";
	
	public static const ADDITIVE:String = "additive";
	
	public static const MULTIPLICATIVE:String = "multiplicative";
	
	public static const B_AND:String = "b-and"; 
	
	public static const B_OR:String = "b-or";
	
	public static const B_XOR:String = "b-xor";
	
	public static const EXPR_LIST:String = "expr-list";
	
	public static const DOT:String = "dot"; 
	
	public static const DOUBLE_COLUMN:String = "double-column";
	
	public static const ARRAY_ACCESSOR:String = "arr-acc";
	
	//----------------------------------
	//  Statement
	//----------------------------------
	
	public static const EXPR_STMNT:String = "expr-stmnt";
	
	public static const LABEL:String = "label";
	
	public static const FOR:String = "for";
	
	public static const INIT:String = "init";
	
	public static const COND:String = "cond";
	
	public static const ITER:String = "iter";
	
	public static const EACH:String = "each";
	
	public static const FOREACH:String = "foreach";
	
	public static const FORIN:String = "forin";
	
	public static const CONTINUE:String = "continue";
	
	public static const IF:String = "if";
	
	public static const CONDITION:String = "condition";
	
	public static const SWITCH:String = "switch";
	
	public static const SWITCH_BLOCK:String = "switch-block";
	
	public static const CASE:String = "case";
	
	public static const CASES:String = "cases";
	
	public static const DEFAULT:String = "default";
	
	public static const DO:String = "do";
	
	public static const WHILE:String = "while";
	
	public static const WITH:String = "with";
	
	public static const TRY:String = "try";
	
	public static const TRY_STMNT:String = "try-stmnt";
	
	public static const FINALLY:String = "finally";
	
	public static const CATCH:String = "catch";
	
	public static const BLOCK:String = "block";
	
	public static const VAR:String = "var";
	
	public static const CONST:String = "const";
	
	public static const RETURN:String = "return";
	
	public static const BREAK:String = "break";
	
	public static const STMT_EMPTY:String = "stmt-empty"; // SEMI
	
	//----------------------------------
	//  Primary
	//----------------------------------
	
	public static const ARRAY:String = "array";
	
	public static const OBJECT:String = "object";
	
	public static const PROP:String = "prop";
	
	public static const LAMBDA:String = "lambda";
	
	public static const SUPER:String = "super";
	
	public static const THIS:String = "this";
	
	public static const THROW:String = "throw";
	
	public static const NEW:String = "new";
	
	public static const ENCAPSULATED:String = "encapsulated";
	
	public static const STRING:String = "string";
	
	public static const NUMBER:String = "number";
	
	public static const REG_EXP:String = "reg-exp";
	
	public static const XML:String = "xml";
	
	public static const TRUE:String = "true";
	
	public static const FALSE:String = "false";
	
	public static const NULL:String = "null";
	
	public static const UNDEFINED:String = "undefined";
	
	public static const PRIMARY:String = "primary";
	
	public static const DF_XML_NS:String = "df-xml-ns";
	
	//----------------------------------
	//  Invocation
	//----------------------------------
	
	public static const CALL:String = "call";
	
	public static const ARGUMENTS:String = "arguments";
	
	//----------------------------------
	//  var, const Declaration
	//----------------------------------
	
	public static const DEC_LIST:String = "dec-list";
	
	public static const DEC_ROLE:String = "dec-role";
	
	public static const VECTOR:String = "vector";
	
	public static const NAME:String = "name";
	
	public static const TYPE:String = "type";
	
	public static const VALUE:String = "value";
	
	public static const NAME_TYPE_INIT:String = "name-type-init";
	
	//----------------------------------
	//  Field
	//----------------------------------
	
	public static const FIELD_LIST:String = "field-list";
	
	public static const FIELD_ROLE:String = "field-role";
	
	public static const MOD_LIST:String = "mod-list";
	
	public static const MODIFIER:String = "mod";
	
	//----------------------------------
	//  Function
	//----------------------------------
	
	public static const FUNCTION:String = "function";
	
	public static const ACCESSOR_ROLE:String = "accessor-role";
	
	public static const GET:String = "get";
	
	public static const SET:String = "set";
	
	public static const PARAMETER:String = "parameter";
	
	public static const PARAMETER_LIST:String = "parameter-list";
	
	public static const REST:String = "rest";
	
	//----------------------------------
	//  XML
	//----------------------------------
	
	public static const XML_NAMESPACE:String = "xml-namespace";
	
	public static const E4X_ATTR:String = "e4x-attr";
	
	public static const E4X_DESCENDENT:String = "e4x-descendent";
	
	public static const E4X_FILTER:String = "e4x-filter";
	
	public static const E4X_STAR:String = "e4x-star";
}
}