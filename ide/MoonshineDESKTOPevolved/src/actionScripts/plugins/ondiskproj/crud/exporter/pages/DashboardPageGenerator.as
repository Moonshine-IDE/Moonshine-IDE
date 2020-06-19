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
	import actionScripts.factory.FileLocation;
	import view.dominoFormBuilder.vo.DominoFormVO;
	
	public class DashboardPageGenerator extends RoyalePageGeneratorBase
	{
		override protected function get pageRelativePathString():String		{	return "src/views/general/Dashboard.mxml";	}
		
		public function DashboardPageGenerator(projectPath:FileLocation, form:DominoFormVO)
		{
			super(projectPath, form);
			generate();
		}
		
		override public function generate():void
		{
			var fileContent:String = loadPageFile();
			if (!fileContent) return;
		}
	}
}