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
	
	import spark.layouts.BasicLayout;
	
	public class PercentLayout extends BasicLayout
	{
		public function PercentLayout()
		{
			super();
		}
		
		//----------------------------------
		//  resizeItems
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for resizeItems.
		 */
		private var _resizeItems:Array;
		
		/**
		 *  resizeItems
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get resizeItems():Array
		{
			return _resizeItems;
		}
		/**
		 *  @private
		 */
		public function set resizeItems(value:Array):void
		{
			if( _resizeItems == value ) return;
			
			_resizeItems = value;
		}
		
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
			if( _percent == value ) return;
			
			_percent = value;
			target.invalidateDisplayList();
		}
		
		
		override public function updateDisplayList( unscaledWidth:Number, unscaledHeight:Number ):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			if( resizeItems && resizeItems.length )
			{
				var element:IVisualElement;
				var originalSize:Number;
				var minSize:Number;
				var availableChange:Number;
				
				for each (var item:Object in resizeItems) 
				{
					if( item is IVisualElement )
					{
						element = IVisualElement( item );
						originalSize = element.getLayoutBoundsWidth();
						minSize = element.getMinBoundsWidth();
						availableChange = originalSize - minSize;
						element.setLayoutBoundsSize( minSize + ( availableChange * ( percent / 100 ) ), element.getLayoutBoundsHeight() );
					}
				}
			}
			
			
		}
	}
}
