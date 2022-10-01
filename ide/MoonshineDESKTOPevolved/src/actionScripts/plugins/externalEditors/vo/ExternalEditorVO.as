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
package actionScripts.plugins.externalEditors.vo
{
	import flash.filesystem.File;
	
	import mx.utils.UIDUtil;
	
	import actionScripts.interfaces.IExternalEditorVO;

	[Bindable]
	public class ExternalEditorVO implements IExternalEditorVO
	{
		public var isMoonshineDefault:Boolean;
		
		private var _title:String;
		public function get title():String								{	return _title;	}
		public function set title(value:String):void					{	_title = value;	}
		
		private var _installPath:File;
		public function get installPath():File							{	return _installPath;	}
		public function set installPath(value:File):void				{	
			_installPath = value;
			if (!_installPath || !_installPath.exists) 
			{
				isEnabled = false;
				isValid = false;
			}
			else
			{
				isValid = true;
			}
		}

		private var _website:String;
		public function get website():String							{	return _website;	}
		public function set website(value:String):void					{	_website = value;	}

		private var _isEnabled:Boolean;
		public function get isEnabled():Boolean							{	return _isEnabled;	}
		public function set isEnabled(value:Boolean):void				{	_isEnabled = value;	}
		
		private var _isValid:Boolean;
		public function get isValid():Boolean							{	return _isValid;	}
		public function set isValid(value:Boolean):void					{	_isValid = value;	}
		
		private var _localID:String;
		public function get localID():String							{	return _localID;	}
		public function set localID(value:String):void					{	_localID = value;	}
		
		private var _defaultInstallPath:String;
		public function get defaultInstallPath():String					{	return _defaultInstallPath;	}
		public function set defaultInstallPath(value:String):void		{	_defaultInstallPath = value;	}
		
		private var _extraArguments:String;
		public function get extraArguments():String						{	return _extraArguments;	}
		public function set extraArguments(value:String):void			{	_extraArguments = value;	}

		private var _version:String;
		public function get version():String							{	return _version;	}
		public function set version(value:String):void					{	_version = value;	}

		private var _fileTypes:Array;
		public function get fileTypes():Array							{	return _fileTypes;	}
		public function set fileTypes(value:Array):void					{	_fileTypes = value;	}
		
		public function ExternalEditorVO(uid:String=null)
		{
			_localID = uid ? uid : UIDUtil.createUID();
		}
		
		public static function cloneToEditorVO(value:Object):ExternalEditorVO
		{
			var tmpVO:ExternalEditorVO = new ExternalEditorVO();
			
			if ("isMoonshineDefault" in value) tmpVO.isMoonshineDefault = value.isMoonshineDefault;
			if ("title" in value) tmpVO.title = value.title;
			if ("website" in value) tmpVO.website = value.website;
			if ("isEnabled" in value) tmpVO.isEnabled = value.isEnabled;
			if ("localID" in value) tmpVO.localID = value.localID;
			if ("defaultInstallPath" in value) tmpVO.defaultInstallPath = value.defaultInstallPath;
			if ("extraArguments" in value) tmpVO.extraArguments = value.extraArguments;
			if (("installPath" in value) && (value.installPath is File)) tmpVO.installPath = value.installPath;
			if ("fileTypes" in value) tmpVO.fileTypes = value.fileTypes;
			else if (("installPath" in value) && value.installPath && ("nativePath" in value.installPath))
			{
				try
				{
					tmpVO.installPath = new File(value.installPath.nativePath);
				}
				catch (e:Error){}
			}
			if (!tmpVO.installPath || !tmpVO.installPath.exists)
			{
				tmpVO.isEnabled = false;
				tmpVO.isValid = false;
			}
			
			return tmpVO;
		}
	}
}