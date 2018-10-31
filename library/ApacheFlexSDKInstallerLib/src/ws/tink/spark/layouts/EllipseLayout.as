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
package ws.tink.spark.layouts
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import mx.core.ILayoutElement;
	
	import spark.layouts.supportClasses.LayoutBase;
	
	public class EllipseLayout extends LayoutBase
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
		public function EllipseLayout()
		{
			super();
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  startAngle
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for startAngle.
		 */
		private var _startAngle:Number = 0;
		
		[Inspectable(category="General")]
		/**
		 *  startAngle
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get startAngle():Number
		{
			return _startAngle;
		}
		/**
		 *  @private
		 */
		public function set startAngle( value:Number ):void
		{
			if( _startAngle == value ) return;
			
			_startAngle = value;
			invalidateDisplayList();
		}
		
		
		//----------------------------------
		//  endAngle
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for endAngle.
		 */
		private var _endAngle:Number = 0;
		
		[Inspectable(category="General")]
		/**
		 *  endAngle
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get endAngle():Number
		{
			return _endAngle;
		}
		/**
		 *  @private
		 */
		public function set endAngle( value:Number ):void
		{
			if( _endAngle == value ) return;
			
			_endAngle = value;
			invalidateDisplayList();
		}
		
		
		//----------------------------------
		//  position
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for position.
		 */
		private var _position:String = "inset";
		
		[Inspectable(category="General")]
		/**
		 *  @private
		 *  Storage property for position.
		 */
		public function get position():String
		{
			return _position;
		}
		/**
		 *  @private
		 */
		public function set position( value:String ):void
		{
			if( _position == value ) return;
			
			_position = value;
			invalidateDisplayList();
		}
		
		public var rotate:Boolean = false;
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private function updateDisplayListVirtual( width:Number, height:Number ):void
		{
			
			
			
			
		}
		
		/**
		 *  @private
		 */
		private function distance( x1:Number, y1:Number, x2:Number, y2:Number ):Number
		{
			const dx:Number = x2 - x1;
			const dy:Number = y2 - y1;
			return Math.sqrt( dx * dx + dy * dy );
		}
		
		/**
		 *  @private
		 */
		private function invalidateDisplayList():void
		{
			if( !target ) return;
			
			target.invalidateDisplayList();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override public function updateDisplayList(width:Number, height:Number):void
		{
			super.updateDisplayList(width,height);
			
			if( !target ) return;
			
			var element:ILayoutElement;
			const numElements:int = target.numElements;
			const angle:Number = 360 / numElements;
			const radiusX:Number = width / 2;
			const radiusY:Number = height / 2;
			var a:Number = startAngle;
			for (var i:int = 0; i < numElements; i++) 
			{
				a = startAngle + ( angle * i );
				element = target.getElementAt( i );
				element.setLayoutBoundsSize( element.getPreferredBoundsWidth(), element.getPreferredBoundsHeight() );
				if( rotate )
				{
					element.transformAround( new Vector3D( element.getPreferredBoundsWidth() / 2, radiusY, 0 ),
						null,
						new Vector3D( 0, 0, a ),
						new Vector3D( radiusX, radiusY, 0 ) );
				}
				else
				{
					element.setLayoutBoundsPosition( radiusX + ( radiusX * Math.cos(a * ( Math.PI / 180 ) ) ) - ( element.getPreferredBoundsWidth() / 2 ),
						radiusY + ( radiusY * Math.sin(a * ( Math.PI / 180 ) ) ) - ( element.getPreferredBoundsHeight() / 2 ) );
				}
				//				switch( position )
				//				{
				//					case "inset" :
				//					{
				//						
				//						break;
				//					}
				//					default :
				//					{
				//						
				//						
				//					}
				//				}
				
				//				var m:Matrix = new Matrix();
				//				m.tx = radiusX + ( radiusX * Math.cos(a * ( Math.PI / 180 ) ) ) - ( element.getPreferredBoundsWidth() / 2 );
				//				m.ty = radiusY + ( radiusY * Math.sin(a * ( Math.PI / 180 ) ) ) - ( element.getPreferredBoundsHeight() / 2 );
				//				m.rotate( a * ( Math.PI / 180 ) );
				//				m.tx = m.ty = 200;
				//								m.tx = radiusX + ( radiusX * Math.cos(a * ( Math.PI / 180 ) ) ) - ( element.getPreferredBoundsWidth() / 2 );
				//								m.ty = radiusY + ( radiusY * Math.sin(a * ( Math.PI / 180 ) ) ) - ( element.getPreferredBoundsHeight() / 2 );
				//				element.setLayoutMatrix( m, false );
				
				//				var x:Number = radiusX + ( radiusX * Math.cos(a * ( Math.PI / 180 ) ) );
				//				var y:Number = radiusY + ( radiusY * Math.cos(a * ( Math.PI / 180 ) ) );
				//				
				//				
				//				trace( i, distance( radiusX, radiusY, x, y ), x, y, radiusX, radiusY );
				
				
			}
		}
		
		
	}
}