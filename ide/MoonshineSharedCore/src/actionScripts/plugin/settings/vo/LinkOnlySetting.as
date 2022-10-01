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
	
	import actionScripts.interfaces.IDisposable;
	import actionScripts.plugin.settings.renderers.LinkOnlySettingsRenderer;
	import actionScripts.plugin.settings.vo.AbstractSetting;
	
	public class LinkOnlySetting extends AbstractSetting implements IDisposable
	{
		public static const EVENT_MODIFY:String = "modify";
		public static const EVENT_REMOVE:String = "delete";
		
		protected var rdr:LinkOnlySettingsRenderer = new LinkOnlySettingsRenderer();
		
		public var fakeSetting:String = "";
		
		private var nameEventPair:Vector.<LinkOnlySettingVO>;
		
		public function LinkOnlySetting(nameEventPair:Vector.<LinkOnlySettingVO>)
		{
			super();
			this.provider = this;
			this.name = 'fakeSetting';
			this.label = 'fakeLabel';
			this.nameEventPair = nameEventPair;
			defaultValue = stringValue = '';
		}
		
		override public function get renderer():IVisualElement
		{
			rdr.setting = this;
			rdr.nameEventPair = nameEventPair;
			return rdr;
		}
		
		public function dispose():void
		{
		}
	}
}