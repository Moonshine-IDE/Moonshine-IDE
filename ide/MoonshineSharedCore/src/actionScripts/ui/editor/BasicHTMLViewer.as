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
package actionScripts.ui.editor
{
	import mx.containers.Canvas;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.ui.IContentWindow;
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	/*
		Simple chrome-less browser, used for binary file viewing (images etc)
		TODO: Make sure it unloads properly!
	*/
	public class BasicHTMLViewer extends Canvas implements IContentWindow
	{
		[Bindable] public var file:FileLocation;
		
		override public function get label():String
		{
			if (file) return file.fileBridge.name;
			return "Image";
		}
		
		public function get longLabel():String
		{
			if (file) return file.fileBridge.nativePath;
			return "Image";
		}
		
		public function save():void
		{
		}
		
		public function isChanged():Boolean
		{
			return false;
		}
		
		public function isEmpty():Boolean
		{
			return true;
		}
		
		public function open(file:FileLocation):void
		{
			this.file = file;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			if (ConstantsCoreVO.IS_AIR) addChild(IDEModel.getInstance().flexCore.getHTMLView(file.fileBridge.url));
		}
	}
}