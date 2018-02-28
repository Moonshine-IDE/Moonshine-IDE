package awaybuilder.desktop.view.components.events
{
	import flash.events.Event;
	
	public class ProductKeyWindowEvent extends Event
	{
		public static const START_OR_CONTINUE_TRIAL:String = "startOrContinueTrial";
		public static const SAVE_PRODUCT_KEY:String = "saveProductKey";
		
		public function ProductKeyWindowEvent(type:String)
		{
			super(type, false, false);
		}
		
		override public function clone():Event
		{
			return new ProductKeyWindowEvent(this.type);
		}
	}
}