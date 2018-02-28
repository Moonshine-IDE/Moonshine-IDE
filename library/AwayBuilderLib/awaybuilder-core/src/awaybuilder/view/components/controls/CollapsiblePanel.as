package awaybuilder.view.components.controls
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import spark.components.Panel;
	import spark.components.supportClasses.ButtonBase;
	import spark.components.supportClasses.ToggleButtonBase;
	
	[Event(name="collapsedChange",type="flash.events.Event")]
	
	[SkinState("collapsed")]
	public class CollapsiblePanel extends Panel
	{
		public function CollapsiblePanel()
		{
			super();
		}
		
		[SkinPart(required="false")]
		public var collapseButton:ButtonBase;
		
		protected var collapsedChanged:Boolean = false;
		
		private var _collapsed:Boolean = false;

		[Bindable("collapsedChange")]
		public function get collapsed():Boolean
		{
			return this._collapsed;
		}

		public function set collapsed(value:Boolean):void
		{
			if(this._collapsed === value)
			{
				return;
			}
			this._collapsed = value;
			this.collapsedChanged = true;
			this.invalidateProperties();
			this.invalidateSkinState();
			this.dispatchEvent(new Event("collapsedChange"));
		}

		override protected function commitProperties():void
		{
			if(this.collapsedChanged)
			{
				if(this.collapseButton && this.collapseButton is ToggleButtonBase)
				{
					ToggleButtonBase(this.collapseButton).selected = this.collapsed;
				}
				this.collapsedChanged = false;
			}
			super.commitProperties();
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
            super.partAdded( partName, instance );
			if(instance == this.collapseButton)
			{
				this.collapseButton.addEventListener(MouseEvent.CLICK, collapseButton_clickHandler);
			}
		}

		override protected function partRemoved(partName:String, instance:Object):void
		{
			if(instance == this.collapseButton)
			{
				this.collapseButton.removeEventListener(MouseEvent.CLICK, collapseButton_clickHandler);
			}
		}
		
		override protected function getCurrentSkinState():String
		{
			return this.collapsed ? "collapsed" : super.getCurrentSkinState();
		}
		
		protected function collapseButton_clickHandler(event:MouseEvent):void
		{
			this.collapsed = !this.collapsed;
		}

	}
}