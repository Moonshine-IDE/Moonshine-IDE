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
package actionScripts.ui.menu.renderers
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import mx.core.UIComponent;

	import spark.components.Label;

	public class MenuBarItemRenderer extends Label
	{
		private var labelView:Label
		private var needsRedrawing:Boolean
		private var itemContainer:UIComponent
		private var background:Sprite
		private var _active:Boolean

		public function MenuBarItemRenderer()
		{
			minWidth = 10;

			minHeight=13;

			setStyle("paddingTop", 5);
			setStyle("paddingBottom",4);
			setStyle("lineBreak", "explicit");
			setStyle("lineHeight",13);
			setStyle("fontSize",12);
			setStyle("textAlign","center");
			setStyle("backgroundColor", 0xB3B6BD);
			setStyle("backgroundAlpha", 0);
			setStyle("paddingLeft", 6); // for some reason we need to +1 to have even sides 
			setStyle("paddingRight", 5);
			setStyle("color",0x333333);

			addEventListener(MouseEvent.ROLL_OVER, rollOverHandler)
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);

		}

		


		private function drawBackground(show:Boolean):void
		{
			graphics.clear();
			if (show)
			{
				graphics.beginFill(0xB3B6BD, .8);
				graphics.drawRect(0, 0, width, height-1);
				graphics.endFill();
			}
		}

		public function set active(v:Boolean):void
		{
			_active = v;
			drawBackground(v);
		}

		private function rollOverHandler(e:MouseEvent):void
		{			
			drawBackground(true);
		}

		private function rollOutHandler(e:MouseEvent):void
		{
			if (!_active)
				drawBackground(false);
		}



	}
}