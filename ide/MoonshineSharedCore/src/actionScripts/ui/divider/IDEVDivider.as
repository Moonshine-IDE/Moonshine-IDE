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
package actionScripts.ui.divider
{
	import mx.containers.dividedBoxClasses.BoxDivider;

	public class IDEVDivider extends BoxDivider
	{
		public function IDEVDivider()
		{
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			/*
				This would have been easier if the knob-skin could draw as it wanted.
				Currently it's /removed/ if the divider is thinner than 6 pixels.
				So we override & draw like this.
			*/
			
			graphics.beginFill(0xa0a0a0, 1);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
			
			graphics.beginFill(0x2d2d2d);
			graphics.drawRect(0, 0, width, 1);
			graphics.endFill();
				
			graphics.beginFill(0x5a5a5a);
			graphics.drawRect(0, 1, width, 1);
			graphics.endFill();
		}
		
	}
}