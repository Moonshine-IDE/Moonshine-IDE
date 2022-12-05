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
package actionScripts.plugin.settings.providers
{
	import actionScripts.events.FilePluginEvent;
	import actionScripts.events.GlobalEventDispatcher;

	import flash.net.SharedObject;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.utils.SharedObjectConst;
	
	public class Java8SettingsProvider implements ISettingsProvider
	{
		protected var model:IDEModel = IDEModel.getInstance();
		
		private var _currentJava8Path:String;
		
		public function Java8SettingsProvider()
		{
			_currentJava8Path = model.java8Path ? model.java8Path.fileBridge.nativePath : null
		}
		
		public function getSettingsList():Vector.<ISetting>
		{
			return null;
		}
		
		public function get currentJava8Path():String
		{
			return _currentJava8Path;
		}
		
		public function set currentJava8Path(value:String):void
		{
			if (_currentJava8Path != value)
			{
				_currentJava8Path = value;
				
				if (!value)
				{
					resetJavaPath();
				}
				else
				{
					setNewJavaPath();
				}
				
				GlobalEventDispatcher.getInstance().dispatchEvent(
					new FilePluginEvent(FilePluginEvent.EVENT_JAVA8_PATH_SAVE, model.java8Path)
				);
			}
			else if (!model.javaVersionInJava8Path)
			{
				updateJavaVersion();
			}
		}
		
		public function onSettingsClose():void
		{
			
		}
		
		protected function resetJavaPath():void
		{
			if (!model.java8Path) return;
			updateToCookie(null);
		}
		
		protected function setNewJavaPath():void
		{
			updateToCookie(new FileLocation(currentJava8Path));
			
			//model.flexCore.updateToCurrentEnvironmentVariable();
		}
		
		protected function updateToCookie(value:FileLocation):void
		{
			var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);
			if (value) 
			{
				cookie.data["java8Path"] = value.fileBridge.nativePath;
			}
			else 
			{
				delete cookie.data["java8Path"];
			}
			
			model.java8Path = value;
			updateJavaVersion();
			cookie.flush();
		}
		
		private function updateJavaVersion():void
		{
			if (model.java8Path) 
				model.flexCore.getJavaVersion(model.java8Path.fileBridge.nativePath, onJavaVersionReadCompletes);
		}
		
		private function onJavaVersionReadCompletes(value:String):void
		{
			model.javaVersionInJava8Path = value;
		}
	}
}