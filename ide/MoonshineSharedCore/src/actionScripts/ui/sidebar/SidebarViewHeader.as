////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
package actionScripts.ui.sidebar
{
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	
	import actionScripts.ui.tabview.TabViewTab;
	
	public class SidebarViewHeader extends TabViewTab
	{
		public function SidebarViewHeader()
		{
			super();
			percentWidth = 100;
			backgroundColor = 0xeeeeee;
			selectedBackgroundColor = 0xeeeeee;
			textColor = 0x2d2d2d;
			closeButtonColor = 0x444444;
			innerGlowColor = 0xFFFFFF;
			selected = false;
		}
		
		private function mouseOut(event:MouseEvent):void
		{
			if (event.relatedObject == closeButton) return;
			if (event.relatedObject == background) 	return;
			selected = false;
		}
		
		private function mouseOver(event:MouseEvent):void
		{
			selected = true;
		}

		override protected function createChildren():void
		{
			super.createChildren();
			
			background.filters = [	new GlowFilter(0xFFFFFF, 1, 6, 6, 1, 1, true),
								  	new DropShadowFilter(2, -90, 0x0, 0.15, 5, 6, 1, 1, true)
								 ];
			
			background.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			background.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			closeButton.addEventListener(MouseEvent.MOUSE_OUT, mouseOut); 
		}
		
		override protected function drawButtonState():void
		{
			if (!background) return;
			
			closeButton.x = width-closeButtonWidth;
			
			background.graphics.clear();
			
			background.graphics.lineStyle(1, 0x0, 0.5);
			background.graphics.moveTo(0, -1);
			background.graphics.lineTo(width, -1);
			background.graphics.lineStyle(0, 0, 0);
			
			var gradWidth:int = 8;
			var labelMaskWidth:int = width-gradWidth;
			
			if (isNaN(getStyle('textPaddingLeft')) == false)
			{
				labelMaskWidth += int(getStyle('textPaddingLeft'));
			}
			//display close button when debug view opens
			if (showCloseButton) closeButton.visible = true;
			
			labelMaskWidth -= closeButtonWidth;
			
			background.graphics.beginFill(selectedBackgroundColor);
			background.graphics.drawRect(0, 0, width, height);
			background.graphics.endFill();

			labelViewMask.graphics.clear();
			labelViewMask.graphics.beginFill(0x0, 1);
			labelViewMask.graphics.drawRect(0, 0, labelMaskWidth, height);
			labelViewMask.graphics.endFill();
			
			var mtr:Matrix = new Matrix();
			mtr.createGradientBox(gradWidth, height, 0, labelMaskWidth, 0);
			labelViewMask.graphics.beginGradientFill('linear', [0x0, 0x0], [1, 0], [0, 255], mtr);
			labelViewMask.graphics.drawRect(labelMaskWidth, 0, gradWidth, height);
			labelViewMask.graphics.endFill();
		}

		override protected function onTabViewTabMouseOverOut(event:MouseEvent):void
		{

		}
	}
}