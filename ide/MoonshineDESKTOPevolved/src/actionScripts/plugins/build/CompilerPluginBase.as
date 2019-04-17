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
package actionScripts.plugins.build
{
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
	import actionScripts.valueObjects.ProjectVO;

	public class CompilerPluginBase extends PluginBase implements IPlugin
	{
		private var invalidPaths:Array;
		
		protected function checkProjectForInvalidPaths(project:ProjectVO):void
		{
			if (project is AS3ProjectVO)
			{
				validateAS3VOPaths(project as AS3ProjectVO);
			}
			else if (project is JavaProjectVO)
			{
				validateJavaVOPaths(project as JavaProjectVO);
			}
		}
		
		protected function onProjectPathsValidated(paths:Array):void
		{
			
		}
		
		private function validateAS3VOPaths(project:AS3ProjectVO):void
		{
			var tmpLocation:FileLocation;
			invalidPaths = [];
			
			checkPathFileLocation(project.folderLocation, "Location");
			if (project.sourceFolder) checkPathFileLocation(project.sourceFolder, "Source Folder");
			if (project.visualEditorSourceFolder) checkPathFileLocation(project.visualEditorSourceFolder, "Source Folder");
			
			if (project.buildOptions.customSDK)
			{
				checkPathFileLocation(project.buildOptions.customSDK, "Custom SDK");
			}
			
			for each (tmpLocation in project.classpaths)
			{
				checkPathFileLocation(tmpLocation, "Classpath");
			}
			for each (tmpLocation in project.resourcePaths)
			{
				checkPathFileLocation(tmpLocation, "Resource");
			}
			for each (tmpLocation in project.externalLibraries)
			{
				checkPathFileLocation(tmpLocation, "External Library");
			}
			for each (tmpLocation in project.libraries)
			{
				checkPathFileLocation(tmpLocation, "Library");
			}
			for each (tmpLocation in project.nativeExtensions)
			{
				checkPathFileLocation(tmpLocation, "Extension");
			}
			for each (tmpLocation in project.runtimeSharedLibraries)
			{
				checkPathFileLocation(tmpLocation, "Shared Library");
			}
			
			onProjectPathsValidated((invalidPaths.length > 0) ? invalidPaths : null);
		}
		
		private function validateJavaVOPaths(project:JavaProjectVO):void
		{
			var tmpLocation:FileLocation;
			invalidPaths = [];
			
			checkPathFileLocation(project.folderLocation, "Location");
			if (project.sourceFolder) checkPathFileLocation(project.sourceFolder, "Source Folder");
			
			for each (tmpLocation in project.classpaths)
			{
				checkPathFileLocation(tmpLocation, "Classpath");
			}
			
			onProjectPathsValidated((invalidPaths.length > 0) ? invalidPaths : null);
		}
		
		private function checkPathString(value:String, type:String):void
		{
			if (!model.fileCore.isPathExists(value))
			{
				invalidPaths.push(type +": "+ value);
			}
		}
		
		private function checkPathFileLocation(value:FileLocation, type:String):void
		{
			if (!value.fileBridge.exists)
			{
				invalidPaths.push(type +": "+ value.fileBridge.nativePath);
			}
		}
	}
}