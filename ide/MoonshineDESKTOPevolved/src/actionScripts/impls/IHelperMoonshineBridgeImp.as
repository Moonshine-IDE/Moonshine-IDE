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
	import actionScripts.utils.MSDKIdownloadUtil;
	import actionScripts.utils.SDKUtils;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.SDKTypes;

	public class IHelperMoonshineBridgeImp implements IHelperMoonshineBridge
	{
		public function isDefaultSDKPresent():Boolean
		{
			return UtilsCore.isDefaultSDKAvailable();
		}
		
		public function isFlexSDKAvailable():Object
		{
			return SDKUtils.checkSDKTypeInSDKList(SDKTypes.FLEX);
		}
		
		public function isFlexJSSDKAvailable():Object
		{
			return SDKUtils.checkSDKTypeInSDKList(SDKTypes.FLEXJS);
		}
		
		public function isRoyaleSDKAvailable():Object
		{
			return SDKUtils.checkSDKTypeInSDKList(SDKTypes.ROYALE);
		}
		
		public function isFeathersSDKAvailable():Object
		{
			return SDKUtils.checkSDKTypeInSDKList(SDKTypes.FEATHERS);
		}
		
		public function isJavaPresent():Boolean
		{
			return UtilsCore.isJavaForTypeaheadAvailable();
		}
		
		public function isAntPresent():Boolean
		{
			return UtilsCore.isAntAvailable();
		}
		
		public function isMavenPresent():Boolean
		{
			return UtilsCore.isMavenAvailable();
		}
		
		public function isSVNPresent():Boolean
		{
			return UtilsCore.isSVNPresent();
		}
		
		public function isGitPresent():Boolean
		{
			return UtilsCore.isGitPresent();	
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
	}
}