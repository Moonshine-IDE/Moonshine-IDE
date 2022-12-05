////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.ui.menu
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.controls.Spacer;
	import mx.core.ScrollPolicy;
	import mx.graphics.GradientEntry;
	import mx.graphics.LinearGradient;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.BorderContainer;
	
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	public class CustomMenuBox extends Canvas
	{
		private const rendererHeight:int = 22;
		
		private var upArrow:BorderContainer;
		private var downArrow:BorderContainer;
		private var bottomPadding:Spacer;
		
		public function CustomMenuBox()
		{
			super();
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			
			/*bottomPadding = new Spacer();
			bottomPadding.height = 3;
			super.addChildAt(bottomPadding, 0);*/
			
			setStyle("paddingTop", 3);
			setStyle("paddingBottom", 3);
			setStyle("verticalGap", 0);
			setStyle("backgroundColor", 0xf0f0f0);
			horizontalScrollPolicy = ScrollPolicy.OFF;
			verticalScrollPolicy = ScrollPolicy.OFF;
			
			filters = [new DropShadowFilter(5, 55, 0x979797, .22, 5, 5)];
			setStyle("borderStyle", "solid");
			setStyle("borderColor", 0x979797);
			setStyle("borderThickeness", 0);
		}
		
		private function onRemoved(event:Event):void
		{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			if (upArrow)
			{
				upArrow.removeEventListener(MouseEvent.MOUSE_OVER, onUpArrowOver);
				upArrow.removeEventListener(MouseEvent.MOUSE_OUT, onUpArrowOut);
				downArrow.removeEventListener(MouseEvent.MOUSE_OVER, onDownArrowOver);
				downArrow.removeEventListener(MouseEvent.MOUSE_OUT, onDownArrowOut);
				
				downArrow.removeEventListener(Event.ENTER_FRAME, onDownArrowClicked);
				upArrow.removeEventListener(Event.ENTER_FRAME, onUpArrowClicked);
			}
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			if (index != 0 && index <= numChildren)
			{
				var tmpChild:DisplayObject = getChildAt(index - 1);
				child.y = tmpChild.y + tmpChild.height;
			}
			else if (index == 0)
				child.y = 3;
			
			return super.addChildAt(child, index);
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
		}
		
		protected function addScrollButtons():void
		{
			if (!downArrow)
			{
				var backgroundColor:SolidColor = new SolidColor(0xf0f0f0);
				var stroke:SolidColorStroke = new SolidColorStroke(0, 0, 0);
				
				var upArrowImage:Image = new Image();
				upArrowImage.source = new ConstantsCoreVO.up_icon_menu_scroll;
				upArrowImage.horizontalCenter = upArrowImage.verticalCenter = 0;
				
				var downArrowImage:Image = new Image();
				downArrowImage.source = new ConstantsCoreVO.down_icon_menu_scroll;
				downArrowImage.horizontalCenter = downArrowImage.verticalCenter = 0;
				
				upArrow = new BorderContainer();
				upArrow.backgroundFill = backgroundColor;
				upArrow.borderStroke = stroke;
				upArrow.height = 20;
				upArrow.addEventListener(MouseEvent.MOUSE_OVER, onUpArrowOver);
				upArrow.addEventListener(MouseEvent.MOUSE_OUT, onUpArrowOut);
				upArrow.visible = false;
				upArrow.y = 0;
				upArrow.addElement(upArrowImage);
				super.addChildAt(upArrow, numChildren);
				
				downArrow = new BorderContainer();
				downArrow.backgroundFill = backgroundColor;
				downArrow.borderStroke = stroke;
				downArrow.height = 20;
				downArrow.y = measuredHeight - downArrow.height;
				downArrow.addEventListener(MouseEvent.MOUSE_OVER, onDownArrowOver);
				downArrow.addEventListener(MouseEvent.MOUSE_OUT, onDownArrowOut);
				downArrow.addElement(downArrowImage);
				downArrow.setStyle("paddingBottom", 3);
				super.addChildAt(downArrow, numChildren);
			}
		}
		
		private function onDownArrowOver(event:MouseEvent):void
		{
			downArrow.addEventListener(Event.ENTER_FRAME, onDownArrowClicked);
		}
		
		private function onDownArrowOut(event:MouseEvent):void
		{
			downArrow.removeEventListener(Event.ENTER_FRAME, onDownArrowClicked);
		}
		
		private function onUpArrowOver(event:MouseEvent):void
		{
			upArrow.addEventListener(Event.ENTER_FRAME, onUpArrowClicked);
		}
		
		private function onUpArrowOut(event:MouseEvent):void
		{
			upArrow.removeEventListener(Event.ENTER_FRAME, onUpArrowClicked);
		}
		
		private function onDownArrowClicked(event:Event):void
		{
			if (detectMouseOver(downArrow))
			{
				this.verticalScrollPosition += rendererHeight;
				downArrow.y += rendererHeight;
				upArrow.y += rendererHeight;
				upArrow.visible = true;
				
				if (verticalScrollPosition >= maxVerticalScrollPosition)
				{
					this.verticalScrollPosition = this.maxVerticalScrollPosition;
					downArrow.removeEventListener(Event.ENTER_FRAME, onDownArrowClicked);
					downArrow.visible = false;
					
					// get last most children instance - downArrow.instance
					var tmpLastRenderer:DisplayObject = getChildAt(numChildren - 3);
					upArrow.y = (tmpLastRenderer.y + tmpLastRenderer.height) - measuredHeight + 2;
					downArrow.y = tmpLastRenderer.y + 4;
				}
			}
		}
		
		private function onUpArrowClicked(event:Event):void
		{
			if (detectMouseOver(upArrow))
			{
				this.verticalScrollPosition -= rendererHeight;
				upArrow.y -= rendererHeight;
				downArrow.y -= rendererHeight;
				downArrow.visible = true;
				
				if (verticalScrollPosition <= 0)
				{
					this.verticalScrollPosition = 0;
					upArrow.removeEventListener(Event.ENTER_FRAME, onDownArrowClicked);
					upArrow.visible = false;
					upArrow.y = 0;
					downArrow.y = measuredHeight - downArrow.height;
				}
			}
		}
		
		private function detectMouseOver(d:DisplayObject):Boolean
		{
			var mousePoint:Point = d.localToGlobal(new Point(d.mouseX,d.mouseY));
			return d.hitTestPoint(mousePoint.x,mousePoint.y,true);
		}
		
		override protected function measure():void
		{
			super.measure();
			if(measuredHeight > this.maxHeight) 
			{
				measuredHeight = this.maxHeight;
				addScrollButtons();
			}
			commitProperties();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (downArrow) 
			{
				upArrow.width = downArrow.width = measuredWidth - 2;
			}
		}
	}
}