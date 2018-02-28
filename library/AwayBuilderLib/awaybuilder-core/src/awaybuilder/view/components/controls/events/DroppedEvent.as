package awaybuilder.view.components.controls.events {
	
	import awaybuilder.model.vo.scene.AssetVO;
	
	import flash.events.Event;
	
	import mx.events.DragEvent;
	
	public class DroppedEvent extends Event {
		
		public static const DROPPED:String = "dropped";
		
		public function DroppedEvent(type:String, item:AssetVO, index:int, targetItem:AssetVO = null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.item = item;
			this.targetItem = targetItem;
			this.index = index;
		}
		
		public var oldItem:AssetVO;
		
		public var item:AssetVO;
		
		public var index:int;
		
		public var complete:DragEvent;
		
		public var targetItem:AssetVO;
	}
}