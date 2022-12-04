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
package actionScripts.plugins.domino.settings
{
	import mx.core.IVisualElement;
	
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugins.domino.view.UpdateSitePathRenderer;
	
	public class UpdateSitePathSetting extends PathSetting
	{
		public static const EVENT_GENRATE_SITE:String = "generateUpdateSite";
		
		private var updateSiteRenderer:UpdateSitePathRenderer;
		
		public function UpdateSitePathSetting(provider:Object, name:String, label:String, directory:Boolean, path:String=null, isSDKPath:Boolean=false, isDropDown:Boolean=false, defaultPath:String=null)
		{
			super(provider, name, label, directory, path, isSDKPath, isDropDown, defaultPath);
		}
		
		override public function get renderer():IVisualElement
		{
			if (!updateSiteRenderer)
			{
				updateSiteRenderer = new UpdateSitePathRenderer();
				updateSiteRenderer.setting = this;
				updateSiteRenderer.enabled = _editable;
				updateSiteRenderer.isGenerateButton = _isGenerateButton; 
				updateSiteRenderer.setMessage(message, messageType);
			}
			
			return updateSiteRenderer;
		}
		
		private var _isGenerateButton:Boolean = true;
		public function set isGenerateButton(value:Boolean):void
		{
			_isGenerateButton = value;
			if (updateSiteRenderer)
			{
				updateSiteRenderer.isGenerateButton = value;
			}
		}
		
		private var _editable:Boolean = true;
		override public function set editable(value:Boolean):void
		{
			_editable = value;
			if (updateSiteRenderer) 
			{
				updateSiteRenderer.enabled = _editable;
			}
		}
		
		public function set path(value:String):void
		{
			if (updateSiteRenderer)
			{
				updateSiteRenderer.path = value;	
			}
		}
	}
}