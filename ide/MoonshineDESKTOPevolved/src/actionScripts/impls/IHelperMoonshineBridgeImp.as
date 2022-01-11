////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.impls
{
	import actionScripts.interfaces.IHelperMoonshineBridge;
	import actionScripts.locator.IDEModel;
	import actionScripts.utils.MSDKIdownloadUtil;
	import actionScripts.utils.SDKUtils;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ComponentTypes;

	public class IHelperMoonshineBridgeImp implements IHelperMoonshineBridge
	{
		public function isDefaultSDKPresent():Boolean
		{
			return UtilsCore.isDefaultSDKAvailable();
		}
		
		public function isFlexSDKAvailable():Object
		{
			return SDKUtils.checkSDKTypeInSDKList(ComponentTypes.TYPE_FLEX);
		}
		
		public function isFlexHarmanSDKAvailable():Object
		{
			return SDKUtils.checkSDKTypeInSDKList(ComponentTypes.TYPE_FLEX_HARMAN);
		}
		
		public function isFlexJSSDKAvailable():Object
		{
			return SDKUtils.checkSDKTypeInSDKList(ComponentTypes.TYPE_FLEXJS);
		}
		
		public function isRoyaleSDKAvailable():Object
		{
			return SDKUtils.checkSDKTypeInSDKList(ComponentTypes.TYPE_ROYALE);
		}
		
		public function isFeathersSDKAvailable():Object
		{
			return SDKUtils.checkSDKTypeInSDKList(ComponentTypes.TYPE_FEATHERS);
		}
		
		public function isJavaPresent():Boolean
		{
			return UtilsCore.isJavaForTypeaheadAvailable();
		}
		
		public function isJava8Present():Boolean
		{
			return UtilsCore.isJava8Present();
		}
		
		public function isAntPresent():Boolean
		{
			return UtilsCore.isAntAvailable();
		}
		
		public function isMavenPresent():Boolean
		{
			return UtilsCore.isMavenAvailable();
		}

		public function isGradlePresent():Boolean
		{
			return UtilsCore.isGradleAvailable();
		}
		
		public function isGrailsPresent():Boolean
		{
			return UtilsCore.isGrailsAvailable();
		}
		
		public function isSVNPresent():Boolean
		{
			return UtilsCore.isSVNPresent();
		}
		
		public function isGitPresent():Boolean
		{
			return UtilsCore.isGitPresent();	
		}
		
		public function isNodeJsPresent():Boolean
		{
			return UtilsCore.isNodeAvailable();
		}
		
		public function isNotesDominoPresent():Boolean
		{
			return UtilsCore.isNotesDominoAvailable();
		}

		public function isVagrantAvailable():Boolean
		{
			return UtilsCore.isVagrantAvailable();
		}

		public function isMacPortsAvailable():Boolean
		{
			return UtilsCore.isMacPortsAvailable();
		}

		public function runOrDownloadSDKInstaller():void
		{
			MSDKIdownloadUtil.getInstance().runOrDownloadSDKInstaller();
		}

		private var _playerglobalExists:Boolean;
		public function get playerglobalExists():Boolean
		{
			return _playerglobalExists;
		}

		public function set playerglobalExists(value:Boolean):void
		{
			_playerglobalExists = value;
		}
		
		public function get javaVersionForTypeahead():String
		{
			return IDEModel.getInstance().javaVersionForTypeAhead;
		}
		
		public function get javaVersionInJava8Path():String
		{
			return IDEModel.getInstance().javaVersionInJava8Path;
		}
	}
}