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
	import mx.core.IVisualElement;
	
	import actionScripts.plugin.settings.renderers.StringListRenderer;
	import mx.collections.ArrayCollection;
	
	public class StringListSetting extends AbstractSetting
	{
		public static const VALUE_UPDATED:String = "valueUpdated";
		
		protected var copiedStrings:ArrayCollection;
		
		private var restrict:String;
		private var rdr:StringListRenderer;

		private var _isEditable:Boolean = true;
		
		public function StringListSetting(provider:Object, name:String, label:String, restrict:String=null)
		{
			super();
			this.provider = provider;
			this.name = name;
			this.label = label;
			this.restrict = restrict;
			defaultValue = stringValue;
		}

		[Bindable]
		public function get stringListValue():Vector.<String>
		{
			return getSetting().toString();
		}
		public function set stringListValue(value:Vector.<String>):void
		{
			setPendingSetting(value);
		}
		
		override public function get renderer():IVisualElement
		{
			rdr = new StringListRenderer();
			if (restrict)
			{
				rdr.restrict = restrict;
			}

			rdr.setting = this;
			rdr.enabled = isEditable;
			rdr.setMessage(message, messageType);
			return rdr;
		}
		
		public function setMessage(value:String, type:String=MESSAGE_NORMAL):void
		{
			if (rdr)
			{
				rdr.setMessage(value, type);
			}
			else
			{
				message = value;
				messageType = type;
			}
		}
		
		public function set isEditable(value:Boolean):void
		{
			_isEditable = value;
			if (rdr) 
			{
				rdr.enabled = _isEditable;
			}
		}

		public function get isEditable():Boolean
		{
			return _isEditable;
		}
		
		public function get strings():ArrayCollection
		{
			if (!copiedStrings)
			{
				if (getSetting() == null) return null;
				
				copiedStrings = new ArrayCollection();
				for each (var s:String in getSetting())
				{
					copiedStrings.addItem(new StringListItemVO(s));
				}
			}
			return copiedStrings;
		}
		
		override public function valueChanged():Boolean
		{
			if (!copiedStrings) return false;
			
			var matches:Boolean = true;
			var itemMatch:Boolean;
			for each (var s1:String in getSetting())
			{
				itemMatch = false;
				for each (var item:StringListItemVO in copiedStrings)
				{
					if(s1 == item.string)
					{
						itemMatch = true;
					}
				}
				
				if (!itemMatch)
				{
					matches = false;
					break;
				}
			}
			
			// Length mismatch?
			if (getSetting() && copiedStrings)
			{
				if (getSetting().length != copiedStrings.length)
				{
					matches = false;	
				}
			}
			
			return !matches;
		}
        
        override public function commitChanges():void
		{
			if (!hasProperty() || !valueChanged()) return;
			
			var pending:Vector.<String> = new Vector.<String>();
			for each (var item:StringListItemVO in copiedStrings)
			{
				var string:String = item.string;
				if (string != null && string.length > 0)
				{
					pending.push(string);
				}
			}
			
			provider[name] = pending;
			hasPendingChanges = false;
		}
	}
}