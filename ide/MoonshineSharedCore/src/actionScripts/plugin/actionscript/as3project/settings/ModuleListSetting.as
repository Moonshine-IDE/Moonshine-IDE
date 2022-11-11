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
package actionScripts.plugin.actionscript.as3project.settings
{
	import mx.collections.ArrayCollection;
	import mx.core.IVisualElement;
	
	import __AS3__.vec.Vector;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.settings.vo.AbstractSetting;
	import actionScripts.valueObjects.FlashModuleVO;
	
	public class ModuleListSetting extends AbstractSetting
	{
		protected var copiedPaths:ArrayCollection;
		
		public var allowFiles:Boolean;
		public var allowFolders:Boolean;
		public var fileMustExist:Boolean;
		public var relativeRoot:FileLocation;
		public var customMessage:IVisualElement;
		
		private var rdr:ModuleListSettingRenderer;
		
		public function ModuleListSetting(provider:Object, name:String, label:String, 
										relativeRoot:FileLocation=null,
										allowFiles:Boolean=true,
										allowFolders:Boolean=true,
										fileMustExist:Boolean=true)
		{
			super();
			this.provider = provider;
			this.name = name;
			this.label = label;
			this.allowFiles = allowFiles;
			this.allowFolders = allowFolders;
			this.fileMustExist = fileMustExist;
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
			rdr = new ModuleListSettingRenderer();
			rdr.setting = this;
			return rdr;
		}
		
		public function get paths():ArrayCollection
		{
			if (!copiedPaths)
			{
				if (getSetting() == null) return null;
				
				copiedPaths = new ArrayCollection();
				addModules(getSetting().source);
			}
			return copiedPaths;
		}
		
		override public function valueChanged():Boolean
        {
        	if (!copiedPaths) return false;
        	
        	var matches:Boolean = true;
        	var itemMatch:Boolean;
        	for each (var f1:FlashModuleVO in getSetting())
        	{
        		itemMatch = false;
        		for each (var item:PathListItemVO in copiedPaths)
        		{
					if (item.file)
					{
	        			if ((f1.sourcePath.fileBridge.nativePath == item.file.fileBridge.nativePath) && 
							(f1.isSelected == item.isSelected))
	        			{
	        				itemMatch = true;
	        			}
					}
        		}
        		
        		if (!itemMatch)
        		{
        			matches = false;
        			break;
        		}
        	}
        	
        	// Length mismatch?
        	if (getSetting() && copiedPaths)
        	{
        		if (getSetting().length != copiedPaths.length)
        		{
        			matches = false;	
        		}
        	}
			
        	return !matches;
        }
        
        override public function commitChanges():void
		{
			if (!hasProperty() || !valueChanged()) return;
			
			var pending:ArrayCollection = new ArrayCollection();
			for each (var item:PathListItemVO in copiedPaths)
			{
				if (item.label != ModuleListSettingRenderer.NOT_SET_PATH_MESSAGE) pending.addItem(
					new FlashModuleVO(item.file, item.isSelected)
				);
			}
			
			provider[name] = pending;
			hasPendingChanges = false;
		}
		
		public function addModules(modules:Array):void
		{
			modules.forEach(function(module:FlashModuleVO, index:int, arr:Array):void
			{
				var tmpPath:PathListItemVO = new PathListItemVO(module.sourcePath, getLabelFor(module.sourcePath));
				tmpPath.isSelected = module.isSelected;
				copiedPaths.addItem(tmpPath);
			});
		}
		
		public function isPathExists(modulePath:String):Boolean
		{
			for each (var item:PathListItemVO in copiedPaths)
			{
				if (item.file.fileBridge.nativePath == modulePath)
					return true;
			}
			return false;
		}
		
		public function removeModules(modules:Array):void
		{
			modules.forEach(function(module:FlashModuleVO, index:int, arr:Array):void
			{
				for (var i:int; i < copiedPaths.length; i++)
				{
					if ((copiedPaths[i] as PathListItemVO).file.fileBridge.nativePath == module.sourcePath.fileBridge.nativePath)
					{
						copiedPaths.removeItem(copiedPaths[i]);
						break;
					}
				}
			});
		}
        
		public function getLabelFor(file:Object):String
		{
			var tmpFL: FileLocation = (file is FileLocation) ? file as FileLocation : new FileLocation(file.nativePath);
			var lbl:String = this.relativeRoot.fileBridge.getRelativePath(tmpFL, true);
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