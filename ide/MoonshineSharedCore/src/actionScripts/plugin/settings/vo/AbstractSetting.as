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
    
    import mx.core.IVisualElement;
    
    import actionScripts.plugin.settings.vo.ISetting;

    public class AbstractSetting extends EventDispatcher implements ISetting
    {
		protected var hasPendingChanges:Boolean = false;
		protected var pendingChanges:*
    	
        private var _name:String;
        [Bindable]
        public function get name():String
        {
            return _name;
        }
        public function set name(v:String):void
        {
            _name = v;
            
            if (provider) validateName();
        }

        private var _label:String;
        [Bindable]
        public function get label():String
        {
            return _label;
        }
        public function set label(v:String):void
        {
            _label = v;
        }
		
        public function get renderer():IVisualElement
        {
            return null;
        }

        protected var _provider:Object
        public function get provider():Object
        {
            return _provider;
        }
        public function set provider(v:Object):void
        {
            _provider = v;
            
            if (name) validateName();
        }

        private var _defaultValue:String;
        protected function get defaultValue():String
        {
            return _defaultValue;
        }
        protected function set defaultValue(v:String):void
        {
            _defaultValue = v;
			
        }

        // Used to save to disc — if you want to serialize do so here.
        [Bindable]
        public function get stringValue():String
        {
			//if(pendingChanges) return pendingChanges.toString();
            return getSetting().toString();
        }
        public function set stringValue(v:String):void
        {
            setPendingSetting(v);
        }
		
		// Not-directly used to save to disk — if we want we can use it for additional purpose.
		private var _additionalValue:Object;
		[Bindable]
		public function get additionalValue():Object
		{
			return _additionalValue;
		}
		public function set additionalValue(v:Object):void
		{
			_additionalValue = v;
		}

        // Fetches default values from the provider
        protected function getSetting():*
        {
			if(pendingChanges != null) return pendingChanges;
            return provider[name] != null ? provider[name] : "";
        }

		protected function validateName():void
		{
			if (!hasProperty())
            {
            	throw new Error("Property " + name +" not found on settings object " + provider + ".");
            }
		}

        protected function hasProperty(... names:Array):Boolean
        {
            names = names || [name];

            if (!provider)
                return false;
            for each (var n:String in names)
            {
                if (!Object(provider).hasOwnProperty(n))
                    return false;
            }
            return true;

        }
		
        // Commits changes back to provider
        protected function setPendingSetting(v:*):void
        {
        	hasPendingChanges = true;
			pendingChanges = v;           
        }

        public function valueChanged():Boolean
        {
            return (hasPendingChanges && defaultValue !== pendingChanges);
        }
		
		public function commitChanges():void
		{
			if (!hasProperty() || !hasPendingChanges) return;
				
			provider[name] = pendingChanges;
			hasPendingChanges = false;
		}

    }
}