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
