////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugin.settings.providers
{
	import actionScripts.events.FilePluginEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.utils.SharedObjectConst;
	
	import flash.net.SharedObject;
	
	public class JavaSettingsProvider implements ISettingsProvider
	{
		private var model:IDEModel = IDEModel.getInstance();
		private var _currentJavaPath:String;
		
		public function JavaSettingsProvider()
		{
			_currentJavaPath = model.javaPathForTypeAhead ? model.javaPathForTypeAhead.fileBridge.nativePath : null
		}
		
		public function getSettingsList():Vector.<ISetting>
		{
			return null;
		}
		
		public function get currentJavaPath():String
		{
			return _currentJavaPath;
		}
		
		public function set currentJavaPath(value:String):void
		{
			if (_currentJavaPath != value)
			{
				_currentJavaPath = value;
				
				if (!value)
				{
					resetJavaPath();
				}
				else
				{
					setNewJavaPath();
				}
				GlobalEventDispatcher
				.getInstance()
					.dispatchEvent(new FilePluginEvent(FilePluginEvent.EVENT_JAVA_TYPEAHEAD_PATH_SAVE, model.javaPathForTypeAhead));
			}
		}
		
		public function onSettingsClose():void
		{
			
		}
		
		private function resetJavaPath():void
		{
			if (!model.javaPathForTypeAhead) return;
			
			var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);
			if (model.activeEditor)
			{
				delete cookie.data["javaPathForTypeahead"];
				model.javaPathForTypeAhead = null;
				
				cookie.flush();
			}
		}
		
		private function setNewJavaPath():void
		{
			model.javaPathForTypeAhead = new FileLocation(currentJavaPath);
			model.flexCore.updateToCurrentEnvironmentVariable();
		}
	}
}