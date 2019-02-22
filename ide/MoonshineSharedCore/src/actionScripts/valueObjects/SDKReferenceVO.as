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
package actionScripts.valueObjects
{
    [Bindable] public class SDKReferenceVO
    {
		//--------------------------------------------------------------------------
		//
		//  PUBLIC VARIABLES
		//
		//--------------------------------------------------------------------------
		
        public var path:String;
        public var version:String;
        public var build:String;
		public var type:String;
		public var status:String;
		
		private var _outputTargets:Array;
		public function get outputTargets():Array
		{
			return _outputTargets;
		}
		public function set outputTargets(value:Array):void
		{
			_outputTargets = value;
		}
		
		private var _name:String;
		public function get name():String
		{
			return _name;
		}
		public function set name(value:String):void
		{
			if (value != _name)
			{
				_name = getNameOfSdk(value);
			}
		}
		
        public function get isJSOnlySdk():Boolean
        {
            var hasJSOutput:Boolean;
            for each (var outputTarget:RoyaleOutputTarget in outputTargets)
            {
                hasJSOutput = outputTarget.name == "js";
            }
            
            return hasJSOutput;
        }
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE API
		//
		//--------------------------------------------------------------------------
		
        private function getNameOfSdk(providedName:String):String
        {
            var suffixName:String = "(";
            var suffixSwf:String = "";

            if (outputTargets)
            {
                var outputTargesCount:int = outputTargets.length;
                for (var i:int = 0; i < outputTargesCount; i++)
                {
                    var outputTarget:RoyaleOutputTarget = outputTargets[i];
                    if (outputTarget.flashVersion || outputTarget.airVersion)
                    {
                        suffixSwf = "FP" + outputTarget.flashVersion + " AIR" + outputTarget.airVersion + " ";
                    }
                    
                    if (outputTargesCount > 1 && outputTargesCount - 1 <= i)
                    {
                       suffixName += ", " + outputTarget.name.toUpperCase();
                    }
                    else
                    {
                        suffixName += outputTarget.name.toUpperCase();
                    }
                }
            }

            if (suffixName.length > 1)
            {
                return providedName + " " + suffixSwf + suffixName + ")";
            }

            return providedName;
        }
    }
}
