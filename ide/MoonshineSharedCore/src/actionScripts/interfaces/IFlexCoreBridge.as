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
	import flash.display.DisplayObject;
	
	import mx.core.IFlexDisplayObject;
	import mx.core.IVisualElement;
	
	import actionScripts.events.NewProjectEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.ui.IPanelWindow;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.menu.vo.MenuItem;
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
		function createAS3Project(event:NewProjectEvent):void;
		function deleteProject(projectWrapper:FileWrapper, finishHandler:Function):void; // finishHandler must return a FileWrapper object
		function getCorePlugins():Array;
		function getDefaultPlugins():Array;
		function getQuitMenuItem():MenuItem;
		function getSettingsMenuItem():MenuItem;
		function getAboutMenuItem():MenuItem;
		function getWindowsMenu():Vector.<MenuItem>;
		function getHTMLView(url:String):DisplayObject;
		function getAccessManagerPopup():IFlexDisplayObject;
		function getSDKInstallerView():IFlexDisplayObject;
		function getTourDeView():IPanelWindow;
		function exitApplication():void;
		function getTourDeEditor(swfSource:String):BasicTextEditor;
		function getSoftwareInformationView():IVisualElement;
		function getNewAntBuild():IFlexDisplayObject;
		function getPluginsNotToShowInSettings():Array;
		function updateFlashPlayerTrustContent(value:FileLocation):void;
		function untar(fileToUnzip:FileLocation, unzipTo:FileLocation, unzipCompleteFunction:Function, unzipErrorFunction:Function = null):void;
		function removeExAttributesTo(path:String):void;
		function getJavaPath(completionHandler:Function):void;
		function startTypeAheadWithJavaPath(path:String):void;
		
		function get runtimeVersion():String;
		function get version():String;
	}
}