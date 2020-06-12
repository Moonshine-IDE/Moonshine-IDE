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