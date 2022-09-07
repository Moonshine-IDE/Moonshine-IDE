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
package actionScripts.plugins.ondiskproj.crud.exporter.components
{
	public class RoyaleScrollableSectionContent extends RoyaleElemenetBase
	{
		public static function toCode(componentName:String, ambiguousName:String = ""):String
		{
			var scrollableSectionContent:String = readTemplate("elements/templates/royaleTabularCRUD/elements/ScrollableSectionContent.template");
			var viewComponent:String = readTemplate("elements/templates/royaleTabularCRUD/elements/ViewComponent.template");
			
			viewComponent = viewComponent.replace(/%ViewComponentName%/ig, componentName);
			viewComponent = viewComponent.replace(/%Namespace%/ig, componentName);
			
			scrollableSectionContent = scrollableSectionContent.replace(/%ViewComponentName%/ig, ambiguousName + componentName);
			scrollableSectionContent = scrollableSectionContent.replace(/%ViewComponent%/ig, viewComponent);
			
			return scrollableSectionContent;
		}
	}
}