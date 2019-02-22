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
	import actionScripts.factory.FileLocation;
	import actionScripts.utils.UtilsCore;

    [Bindable] public class SDKReferenceVO
    {
		private static const JS_SDK_COMPILER_NEW:String = "js/bin/mxmlc";
		private static const JS_SDK_COMPILER_OLD:String = "bin/mxmlc";
		private static const FLEX_SDK_COMPILER:String = "bin/fcsh";
		
		//--------------------------------------------------------------------------
		//
		//  PUBLIC VARIABLES
		//
		//--------------------------------------------------------------------------
		
        public var version:String;
        public var build:String;
		public var type:String;
		public var status:String;
		
        private var _path:String;
		public function set path(value:String):void
		{
			if (_path != value)
			{
				_path = value;
				findType();
			}
		}
		public function get path():String
		{
			return _path;
		}
		
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
		
		private var _fileLocation:FileLocation;
		public function get fileLocation():FileLocation
		{
			if (!_fileLocation) _fileLocation = new FileLocation(path);
			return _fileLocation;
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
		
		private function findType():void
		{
			var isTypeFound:Boolean = isFlex();
			if (isTypeFound) 
			{
				type = SDKTypes.FLEX;
				return;
			}
			
			isTypeFound = isFlexJS();
			if (isTypeFound) 
			{
				type = SDKTypes.FLEXJS;
				return;
			}
		}
		
		private function isFlexJS():Boolean
		{
			// determine if the sdk version is lower than 0.8.0 or not
			var isFlexJSAfter7:Boolean = UtilsCore.isNewerVersionSDKThan(7, currentSDK.nativePath);
			
			var compilerExtension:String = ConstantsCoreVO.IS_MACOS ? "" : ".bat";
			var mxmlcFile:File = fileLocation.resolvePath(JS_SDK_COMPILER_NEW + compilerExtension);
			if (!mxmlcFile.exists)
			{
				return true;
			}
			
			// @fix
			// https://github.com/prominic/Moonshine-IDE/issues/26
			// We've found js/bin/mxmlc compiletion do not produce
			// valid swf with prior 0.8 version; we shall need following
			// executable for version less than 0.8
			if (!isFlexJSAfter7) mxmlcFile = fileLocation.resolvePath(JS_SDK_COMPILER_OLD + compilerExtension);
			if (mxmlcFile.exists)
			{
				return true;
			}
			
			return false;
		}
		
		private function isFlex():Boolean
		{
			var compilerExtension:String = ConstantsCoreVO.IS_MACOS ? "" : ".bat";
			var fcshFile:File = fileLocation.resolvePath(FLEX_SDK_COMPILER + compilerExtension);
			if (!fcshFile.exists)
			{
				return true;
			}
			
			return false;
		}
    }
}
