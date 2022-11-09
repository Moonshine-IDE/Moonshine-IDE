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
package actionScripts.plugins.js
{
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.events.SdkEvent;
	import flash.filesystem.File;
	
	public class JavaScriptPlugin extends PluginBase implements ISettingsProvider
	{
		override public function get name():String			{ return "JavaScript"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String	{ return "JavaScript Plugin"; }

		public function JavaScriptPlugin()
		{
			super();

			if(!ConstantsCoreVO.IS_MACOS || !ConstantsCoreVO.IS_APP_STORE_VERSION)
			{
				// because most users install Node.js to a standard installation
				// directory, we can try to use it as the default, if it exists.
				// if the user saves a different path (or clears the path) in
				// the settings, these default values will be safely ignored.
				var nodeDir:File = new File(ConstantsCoreVO.IS_MACOS ? "/usr/local/bin" : "C:\\Program Files\\nodejs")
				defaultNodePath = (nodeDir.exists && nodeDir.isDirectory) ? nodeDir.nativePath : null;
				if(defaultNodePath && model.nodePath == null)
				{
					model.nodePath = defaultNodePath;
				}
			}
		}
		
		private var nodePathSetting:PathSetting;
		private var defaultNodePath:String;

        public function get nodePath():String
        {
            return model ? model.nodePath : null;
        }

        public function set nodePath(value:String):void
        {
            if (model.nodePath != value)
            {
                model.nodePath = value;
			    dispatcher.dispatchEvent(new SdkEvent(SdkEvent.CHANGE_NODE_SDK));
            }
        }

        public function getSettingsList():Vector.<ISetting>
        {
			onSettingsClose();

			nodePathSetting = new PathSetting(this, 'nodePath', 'Node.js Home', true, nodePath, false, false, defaultNodePath);
			
			return Vector.<ISetting>([
                nodePathSetting
			]);
        }
		
		override public function onSettingsClose():void
		{
			if (nodePathSetting)
			{
				nodePathSetting = null;
			}
		}
	}
}
		