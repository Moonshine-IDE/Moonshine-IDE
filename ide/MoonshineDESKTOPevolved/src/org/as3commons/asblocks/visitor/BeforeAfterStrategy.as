package org.as3commons.asblocks.visitor
{
import org.as3commons.asblocks.api.IScriptNode;

public class BeforeAfterStrategy extends FilterStrategy
{
	//----------------------------------
	//  before
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _before:IScriptNodeStrategy;
	
	/**
	 * doc
	 */
	public function get before():IScriptNodeStrategy
	{
		return _before;
	}
	
	/**
	 * @private
	 */	
	public function set before(value:IScriptNodeStrategy):void
	{
		_before = value;
	}
	
	//----------------------------------
	//  after
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _after:IScriptNodeStrategy;
	
	/**
	 * doc
	 */
	public function get after():IScriptNodeStrategy
	{
		return _after;
	}
	
	/**
	 * @private
	 */	
	public function set after(value:IScriptNodeStrategy):void
	{
		_after = value;
	}
	
	public function BeforeAfterStrategy(filtered:FilterStrategy, 
										before:IScriptNodeStrategy = null, 
										after:IScriptNodeStrategy = null)
	{
		super(filtered);
		this.before = before;
		this.after = after;
	}
	
	override public function handle(element:IScriptNode):void
	{
		handleBefore(element);
		super.handle(element);
		handleAfter(element);
	}
	
	protected function handleBefore(element:IScriptNode):void
	{
		if (before)
		{
			before.handle(element);
		}
	}
	
	protected function handleAfter(element:IScriptNode):void
	{
		if (after)
		{
			after.handle(element);
		}
	}
}
}