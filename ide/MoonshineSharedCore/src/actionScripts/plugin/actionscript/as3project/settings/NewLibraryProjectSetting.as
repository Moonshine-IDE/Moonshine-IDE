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
package actionScripts.plugin.actionscript.as3project.settings
{
	import mx.core.IVisualElement;
	
	import __AS3__.vec.Vector;

	import actionScripts.plugin.actionscript.as3project.vo.LibrarySettingsVO;
	import actionScripts.plugin.settings.vo.AbstractSetting;

	public class NewLibraryProjectSetting extends AbstractSetting
	{
		private var rdr:NewLibraryProjectSettingRenderer;
		private var _isEnabled:Boolean = true;

		public function NewLibraryProjectSetting(provider:Object, name:String)
		{
			super();
			this.provider = provider;
			this.name = name;
			defaultValue = "";
		}
		
		override public function get renderer():IVisualElement
		{
			rdr = new NewLibraryProjectSettingRenderer();
			rdr.setting = this;
			rdr.enabled = _isEnabled; 
			return rdr;
		}
		
		public function set isEnabled(value:Boolean):void
		{
			_isEnabled = value;
			if (rdr) rdr.enabled = _isEnabled;
		}
		
		public function get isEnabled():Boolean
		{
			return _isEnabled;
		}
		
		public function get librarySettingObject():LibrarySettingsVO
		{
			if (rdr) return rdr.librarySettingObject;
			return null;
		}
    }
}