package awaybuilder.view.components.controls.tree
{
import flash.events.Event;

/**
 * Dispatched by spark Tree.
 */
public class TreeEvent extends Event
{
	
	//--------------------------------------------------------------------------
	//
	//  Static constants
	//
	//--------------------------------------------------------------------------
	
	public static const ITEM_CLOSE:String = "itemClose";
	
	public static const ITEM_OPEN:String = "itemOpen";
	
	public static const ITEM_OPENING:String = "itemOpening";
	
	public static const ITEM_DROPPED:String = "itemDropped";
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	public function TreeEvent(type:String, bubbles:Boolean = false, 
		cancelable:Boolean = false, item:Object = null, itemRenderer:ITreeItemRenderer = null, opening:Boolean = true)
	{
		super(type, bubbles, cancelable);
		
		this.item = item;
		this.itemRenderer = itemRenderer;
		this.opening = opening && type == ITEM_OPENING;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	public var item:Object;
	
	public var itemRenderer:ITreeItemRenderer;
	
	/**
	 *  Used for an <code>ITEM_OPENING</code> type events only.
	 *  Indicates whether the item is opening <code>true</code>, or closing <code>false</code>.
	 */
	public var opening:Boolean;
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods: Event
	//
	//--------------------------------------------------------------------------
	
	/**
	 *  @private
	 */
	override public function clone():Event
	{
		return new TreeEvent(type, bubbles, cancelable,
			item, itemRenderer, opening);
	}
}
}