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