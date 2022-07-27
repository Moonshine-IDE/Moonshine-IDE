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
package actionScripts.events
{
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;

    import flash.events.Event;
	
	import actionScripts.factory.FileLocation;

	public class NewProjectEvent extends Event
	{
		public static const CREATE_NEW_PROJECT:String = "createNewProjectEvent";
		public static const IMPORT_AS_NEW_PROJECT:String = "openFolderAsNewProjectEvent";

		private var _exportProject:AS3ProjectVO;
		
		public var settingsFile:FileLocation;
		public var templateDir:FileLocation;
		public var projectFileEnding:String;

		public function NewProjectEvent(type:String, projectFileEnding:String,
										settingsFile:FileLocation, templateDir:FileLocation,
										project:AS3ProjectVO = null)
		{
			this.projectFileEnding = projectFileEnding;
			this.settingsFile = settingsFile;
			this.templateDir = templateDir;
			_exportProject = project;

			super(type, false, true);
		}

		public function get isExport():Boolean
		{
			return _exportProject != null;
		}

		public function get exportProject():AS3ProjectVO
		{
			return _exportProject;
		}
	}
}