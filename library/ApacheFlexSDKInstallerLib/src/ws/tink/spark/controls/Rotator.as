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
	import flash.events.TimerEvent;
	import flash.geom.Vector3D;
	import flash.utils.Timer;
	
	import mx.core.ILayoutElement;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.PropertyChangeEvent;
	
	import spark.components.supportClasses.SkinnableComponent;
	import spark.layouts.supportClasses.LayoutElementHelper;
	import spark.primitives.supportClasses.GraphicElement;
	
	
	/**
	 *  The Rotator control is a simple skinnable component that rotates it's skin when playing.
	 *
	 *  <p>You can set the amount of rotation on each frame by changing the <code>delta</code> property.</p>
	 *
	 *  <p>The List control has the following default characteristics:</p>
	 *  <table class="innertable">
	 *     <tr><th>Characteristic</th><th>Description</th></tr>
	 *     <tr><td>Default skin class</td><td>ws.tink.spark.skins.controls.RotatorSkin</td></tr>
	 *  </table>
	 *
	 *  @mxml <p>The <code>&lt;st:Rotator&gt;</code> tag inherits all of the tag 
	 *  attributes of its superclass and adds the following tag attributes:</p>
	 *
	 *  <pre>
	 *  &lt;st:Rotator
	 *    <strong>Properties</strong>
	 *    delta="10"
	 *  /&gt;
	 *  </pre>
	 *
	 *  @see ws.tink.spark.skins.controls.RotatorSkin
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public class Rotator extends SkinnableComponent implements IAnimator
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
		public function Rotator()
		{
			super();
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private var _playing:Boolean;
		
		/**
		 *  @private
		 */
		private var _rotation:Number = 0;
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  delta
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage property for delta.
		 */
		private var _delta:Number = 10;
		
		[Inspectable(type="Boolean", defaultValue="10")]
		/**
		 *  The amount to rotate in degrees each frame.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get delta():Number
		{
			return _delta;
		}
		/**
		 *  @private
		 */
		public function set delta(value:Number):void
		{
			if (_delta == value) return;
			
			_delta = value;
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @inheritDoc
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function play():void
		{
			_playing = true;
			addEventListener( Event.ENTER_FRAME, enterFrameHandler, false, 0, true );
		}
		
		/**
		 *  @inheritDoc
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function stop():void
		{
			_playing = false;
			removeEventListener( Event.ENTER_FRAME, enterFrameHandler, false );
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Event Handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private function enterFrameHandler( event:Event ):void
		{
			if( skin )
			{
				_rotation += ( 360 / 10 );
				skin.transformAround( new Vector3D( unscaledWidth / 2, unscaledHeight / 2, 0 ),
					new Vector3D( 1, 1, 1 ),
					new Vector3D( 0, 0, _rotation ) );
			}
		}
	}
}
