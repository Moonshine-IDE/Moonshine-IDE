////////////////////////////////////////////////////////////////////////////////
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
// 
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugin.settings.vo
{
	import flash.events.EventDispatcher;
	
	import __AS3__.vec.Vector;
	
	import actionScripts.plugin.settings.IHasSettings;

	public class SettingsWrapper extends EventDispatcher implements IHasSettings
	{
		protected var _name:String;
		protected var _settings:Vector.<ISetting>;
		
		public function SettingsWrapper(name:String, settings:Vector.<ISetting>)
		{
			_name = name;
			_settings = settings;
		}

		[Bindable(event="weDontReallyCare")]
		public function get name():String
		{
			return _name;
		}
		
		public function getSettingsList():Vector.<ISetting>
		{
			return _settings;
		}
		
		public function hasChanged():Boolean
		{
			for each(var setting:ISetting in _settings)
			{
				if(setting.valueChanged())
				{
					return true;
				}
			}
			return false;
		}
		
		public function commitChanges():void
		{
			for each(var setting:ISetting in _settings)
			{
				if(setting.valueChanged())
				{
					setting.commitChanges();
				}
			}
		}
		
	}
}