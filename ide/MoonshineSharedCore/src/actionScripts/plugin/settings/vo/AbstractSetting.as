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
package actionScripts.plugin.settings.vo
{   
    import flash.events.EventDispatcher;
    
    import mx.core.IVisualElement;

    public class AbstractSetting extends EventDispatcher implements ISetting
    {
		public static const PATH_SELECTED:String = "pathSelected";
        public static const MAINCLASS_SELECTED:String = "mainClassSelected";
		public static const MESSAGE_CRITICAL:String = "MESSAGE_CRITICAL";
		public static const MESSAGE_IMPORTANT:String = "MESSAGE_IMPORTANT";
		public static const MESSAGE_NORMAL:String = "MESSAGE_NORMAL";
		
		protected var hasPendingChanges:Boolean = false;
		protected var pendingChanges:*;
		protected var message:String;
		protected var messageType:String;
    	
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

        protected var _provider:Object;
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
        public function set stringValue(value:String):void
        {
            setPendingSetting(value);
        }
		
		// Not-directly used to save to disk — if we want we can use it for additional purpose.
		private var _additionalValue:Object;
		[Bindable]
		public function get additionalValue():Object
		{
			return _additionalValue;
		}
		public function set additionalValue(value:Object):void
		{
			_additionalValue = value;
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