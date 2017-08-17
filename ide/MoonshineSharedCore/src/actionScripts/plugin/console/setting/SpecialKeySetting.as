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
package actionScripts.plugin.console.setting
{
	
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.AbstractSetting;
	import actionScripts.valueObjects.Settings;
	
	import mx.core.IVisualElement;
	
	public class SpecialKeySetting extends AbstractSetting
	{
		[Bindable]
		public var eventPropName:String;
		
		[Bindable]
		public var ctrl:Boolean;
		[Bindable]
		public var cmd:Boolean;
		[Bindable]
		public var alt:Boolean;
		
		[Bindable]
		public var keyValue:String;
		
		private var _eventValue:int;
		[Bindable]
		public function get eventValue():int
		{
			return _eventValue;
		}
		public function set eventValue(v:int):void
		{
			_eventValue = v;
			//setPendingSetting(null);
		}
		
		public function SpecialKeySetting(provider:ISettingsProvider, name:String, label:String=null, path:String=null)
		{
			super();
			this.provider = provider;
			this.name = name;
			this.label = label; 
			defaultValue = stringValue = (path != null) ? path : stringValue ? stringValue :"";
		}
		
		public function getKeyAsChar():String
		{
			if (eventPropName == 'charCode')
			{
				var str:String="";
				if(ctrl)
					str+="Ctrl + ";
				if(cmd)
					str+="Cmd + ";
				if(alt)
					str+="Alt + ";
				
				if(eventValue<48) //  return blank charcode for some combination key like ctrl + alt + key
					str = "?";
				else
					str+=String.fromCharCode(eventValue);
				keyValue = eventPropName + ':' + eventValue + ':' + alt + ':' + ctrl + ':' + cmd;
				return str;
			}
			else if (eventPropName == 'keyCode')
			{
				var keystr:String = "";
				if (eventValue == 112) 
					keystr = "F1";
				else if (eventValue == 113) 
					keystr = "F2";
				else if (eventValue == 114) 
					keystr = "F3";
				else if (eventValue == 115) 
					keystr = "F4";
				else if (eventValue == 116) 
					keystr = "F5";
				else if (eventValue == 117) 
					keystr = "F6";
				else if (eventValue == 118) 
					keystr = "F7";
				else if (eventValue == 119) 
					keystr = "F8";
				else if (eventValue == 122) 
					keystr = "F11";
				else if (eventValue == 123) 
					keystr = "F12";
				keyValue = eventPropName + ':' + eventValue + ':' + alt + ':' + ctrl + ':' + cmd;
				return keystr;
			}
			
			return "?";
		}
		
		override public function get renderer():IVisualElement
		{
			var rdr:SpecialKeyRenderer = new SpecialKeyRenderer();
			rdr.setting = this;
			return rdr;
		}
	
	   public function  setLabel(v:String):String 
		{
		   var str:String ="";
			if (v)
			{
				var values:Array = v.split(":");
				eventPropName = values[0];
				alt  = (values[2]=="false"?false:true);
				ctrl = (values[3]=="false"?false:true);
				cmd  = (values[4]=="false"?false:true);
				eventValue = parseInt(values[1]);
				str = getKeyAsChar();
			}
			return str;
			//setSetting(v);
		}		
		
		/*override protected function getSetting() : *{
			if(pendingChanges != null) return pendingChanges;
			
			if (!provider) return "";
			eventPropName = provider['consoleTriggerKeyPropertyName'];
			alt = provider['alt'];
			ctrl = provider['ctrl'];
			cmd = provider['cmd'];
			eventValue = provider['consoleTriggerKeyValue'];
			keyValue = eventPropName + ':' + eventValue + ':' + alt + ':' + ctrl + ':' + cmd;
			return provider[name] != null ? provider[name] : "";
		}
		private function setSetting(v:*):void 
		{
				if (!provider) return;
				provider['consoleTriggerKeyPropertyName'] = eventPropName;
				provider['consoleTriggerKeyValue'] = eventValue;
				provider['ctrl'] = ctrl;
				provider['alt'] = alt;
				provider['cmd'] = cmd;
				/*provider[name] = eventPropName + ':' + eventValue + ':' + alt + ':' + ctrl + ':' + cmd;
				hasPendingChanges = true;
				pendingChanges = v;  
		}*/
		
	}
}