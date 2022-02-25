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
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.plugins.ondiskproj.crud.exporter.settings.RoyaleCRUDClassReferenceSettings;
	import actionScripts.utils.FileUtils;
	import actionScripts.valueObjects.ProjectVO;
	
	import view.dominoFormBuilder.vo.DominoFormVO;

	public class RoyalePageGeneratorBase extends EventDispatcher
	{
		protected var pagePath:FileLocation;
		protected var form:DominoFormVO;
		protected var project:ProjectVO;
		protected var classReferenceSettings:RoyaleCRUDClassReferenceSettings;
		protected var onCompleteHandler:Function;
		
		protected function get pageRelativePathString():String		{	return null;	}
		
		public function RoyalePageGeneratorBase(project:ProjectVO, form:DominoFormVO, classReferenceSettings:RoyaleCRUDClassReferenceSettings, onComplete:Function=null)
		{
			this.project = project;
			this.form = form;
			this.classReferenceSettings = classReferenceSettings;
			this.onCompleteHandler = onComplete;
			
			if (pageRelativePathString) 
				pagePath = project.sourceFolder.fileBridge.resolvePath(pageRelativePathString);
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

		protected function dispatchCompletion():void
		{
			if (onCompleteHandler != null)
			{
				onCompleteHandler(this);
				onCompleteHandler = null;
			}
		}
	}
}