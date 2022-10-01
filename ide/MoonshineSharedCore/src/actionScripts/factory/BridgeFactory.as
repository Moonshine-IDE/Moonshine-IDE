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
	import actionScripts.plugin.genericproj.interfaces.IGenericProjectBridge;

	import flash.system.ApplicationDomain;
    
    import actionScripts.interfaces.IAboutBridge;
    import actionScripts.interfaces.IClipboardBridge;
    import actionScripts.interfaces.IContextMenuBridge;
    import actionScripts.interfaces.IFileBridge;
    import actionScripts.interfaces.IFlexCoreBridge;
    import actionScripts.interfaces.IGroovyBridge;
    import actionScripts.interfaces.IHaxeBridge;
    import actionScripts.interfaces.IJavaBridge;
    import actionScripts.interfaces.ILanguageServerBridge;
    import actionScripts.interfaces.IOSXBookmarkerBridge;
    import actionScripts.interfaces.IOnDiskBridge;
    import actionScripts.interfaces.IVisualEditorBridge;
	
	/**
	 * BridgeFactory
	 * 
	 *
	 * @date 01.17.2013
	 * @version 1.0
	 */
	public class BridgeFactory
	{
		//--------------------------------------------------------------------------
		//
		//  PUBLIC API
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Returns the bridge instance for
		 * file API implementation
		 */
		public static function getFileInstance(): IFileBridge 
		{
			var clsToCreate : Object = getClassToCreate("actionScripts.impls.IFileBridgeImp");
			var gb: IFileBridge = new clsToCreate();
			return gb;
		}
		
		public static function getFileInstanceObject(): Object 
		{
			return getClassToCreate("actionScripts.impls.IFileBridgeImp");
		}
		
		public static function getContextMenuInstance(): IContextMenuBridge 
		{
			var clsToCreate : Object = getClassToCreate("actionScripts.impls.IContextMenuBridgeImp");
			var gb: IContextMenuBridge = new clsToCreate();
			return gb;
		}

		public static function getClipboardInstance():IClipboardBridge
		{
            var clsToCreate : Object = getClassToCreate("actionScripts.impls.IClipboardBridgeImp");
            var gb: IClipboardBridge = new clsToCreate();
            return gb;
		}

		public static function getNativeMenuItemInstance(): Object 
		{
			return getClassToCreate("actionScripts.impls.INativeMenuItemBridgeImp");
		}
		
		public static function getFlexCoreInstance(): IFlexCoreBridge 
		{
			var clsToCreate : Object = getClassToCreate("actionScripts.impls.IFlexCoreBridgeImp");
			var gb: IFlexCoreBridge = new clsToCreate();
			return gb;
		}
		
		public static function getOSXBookmarkerCoreInstance(): IOSXBookmarkerBridge 
		{
			var clsToCreate : Object = getClassToCreate("actionScripts.impls.IOSXBookmarkerBridgeImp");
			var gb: IOSXBookmarkerBridge = new clsToCreate();
			return gb;
		}

		public static function getVisualEditorInstance():IVisualEditorBridge
		{
            var clsToCreate : Object = getClassToCreate("actionScripts.impls.IVisualEditorProjectBridgeImpl");
            var gb: IVisualEditorBridge = new clsToCreate();
            return gb;
		}

		public static function getAboutInstance(): IAboutBridge 
		{
			var clsToCreate : Object = getClassToCreate("actionScripts.impls.IAboutBridgeImp");
			var gb: IAboutBridge = new clsToCreate();
			return gb;
		}

		public static function getJavaInstance(): IJavaBridge 
		{
			var clsToCreate : Object = getClassToCreate("actionScripts.impls.IJavaBridgeImpl");
			var gb: IJavaBridge = new clsToCreate();
			return gb;
		}

		public static function getGroovyInstance(): IGroovyBridge 
		{
			var clsToCreate : Object = getClassToCreate("actionScripts.impls.IGroovyBridgeImpl");
			var gb: IGroovyBridge = new clsToCreate();
			return gb;
		}

		public static function getHaxeInstance(): IHaxeBridge 
		{
			var clsToCreate : Object = getClassToCreate("actionScripts.impls.IHaxeBridgeImpl");
			var gb: IHaxeBridge = new clsToCreate();
			return gb;
		}

		public static function getLanguageServerCoreInstance(): ILanguageServerBridge
		{
			var clsToCreate : Object = getClassToCreate("actionScripts.impls.ILanguageServerBridgeImp");
			var gb: ILanguageServerBridge = new clsToCreate();
			return gb;
		}
		
		public static function getOnDiskInstance(): IOnDiskBridge 
		{
			var clsToCreate : Object = getClassToCreate("actionScripts.impls.IOnDiskBridgeImpl");
			var gb: IOnDiskBridge = new clsToCreate();
			return gb;
		}

		public static function getGenericInstance(): IGenericProjectBridge
		{
			var clsToCreate : Object = getClassToCreate("actionScripts.impls.IGenericBridgeImpl");
			var gb: IGenericProjectBridge = new clsToCreate();
			return gb;
		}
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE API
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Retreives the Class definition from 
		 * running project
		 * 
		 * @required
		 * Class name
		 * @return
		 * Class
		 */
		private static function getClassToCreate(className:String): Object 
		{
			var tmpClass: Object = ApplicationDomain.currentDomain.getDefinition(className);
			return tmpClass;
		}
    }
}