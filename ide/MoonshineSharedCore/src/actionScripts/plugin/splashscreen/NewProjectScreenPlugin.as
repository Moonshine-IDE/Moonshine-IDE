
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
package actionScripts.plugin.splashscreen
{
	import components.views.project.NewProjectScreen;

	import flash.events.Event;
    import mx.collections.ArrayCollection;
    import actionScripts.plugin.IMenuPlugin;
    import actionScripts.plugin.PluginBase;
    import actionScripts.ui.IContentWindow;
    import actionScripts.ui.menu.vo.MenuItem;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.TemplateVO;


	public class NewProjectScreenPlugin extends PluginBase implements IMenuPlugin
	{
		override public function get name():String			{ return "New Project Screen Plugin"; }
		override public function get author():String		{ return "Moonshine Project Team"; }
		override public function get description():String	{ return "Shows all possibility to create new projects"; }

		public static const EVENT_SHOW_NEWPROJECT_SCREEN:String = "eventShowNewProjectScreen";

		[Bindable]
		public var projectsTemplates:ArrayCollection;

		override public function activate():void
		{
			super.activate();

			dispatcher.addEventListener(EVENT_SHOW_NEWPROJECT_SCREEN, newProjectScreenHandler);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			
			dispatcher.removeEventListener(EVENT_SHOW_NEWPROJECT_SCREEN, newProjectScreenHandler);
		}
		
		public function getMenu():MenuItem
		{
			// Since plugin will be activated if needed we can return null to block menu
			if( !_activated ) return null;
			
			return UtilsCore.getRecentProjectsMenu();
		}

		protected function newProjectScreenHandler(event:Event):void
		{
			showNewProjectScreen();
		}

        private function showNewProjectScreen():void
        {
            for each (var tab:IContentWindow in model.editors)
            {
                if (tab is NewProjectScreen) return;
            }

			var newProject:NewProjectScreen = new NewProjectScreen();
			newProject.plugin = this;

            model.editors.addItem(newProject);
			
            // following will load template data from local for desktop
            if (ConstantsCoreVO.IS_AIR)
            {
                projectsTemplates = getProjectsTemplatesForNewProjectScreen();
            }
        }

		private function getProjectsTemplatesForNewProjectScreen():ArrayCollection
		{
			var templates:Array = ConstantsCoreVO.TEMPLATES_PROJECTS.source.filter(filterProjectsTemplates);
			var specialTemplates:Array = ConstantsCoreVO.TEMPLATES_PROJECTS_SPECIALS.source.filter(filterProjectsTemplates);

			return new ArrayCollection(templates.concat(specialTemplates));
		}

		private function filterProjectsTemplates(item:TemplateVO, index:int, arr:Array):Boolean
		{
			return ConstantsCoreVO.EXCLUDE_PROJECT_TEMPLATES_IN_MENU.indexOf(item.title) == -1;
        }
    }
}