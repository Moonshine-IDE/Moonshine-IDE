package awaybuilder.view.skins
{
	import awaybuilder.view.components.controls.DragableNumericStepper;
	
	import flash.events.Event;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	public class DragableLabelFocusSkin extends UIComponent
	{
		
		private var _target:DragableNumericStepper;
		
		/**
		 *  Object to target.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get target():DragableNumericStepper
		{
			return _target;
		}
		
		public function set target(value:DragableNumericStepper):void
		{
			_target = value;
			
			// Add an "updateComplete" listener to the skin so we can redraw
			// whenever the skin is drawn.
			if (_target.skin)
				_target.skin.addEventListener(FlexEvent.UPDATE_COMPLETE, 
					skin_updateCompleteHandler, false, 0, true);
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{   
			this.graphics.clear();
			this.graphics.beginFill( 0x0000F0, 0.5 );
			this.graphics.drawRect( 1,1, target.width-1, target.height-1 );
			this.graphics.endFill();
		}
		
		private function skin_updateCompleteHandler(event:Event):void
		{
			invalidateDisplayList();
		}
	}
}        
