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
package actionScripts.ui.menu.vo
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;

	public class ProjectMenuTypes
	{
		public static const FLEX_AS:String = "flexASproject";
		public static const PURE_AS:String = "pureASProject";
		public static const JS_ROYALE:String = "flexJSroyale";
		public static const VISUAL_EDITOR_FLEX:String = "visualEditorFlex";
		public static const VISUAL_EDITOR_PRIMEFACES:String = "visualEditorPrimefaces";
		public static const LIBRARY_FLEX_AS:String = "libraryFlexAS";
		public static const GIT_PROJECT:String = "gitProject";
		public static const SVN_PROJECT:String = "svnProject";
		public static const JAVA:String = "java";
		public static const GRAILS:String = "grails";
		public static const HAXE:String = "haxe";
		public static const TEMPLATE:String = "template";
		
		public static var VISUAL_EDITOR_FILE_TEMPLATE_ITEMS:Array;
		public static var VISUAL_EDITOR_FILE_TEMPLATE_ITEMS_TYPE:Array;
		
		private static var resourceManager:IResourceManager = ResourceManager.getInstance();
		
		{
			VISUAL_EDITOR_FILE_TEMPLATE_ITEMS = [resourceManager.getString('resources', 'VISUALEDITOR_FLEX_FILE'), resourceManager.getString('resources', 'VISUALEDITOR_PRIMEFACES_FILE')];
			VISUAL_EDITOR_FILE_TEMPLATE_ITEMS_TYPE = [VISUAL_EDITOR_FLEX, VISUAL_EDITOR_PRIMEFACES];
		}
	}
}