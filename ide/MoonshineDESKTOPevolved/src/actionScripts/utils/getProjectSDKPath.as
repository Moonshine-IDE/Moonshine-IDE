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
package actionScripts.utils
{
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
	import actionScripts.plugin.groovy.grailsproject.vo.GrailsProjectVO;
	import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;

	public function getProjectSDKPath(project:ProjectVO, model:IDEModel):String
	{
		var sdkPath:String = null;
		if(project is AS3ProjectVO)
		{
			var as3Project:AS3ProjectVO = AS3ProjectVO(project);
			if(as3Project.buildOptions.customSDK)
			{
				return as3Project.buildOptions.customSDK.fileBridge.nativePath;
			}
			else if(model.defaultSDK)
			{
				return model.defaultSDK.fileBridge.nativePath;
			}
		}
		else if(project is JavaProjectVO)
		{
			var javaProject:JavaProjectVO = JavaProjectVO(project);
			if(model.javaPathForTypeAhead)
			{
				return model.javaPathForTypeAhead.fileBridge.nativePath;
			}
		}
		else if(project is GrailsProjectVO)
		{
			var grailsProject:GrailsProjectVO = GrailsProjectVO(project);
			if(model.javaPathForTypeAhead)
			{
				return model.javaPathForTypeAhead.fileBridge.nativePath;
			}
		}
		else if(project is HaxeProjectVO)
		{
			var haxeProject:HaxeProjectVO = HaxeProjectVO(project);
			if(model.haxePath)
			{
				return model.haxePath;
			}
		}
		return null;
	}
}
