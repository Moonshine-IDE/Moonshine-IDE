package org.as3commons.asblocks.impl
{

import org.as3commons.asblocks.api.IArrayAccessExpression;
import org.as3commons.asblocks.api.IExpression;
import org.as3commons.asblocks.parser.api.IParserNode;

/**
 * The <code>IArrayAccessExpression</code> implementation.
 * 
 * @author Michael Schmalle
 * @copyright Teoti Graphix, LLC
 * @productversion 1.0
 */
public class ArrayAccessExpressionNode extends ExpressionNode 
	implements IArrayAccessExpression
{
	//--------------------------------------------------------------------------
	//
	//  IArrayAccessExpression API :: Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  target
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IArrayAccessExpression#target
	 */
	public function get target():IExpression
	{
		return ExpressionBuilder.build(node.getFirstChild());
	}
	
	/**
	 * @private
	 */	
	public function set target(value:IExpression):void
	{
		node.setChildAt(value.node, 0);
	}
	
	//----------------------------------
	//  subscript
	//----------------------------------
	
	/**
	 * @copy org.as3commons.asblocks.api.IArrayAccessExpression#subscript
	 */
	public function get subscript():IExpression
	{
		return ExpressionBuilder.build(node.getLastChild());
	}
	
	/**
	 * @private
	 */	
	public function set subscript(value:IExpression):void
	{
		node.setChildAt(value.node, 1);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function ArrayAccessExpressionNode(node:IParserNode)
	{
		super(node);
	}
}
}