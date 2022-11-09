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
package actionScripts.plugin.run
{
	import mx.collections.ArrayCollection;
	import mx.core.IVisualElement;
	
	import __AS3__.vec.Vector;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.run.view.RunMobileSettingRenderer;
	import actionScripts.plugin.settings.vo.AbstractSetting;
	
	
	public class RunMobileSetting extends AbstractSetting
	{
		protected var copiedPaths:ArrayCollection;
		
		public var relativeRoot:FileLocation;
		
		private var rdr:RunMobileSettingRenderer;
		
		private var _project:AS3ProjectVO;
		private var _visible:Boolean = true;
		
		public function RunMobileSetting(provider:Object, label:String, 
										relativeRoot:FileLocation=null)
		{
			super();
			this.provider = provider;
			this.label = label;
			this.relativeRoot = relativeRoot;
			defaultValue = "";
		}
		
		override public function set stringValue(v:String):void 
		{
			if (v != "")
			{
				var toRet:Vector.<FileLocation> = new Vector.<FileLocation>();
				var values:Array = v.split(",");
				for each (var value:String in values)
				{
					toRet.push( new FileLocation(value) );
				}
			}
			setPendingSetting(toRet);
		}
		
		override public function get renderer():IVisualElement
		{
			rdr = new RunMobileSettingRenderer();
			rdr.setting = this;
			rdr.enabled = _visible; 
			return rdr;
		}
		
		override public function commitChanges():void
		{
			if (rdr) rdr.commitChanges();
		}
		
		public function set visible(value:Boolean):void
		{
			_visible = value;
			if (rdr) rdr.enabled = _visible;
		}
		public function get visible():Boolean
		{
			return _visible;
		}
		
		public function set project(value:AS3ProjectVO):void
		{
			_project = value;
		}
		public function get project():AS3ProjectVO
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
		
		public function updateDevices(forPlatform:String):void
		{
			if (rdr) rdr.updateDevices(forPlatform);
		}
	}
}