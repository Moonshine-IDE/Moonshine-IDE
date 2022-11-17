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
		
		function convertFlashDevelopToDomino(file:FileLocation=null):void;
		function exportFlashDevelop(project:AS3ProjectVO, file:FileLocation):void;
		function exportFlashBuilder(project:AS3ProjectVO, file:FileLocation):void;
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
		function isValidExecutableBy(type:String, originPath:String, validationPath:Array=null):Boolean;
		function getExternalEditors():ArrayCollection;
		function getTerminalThemeList():Array;
		function generateTabularRoyaleProject():void;
		function generateCRUDJavaAgents():void;
		function generateJavaAgentsVisualEditor(components:Array):void;
		function getModulesFinder():IModulesFinder;
		function getJavaVersion(javaPath:String=null, onComplete:Function=null):void;
		function setMSDKILocalPathConfig():void;
		function checkRequireJava(project:ProjectVO=null):Boolean;
		function searchAntFile(insideProject:ProjectVO):ArrayCollection;

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