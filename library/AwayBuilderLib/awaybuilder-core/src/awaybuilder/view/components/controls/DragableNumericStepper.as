package awaybuilder.view.components.controls
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	
	import spark.components.Application;
	import spark.components.Label;
	import spark.components.NumericStepper;
	
	public class DragableNumericStepper extends NumericStepper
	{
		public function DragableNumericStepper()
		{
			super();
			
			valueParseFunction = stepperParseFunc;
			valueFormatFunction = stepperFormatFunc;
			
			editingMode = false;
			
			minimum = -999999;
			maximum = Number.MAX_VALUE;
		}
		
		private var _isFocused:Boolean;
		
		[SkinPart(required="true")]		public var valueDisplay:Label;

		[Bindable] public var editingMode:Boolean;
		
		private function stepperFormatFunc(val:Number):String 
		{ 
			return val.toString().replace(".",","); 
		} 
		
		private function stepperParseFunc(val:String):Number 
		{ 
			var stringVal:String = val.replace(",","."); 
			return Number(stringVal);     
		} 
		
		override protected function createChildren():void
		{
			this.addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler );
		}
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == valueDisplay)
			{
				valueDisplay.text = value.toString();
				valueDisplay.addEventListener( MouseEvent.MOUSE_DOWN, valueDisplay_mouseDownHandler );
				this.addEventListener(FocusEvent.FOCUS_IN, onFocusInHandler);
				this.addEventListener(FocusEvent.FOCUS_OUT, onFocusOutHandler);
			}
			if (instance == textDisplay)
			{
				textDisplay.addEventListener(FlexEvent.ENTER, textDisplay_enterHandler);
				textDisplay.addEventListener(FocusEvent.FOCUS_OUT, textDisplay_focusOutHandler); 
			}
		}
		
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			if (instance == valueDisplay)
			{
				valueDisplay.removeEventListener(MouseEvent.MOUSE_DOWN,	valueDisplay_mouseDownHandler);
				this.removeEventListener(FocusEvent.FOCUS_IN, onFocusInHandler);
				this.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOutHandler);
			}
			if (instance == textDisplay)
			{
				textDisplay.removeEventListener(FlexEvent.ENTER, textDisplay_enterHandler);
			}
		}
		
		private function valueDisplay_mouseDownHandler( event:MouseEvent ):void
		{
			valueDisplay.removeEventListener( MouseEvent.CLICK, valueDisplay_clickHandler );
			valueDisplay.addEventListener( MouseEvent.CLICK, valueDisplay_clickHandler );
			systemManager.getSandboxRoot().addEventListener( MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler );
			systemManager.getSandboxRoot().addEventListener( MouseEvent.MOUSE_UP, stage_mouseUpHandler );
			prevX = event.stageX;
			prevY = event.stageY;
			baseX = event.stageX;
			baseY = event.stageY;
		}
		private function valueDisplay_clickHandler( event:MouseEvent ):void
		{
			stage.focus = textDisplay;
			valueDisplay.removeEventListener( MouseEvent.CLICK, valueDisplay_clickHandler );
			editingMode = true;
			systemManager.getSandboxRoot().removeEventListener( MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler );
			systemManager.getSandboxRoot().removeEventListener( MouseEvent.MOUSE_UP, stage_mouseUpHandler );
		}
		
		private var prevX:Number = 0;
		private var prevY:Number = 0;
		private var baseX:Number = 0;
		private var baseY:Number = 0;
		
		private function stage_mouseMoveHandler( event:MouseEvent ):void
		{
			valueDisplay.removeEventListener( MouseEvent.CLICK, valueDisplay_clickHandler );
			var offsetX:Number = event.stageX - baseX;
			var offsetY:Number = event.stageY - baseY;
			var deltaX:Number = event.stageX - prevX;
			var deltaY:Number = event.stageY - prevY;
			if( deltaX > 0 )
			{
				if( offsetX > 25 ) {
					changeValue(true);
					changeValue(true);
					changeValue(true);
				}
				changeValue(true);
			}
			else if( deltaX < 0 )
			{
				if( offsetX < -25 ) {
					changeValue(false);
					changeValue(false);
					changeValue(false);
				}
				changeValue(false);
			}
			if( deltaY < 0 )
			{
				if( offsetY < -25 ) {
					changeValue(true);
					changeValue(true);
					changeValue(true);
				}
				changeValue(true);
			}
			else if( deltaY > 0 )
			{
				if( offsetY > 25 ) {
					changeValue(false);
					changeValue(false);
					changeValue(false);
				}
				changeValue(false);
			}
			prevX = event.stageX;
			prevY = event.stageY;
		}
		private function stage_mouseUpHandler( event:MouseEvent ):void
		{
			systemManager.getSandboxRoot().removeEventListener( MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler );
			systemManager.getSandboxRoot().removeEventListener( MouseEvent.MOUSE_UP, stage_mouseUpHandler );
		}
		private function textDisplay_enterHandler(event:Event):void
		{
			commitTextInput();
		}
		private function textDisplay_focusOutHandler(event:Event):void
		{
			commitTextInput();
		}
		
		private function commitTextInput():void
		{
			editingMode = false;
		}
		private function changeValue(increase:Boolean = true):void
		{
			dispatchEvent(new Event(Event.CHANGE));
			super.changeValueByStep(increase);
		}
		
		override protected function setValue(newValue:Number):void
		{
			super.setValue(newValue);
			if( isNaN( newValue) ) 
			{
				valueDisplay.text = " - ";
				return;
			}
			if( stepSize<1 ) 
			{
				const parts:Array = (new String(1 + snapInterval)).split("."); 
				valueDisplay.text = newValue.toFixed(parts[1].length);
			}
			else 
			{
				valueDisplay.text = newValue.toString();
			}
		}
		
		override protected function nearestValidValue(value:Number, interval:Number):Number
		{ 
			if (interval == 0)
				return Math.max(minimum, Math.min(maximum, value));
			
			var maxValue:Number = maximum - minimum;
			var scale:Number = 1;
			
			value -= minimum;
			
			if (interval != Math.round(interval)) 
			{ 
				const parts:Array = (new String(1 + interval)).split("."); 
				scale = Math.pow(10, parts[1].length);
				maxValue *= scale;
				value = Math.round(value * scale);
				interval = Math.round(interval * scale);
			}   
			
			var lower:Number = Math.max(0, Math.floor(value / interval) * interval);
			var upper:Number = Math.min(maxValue, Math.floor((value + interval) / interval) * interval);
			var validValue:Number = ((value - lower) >= ((upper - lower) / 2)) ? upper : lower;
			var size:Number = validValue / scale;
			var newVal:Number = size + minimum;
			return Math.round( newVal*scale)/scale;
		}
		
		private function onFocusInHandler(event:FocusEvent):void {
			_isFocused = true;
			invalidateSkinState();
			systemManager.getSandboxRoot().addEventListener(MouseEvent.CLICK,childUpOutside);
		}
		
		private function onFocusOutHandler(event:FocusEvent):void {
			if( stage )
			{
				_isFocused = false;
				invalidateSkinState();
				systemManager.getSandboxRoot().removeEventListener(MouseEvent.CLICK, childUpOutside);
				editingMode = false;
			}
			
		}
		
		private function childUpOutside(event:MouseEvent):void
		{
			if( !hitTestPoint( event.stageX, event.stageY ) )
			{
				var s:Stage = Application(FlexGlobals.topLevelApplication).stage;
				stage.focus = null;
				systemManager.getSandboxRoot().removeEventListener(MouseEvent.CLICK, childUpOutside);
			}
			
		}
		private function removedFromStageHandler(event:Event):void
		{
			systemManager.getSandboxRoot().removeEventListener(MouseEvent.CLICK, childUpOutside);
		}
		
		override protected function getCurrentSkinState():String {
			if( _isFocused ) 
			{
				return "focused";
			} 
			return super.getCurrentSkinState();
		}
		
	}
}