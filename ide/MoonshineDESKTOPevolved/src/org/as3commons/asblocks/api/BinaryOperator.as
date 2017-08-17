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

package org.as3commons.asblocks.api
{

import com.ericfeminella.collections.HashMap;
import com.ericfeminella.collections.IMap;

import flash.errors.IllegalOperationError;

import org.as3commons.asblocks.parser.api.AS3NodeKind;
import org.as3commons.asblocks.parser.api.IToken;
import org.as3commons.asblocks.parser.core.LinkedListToken;
import org.as3commons.asblocks.utils.ASTUtil;

/**
 * Binary operators.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public final class BinaryOperator
{	
	//--------------------------------------------------------------------------
	//
	//  Public :: Constants
	//
	//--------------------------------------------------------------------------
	
	/**
	 * The <code>+</code> operator.
	 */
	public static var ADD:BinaryOperator = BinaryOperator.create("ADD");
	
	/**
	 * The <code>&&</code> operator.
	 */
	public static var AND:BinaryOperator = BinaryOperator.create("AND");
	
	/**
	 * The <code>&</code> operator.
	 */
	public static var BITAND:BinaryOperator = BinaryOperator.create("BITAND");
	
	/**
	 * The <code>|</code> operator.
	 */
	public static var BITOR:BinaryOperator = BinaryOperator.create("BITOR");
	
	/**
	 * The <code>^</code> operator.
	 */
	public static var BITXOR:BinaryOperator = BinaryOperator.create("BITXOR");
	
	/**
	 * The <code>/</code> operator.
	 */
	public static var DIV:BinaryOperator = BinaryOperator.create("DIV");
	
	/**
	 * The <code>==</code> operator.
	 */
	public static var EQ:BinaryOperator = BinaryOperator.create("EQ");
	
	/**
	 * The <code>>=</code> operator.
	 */
	public static var GE:BinaryOperator = BinaryOperator.create("GE");
	
	/**
	 * The <code>></code> operator.
	 */
	public static var GT:BinaryOperator = BinaryOperator.create("GT");
	
	/**
	 * The <code<=</code> operator.
	 */
	public static var LE:BinaryOperator = BinaryOperator.create("LE");
	
	/**
	 * The <code><</code> operator.
	 */
	public static var LT:BinaryOperator = BinaryOperator.create("LT");
	
	/**
	 * The <code>%</code> operator.
	 */
	public static var MOD:BinaryOperator = BinaryOperator.create("MOD");
	
	/**
	 * The <code>*</code> operator.
	 */
	public static var MUL:BinaryOperator = BinaryOperator.create("MUL");
	
	/**
	 * The <code>!=</code> operator.
	 */
	public static var NE:BinaryOperator = BinaryOperator.create("NE");
	
	/**
	 * The <code>||</code> operator.
	 */
	public static var OR:BinaryOperator = BinaryOperator.create("OR");
	
	/**
	 * The <code><<</code> operator.
	 */
	public static var SL:BinaryOperator = BinaryOperator.create("SL");
	
	/**
	 * The <code>>></code> operator.
	 */
	public static var SR:BinaryOperator = BinaryOperator.create("SR");
	
	/**
	 * The <code>>>></code> operator.
	 */
	public static var SRU:BinaryOperator = BinaryOperator.create("SRU");
	
	/**
	 * The <code>-</code> operator.
	 */
	public static var SUB:BinaryOperator = BinaryOperator.create("SUB");
	
	//--------------------------------------------------------------------------
	//
	//  Private Static :: Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	private static var OPERATORS_BY_TYPE:IMap = new HashMap();
	
	/**
	 * @private
	 */
	private static var TYPES_BY_OPERATOR:IMap = new HashMap();
	
	/**
	 * @private
	 */
	private static var intialized:Boolean = false;
	
	/**
	 * @private
	 */
	private static function initialize():void
	{
		if (intialized)
			return;
		
		mapOp(AS3NodeKind.PLUS, "+", BinaryOperator.ADD);
		mapOp(AS3NodeKind.LAND, "&&", BinaryOperator.AND);
		mapOp(AS3NodeKind.BAND, "&", BinaryOperator.BITAND);
		mapOp(AS3NodeKind.BOR, "|", BinaryOperator.BITOR);
		mapOp(AS3NodeKind.BXOR, "^", BinaryOperator.BITXOR);
		mapOp(AS3NodeKind.DIV, "/", BinaryOperator.DIV);
		mapOp(AS3NodeKind.EQUAL, "==", BinaryOperator.EQ);
		mapOp(AS3NodeKind.GE, ">=", BinaryOperator.GE);
		mapOp(AS3NodeKind.GT, ">", BinaryOperator.GT);
		mapOp(AS3NodeKind.LE, "<=", BinaryOperator.LE);
		mapOp(AS3NodeKind.LT, "<", BinaryOperator.LT);
		mapOp(AS3NodeKind.MOD, "%", BinaryOperator.MOD);
		mapOp(AS3NodeKind.STAR, "*", BinaryOperator.MUL);
		mapOp(AS3NodeKind.NOT_EQUAL, "!=", BinaryOperator.NE);
		mapOp(AS3NodeKind.LOR, "||", BinaryOperator.OR);
		mapOp(AS3NodeKind.SL, "<<", BinaryOperator.SL);
		mapOp(AS3NodeKind.SR, ">>", BinaryOperator.SR);
		mapOp(AS3NodeKind.BSR, ">>>", BinaryOperator.SRU);
		mapOp(AS3NodeKind.MINUS, "-", BinaryOperator.SUB);
		
		intialized = true;
	}
	
	/**
	 * @private
	 */
	private static function mapOp(kind:String, text:String, operator:BinaryOperator):void
	{
		OPERATORS_BY_TYPE.put(kind, operator);
		TYPES_BY_OPERATOR.put(operator, new LinkedListToken(kind, text));
	}
	
	//--------------------------------------------------------------------------
	//
	//  Public :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  name
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _name:String;
	
	/**
	 * The operator name.
	 */
	public function get name():String
	{
		return _name;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	public function BinaryOperator(name:String)
	{
		_name = name;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Public :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	public function toString():String
	{
		return _name;
	}
	
	/**
	 * @private
	 */
	public function equals(other:BinaryOperator):Boolean
	{
		return _name == other.name;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Public Class :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Returns the operator from a node kind.
	 * 
	 * @param The node kind.
	 * @return The <code>BinaryOperator</code> for the node kind or throws
	 * an error.
	 * @throws IllegalOperationError No operator for token-kind
	 */
	public static function opFromKind(kind:String):BinaryOperator
	{
		if (!intialized)
		{
			initialize();
		}
		
		var op:BinaryOperator = OPERATORS_BY_TYPE.getValue(kind);
		if (op == null) 
		{
			throw new IllegalOperationError("No operator for token-kind '" + 
				ASTUtil.tokenName(kind) + "'");
		}
		return op;
	}
	
	/**
	 * Initializes a token from an operator.
	 * 
	 * @param operator The <code>BinaryOperator</code> to initialize the token.
	 * an error.
	 * @param token The <code>IToken</code> to initialize.
	 * @throws IllegalOperationError No operator for Op
	 */
	public static function initializeFromOp(operator:BinaryOperator, 
											token:IToken):void
	{
		if (!intialized)
		{
			initialize();
		}
		
		var type:LinkedListToken = TYPES_BY_OPERATOR.getValue(operator);
		if (type == null) 
		{
			throw new IllegalOperationError("No operator for Op " + operator);
		}
		
		token.kind = type.kind;
		token.text = type.text;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Private Class :: Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Creates a new <code>BinaryOperator</code>.
	 * 
	 * @param name A <code>String</code> indicating the name of the 
	 * <code>BinaryOperator</code>.
	 * @return A new <code>BinaryOperator</code> instance.
	 */
	private static function create(name:String):BinaryOperator
	{
		return new BinaryOperator(name);
	}
}
}