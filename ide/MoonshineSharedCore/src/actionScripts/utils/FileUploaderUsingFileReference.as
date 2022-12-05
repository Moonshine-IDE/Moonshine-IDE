////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
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

	public class FileUploaderUsingFileReference extends EventDispatcher
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

		public function FileUploaderUsingFileReference()
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
		public function startUpload():void
		{
			if (_arrUploadFiles.length > 0)
			{
				var request:URLRequest = new URLRequest();
				//request.data = anUV;
				request.url = _strUploadUrl;
				request.method = URLRequestMethod.POST;
				_refUploadFile = new FileReference();
				_refUploadFile = _arrUploadFiles[_arrUploadFiles.length - 1].file;
				configureListeners(true);
				_refUploadFile.upload(request, uploadField);
			}
		}

		private function configureListeners(listen:Boolean, clearUploadComplete:Boolean=false):void
		{
			if (listen)
			{
				_refUploadFile.addEventListener(Event.CANCEL, onUploadCanceled);
				_refUploadFile.addEventListener(ProgressEvent.PROGRESS, onUploadProgress);
				_refUploadFile.addEventListener(Event.COMPLETE, onUploadComplete);
				_refUploadFile.addEventListener(IOErrorEvent.IO_ERROR, onUploadIoError);
				_refUploadFile.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onUploadSecurityError);
				_refUploadFile.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, uploadCompleteDataHandler);
				_refUploadFile.addEventListener(HTTPStatusEvent.HTTP_STATUS, onUploadFails);
			}
			else if (_refUploadFile)
			{
				_refUploadFile.removeEventListener(Event.CANCEL, onUploadCanceled);
				_refUploadFile.removeEventListener(ProgressEvent.PROGRESS, onUploadProgress);
				_refUploadFile.removeEventListener(Event.COMPLETE, onUploadComplete);
				_refUploadFile.removeEventListener(IOErrorEvent.IO_ERROR, onUploadIoError);
				_refUploadFile.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onUploadSecurityError);
				if ( clearUploadComplete ) _refUploadFile.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, uploadCompleteDataHandler);
				_refUploadFile.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onUploadFails);
				_refUploadFile = null;

				updateProgBar();
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
			configureListeners(false, true);
			this.dispatchEvent(new FileUploaderEvent(FileUploaderEvent.EVENT_UPLOAD_COMPLETE_DATA, event.data));

			// checking the session status
			//if ( (tmpXML..ErrorMessage != "") ) {

			//dispatchEvent( new GeneralEvents(GeneralEvents.UPLOAD_RESULT, tmpXML..ErrorMessage) );

			//} else {

			//dispatchEvent( new GeneralEvents(GeneralEvents.UPLOAD_RESULT_SUCCESS, tmpXML..successMessage) );
			clearUploadHolding();
			//}
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
			configureListeners(false, true);
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
			configureListeners(false);
			//}
		}

		// Called on upload io error
		private function onUploadIoError(event:IOErrorEvent):void {
			configureListeners(false, true);
			dispatchEvent(new FileUploaderEvent(FileUploaderEvent.EVENT_UPLOAD_ERROR, event.text));
		}

		// Called on upload security error
		private function onUploadSecurityError(event:SecurityErrorEvent):void {
			configureListeners(false, true);
			dispatchEvent(new FileUploaderEvent(FileUploaderEvent.EVENT_UPLOAD_ERROR, event.text));
		}
	}
}
