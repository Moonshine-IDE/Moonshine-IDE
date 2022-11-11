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
	import flash.events.Event;

	import mx.core.IVisualElement;
	
	import actionScripts.plugin.settings.renderers.MultiOptionRenderer;

	public class MultiOptionSetting extends StringSetting
	{
		public static const EVENT_MULTIOPTION_CHANGE:String = "eventMultiOptionChange";

		public var isCommitOnChange:Boolean;
		
		private var _options:Vector.<NameValuePair>;

		private var _isEditable:Boolean;
		
		private var rdr:MultiOptionRenderer;
		
		public function MultiOptionSetting(provider:Object, name:String, label:String,options:Vector.<NameValuePair>)
		{
			super(provider,name,label);
			_options = options;
			value = defaultValue = stringValue;
		}
		
		public function get value():Object{
			return getSetting();
		}
		public function set value(v:Object):void{
			setPendingSetting(v);			
		}
		
		override public function get renderer():IVisualElement
		{
			rdr = new MultiOptionRenderer();
			rdr.addEventListener(EVENT_MULTIOPTION_CHANGE, onOptionChange, false, 0, true);
			rdr.options = _options;
			rdr.setting = this;			
			return rdr;
		}
		
		override public function set isEditable(value:Boolean):void
		{
			_isEditable = value;
			if (rdr) 
			{
				rdr.mouseChildren = _isEditable;
				//rdr.filters = _isEditable ? [] : [myBlurFilter];
			}
		}
		override public function get isEditable():Boolean
		{
			return _isEditable;
		}

		private function onOptionChange(event:Event):void
		{
			dispatchEvent(event);
		}
	}
}