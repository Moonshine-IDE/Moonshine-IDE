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
package actionScripts.ui.tabNavigator
{
    import mx.core.UIComponent;

    public class CloseTabButton extends UIComponent
    {
        public function CloseTabButton()
        {
            super();

            this.graphics.lineStyle(1, 0xFFFFFF, 0.05);
            this.graphics.moveTo(0, 1);
            this.graphics.lineTo(0, 24);
            this.graphics.lineStyle(1, 0x0, 0.05);
            this.graphics.moveTo(1, 1);
            this.graphics.lineTo(1, 24);
            // Circle
            this.graphics.lineStyle(1, 0xFFFFFF, 0.8);
            this.graphics.beginFill(0x0, 0);
            this.graphics.drawCircle(14, 12, 6);
            this.graphics.endFill();
            // X (\)
            this.graphics.lineStyle(2, 0xFFFFFF, 0.8, true);
            this.graphics.moveTo(12, 10);
            this.graphics.lineTo(16, 14);
            // X (/)
            this.graphics.moveTo(16, 10);
            this.graphics.lineTo(12, 14);
            // Hit area
            this.graphics.lineStyle(0, 0x0, 0);
            this.graphics.beginFill(0x0, 0);
            this.graphics.drawRect(0, 0, 27, 25);
            this.graphics.endFill();

            this.buttonMode = true;
            this.depth = 1;
        }

        private var _itemIndex:int = -1;

        public function get itemIndex():int
        {
            return _itemIndex;
        }

        public function set itemIndex(value:int):void
        {
            _itemIndex = value;
        }
    }
}
