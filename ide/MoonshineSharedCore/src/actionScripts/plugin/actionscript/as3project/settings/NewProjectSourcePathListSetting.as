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
package actionScripts.plugin.actionscript.as3project.settings
{
	import mx.core.IVisualElement;
	
	import __AS3__.vec.Vector;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.settings.vo.AbstractSetting;
	
	public class NewProjectSourcePathListSetting extends AbstractSetting
	{
		public var relativeRoot:FileLocation;

		private var _project:Object;
		private var _editable:Boolean = true;

		public function NewProjectSourcePathListSetting(provider:Object, name:String, label:String, 
										relativeRoot:FileLocation=null)
		{
			super();
			this.provider = provider;
			this.name = name;
			this.label = label;
			this.relativeRoot = relativeRoot;
			defaultValue = "";
		}
		
		override public function set stringValue(value:String):void
		{
			if (value != "")
			{
				var toRet:Vector.<FileLocation> = new Vector.<FileLocation>();
				var values:Array = value.split(",");
				for each (var v:String in values)
				{
					toRet.push( new FileLocation(v) );
				}
			}
			setPendingSetting(toRet);
		}

		private var _renderer:NewProjectSourcePathListSettingRenderer;

		override public function get renderer():IVisualElement
		{
			_renderer = new NewProjectSourcePathListSettingRenderer();
			_renderer.setting = this;
			_renderer.enabled = _editable;
			return _renderer;
		}
		
		public function set editable(value:Boolean):void
		{
			_editable = value;
			if (_renderer)
			{
				_renderer.enabled = _editable;
			}
		}
		
		public function get editable():Boolean
		{
			return _editable;
		}

		public function set project(value:Object):void
		{
			_project = value;
			if (_renderer)
			{
				_renderer.resetAllProjectPaths();
			}
		}
		[Bindable]
		public function get project():Object
		{
			return _project;
		}
        
		// Helper function
		public function getLabelFor(file:Object):String
		{
			var tmpFL: FileLocation = (file is FileLocation) ? file as FileLocation : new FileLocation(file.nativePath);
			var lbl:String = FileLocation(provider.folderLocation).fileBridge.getRelativePath(tmpFL, true);
			if (!lbl)
			{
				if (relativeRoot) lbl = relativeRoot.fileBridge.getRelativePath(tmpFL);
				if (relativeRoot && relativeRoot.fileBridge.nativePath == tmpFL.fileBridge.nativePath) lbl = "/";
				if (!lbl) lbl = tmpFL.fileBridge.nativePath;
				
				if (tmpFL.fileBridge.isDirectory
					&& lbl.charAt(lbl.length-1) != "/")
				{
					lbl += "/";	
				}
			}
			
			return lbl;
		}
    }
}