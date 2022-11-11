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
	import mx.collections.IList;
	import mx.core.IVisualElement;
	
	import actionScripts.plugin.settings.renderers.DropDownListSettingRenderer;
	
	public class DropDownListSetting extends AbstractSetting
	{
		[Bindable] public var dataProvider:IList;
		public var labelField:String;
		
		private var rdr:DropDownListSettingRenderer;
		
		private var _isEditable:Boolean = true;
		
		public function DropDownListSetting(provider:Object, name:String, label:String, dataProvider:IList, labelField:String=null)
		{
			super();
			this.provider = provider;
			this.name = name;
			this.label = label;
			this.labelField = labelField;
			this.dataProvider = dataProvider;
			defaultValue = "";
		}
		
		override public function get renderer():IVisualElement
		{
			rdr = new DropDownListSettingRenderer();
			rdr.setting = this;
			rdr.enabled = _isEditable;
			return rdr;
		}
		
		public function set isEditable(value:Boolean):void
		{
			_isEditable = value;
			if (rdr) 
			{
				rdr.mouseChildren = _isEditable;
				rdr.enabled = _isEditable;
			}
		}
		public function get isEditable():Boolean
		{
			return _isEditable;
		}
	}
}