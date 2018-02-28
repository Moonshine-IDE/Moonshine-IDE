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
	import mx.core.IVisualElement;
	import mx.rpc.events.HeaderEvent;
	
	import spark.components.supportClasses.SkinnableComponent;
	
	public class ProgressBar extends SkinnableComponent
	{
		
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function ProgressBar()
		{
			super();
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Skin Parts
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  bar
		//----------------------------------
		
		[SkinPart(required="true")]
		
		/**
		 *  bar.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public var percentLayout:PercentLayout;
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  percent
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for percent.
		 */
		private var _percent:Number = 0;
		
		/**
		 *  percent
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get percent():Number
		{
			return _percent;
		}
		/**
		 *  @private
		 */
		public function set percent(value:Number):void
		{
//			if( _percent == value ) return;
			
			_percent = value;
			if( percentLayout ) percentLayout.percent = percent;
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded( partName, instance );
			
			if( instance == percentLayout ) percentLayout.percent = percent;
		}
	}
}
