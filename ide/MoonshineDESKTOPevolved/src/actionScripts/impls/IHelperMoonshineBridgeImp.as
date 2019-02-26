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
	import actionScripts.utils.SDKUtils;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.SDKTypes;

	public class IHelperMoonshineBridgeImp implements IHelperMoonshineBridge
	{
		public function isDefaultSDKPresent():Boolean
		{
			return UtilsCore.isDefaultSDKAvailable();
		}
		
		public function isFlexSDKAvailable():Boolean
		{
			return SDKUtils.checkSDKTypeInSDKList(SDKTypes.FLEX);
		}
		
		public function isFlexJSSDKAvailable():Boolean
		{
			return SDKUtils.checkSDKTypeInSDKList(SDKTypes.FLEXJS);
		}
		
		public function isRoyaleSDKAvailable():Boolean
		{
			return SDKUtils.checkSDKTypeInSDKList(SDKTypes.ROYALE);
		}
		
		public function isFeathersSDKAvailable():Boolean
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
			return (UtilsCore.getMavenBinPath() != null);
		}
		
		public function isSVNPresent():Boolean
		{
			return UtilsCore.isSVNPresent();
		}
		
		public function isGitPresent():Boolean
		{
			return UtilsCore.isGitPresent();	
		}
	}
}