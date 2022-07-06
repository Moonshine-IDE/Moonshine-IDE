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
	import actionScripts.events.FileUploaderEvent;
	import actionScripts.events.GlobalEventDispatcher;

	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	public class FileUploader extends EventDispatcher
	{
		public var anUV:URLVariables;
		public var uploadField:String;
		public var isUploadFileSelected : Boolean;
		public var isSingleUpload:Boolean;

		private var _fileName:String;
		public function get fileName():String
		{
			return _fileName;
		}

		private var _strUploadUrl:String;
		public function set uploadUrl(strUploadUrl:String):void {
			_strUploadUrl = strUploadUrl;
		}

		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var _refAddFiles:FileReferenceList;
		private var _refUploadFile:FileReference;
		private var _arrUploadFiles:Array;
		private var _numCurrentUpload:Number = 0;

		public function FileUploader()
		{
			super();
			_arrUploadFiles = new Array();
		}

		// Called to add file(s) for upload
		public function addFiles(fileFilters:Array=null):void
		{
			//var fileFilter : FileFilter = new FileFilter("File Title", "*.ext");
			if (isSingleUpload)
			{
				_refUploadFile = new FileReference();
				_refUploadFile.addEventListener(Event.SELECT, onSelectFile, false, 0, true);
				_refUploadFile.browse(fileFilters);
			}
			else
			{
				_refAddFiles = new FileReferenceList();
				_refAddFiles.addEventListener(Event.SELECT, onSelectFile, false, 0, true);
				_refAddFiles.browse(fileFilters);
			}
		}

		// Called when a file is selected
		private function onSelectFile(event:Event):void
		{
			var arrFoundList:Array = new Array();
			_arrUploadFiles = new Array(); // For single Upload

			if (isSingleUpload)
			{
				_refUploadFile.removeEventListener(Event.SELECT, onSelectFile);

				_arrUploadFiles.push({
					name:_refUploadFile.name,
					size:formatFileSize(_refUploadFile.size),
					file:_refUploadFile});

				_fileName = _refUploadFile.name;
			}
			else
			{
				_refAddFiles.removeEventListener(Event.SELECT, onSelectFile);

				// Get list of files from fileList, make list of files already on upload list
				for (var i:Number = 0; i < _arrUploadFiles.length; i++) {
					for (var j:Number = 0; j < _refAddFiles.fileList.length; j++) {
						if (_arrUploadFiles[i].name == _refAddFiles.fileList[j].name) {
							arrFoundList.push(_refAddFiles.fileList[j].name);
							_refAddFiles.fileList.splice(j, 1);
							j--;
						}
					}
				}
				if (_refAddFiles.fileList.length >= 1) {
					for (var k:Number = 0; k < _refAddFiles.fileList.length; k++) {
						_arrUploadFiles.push({
							name:_refAddFiles.fileList[k].name,
							size:formatFileSize(_refAddFiles.fileList[k].size),
							file:_refAddFiles.fileList[k]});
					}
					//listFiles.dataProvider = _arrUploadFiles;
					//listFiles.selectedIndex = _arrUploadFiles.length - 1;
					_fileName = _arrUploadFiles[_arrUploadFiles.length - 1].name;
				}
				/* if (arrFoundList.length >= 1) {
					Alert.show("The file(s): \n\n• " + arrFoundList.join("\n• ") + "\n\n...are already on the upload list. Please change the filename(s) or pick a different file.", "File(s) already on list");
				} */
			}

			updateProgBar();
			isUploadFileSelected = true;
			dispatchEvent(new FileUploaderEvent(FileUploaderEvent.EVENT_UPLOAD_LOADED, _fileName));
		}

		// Called to format number to file size
		private function formatFileSize(numSize:Number):String
		{
			var strReturn:String;
			numSize = Number(numSize / 1000);
			strReturn = String(numSize.toFixed(1) + " KB");
			if (numSize > 1000) {
				numSize = numSize / 1000;
				strReturn = String(numSize.toFixed(1) + " MB");
				if (numSize > 1000) {
					numSize = numSize / 1000;
					strReturn = String(numSize.toFixed(1) + " GB");
				}
			}
			return strReturn;
		}

		// Called to upload file based on current upload number
		public function startUpload():void {

			if (_arrUploadFiles.length > 0)
			{
				var request:URLRequest = new URLRequest();
				//request.data = anUV;
				request.url = _strUploadUrl;
				request.method = URLRequestMethod.POST;
				_refUploadFile = new FileReference();
				_refUploadFile = _arrUploadFiles[_arrUploadFiles.length - 1].file;
				_refUploadFile.addEventListener(ProgressEvent.PROGRESS, onUploadProgress);
				_refUploadFile.addEventListener(Event.COMPLETE, onUploadComplete);
				_refUploadFile.addEventListener(IOErrorEvent.IO_ERROR, onUploadIoError);
				_refUploadFile.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onUploadSecurityError);
				_refUploadFile.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, uploadCompleteDataHandler);
				_refUploadFile.addEventListener(HTTPStatusEvent.HTTP_STATUS, onUploadFails);
				_refUploadFile.upload(request, uploadField);
			}
		}

		private function onUploadFails( event:HTTPStatusEvent ) : void {

			trace(event);
			dispatchEvent(new FileUploaderEvent(FileUploaderEvent.EVENT_UPLOAD_ERROR, event.toString()));
			//clearUpload( true );
			//dispatchEvent( new GeneralEvents(GeneralEvents.UPLOAD_ERROR, "Error!\nUpload failed to connect!") );
		}

		private function uploadCompleteDataHandler(event:DataEvent):void {

			//var tmpXML : XMLList = XMLList(event.data);
			clearUpload(true);
			this.dispatchEvent(new FileUploaderEvent(FileUploaderEvent.EVENT_UPLOAD_COMPLETE_DATA, event.data));

			// checking the session status
			//if ( (tmpXML..ErrorMessage != "") ) {

			//dispatchEvent( new GeneralEvents(GeneralEvents.UPLOAD_RESULT, tmpXML..ErrorMessage) );

			//} else {

			//dispatchEvent( new GeneralEvents(GeneralEvents.UPLOAD_RESULT_SUCCESS, tmpXML..successMessage) );
			clearUploadHolding();
			//}
		}

		// Cancel and clear eventlisteners on last upload
		public function clearUpload( clearUploadComplete:Boolean=false ):void {

			if ( !_refUploadFile ) return;

			_refUploadFile.removeEventListener(ProgressEvent.PROGRESS, onUploadProgress);
			_refUploadFile.removeEventListener(Event.COMPLETE, onUploadComplete);
			_refUploadFile.removeEventListener(IOErrorEvent.IO_ERROR, onUploadIoError);
			_refUploadFile.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onUploadSecurityError);
			_refUploadFile.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onUploadFails);
			if ( clearUploadComplete ) _refUploadFile.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, uploadCompleteDataHandler);
			_refUploadFile.cancel();
			updateProgBar();
		}

		// mark as no 'holding' uploads
		private function clearUploadHolding() : void {

			_numCurrentUpload = 0;
			_arrUploadFiles = new Array();
			updateProgBar();
			_fileName = "";
		}

		// Called on upload cancel
		private function onUploadCanceled():void {
			clearUpload(true);
			dispatchEvent(new FileUploaderEvent(FileUploaderEvent.EVENT_UPLOAD_CANCELED));
		}

		// Get upload progress
		private function onUploadProgress(event:ProgressEvent):void
		{
			var numPerc:Number = Math.round((event.bytesLoaded / event.bytesTotal) * 100);
			dispatchEvent(new FileUploaderEvent(FileUploaderEvent.EVENT_UPLOAD_PROGRESS, numPerc));
			//updateProgBar(numPerc);
		}

		// Update progBar
		private function updateProgBar(numPerc:Number = 0):void {
			//var strLabel:String = (_numCurrentUpload + 1) + "/" + _arrUploadFiles.length;
			var strLabel:String = _arrUploadFiles.length.toString();
			strLabel = (_numCurrentUpload + 1 <= _arrUploadFiles.length && numPerc > 0 && numPerc < 100) ? numPerc + "% - " + strLabel : strLabel;
			strLabel = (_numCurrentUpload + 1 == _arrUploadFiles.length && numPerc == 100) ? "Upload Complete - " + strLabel : strLabel;
			strLabel = (_arrUploadFiles.length == 0) ? "" : strLabel;
			/*progBar.label = strLabel;
			trace(numPerc);
			progBar.setProgress(numPerc, 100);
			progBar.validateNow();*/
		}

		// Called on upload complete
		private function onUploadComplete(event:Event):void {
			_numCurrentUpload++;
			dispatchEvent(new FileUploaderEvent(FileUploaderEvent.EVENT_UPLOAD_COMPLETE));
			/* if (_numCurrentUpload < _arrUploadFiles.length) {
				startUpload();
			} else { */
			clearUpload();
			//}
		}

		// Called on upload io error
		private function onUploadIoError(event:IOErrorEvent):void {
			clearUpload(true);
			dispatchEvent(new FileUploaderEvent(FileUploaderEvent.EVENT_UPLOAD_ERROR, event.text));
		}

		// Called on upload security error
		private function onUploadSecurityError(event:SecurityErrorEvent):void {
			clearUpload(true);
			dispatchEvent(new FileUploaderEvent(FileUploaderEvent.EVENT_UPLOAD_ERROR, event.text));
		}
	}
}
