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
package actionScripts.plugins.royale
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.net.SharedObject;
	
	import mx.events.CloseEvent;
	
	import actionScripts.events.AddTabEvent;
	import actionScripts.events.RoyaleApiReportEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.actionscript.as3project.settings.PathListSetting;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.royale.RoyaleApiConfigView;
	import actionScripts.plugin.settings.SettingsView;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugin.settings.vo.SettingsWrapper;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.utils.SharedObjectConst;
	import moonshine.haxeScripts.valueObjects.ComponentTypes;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.RoyaleApiReportVO;
	import actionScripts.valueObjects.SDKReferenceVO;

	public class RoyaleApiReportConfiguratorPlugin extends PluginBase implements IPlugin
	{
		override public function get name():String			{ return "Apache Royale Api Report Configurator Plugin."; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return "Apache Royale Api Report Configurator Plugin."; }

		private var configView:RoyaleApiConfigView;

		public var royaleSdkPath:String;
		public var flexSdkPath:String;
		public var libraries:Vector.<FileLocation>;
		public var mainAppFile:String;
		public var outputPath:String;
		public var outputLogPath:String;

		public function RoyaleApiReportConfiguratorPlugin():void
		{
			super();
		}

		private var _folderLocation:FileLocation;
		public function get folderLocation():FileLocation
		{
			return _folderLocation;
		}

		override public function activate():void
		{
			super.activate();

			dispatcher.addEventListener(RoyaleApiReportEvent.LAUNCH_REPORT_CONFIGURATION, onLaunchReportConfigration);
			dispatcher.addEventListener(RoyaleApiReportEvent.REPORT_GENERATION_COMPLETED, onReportCompleted);
		}

		private function addReportItems():void
		{
			if (!model.activeProject)
			{
				return;
			}

			var apiReportItems:Vector.<ISetting> = Vector.<ISetting>([]);

			var royaleSdk:ISetting = getRoyaleSdkSetting();
			apiReportItems.push(royaleSdk);

			var flexSdk:ISetting = getFlexSdkSetting();
			apiReportItems.push(flexSdk);

			var projectLibraries:ISetting = getLibraries();
			apiReportItems.push(projectLibraries);

			var mainAppFile:ISetting = getMainApplicationFileSetting();
			apiReportItems.push(mainAppFile);

			var logOutputPath:ISetting = getOutputLogPath();
			apiReportItems.push(logOutputPath);

			var outputPath:ISetting = getOutputPath();
			apiReportItems.push(outputPath);

			var settingsWrapper:SettingsWrapper = new SettingsWrapper("Royale Api Report", apiReportItems);

			configView.addCategory("Report");
			configView.addSetting(settingsWrapper, "Report");
		}

		private function getRoyaleSdkSetting():ISetting
		{
			var royaleSdkPath:String = null;
			for each (var sdk:SDKReferenceVO in model.userSavedSDKs)
			{
				if (sdk.type == ComponentTypes.TYPE_ROYALE)
				{
					royaleSdkPath = sdk.path;
					break;
				}
			}

			this.royaleSdkPath = royaleSdkPath;
			return new PathSetting(this, "royaleSdkPath", "Apache Royale SDK", true, royaleSdkPath, true, false, royaleSdkPath);
		}

		private function getFlexSdkSetting():ISetting
		{
			var currentProject:ProjectVO = model.activeProject;
			var as3Project:AS3ProjectVO =  (currentProject as AS3ProjectVO);

			this.flexSdkPath = as3Project.customSDKPath;
			return new PathSetting(this, "flexSdkPath", "Apache Flex SDK", true, as3Project.customSDKPath, true, false, as3Project.customSDKPath);
		}

		public function getLibraries():ISetting
		{
			var as3Project:AS3ProjectVO = model.activeProject as AS3ProjectVO;

			libraries = new Vector.<FileLocation>();
			for each (var library:FileLocation in as3Project.libraries)
			{
				libraries.push(library);
			}

			_folderLocation = model.activeProject.folderLocation;
			return new PathListSetting(this, "libraries", "Libraries", model.activeProject.folderLocation);
		}

		private function getMainApplicationFileSetting():ISetting
		{
			var currentProject:ProjectVO = model.activeProject;
			var asProject:AS3ProjectVO = currentProject as AS3ProjectVO;
			var targets:Vector.<FileLocation> = asProject.targets;

			this.mainAppFile = targets[0].fileBridge.nativePath;
			return new PathSetting(this, "mainAppFile", "Main application file", false, targets[0].fileBridge.nativePath, false, false, targets[0].fileBridge.nativePath);
		}

		private function getOutputPath():ISetting
		{
			var currentProject:ProjectVO = model.activeProject;
			var as3Project:AS3ProjectVO =  (currentProject as AS3ProjectVO);

			if (!model.fileCore.isPathExists(as3Project.outputPath))
			{
				this.outputPath = as3Project.folderPath + model.fileCore.separator + as3Project.outputPath;
			}
			else
			{
				this.outputPath = as3Project.outputPath;
			}

			return new PathSetting(this, "outputPath", "Api report output path", true, this.outputPath, false, false, as3Project.folderLocation.fileBridge.nativePath);
		}

		private function getOutputLogPath():ISetting
		{
			var currentProject:ProjectVO = model.activeProject;
			var as3Project:AS3ProjectVO =  (currentProject as AS3ProjectVO);

			if (!model.fileCore.isPathExists(as3Project.outputPath))
			{
				this.outputLogPath = as3Project.folderPath + model.fileCore.separator + as3Project.outputPath;
			}
			else
			{
				this.outputLogPath = as3Project.outputPath;
			}

			return new PathSetting(this, "outputLogPath", "Api report log build file", true, this.outputLogPath, false, false, as3Project.folderLocation.fileBridge.nativePath);
		}

		override public function deactivate():void
		{
			super.deactivate();
		}

		private function onRunReport(event:Event):void
		{
			configView.enabled = false;
			var reportConfiguration:RoyaleApiReportVO = new RoyaleApiReportVO(
					this.royaleSdkPath,
					this.flexSdkPath,
					this.libraries,
					this.mainAppFile,
					this.outputPath,
					this.outputLogPath,
					model.activeProject.projectFolder.nativePath
			);

			var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);
			cookie.data["doNotShowRoyaleApiPrompt"] = configView.doNotShowPromptAgain;
			cookie.flush();

			dispatcher.dispatchEvent(new RoyaleApiReportEvent(RoyaleApiReportEvent.LAUNCH_REPORT_GENERATION, reportConfiguration));
		}

		private function onCancelReport(event:CloseEvent):void
		{
			dispatcher.dispatchEvent(new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, configView as DisplayObject));

			cleanUp();
		}

		private function cleanUp():void
		{
			configView.removeEventListener(SettingsView.EVENT_CLOSE, onRunReport);
			configView.removeEventListener(SettingsView.EVENT_SAVE, onCancelReport);

			configView = null;

			royaleSdkPath = null;
			flexSdkPath = null;
			libraries = null;
			mainAppFile = null;
			outputPath = null;
		}

		private function onLaunchReportConfigration(event:Event):void
		{
			var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);

			configView = new RoyaleApiConfigView();
			configView.label = "API Report Configuration";
			configView.defaultSaveLabel = "Run";
			configView.doNotShowPromptAgain = Boolean(cookie.data.doNotShowRoyaleApiPrompt);

			configView.addEventListener(SettingsView.EVENT_SAVE, onRunReport);
			configView.addEventListener(CloseEvent.CLOSE, onCancelReport);

			addReportItems();
			dispatcher.dispatchEvent(new AddTabEvent(configView));
		}

		private function onReportCompleted(event:RoyaleApiReportEvent):void
		{
			dispatcher.dispatchEvent(new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, configView as DisplayObject));

			cleanUp();
		}
	}
}