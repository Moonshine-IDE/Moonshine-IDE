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
				
				/*GlobalEventDispatcher.getInstance().dispatchEvent(
						new FilePluginEvent(FilePluginEvent.EVENT_JAVA_TYPEAHEAD_PATH_SAVE, model.java8Path)
				);*/
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