////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.factory
{
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