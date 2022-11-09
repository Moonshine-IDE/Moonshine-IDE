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
	
	import actionScripts.plugin.settings.renderers.StaticLabelRenderer;
	
	public class StaticLabelSetting extends AbstractSetting
	{
		[Bindable] public var fontSize:int;
		[Bindable] public var fontColor:uint;
		
		public var fakeSetting:String = "";
		
		public function StaticLabelSetting(label:String, fontSize:int=24, fontColor:uint=0xe252d3)
		{
			super();
			this.name = "fakeSetting";
			this.label = label;
			this.fontSize = fontSize;
			this.fontColor = fontColor;
		}
		
		override public function get renderer():IVisualElement
		{
			var rdr:StaticLabelRenderer = new StaticLabelRenderer();
			rdr.setting = this;
			return rdr;
		}
		
		
		// Do nothing
        override protected function getSetting():*
        {
        	return "";
        }

        override protected function hasProperty(... names:Array):Boolean
        {
            return false;
        }
        
        override protected function setPendingSetting(v:*):void
        {        
        }

        override public function valueChanged():Boolean
        {
            return false;
        }
		
		override public function commitChanges():void
		{
		}
		
	}
}