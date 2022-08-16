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
package actionScripts.plugins.ondiskproj.crud.exporter.pages
{
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.ondiskproj.vo.OnDiskProjectVO;
	import actionScripts.plugins.ondiskproj.crud.exporter.settings.RoyaleCRUDClassReferenceSettings;
	import actionScripts.valueObjects.ProjectVO;

	public class GlobalClassGenerator extends RoyalePageGeneratorBase
	{
		public function GlobalClassGenerator(project:ProjectVO, classReferenceSettings:RoyaleCRUDClassReferenceSettings, onComplete:Function=null)
		{
			super(project, null, classReferenceSettings, onComplete);
			generate();
		}
		
		override public function generate():void
		{
			var onDiskProject:OnDiskProjectVO = IDEModel.getInstance().activeProject as OnDiskProjectVO;
			pagePath = project.sourceFolder.resolvePath("classes/vo/Constants.as")
			var fileContent:String = loadPageFile();
			if (!fileContent) return;

			fileContent = fileContent.replace(
					/%AGENT_BASE_URL%/gi,
					onDiskProject.dominoBaseAgentURL ? "\""+ onDiskProject.dominoBaseAgentURL +"\"" : "null"
			);
			saveFile(fileContent);
			dispatchCompletion();
		}
	}
}