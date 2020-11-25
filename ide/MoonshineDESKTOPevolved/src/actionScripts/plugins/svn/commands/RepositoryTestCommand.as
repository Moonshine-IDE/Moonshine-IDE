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
package actionScripts.plugins.svn.commands
{
	import flash.events.Event;
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;
	
	import actionScripts.events.ProjectEvent;
	import actionScripts.ui.menu.MenuPlugin;
	import actionScripts.ui.menu.vo.ProjectMenuTypes;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.VersionControlTypes;
	
	public class RepositoryTestCommand extends InfoCommand
	{
		private var project:ProjectVO;
		
		public function RepositoryTestCommand(project:ProjectVO, executable:File, root:File)
		{
			this.project = project;
			
			super(executable, root);
			request(root, false);
		}
		
		override protected function svnExit(event:NativeProcessExitEvent):void
		{
			if (event.exitCode == 0)
			{
				project.menuType += ","+ ProjectMenuTypes.SVN_PROJECT;
				project.hasVersionControlType = VersionControlTypes.SVN;
			}
			
			// following will enable/disable Moonshine top menus based on project
			dispatcher.dispatchEvent(new Event(MenuPlugin.REFRESH_MENU_STATE));
			dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.ACTIVE_PROJECT_CHANGED, project));
			
			removeListeners();
		}
	}
}