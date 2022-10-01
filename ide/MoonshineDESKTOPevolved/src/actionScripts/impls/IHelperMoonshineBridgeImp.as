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
package actionScripts.impls
{
	import actionScripts.interfaces.IHelperMoonshineBridge;
	import actionScripts.locator.IDEModel;
	import actionScripts.utils.MSDKIdownloadUtil;
	import actionScripts.utils.SDKUtils;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ComponentTypes;

	public class IHelperMoonshineBridgeImp implements IHelperMoonshineBridge
	{
		public function isDefaultSDKPresent():Boolean
		{
			return UtilsCore.isDefaultSDKAvailable();
		}
		
		public function isFlexSDKAvailable():Object
		{
			return SDKUtils.checkSDKTypeInSDKList(ComponentTypes.TYPE_FLEX);
		}
		
		public function isFlexHarmanSDKAvailable():Object
		{
			return SDKUtils.checkSDKTypeInSDKList(ComponentTypes.TYPE_FLEX_HARMAN);
		}
		
		public function isFlexJSSDKAvailable():Object
		{
			return SDKUtils.checkSDKTypeInSDKList(ComponentTypes.TYPE_FLEXJS);
		}
		
		public function isRoyaleSDKAvailable():Object
		{
			return SDKUtils.checkSDKTypeInSDKList(ComponentTypes.TYPE_ROYALE);
		}
		
		public function isFeathersSDKAvailable():Object
		{
			return SDKUtils.checkSDKTypeInSDKList(ComponentTypes.TYPE_FEATHERS);
		}
		
		public function isJavaPresent():Boolean
		{
			return UtilsCore.isJavaForTypeaheadAvailable();
		}
		
		public function isJava8Present():Boolean
		{
			return UtilsCore.isJava8Present();
		}
		
		public function isAntPresent():Boolean
		{
			return UtilsCore.isAntAvailable();
		}
		
		public function isMavenPresent():Boolean
		{
			return UtilsCore.isMavenAvailable();
		}

		public function isGradlePresent():Boolean
		{
			return UtilsCore.isGradleAvailable();
		}
		
		public function isGrailsPresent():Boolean
		{
			return UtilsCore.isGrailsAvailable();
		}
		
		public function isSVNPresent():Boolean
		{
			return UtilsCore.isSVNPresent();
		}
		
		public function isGitPresent():Boolean
		{
			return UtilsCore.isGitPresent();	
		}
		
		public function isNodeJsPresent():Boolean
		{
			return UtilsCore.isNodeAvailable();
		}
		
		public function isNotesDominoPresent():Boolean
		{
			return UtilsCore.isNotesDominoAvailable();
		}

		public function isVagrantAvailable():Boolean
		{
			return UtilsCore.isVagrantAvailable();
		}

		public function isMacPortsAvailable():Boolean
		{
			return UtilsCore.isMacPortsAvailable();
		}

		public function isHaxeAvailable():Boolean
		{
			return UtilsCore.isHaxeAvailable();
		}

		public function isNekoAvailable():Boolean
		{
			return UtilsCore.isNekoAvailable();
		}

		public function runOrDownloadSDKInstaller():void
		{
			MSDKIdownloadUtil.getInstance().runOrDownloadSDKInstaller();
		}

		private var _playerglobalExists:Boolean;
		public function get playerglobalExists():Boolean
		{
			return _playerglobalExists;
		}

		public function set playerglobalExists(value:Boolean):void
		{
			_playerglobalExists = value;
		}
		
		public function get javaVersionForTypeahead():String
		{
			return IDEModel.getInstance().javaVersionForTypeAhead;
		}
		
		public function get javaVersionInJava8Path():String
		{
			return IDEModel.getInstance().javaVersionInJava8Path;
		}
	}
}