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
	import flash.filesystem.File;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.utils.FileUtils;
	
	import view.dominoFormBuilder.vo.DominoFormVO;

	public class RoyalePageGenerator
	{
		protected var projectPath:FileLocation;
		protected var pagePath:FileLocation;
		protected var form:DominoFormVO;
		
		protected function get pageRelativePathString():String		{	return null;	}
		
		public function RoyalePageGenerator(projectPath:FileLocation, form:DominoFormVO)
		{
			this.projectPath = projectPath;
			this.form = form;
			
			if (pageRelativePathString) 
				pagePath = projectPath.fileBridge.resolvePath(pageRelativePathString);
		}
		
		public function generate():void
		{
			
		}
		
		public function loadPageFile():String
		{
			if (pagePath && pagePath.fileBridge.exists)
			{
				return (pagePath.fileBridge.read() as String);
			}
			
			return null;
		}
		
		protected function saveFile(content:String):void
		{
			FileUtils.writeToFileAsync(pagePath.fileBridge.getFile as File, content, onSuccessWriting, onFailWriting);
			
			/*
			 * @local
			 */
			function onSuccessWriting():void
			{
				
			}
			function onFailWriting(message:String):void
			{
				
			}
		}
	}
}