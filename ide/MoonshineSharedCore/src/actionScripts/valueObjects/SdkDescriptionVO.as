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
    public class SdkDescriptionVO
    {
        private var _sdkPath:String;
        private var _name:String;
        private var _version:String;
        private var _build:String;
        private var _outputTargets:Array;

        public function SdkDescriptionVO(sdkPath:String, name:String,
                                         version:String, build:String, outputTargets:Array = null)
        {
            _sdkPath = sdkPath;
            _version = version;
            _build = build;
            _outputTargets = outputTargets;
            _name = getNameOfSdk(name);
        }

        public function get sdkPath():String
        {
            return _sdkPath;
        }

        public function get name():String
        {
            return _name;
        }

        public function get version():String
        {
            return _version;
        }

        public function get build():String
        {
            return _build;
        }

        public function get outputTargets():Array
        {
            return _outputTargets;
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
