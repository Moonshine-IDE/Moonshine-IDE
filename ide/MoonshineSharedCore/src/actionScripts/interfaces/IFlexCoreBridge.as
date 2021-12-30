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
package actionScripts.interfaces
{
	import actionScripts.valueObjects.ProjectVO;

	import flash.display.DisplayObject;
    
    import mx.collections.ArrayCollection;
    import mx.core.IFlexDisplayObject;
    
    import actionScripts.events.NewProjectEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.ui.menu.vo.MenuItem;
    import actionScripts.valueObjects.EnvironmentUtilsCusomSDKsVO;
    import actionScripts.valueObjects.FileWrapper;

	/**
	 * IFlexCoreBridge
	 * 
	 *
	 * @date 10.28.2015
	 * @version 1.0
	 * 
	 * All methods those particularly useful
	 * in multiple projects (AIR or Web)
	 */
	public interface IFlexCoreBridge
	{
		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------
		
		function parseFlashDevelop(project:AS3ProjectVO=null, file:FileLocation=null, projectName:String=null):AS3ProjectVO;
		function parseFlashBuilder(file:FileLocation):AS3ProjectVO;
		function exportFlashDevelop(project:AS3ProjectVO, file:FileLocation):void;
		function exportFlashBuilder(project:AS3ProjectVO, file:FileLocation):void;
		function testFlashDevelop(file:Object):FileLocation;
		function testFlashBuilder(file:Object):FileLocation;
		function getQuitMenuItem():MenuItem;
		function getSettingsMenuItem():MenuItem;
		function getAboutMenuItem():MenuItem;
		function getWindowsMenu():Vector.<MenuItem>;
		function getHTMLView(url:String):DisplayObject;
		function getAccessManagerPopup():IFlexDisplayObject;
		function getSDKInstallerView():IFlexDisplayObject;
		function getTourDeEditor(swfSource:String):BasicTextEditor;
		function getNewAntBuild():IFlexDisplayObject;
		function untar(fileToUnzip:FileLocation, unzipTo:FileLocation, unzipCompleteFunction:Function, unzipErrorFunction:Function = null):void;
		function removeExAttributesTo(path:String):void;
		function getJavaPath(completionHandler:Function):void;
		function reAdjustApplicationSize(width:Number=NaN, height:Number=NaN):void;
        function createProject(event:NewProjectEvent):void;
		function importArchiveProject():void;
		function updateToCurrentEnvironmentVariable():void;
		function initCommandGenerationToSetLocalEnvironment(completion:Function, customSDKs:EnvironmentUtilsCusomSDKsVO=null, withCommands:Array=null):void;
		function getComponentByType(type:String):Object;
		function isValidExecutableBy(type:String, originPath:String, validationPath:String=null):Boolean;
		function getExternalEditors():ArrayCollection;
		function getModulesFinder():IModulesFinder;
		function getJavaVersion(javaPath:String=null, onComplete:Function=null):void;
		function setMSDKILocalPathConfig():void;
		function checkRequireJava(project:ProjectVO=null):Boolean;

        /**
         *
         * @param projectWrapper
         * @param finishHandler - handler must return FileWrapper object
         */
        function deleteProject(projectWrapper:FileWrapper, finishHandler:Function, isDeleteRoot:Boolean=false):void;

        function getCorePlugins():Array;
        function getDefaultPlugins():Array;
        function getPluginsNotToShowInSettings():Array;

		function get runtimeVersion():String;
		function get version():String;
		function get defaultInstallationPathSDKs():String;
		function get vagrantMenuOptions():Array;
	}
}