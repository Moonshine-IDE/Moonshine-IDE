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
	import mx.events.FlexEvent;
	import mx.managers.IToolTipManagerClient;
	
	import spark.components.Label;
	import spark.components.supportClasses.SkinnableComponent;
	
	import ws.tink.spark.controls.Rotator;

	/**
	 *  An indicator showing the indeterminate progress of a task.
	 *
	 * 	@langversion 3.0
	 * 	@playerversion Flash 10
	 * 	@playerversion AIR 1.5
	 * 	@productversion Flex 4
	 */
	public class ActivityIndicator extends SkinnableComponent
	{

		

		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------

		/**
		 *  Constructor
		 *
		 *  @langversion 3.0
  	 	 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function ActivityIndicator()
		{
			addEventListener(FlexEvent.SHOW, showHandler, false, 0, true);
			addEventListener(FlexEvent.HIDE, hideHandler, false, 0, true);
		}

		
		
		//--------------------------------------------------------------------------
		//
		//  SkinParts
		//
		//--------------------------------------------------------------------------	
		
		//----------------------------------
		//  indicator
		//----------------------------------
		
		[SkinPart(required='true')]
		/**
		 *  The rotator used to show an indicator
		 *
		 *  @langversion 3.0
  	 	 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public var indicator:IAnimator;
		
		//----------------------------------
		//  label
		//----------------------------------
		
		[SkinPart]
		/**
		 *  The labelDisplay to show the activity status
		 *
		 *  @langversion 3.0
  	 	 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public var labelDisplay:Label;
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------	

		//----------------------------------
		//  label
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for label.
		 */
		private var _label:String = '';
		
		/**
		 *  Text representing the status of the activity in progress.
		 *  This will be shown to the user, depending on the skin.
		 *
		 *  @langversion 3.0
  	 	 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get label():String
		{
			if(_label == '')
				return null;
			return _label;
		}
		/**
		 *  @private
		 */
		public function set label(value:String):void
		{
			if( _label == value ) return;
			
			_label = value;
			
			if (indicator && indicator is IToolTipManagerClient)
				IToolTipManagerClient( indicator ).toolTip = label;
			
			if (labelDisplay)
				labelDisplay.text = _label;
		}

		
		//----------------------------------
		//  autoAnimate
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for autoAnimate.
		 */
		private var _autoAnimate:Boolean = true;
		
		[Inspectable(type="Boolean",defaultValue="true")]
		/**
		 *  Indicates that the <code>ActivityIndicator</code> should animate by default.
		 *
		 *  This includes starting and stopping the animation when the component is shown and hidden.
		 *
		 *  @langversion 3.0
  	 	 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get autoAnimate():Boolean
		{
			return _autoAnimate;
		}
		/**
		 *  @private
		 */
		public function set autoAnimate(value:Boolean):void
		{
			_autoAnimate = value;
			if (value && visible)
				play();
			else
				stop();
		}

		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------	
		
		/**
		 *  Start the activity animation.
		 *  This can be managed automatically when show/hidden using autoAnimate.
		 * 
		 *  @see autoAnimate
		 * 
		 *  @langversion 3.0
  	 	 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */	
		public function play():void
		{
			if (indicator)
				indicator.play();
		}

		/**
		 *  Stop the activity animation.
		 *  This can be managed automatically when show/hidden using autoAnimate.
		 * 
		 *  @see autoAnimate
		 *
		 *  @langversion 3.0
  	 	 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */	
		public function stop():void
		{
			if (indicator)
				indicator.stop();
		}

		

		//--------------------------------------------------------------------------
		//
		//  Overridden Methods
		//
		//--------------------------------------------------------------------------	
		
		/**
		 *  @private
		 */
		protected override function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch( instance )
			{
				case indicator :
				{
					if( label && indicator is IToolTipManagerClient )
						IToolTipManagerClient( indicator ).toolTip = label;
					if( autoAnimate ) play();
					break;
				}
				case labelDisplay :
				{
					labelDisplay.text = label;
					break;
				}
			}
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Event Handlers
		//
		//--------------------------------------------------------------------------	
		
		/**
		 *  @private
		 */
		private function hideHandler(event:FlexEvent):void
		{
			if( autoAnimate ) stop();
		}
		
		/**
		 *  @private
		 */
		private function showHandler(event:FlexEvent):void
		{
			if (autoAnimate)
				play();
		}
	}
}
