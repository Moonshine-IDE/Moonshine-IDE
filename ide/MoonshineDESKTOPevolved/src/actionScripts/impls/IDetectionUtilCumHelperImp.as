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
	import actionScripts.locator.IDEModel;

	public class IDetectionUtilCumHelperImp
	{
		private static var model:IDEModel = IDEModel.getInstance();
		
		public function isDefaultSDKPresent():Boolean
		{
			if (!model.defaultSDK)
			{
				return false;
			}
			
			return true;
		}
		
		public function isJavaPresent():Boolean
		{
			var isJavaPathExists:Boolean = model.javaPathForTypeAhead && model.javaPathForTypeAhead.fileBridge.exists;
			if (!model.javaPathForTypeAhead || !isJavaPathExists)
			{
				return false;
			}
			
			return true;
		}
		
		public function isAntPresent():Boolean
		{
			if (!model.antHomePath)
			{
				return false;
			}
			
			return true;
		}
		
		public function isMavenPresent():Boolean
		{
			if (!model.mavenPath || model.mavenPath == "")
			{
				return false;
			}
			
			return true;
		}
		
		public function isSVNPresent():Boolean
		{
			return false;
		}
		
		public function isGitPresent():Boolean
		{
			return false;	
		}
	}
}