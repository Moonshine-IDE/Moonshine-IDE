package awaybuilder.view.components.controls
{
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import spark.components.supportClasses.ButtonBase;

	[Event(name="addNewItem",type="flash.events.MouseEvent")]
	
	public class LibraryCollapsiblePanel extends CollapsiblePanel
	{

		[SkinPart(required="false")]
		public var addButton:ButtonBase;
		
		private var _addEnabled:Boolean = false;
		
		[Bindable("addEnabledChange")]
		public function get addEnabled():Boolean
		{
			return this._addEnabled;
		}
		
		public function set addEnabled(value:Boolean):void
		{
			if(this._addEnabled === value)
			{
				return;
			}
			this._addEnabled = value;
			this.invalidateProperties();
			this.invalidateSkinState();
			this.dispatchEvent(new Event("addEnabledChange"));
		}
		
		public function LibraryCollapsiblePanel()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			if(this.addButton)
			{
				this.addButton.visible = addEnabled;
			}
			super.commitProperties();
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded( partName, instance );
			if(instance == this.addButton)
			{
				this.addButton.addEventListener(MouseEvent.CLICK, addButton_clickHandler);
				this.addButton.visible = addEnabled;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			if(instance == this.addButton)
			{
				this.addButton.removeEventListener(MouseEvent.CLICK, addButton_clickHandler);
			}
		}
		
		private function addButton_clickHandler( event:MouseEvent ):void
		{
			this.dispatchEvent(new MouseEvent("addNewItem", true, false, event.target.x, event.target.x, event.target as InteractiveObject));
		}
	}
}