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
package actionScripts.plugin.settings.vo
{
    import mx.core.IVisualElement;
    
    import actionScripts.plugin.settings.renderers.BooleanRenderer;

    public class BooleanSetting extends AbstractSetting
    {
        public static const VALUE_UPDATED:String = "valueUpdated";

		private var immediateSave:Boolean;

        public function BooleanSetting(provider:Object, name:String, label:String, immediateSave:Boolean=false)
        {
            super();
            this.provider = provider;
            this.name = name;
            this.label = label;
			this.immediateSave = immediateSave;
            defaultValue = stringValue;
        }


        override protected function setPendingSetting(v:*):void
        {
            super.setPendingSetting(v is String ? v == "true" ? true : false : v);
        }

        [Bindable]
        public function get value():Boolean
        {
            var val:String = getSetting();
            return val == "true" ? true : false;
        }

        public function set value(v:Boolean):void
        {
            setPendingSetting(v);
			if (immediateSave) commitChanges();
        }

        private var _editable:Boolean;

        public function set editable(value:Boolean):void
        {
            _editable = value;
            if (_renderer)
            {
                _renderer.enabled = _editable;
            }
        }

        public function get editable():Boolean
        {
            return _editable;
        }

        private var _renderer:BooleanRenderer;

        override public function get renderer():IVisualElement
        {
            if (!_renderer)
            {
                _renderer = new BooleanRenderer();
                _renderer.setting = this;
            }

            return _renderer;
        }

    }
}