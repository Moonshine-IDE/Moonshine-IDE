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
package actionScripts.utils.uploadUsingURLLoader
{
	import actionScripts.events.FileUploaderEvent;
	import actionScripts.factory.FileLocation;

	import flash.events.Event;
	import flash.events.EventDispatcher;

	import flash.events.IOErrorEvent;

	import flash.events.SecurityErrorEvent;

	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;

	import flash.utils.ByteArray;

	import flash.utils.Dictionary;

	public class FileUploaderUsingURLLoader extends EventDispatcher
	{
		public function FileUploaderUsingURLLoader()
		{
			super();
		}

        public function upload(file:FileLocation, toURL:String, uploadFieldName:String, urlVariables:Dictionary = null):void
		{
			var readedBytes:ByteArray = file.fileBridge.readByteArray;

			var variables:URLVariables = new URLVariables();
			variables[uploadFieldName] = new URLFileVariable(readedBytes, file.name);

			var request:URLRequest = new URLRequestBuilder(variables).build();
			request.url = toURL;

			var loader:URLLoader = new URLLoader();
			configListeners(loader);

			try
			{
				loader.load(request);
			}
			catch (error:Error)
			{
				trace("Unable to dispatch load request: " + error);
			}
		}

		private function configListeners(loader:URLLoader):void
		{
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onURLLoaderSecurityError, false, 0, true);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onURLLoaderIOError, false, 0, true);
			loader.addEventListener(Event.COMPLETE, onURLLoaderSuccess, false, 0, true);
		}

		private function removeListeners(loader:URLLoader):void
		{
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onURLLoaderSecurityError);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onURLLoaderIOError);
			loader.removeEventListener(Event.COMPLETE, onURLLoaderSuccess);
			loader = null;
		}

		private function onURLLoaderSuccess(event:Event):void
		{
			dispatchEvent(new FileUploaderEvent(FileUploaderEvent.EVENT_UPLOAD_COMPLETE, (event.target as URLLoader).data));
			removeListeners(event.target as URLLoader);
		}

		private function onURLLoaderSecurityError(event:SecurityErrorEvent):void
		{
			dispatchEvent(new FileUploaderEvent(FileUploaderEvent.EVENT_UPLOAD_ERROR, event.text));
			removeListeners(event.target as URLLoader);
		}

		private function onURLLoaderIOError(event:IOErrorEvent):void
		{
			dispatchEvent(new FileUploaderEvent(FileUploaderEvent.EVENT_UPLOAD_ERROR, event.text));
			removeListeners(event.target as URLLoader);
		}
	}
}
