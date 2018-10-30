/*

Licensed to the Apache Software Foundation (ASF) under one or more
contributor license agreements.  See the NOTICE file distributed with
this work for additional information regarding copyright ownership.
The ASF licenses this file to You under the Apache License, Version 2.0
(the "License"); you may not use this file except in compliance with
the License.  You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

*/
package ws.tink.spark.controls
{
	import flash.events.Event;
	
	import mx.events.PropertyChangeEvent;
	
	import spark.components.DataRenderer;
	import spark.components.IItemRenderer;
	
	public class StepRendererBase extends DataRenderer implements IItemRenderer
	{
		public function StepRendererBase()
		{
			super();
		}
		
		private var _itemIndex:int;
		[Bindable("itemIndexChanged")]
		public function get itemIndex():int
		{
			return _itemIndex;
		}
		
		public function set itemIndex(value:int):void
		{
			if( _itemIndex == value ) return;
			_itemIndex = value;
			dispatchEvent(new Event("itemIndexChanged"));
		}
		
		private var _stateColor:Number;
		[Bindable(type="currentStateChange")]
		public function get stateColor():Number { return _stateColor; }
		
		
		
		override public function set data(value:Object):void
		{
			super.data = value;
			
			invalidateProperties();
		}
		
		override public function setCurrentState(stateName:String, playTransition:Boolean=true):void
		{
			_stateColor = stateName == "normal" ? getStyle( "color" ) : getStyle( stateName + "Color" );
			super.setCurrentState(stateName, playTransition);
		}
		
		override protected function commitProperties():void
		{
			if (data && data is StepItem && hasState( StepItem( data ).status ))
			{
				setCurrentState( StepItem( data ).status );
			}
			else
			{
				setCurrentState( "normal" );
			}
			
			toolTip = (data && data is StepItem )? StepItem( data ).label : "";
			
			super.commitProperties();
		}
		
		public function get label():String
		{
			return "";
		}
		
		public function set label(value:String):void
		{
		}
		public function get selected():Boolean
		{
			return false;
		}
		
		public function set selected(value:Boolean):void
		{
		}
		
		public function get showsCaret():Boolean
		{
			return false;
		}
		
		public function set showsCaret(value:Boolean):void
		{
		}
		
		public function get dragging():Boolean
		{
			return false;
		}
		
		public function set dragging(value:Boolean):void
		{
		}
		
	}
}
