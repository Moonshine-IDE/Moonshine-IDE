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
	import actionScripts.plugin.settings.renderers.MainClassRenderer;
	import mx.core.IVisualElement;
	
	[Event(name="mainClassSelected", type="flash.events.Event")]
	public class MainClassSetting extends AbstractSetting
	{
		public var fileFilters:Array;

		private var rdr:MainClassRenderer;

		private var _editable:Boolean = true;
		private var _path:String;
		private var _mainClassOrFolderPath:String;

		public function MainClassSetting(provider:Object, name:String, label:String, path:String=null, mainClassOrFolderPath:String = null)
		{
			super();
			this.provider = provider;
			this.name = name;
			this.label = label;

			_path = path;
			_mainClassOrFolderPath = mainClassOrFolderPath;

			defaultValue = stringValue = (path != null) ? path : stringValue ? stringValue :"";
		}

		public function get path():String
		{
			return _path;
		}

		public function get mainClassOrFolderPath():String
		{
			return _mainClassOrFolderPath;
		}

		public function setMessage(value:String, type:String=MESSAGE_NORMAL):void
		{
			if (rdr)
			{
				rdr.setMessage(value, type);
            }
			else
			{
				message = value;
				messageType = type;
			}
		}
		
		override public function get renderer():IVisualElement
		{
			if (!rdr)
			{
				rdr = new MainClassRenderer();
				rdr.setting = this;
				rdr.enabled = _editable;
				rdr.setMessage(message, messageType);
			}

			return rdr;
		}
		
		public function set editable(value:Boolean):void
		{
			_editable = value;
			if (rdr) 
			{
				rdr.enabled = _editable;
			}
		}
		public function get editable():Boolean
		{
			return _editable;
		}
	}
}