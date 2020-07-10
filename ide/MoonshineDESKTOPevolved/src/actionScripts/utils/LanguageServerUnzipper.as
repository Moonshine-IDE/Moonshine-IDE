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
package actionScripts.utils
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.net.SharedObject;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	import actionScripts.events.GeneralEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.LanguageServerUnzipperEvent;
	import actionScripts.locator.IDEModel;
	import actionScripts.valueObjects.HelperConstants;
	
	import components.popup.LanguageServerUnzipProgressPopup;

	public class LanguageServerUnzipper extends EventDispatcher
	{
		protected var targetUnzipDirectory:String = "elements";
		protected var queues:Array = [
			"elements/as3mxml-language-server.zip", 
			"elements/chrome-debug-adapter.zip", 
			"elements/firefox-debug-adapter.zip"
		];
		
		private var model:IDEModel = IDEModel.getInstance();
		private var progressPopup:LanguageServerUnzipProgressPopup;
		
		public function LanguageServerUnzipper() {}
		
		public function checkAndUnzip():void
		{
			var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);
			if (cookie.data.hasOwnProperty('revision') && cookie.data['revision'] == model.revision)
			{
				notifyCompletion();
				return;
			}
			
			initiateProcess();
		}
		
		protected function notifyCompletion():void
		{
			PopUpManager.removePopUp(progressPopup);
			GlobalEventDispatcher.getInstance().dispatchEvent(new LanguageServerUnzipperEvent(LanguageServerUnzipperEvent.EVENT_LANGUAGE_SERVER_UNZIP_COMPLETES));
		}
		
		protected function initiateProcess():void
		{
			progressPopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, LanguageServerUnzipProgressPopup, true) as LanguageServerUnzipProgressPopup;
			PopUpManager.centerPopUp(progressPopup);
			
			startUnzip();
		}
		
		protected function startUnzip():void
		{
			var unzip:Unzip = new Unzip(
				File.applicationDirectory.resolvePath(queues[0])
			);
			unzip.addEventListener(Unzip.FILE_LOAD_SUCCESS, onFileLoadedInMemory);
			
			/*
			* @local
			*/
			function onFileLoadedInMemory(event:Event):void
			{
				event.target.removeEventListener(Unzip.FILE_LOAD_SUCCESS, onFileLoadedInMemory);
			
				var tmpTargetDirectory:File = File.applicationDirectory.resolvePath(
					(targetUnzipDirectory ? targetUnzipDirectory +"/" : "") + FileUtils.getFileNameWithoutExtension(unzip.zipFile)
				);
				if (!tmpTargetDirectory.exists)
				{
					Alert.show(tmpTargetDirectory.nativePath);
					tmpTargetDirectory.createDirectory();
				}
				
				unzip.addEventListener(Unzip.FILE_PROGRESSED_COUNT, onFilesUnzipped);
				unzip.unzipTo(tmpTargetDirectory, onUnzipCompleted);
			}
			function onUnzipCompleted(destination:File):void
			{
				dispatchEvent(new GeneralEvent(GeneralEvent.DONE));
			}
			function onFilesUnzipped(event:GeneralEvent):void
			{
				trace("------------------ "+ event.value.toString());
			}
		}
	}
}