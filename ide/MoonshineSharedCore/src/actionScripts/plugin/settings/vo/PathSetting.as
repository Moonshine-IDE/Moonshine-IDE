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
	import mx.collections.ArrayCollection;
	import mx.core.IVisualElement;
	
	import actionScripts.plugin.settings.renderers.PathRenderer;
	
	[Event(name="pathSelected", type="flash.events.Event")]
	public class PathSetting extends AbstractSetting
	{
		[Bindable] public var dropdownListItems:ArrayCollection;
		[Bindable] public var directory:Boolean;
		public var fileFilters:Array;
		
		private var isSDKPath:Boolean;
		private var isDropDown:Boolean;
		private var rdr:PathRenderer;

		private var _editable:Boolean = true;
		private var _path:String;
		private var _defaultPath:String;

		public function PathSetting(provider:Object, name:String, label:String, directory:Boolean,
									path:String=null, isSDKPath:Boolean=false, isDropDown:Boolean = false, defaultPath:String = null)
		{
			super();
			this.provider = provider;
			this.name = name;
			this.label = label;
			this.directory = directory;
			this.isSDKPath = isSDKPath;
			this.isDropDown = isDropDown;

			_path = path;
			_defaultPath = defaultPath;

			defaultValue = stringValue = (path != null) ? path : stringValue ? stringValue :"";
		}

		public function get path():String
		{
			return _path;
		}

		public function get defaultPath():String
		{
			return _defaultPath;
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
				rdr = new PathRenderer();
				rdr.setting = this;
				rdr.isSDKPath = isSDKPath;
				rdr.isDropDown = isDropDown;
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