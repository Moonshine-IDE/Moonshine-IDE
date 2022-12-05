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
package actionScripts.plugins.macports
{
	import flash.filesystem.File;

	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugins.build.ConsoleBuildPluginBase;
	import actionScripts.valueObjects.ConstantsCoreVO;

	public class MacPortsPlugin extends ConsoleBuildPluginBase implements ISettingsProvider
	{
		public static var NAMESPACE:String = "actionScripts.plugins.macports::MacPortsPlugin";
		
		override public function get name():String			{ return "MacPorts"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String	{ return "Access to MacPorts support from Moonshine-IDE"; }
		
		private var pathSetting:PathSetting;
		private var defaultMacportsPath:String;

		public function get macportsPath():String
		{
			return model ? model.macportsPath : null;
		}
		public function set macportsPath(value:String):void
		{
			if (model.macportsPath != value)
			{
				model.macportsPath = value;
			}
		}

		override public function activate():void
		{
			super.activate();

			if (!ConstantsCoreVO.IS_APP_STORE_VERSION)
			{
				var macportsPath:File = new File("/opt/local/bin");
				defaultMacportsPath = macportsPath.exists ? macportsPath.nativePath : null;
				if (defaultMacportsPath && !model.macportsPath)
				{
					model.macportsPath = defaultMacportsPath;
				}
			}
		}
		
		override public function deactivate():void
		{
			super.deactivate();
		}

		override public function resetSettings():void
		{
			macportsPath = null;
		}
		
		override public function onSettingsClose():void
		{
			if (pathSetting)
			{
				pathSetting = null;
			}
		}

		override protected function outputMsg(msg:*):void
		{
			dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT_VAGRANT, msg));
		}
		
        public function getSettingsList():Vector.<ISetting>
        {
			onSettingsClose();
			pathSetting = new PathSetting(this, 'macportsPath', 'MacPorts Home', true, macportsPath, false, false, defaultMacportsPath);

			return Vector.<ISetting>([
				pathSetting
			]);
        }
	}
}