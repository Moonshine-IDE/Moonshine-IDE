package org.as3commons.asblocks.visitor
{

import org.as3commons.asblocks.api.IScriptNode;

public class FilterStrategy implements IScriptNodeStrategy
{
	//----------------------------------
	//  filtered
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _filtered:IScriptNodeStrategy;
	
	/**
	 * doc
	 */
	public function get filtered():IScriptNodeStrategy
	{
		return _filtered;
	}
	
	/**
	 * @private
	 */	
	public function set filtered(value:IScriptNodeStrategy):void
	{
		_filtered = value;
	}
	
	public function FilterStrategy(filtered:IScriptNodeStrategy = null)
	{
		this.filtered = filtered;
	}
	
	public function handle(element:IScriptNode):void
	{
	}
}
}