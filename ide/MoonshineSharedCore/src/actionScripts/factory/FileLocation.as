////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
package actionScripts.factory
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import actionScripts.controllers.DataAgent;
	import actionScripts.interfaces.IFileBridge;
	import actionScripts.locator.IDEModel;
	import actionScripts.valueObjects.URLDescriptorVO;
	
	[Bindable] public class FileLocation extends EventDispatcher
	{
		public var fileBridge: IFileBridge;
		
		public function FileLocation(path:String = null, isURL:Boolean = false):void
		{
			// ** IMPORTANT **
			var obj:Object = BridgeFactory.getFileInstanceObject();
			fileBridge = new obj();
			if (!path) 
			{
				path = IDEModel.getInstance().fileCore.nativePath;
				return;
			}

			if(isURL)
			{
				fileBridge.url = path;
			}
			else
			{
				fileBridge.nativePath = path;
			}
		}
		
		public function resolvePath(path:String):FileLocation
		{
			return fileBridge.resolvePath(path);
		}
		
		public function get name():String
		{
			return fileBridge.name;
		}
		
		//--------------------------------------------------------------------------
		//
		//  WEB METHODS
		//
		//--------------------------------------------------------------------------
		
		public function deleteFileOrDirectory():void
		{
			var tmpLoader: DataAgent = new DataAgent(URLDescriptorVO.FILE_REMOVE, onSuccessDelete, onFault, {path:fileBridge.nativePath}, DataAgent.POSTEVENT);
		}
		
		private function onSuccessDelete(value:Object, message:String=null):void
		{
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function onFault(message:String=null):void
		{
			dispatchEvent(new Event(Event.CLOSE));
		}
	}
}