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
package actionScripts.plugin.settings.vo
{
    import mx.core.IVisualElement;
    import actionScripts.plugin.settings.renderers.NumericStepperRenderer;

    public class NumericStepperSetting extends AbstractSetting
    {
        public function NumericStepperSetting(provider:Object, name:String, label:String, minimum:Number = 0.0, maximum:Number = 100.0, stepSize:Number = 1.0, snapInterval:Number = 1.0)
        {
            super();
            this.provider = provider;
            this.name = name;
            this.label = label;
			this.minimum = minimum;
			this.maximum = maximum;
			this.stepSize = stepSize;
			this.snapInterval = snapInterval;
            defaultValue = stringValue;
        }

        [Bindable]
		public var minimum:Number;

        [Bindable]
		public var maximum:Number;

        [Bindable]
		public var stepSize:Number;

        [Bindable]
		public var snapInterval:Number;
        
        public function get value():Number
        {
            return parseFloat(getSetting());
        }

        public function set value(v:Number):void
        {
            setPendingSetting(v);
        }

        override public function get renderer():IVisualElement
        {
            var rdr:NumericStepperRenderer = new NumericStepperRenderer();
            rdr.setting = this;

            return rdr;
        }

    }
}