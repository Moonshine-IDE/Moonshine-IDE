////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
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
package actionScripts.plugins.vagrant
{
	import actionScripts.events.DominoEvent;
	import actionScripts.events.OnDiskBuildEvent;
	import actionScripts.plugins.vagrant.settings.LinkedInstancesSetting;
	import actionScripts.plugins.vagrant.utils.ConvertDatabaseJob;
	import actionScripts.plugins.vagrant.utils.DatabaseJobBase;
	import actionScripts.plugins.vagrant.utils.DeployBuildOnVagrantJob;
	import actionScripts.plugins.vagrant.utils.DeployDatabaseJob;
	import actionScripts.plugins.vagrant.utils.DeployRoyaleToVagrantJob;
import actionScripts.plugins.vagrant.utils.ImportDocumentsJSONJob;
import actionScripts.plugins.vagrant.utils.RunDatabaseOnVagrantJob;

	import components.popup.ConvertDominoDatabasePopup;
	import components.popup.DeployDominoDatabasePopup;
	import components.popup.DeployRoyaleVagrantPopup;
import components.popup.ImportDocumentJSONPopup;
import components.popup.SelectVagrantPopup;

	import flash.display.DisplayObject;

	import flash.events.Event;
	import flash.events.NativeProcessExitEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;

	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;

	import spark.components.Alert;
	
	import actionScripts.events.FilePluginEvent;
	import actionScripts.events.SettingsEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugins.build.ConsoleBuildPluginBase;
	import actionScripts.plugins.vagrant.utils.VagrantUtil;
	import actionScripts.ui.renderers.FTETreeItemRenderer;
	import actionScripts.utils.FileUtils;
	import actionScripts.utils.MethodDescriptor;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;

	public class VagrantPlugin extends ConsoleBuildPluginBase implements ISettingsProvider
	{
		public static var NAMESPACE:String = "actionScripts.plugins.vagrant::VagrantPlugin";

		override public function get name():String			{ return "Vagrant"; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String	{ return "Access to Vagrant support from Moonshine-IDE"; }
		
		private var pathSetting:PathSetting;
		private var defaultVagrantPath:String;
		private var defaultVirtualBoxPath:String;
		private var vagrantConsole:VagrantConsolePlugin;
		private var haltMethod:MethodDescriptor;
		private var destroyMethod:MethodDescriptor;
		private var vagrantFileLocation:FileLocation;
		private var vagrantInstances:ArrayCollection;
		private var convertDominoDBPopup:ConvertDominoDatabasePopup;
		private var deployDominoDBPopup:DeployDominoDatabasePopup;
		private var importDocumentsJSONPopup:ImportDocumentJSONPopup;
		private var deployRoyaleVagrantPopup:DeployRoyaleVagrantPopup;
		private var selectVagrantPopup:SelectVagrantPopup;
		private var dbConversionJob:ConvertDatabaseJob;
		private var deployDBJob:DeployDatabaseJob;
		private var importDocumentJSONJob:ImportDocumentsJSONJob;
		private var deployRoyaleToVagrantJob:DeployRoyaleToVagrantJob;
		private var runDatabaseOnVagrantJob:RunDatabaseOnVagrantJob;
		private var deployBuildOnVagrantJob:DeployBuildOnVagrantJob;

		public function get vagrantPath():String
		{
			return model ? model.vagrantPath : null;
		}
		public function set vagrantPath(value:String):void
		{
			if (model.vagrantPath != value)
			{
				model.vagrantPath = value;
			}
		}

		public function get virtualBoxPath():String
		{
			return model ? model.virtualBoxPath : null;
		}
		public function set virtualBoxPath(value:String):void
		{
			if (model.virtualBoxPath != value)
			{
				model.virtualBoxPath = value;
			}
		}

		override public function activate():void
		{
			super.activate();
			updateEventListeners();
			vagrantInstances = VagrantUtil.getVagrantInstances();

			if (!ConstantsCoreVO.IS_MACOS || !ConstantsCoreVO.IS_APP_STORE_VERSION)
			{
				// because most users install Vagrant to a standard installation
				// directory, we can try to use it as the default, if it exists.
				// if the user saves a different path (or clears the path) in
				// the settings, these default values will be safely ignored.
				// --vagrant--
				var defaultLocation:File = new File(ConstantsCoreVO.IS_MACOS ? "/usr/local/bin" : "C:\\HashiCorp\\Vagrant");
				defaultVagrantPath = defaultLocation.exists ? defaultLocation.nativePath : null;
				if (defaultVagrantPath && !model.vagrantPath)
				{
					model.vagrantPath = defaultVagrantPath;
				}
				// --virtualBox--
				defaultLocation = new File(ConstantsCoreVO.IS_MACOS ? "/usr/local/bin" : FileUtils.getValidOrPossibleWindowsInstallation("Oracle/VirtualBox"));
				defaultVirtualBoxPath = defaultLocation.exists ? defaultLocation.nativePath : null;
				if (defaultVirtualBoxPath && !model.virtualBoxPath)
				{
					model.virtualBoxPath = defaultVirtualBoxPath;
				}
			}

			dispatcher.addEventListener(DominoEvent.EVENT_CONVERT_DOMINO_DATABASE, onConvertDominoDatabase, false, 0, true);
			dispatcher.addEventListener(DominoEvent.EVENT_RUN_DOMINO_ON_VAGRANT, onRunDominoOnVagrant, false, 0, true);
			dispatcher.addEventListener(DominoEvent.EVENT_BUILD_ON_VAGRANT, onBuildOnVagrant, false, 0, true);
			dispatcher.addEventListener(DominoEvent.IMPORT_DOCUMENTS_JSON_VAGRANT, onImportDocumentsJSONRequest, false, 0, true);
			dispatcher.addEventListener(OnDiskBuildEvent.DEPLOY_DOMINO_DATABASE, onDeployDominoDatabseRequest, false, 0, true);
			dispatcher.addEventListener(OnDiskBuildEvent.DEPLOY_ROYALE_TO_VAGRANT, onDeployRoyalToVagrantRequest, false, 0, true);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			removeMenuListeners();
			onConsoleDeactivated(null);
			dispatcher.removeEventListener(DominoEvent.EVENT_CONVERT_DOMINO_DATABASE, onConvertDominoDatabase);
			dispatcher.removeEventListener(DominoEvent.EVENT_RUN_DOMINO_ON_VAGRANT, onRunDominoOnVagrant);
			dispatcher.removeEventListener(DominoEvent.EVENT_BUILD_ON_VAGRANT, onBuildOnVagrant);
			dispatcher.removeEventListener(DominoEvent.IMPORT_DOCUMENTS_JSON_VAGRANT, onImportDocumentsJSONRequest);
			dispatcher.removeEventListener(OnDiskBuildEvent.DEPLOY_DOMINO_DATABASE, onDeployDominoDatabseRequest);
			dispatcher.removeEventListener(OnDiskBuildEvent.DEPLOY_ROYALE_TO_VAGRANT, onDeployRoyalToVagrantRequest);
		}

		override public function resetSettings():void
		{
			vagrantPath = null;
		}
		
		override public function onSettingsClose():void
		{
			if (pathSetting)
			{
				pathSetting = null;
			}
		}

		override protected function outputMsg(msg:*):void
		{
			dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT_VAGRANT, msg));
		}
		
        public function getSettingsList():Vector.<ISetting>
        {
			onSettingsClose();
			pathSetting = new PathSetting(this, 'vagrantPath', 'Vagrant Home', true, vagrantPath, false, false, defaultVagrantPath);

			return Vector.<ISetting>([
				pathSetting,
				new PathSetting(this, 'virtualBoxPath', 'VirtualBox Home (Optional)', true, virtualBoxPath, false, false, defaultVirtualBoxPath),
				new LinkedInstancesSetting(vagrantInstances)
			]);
        }

		private function onConvertDominoDatabase(event:Event):void
		{
			if (!convertDominoDBPopup)
			{
				convertDominoDBPopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, ConvertDominoDatabasePopup) as ConvertDominoDatabasePopup;
				convertDominoDBPopup.instances = vagrantInstances;
				convertDominoDBPopup.addEventListener(CloseEvent.CLOSE, onConvertDominoDBPopupClosed);
				convertDominoDBPopup.addEventListener(ConvertDominoDatabasePopup.EVENT_START_CONVERSION, onStartNSFConversionProcess);
				PopUpManager.centerPopUp(convertDominoDBPopup);
			}
		}

		private function onRunDominoOnVagrant(event:Event):void
		{
			if (!selectVagrantPopup)
			{
				selectVagrantPopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, SelectVagrantPopup, true) as SelectVagrantPopup;
				selectVagrantPopup.instances = vagrantInstances;
				selectVagrantPopup.requireCapability = "java-domino-gradle";
				selectVagrantPopup.addEventListener(CloseEvent.CLOSE, onSelectVagrantPopupClosed);
				selectVagrantPopup.addEventListener(SelectVagrantPopup.EVENT_INSTANCE_SELECTED, onVagrantInstanceSelectedRunDominoOnVagrant);
				PopUpManager.centerPopUp(selectVagrantPopup);
			}
		}

		private function onBuildOnVagrant(event:Event):void
		{
			if (!selectVagrantPopup)
			{
				selectVagrantPopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, SelectVagrantPopup, true) as SelectVagrantPopup;
				selectVagrantPopup.instances = vagrantInstances;
				selectVagrantPopup.requireCapability = "nsfodp";
				selectVagrantPopup.addEventListener(CloseEvent.CLOSE, onSelectVagrantPopupClosed);
				selectVagrantPopup.addEventListener(SelectVagrantPopup.EVENT_INSTANCE_SELECTED, onVagrantInstanceSelectedBuildOnVagrant);
				PopUpManager.centerPopUp(selectVagrantPopup);
			}
		}

		private function onDeployDominoDatabseRequest(event:Event):void
		{
			if (!deployDominoDBPopup)
			{
				deployDominoDBPopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, DeployDominoDatabasePopup) as DeployDominoDatabasePopup;
				deployDominoDBPopup.instances = vagrantInstances;
				deployDominoDBPopup.addEventListener(CloseEvent.CLOSE, onDeployDominoDBPopupClosed);
				deployDominoDBPopup.addEventListener(ConvertDominoDatabasePopup.EVENT_START_CONVERSION, onStartDeployDatabaseProcess);
				PopUpManager.centerPopUp(deployDominoDBPopup);
			}
		}

		private function onImportDocumentsJSONRequest(event:Event):void
		{
			if (!importDocumentsJSONPopup)
			{
				importDocumentsJSONPopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, ImportDocumentJSONPopup) as ImportDocumentJSONPopup;
				importDocumentsJSONPopup.instances = vagrantInstances;
				importDocumentsJSONPopup.addEventListener(CloseEvent.CLOSE, onImportDocumentJSONPopupClosed);
				importDocumentsJSONPopup.addEventListener(ConvertDominoDatabasePopup.EVENT_START_CONVERSION, onImportDocumentJSONDatabaseProcess);
				PopUpManager.centerPopUp(importDocumentsJSONPopup);
			}
		}

		private function onDeployRoyalToVagrantRequest(event:Event):void
		{
			if (!deployRoyaleVagrantPopup)
			{
				deployRoyaleVagrantPopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, DeployRoyaleVagrantPopup) as DeployRoyaleVagrantPopup;
				deployRoyaleVagrantPopup.instances = vagrantInstances;
				deployRoyaleVagrantPopup.addEventListener(CloseEvent.CLOSE, onDeployRoyaleVagrantPopupClosed);
				deployRoyaleVagrantPopup.addEventListener(ConvertDominoDatabasePopup.EVENT_START_CONVERSION, onStartDeployRoyaleVagrantProcess);
				PopUpManager.centerPopUp(deployRoyaleVagrantPopup);
			}
		}

		private function onConvertDominoDBPopupClosed(event:CloseEvent):void
		{
			convertDominoDBPopup.removeEventListener(CloseEvent.CLOSE, onConvertDominoDBPopupClosed);
			convertDominoDBPopup.removeEventListener(ConvertDominoDatabasePopup.EVENT_START_CONVERSION, onStartNSFConversionProcess);
			convertDominoDBPopup = null;
		}

		private function onDeployDominoDBPopupClosed(event:CloseEvent):void
		{
			deployDominoDBPopup.removeEventListener(CloseEvent.CLOSE, onConvertDominoDBPopupClosed);
			deployDominoDBPopup.removeEventListener(ConvertDominoDatabasePopup.EVENT_START_CONVERSION, onStartDeployDatabaseProcess);
			deployDominoDBPopup = null;
		}

		private function onImportDocumentJSONPopupClosed(event:CloseEvent):void
		{
			importDocumentsJSONPopup.removeEventListener(CloseEvent.CLOSE, onImportDocumentJSONPopupClosed);
			importDocumentsJSONPopup.removeEventListener(ConvertDominoDatabasePopup.EVENT_START_CONVERSION, onImportDocumentJSONDatabaseProcess);
			importDocumentsJSONPopup = null;
		}

		private function onDeployRoyaleVagrantPopupClosed(event:CloseEvent):void
		{
			deployRoyaleVagrantPopup.removeEventListener(CloseEvent.CLOSE, onDeployRoyaleVagrantPopupClosed);
			deployRoyaleVagrantPopup.removeEventListener(ConvertDominoDatabasePopup.EVENT_START_CONVERSION, onStartDeployRoyaleVagrantProcess);
			deployRoyaleVagrantPopup = null;
		}

		private function onSelectVagrantPopupClosed(event:CloseEvent):void
		{
			selectVagrantPopup.removeEventListener(CloseEvent.CLOSE, onSelectVagrantPopupClosed);
			selectVagrantPopup.removeEventListener(SelectVagrantPopup.EVENT_INSTANCE_SELECTED, onVagrantInstanceSelectedRunDominoOnVagrant);
			selectVagrantPopup.removeEventListener(SelectVagrantPopup.EVENT_INSTANCE_SELECTED, onVagrantInstanceSelectedBuildOnVagrant);
			selectVagrantPopup = null;
		}

		private function onStartNSFConversionProcess(event:Event):void
		{
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED,"Converting SomeNSF"));
			dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateConversionRequest, false, 0, true);

			// get the object to work with
			dbConversionJob = new ConvertDatabaseJob(
					convertDominoDBPopup.selectedInstance.url,
					convertDominoDBPopup.destinationFolder
			);
			configureListenersDBConversionJob(true);
			dbConversionJob.uploadAndRunCommandOnServer(new File(convertDominoDBPopup.databasePath));
		}

		private function onStartDeployDatabaseProcess(event:Event):void
		{
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED,"Deploying Database"));
			dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateDeployDatabaseRequest, false, 0, true);

			// get the object to work with
			deployDBJob = new DeployDatabaseJob(
					deployDominoDBPopup.selectedInstance.url,
					deployDominoDBPopup.targetDatabase
			);
			configureListenersDeployDatabaseJob(true);
			deployDBJob.uploadAndRunCommandOnServer(new File(deployDominoDBPopup.localDatabasePath));
		}

		private function onImportDocumentJSONDatabaseProcess(event:Event):void
		{
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Deploying Database"));
			dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateImportDocumentJSONRequest, false, 0, true);

			// get the object to work with
			importDocumentJSONJob = new ImportDocumentsJSONJob(
					importDocumentsJSONPopup.selectedInstance.url
			);
			configureListenersImportDocumentJSONJob(true);
			importDocumentJSONJob.uploadAndRunCommandOnServer(new File(importDocumentsJSONPopup.jsonFilePath));
		}

		private function onStartDeployRoyaleVagrantProcess(event:Event):void
		{
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED,"Deploying Royale to Vagrant"));
			dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateDeployRoyaleVagrantRequest, false, 0, true);

			// get the object to work with
			deployRoyaleToVagrantJob = new DeployRoyaleToVagrantJob(
					deployRoyaleVagrantPopup.selectedInstance.url,
					deployRoyaleVagrantPopup.targetDatabase
			);
			deployRoyaleToVagrantJob.deployedURL = deployRoyaleVagrantPopup.databaseURL;
			configureListenersDeployRoyaleToVagrantJob(true);
			deployRoyaleToVagrantJob.zipProject(deployRoyaleVagrantPopup.sourceDirectory);
		}

		private function onVagrantInstanceSelectedRunDominoOnVagrant(event:Event):void
		{
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED,"Deploy and run database to Vagrant"));
			dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateRunDatabaseVagrantRequest, false, 0, true);

			// get the object to work with
			runDatabaseOnVagrantJob = new RunDatabaseOnVagrantJob(
					selectVagrantPopup.selectedInstance.url
			);
			configureListenersRunDatabaseToVagrantJob(true);
			runDatabaseOnVagrantJob.zipProject(model.activeProject.folderLocation);
		}

		private function onVagrantInstanceSelectedBuildOnVagrant(event:Event):void
		{
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED,"Running Build on Vagrant"));
			dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateBuildOnVagrantRequest, false, 0, true);

			// get the object to work with
			deployBuildOnVagrantJob = new DeployBuildOnVagrantJob(
					selectVagrantPopup.selectedInstance.url
			);
			configureListenersDeployBuildOnVagrantJob(true);
			deployBuildOnVagrantJob.zipProject(model.activeProject.folderLocation);
		}

		private function configureListenersDBConversionJob(listen:Boolean):void
		{
			if (listen)
			{
				dbConversionJob.addEventListener(DatabaseJobBase.EVENT_CONVERSION_COMPLETE, onDBConversionEnded, false, 0, true);
				dbConversionJob.addEventListener(DatabaseJobBase.EVENT_CONVERSION_FAILED, onDBConversionEnded, false, 0, true);
				dbConversionJob.addEventListener(DatabaseJobBase.EVENT_VAGRANT_UPLOAD_COMPLETES, onDBConversionUploadUpdates, false, 0, true);
				dbConversionJob.addEventListener(DatabaseJobBase.EVENT_VAGRANT_UPLOAD_FAILED, onDBConversionUploadUpdates, false, 0, true);
			}
			else
			{
				dbConversionJob.removeEventListener(DatabaseJobBase.EVENT_CONVERSION_COMPLETE, onDBConversionEnded);
				dbConversionJob.removeEventListener(DatabaseJobBase.EVENT_CONVERSION_FAILED, onDBConversionEnded);
				dbConversionJob.addEventListener(DatabaseJobBase.EVENT_VAGRANT_UPLOAD_COMPLETES, onDBConversionUploadUpdates);
				dbConversionJob.addEventListener(DatabaseJobBase.EVENT_VAGRANT_UPLOAD_FAILED, onDBConversionUploadUpdates);
				dbConversionJob = null;
			}
		}

		private function configureListenersDeployDatabaseJob(listen:Boolean):void
		{
			if (listen)
			{
				deployDBJob.addEventListener(DatabaseJobBase.EVENT_CONVERSION_COMPLETE, onDeployDatabaseEnded, false, 0, true);
				deployDBJob.addEventListener(DatabaseJobBase.EVENT_CONVERSION_FAILED, onDeployDatabaseEnded, false, 0, true);
				deployDBJob.addEventListener(DatabaseJobBase.EVENT_VAGRANT_UPLOAD_COMPLETES, onDeployDatabaseUploadUpdates, false, 0, true);
				deployDBJob.addEventListener(DatabaseJobBase.EVENT_VAGRANT_UPLOAD_FAILED, onDeployDatabaseUploadUpdates, false, 0, true);
			}
			else
			{
				deployDBJob.removeEventListener(DatabaseJobBase.EVENT_CONVERSION_COMPLETE, onDeployDatabaseEnded);
				deployDBJob.removeEventListener(DatabaseJobBase.EVENT_CONVERSION_FAILED, onDeployDatabaseEnded);
				deployDBJob.removeEventListener(DatabaseJobBase.EVENT_VAGRANT_UPLOAD_COMPLETES, onDeployDatabaseUploadUpdates);
				deployDBJob.removeEventListener(DatabaseJobBase.EVENT_VAGRANT_UPLOAD_FAILED, onDeployDatabaseUploadUpdates);
				deployDBJob = null;
			}
		}

		private function configureListenersImportDocumentJSONJob(listen:Boolean):void
		{
			if (listen)
			{
				importDocumentJSONJob.addEventListener(DatabaseJobBase.EVENT_CONVERSION_COMPLETE, onImportDocumentJSONJobEnded, false, 0, true);
				importDocumentJSONJob.addEventListener(DatabaseJobBase.EVENT_CONVERSION_FAILED, onImportDocumentJSONJobEnded, false, 0, true);
				importDocumentJSONJob.addEventListener(DatabaseJobBase.EVENT_VAGRANT_UPLOAD_COMPLETES, onImportDocumentJSONUploadUpdates, false, 0, true);
				importDocumentJSONJob.addEventListener(DatabaseJobBase.EVENT_VAGRANT_UPLOAD_FAILED, onImportDocumentJSONUploadUpdates, false, 0, true);
			}
			else
			{
				importDocumentJSONJob.removeEventListener(DatabaseJobBase.EVENT_CONVERSION_COMPLETE, onImportDocumentJSONJobEnded);
				importDocumentJSONJob.removeEventListener(DatabaseJobBase.EVENT_CONVERSION_FAILED, onImportDocumentJSONJobEnded);
				importDocumentJSONJob.removeEventListener(DatabaseJobBase.EVENT_VAGRANT_UPLOAD_COMPLETES, onImportDocumentJSONUploadUpdates);
				importDocumentJSONJob.removeEventListener(DatabaseJobBase.EVENT_VAGRANT_UPLOAD_FAILED, onImportDocumentJSONUploadUpdates);
				importDocumentJSONJob = null;
			}
		}

		private function configureListenersDeployRoyaleToVagrantJob(listen:Boolean):void
		{
			if (listen)
			{
				deployRoyaleToVagrantJob.addEventListener(DatabaseJobBase.EVENT_CONVERSION_COMPLETE, onDeployRoyaleEnded, false, 0, true);
				deployRoyaleToVagrantJob.addEventListener(DatabaseJobBase.EVENT_CONVERSION_FAILED, onDeployRoyaleEnded, false, 0, true);
				deployRoyaleToVagrantJob.addEventListener(DatabaseJobBase.EVENT_VAGRANT_UPLOAD_COMPLETES, onDeployRoyaleUploadUpdates, false, 0, true);
				deployRoyaleToVagrantJob.addEventListener(DatabaseJobBase.EVENT_VAGRANT_UPLOAD_FAILED, onDeployRoyaleUploadUpdates, false, 0, true);
			}
			else
			{
				deployRoyaleToVagrantJob.removeEventListener(DatabaseJobBase.EVENT_CONVERSION_COMPLETE, onDeployRoyaleEnded);
				deployRoyaleToVagrantJob.removeEventListener(DatabaseJobBase.EVENT_CONVERSION_FAILED, onDeployRoyaleEnded);
				deployRoyaleToVagrantJob.removeEventListener(DatabaseJobBase.EVENT_VAGRANT_UPLOAD_COMPLETES, onDeployRoyaleUploadUpdates);
				deployRoyaleToVagrantJob.removeEventListener(DatabaseJobBase.EVENT_VAGRANT_UPLOAD_FAILED, onDeployRoyaleUploadUpdates);
				deployRoyaleToVagrantJob = null;
			}
		}

		private function configureListenersRunDatabaseToVagrantJob(listen:Boolean):void
		{
			if (listen)
			{
				runDatabaseOnVagrantJob.addEventListener(DatabaseJobBase.EVENT_CONVERSION_COMPLETE, onRunDatabaseToVagrantEnded, false, 0, true);
				runDatabaseOnVagrantJob.addEventListener(DatabaseJobBase.EVENT_CONVERSION_FAILED, onRunDatabaseToVagrantEnded, false, 0, true);
				runDatabaseOnVagrantJob.addEventListener(DatabaseJobBase.EVENT_VAGRANT_UPLOAD_COMPLETES, onVagrantUploadUpdates, false, 0, true);
				runDatabaseOnVagrantJob.addEventListener(DatabaseJobBase.EVENT_VAGRANT_UPLOAD_FAILED, onVagrantUploadUpdates, false, 0, true);
			}
			else
			{
				runDatabaseOnVagrantJob.removeEventListener(DatabaseJobBase.EVENT_CONVERSION_COMPLETE, onRunDatabaseToVagrantEnded);
				runDatabaseOnVagrantJob.removeEventListener(DatabaseJobBase.EVENT_CONVERSION_FAILED, onRunDatabaseToVagrantEnded);
				runDatabaseOnVagrantJob.removeEventListener(DatabaseJobBase.EVENT_VAGRANT_UPLOAD_COMPLETES, onVagrantUploadUpdates);
				runDatabaseOnVagrantJob.removeEventListener(DatabaseJobBase.EVENT_VAGRANT_UPLOAD_FAILED, onVagrantUploadUpdates);
				runDatabaseOnVagrantJob = null;
			}
		}

		private function configureListenersDeployBuildOnVagrantJob(listen:Boolean):void
		{
			if (listen)
			{
				deployBuildOnVagrantJob.addEventListener(DatabaseJobBase.EVENT_CONVERSION_COMPLETE, onDeployBuildOnVagrantEnded, false, 0, true);
				deployBuildOnVagrantJob.addEventListener(DatabaseJobBase.EVENT_CONVERSION_FAILED, onDeployBuildOnVagrantEnded, false, 0, true);
				deployBuildOnVagrantJob.addEventListener(DatabaseJobBase.EVENT_VAGRANT_UPLOAD_COMPLETES, onBuildOnVagrantUploadUpdates, false, 0, true);
				deployBuildOnVagrantJob.addEventListener(DatabaseJobBase.EVENT_VAGRANT_UPLOAD_FAILED, onBuildOnVagrantUploadUpdates, false, 0, true);
			}
			else
			{
				deployBuildOnVagrantJob.removeEventListener(DatabaseJobBase.EVENT_CONVERSION_COMPLETE, onDeployBuildOnVagrantEnded);
				deployBuildOnVagrantJob.removeEventListener(DatabaseJobBase.EVENT_CONVERSION_FAILED, onDeployBuildOnVagrantEnded);
				deployBuildOnVagrantJob.removeEventListener(DatabaseJobBase.EVENT_VAGRANT_UPLOAD_COMPLETES, onBuildOnVagrantUploadUpdates);
				deployBuildOnVagrantJob.removeEventListener(DatabaseJobBase.EVENT_VAGRANT_UPLOAD_FAILED, onBuildOnVagrantUploadUpdates);
				deployBuildOnVagrantJob = null;
			}
		}

		private function onDBConversionEnded(event:Event):void
		{
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
			dispatcher.removeEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateConversionRequest);
			configureListenersDBConversionJob(false);
		}

		private function onDeployDatabaseEnded(event:Event):void
		{
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
			dispatcher.removeEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateDeployDatabaseRequest);
			configureListenersDeployDatabaseJob(false);
		}

		private function onImportDocumentJSONJobEnded(event:Event):void
		{
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
			dispatcher.removeEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateImportDocumentJSONRequest);
			configureListenersImportDocumentJSONJob(false);
		}

		private function onDeployRoyaleEnded(event:Event):void
		{
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
			dispatcher.removeEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateDeployRoyaleVagrantRequest);

			if (event && event.type == DatabaseJobBase.EVENT_CONVERSION_COMPLETE)
			{
				navigateToURL(new URLRequest(deployRoyaleToVagrantJob.deployedURL));
			}

			configureListenersDeployRoyaleToVagrantJob(false);
		}

		private function onRunDatabaseToVagrantEnded(event:Event):void
		{
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
			dispatcher.removeEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateRunDatabaseVagrantRequest);

			if (event && event.type == DatabaseJobBase.EVENT_CONVERSION_COMPLETE)
			{

			}

			configureListenersRunDatabaseToVagrantJob(false);
		}

		private function onDeployBuildOnVagrantEnded(event:Event):void
		{
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
			dispatcher.removeEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateBuildOnVagrantRequest);

			if (event && event.type == DatabaseJobBase.EVENT_CONVERSION_COMPLETE)
			{

			}

			configureListenersDeployBuildOnVagrantJob(false);
		}

		private function onDBConversionUploadUpdates(event:Event):void
		{
			if (event.type == DatabaseJobBase.EVENT_VAGRANT_UPLOAD_COMPLETES)
			{
				convertDominoDBPopup.close();
			}
			else
			{
				convertDominoDBPopup.reset();
			}
		}

		private function onDeployDatabaseUploadUpdates(event:Event):void
		{
			if (event.type == DatabaseJobBase.EVENT_VAGRANT_UPLOAD_COMPLETES)
			{
				deployDominoDBPopup.close();
			}
			else
			{
				deployDominoDBPopup.reset();
			}
		}

		private function onImportDocumentJSONUploadUpdates(event:Event):void
		{
			if (event.type == DatabaseJobBase.EVENT_VAGRANT_UPLOAD_COMPLETES)
			{
				importDocumentsJSONPopup.close();
			}
			else
			{
				importDocumentsJSONPopup.reset();
			}
		}

		private function onDeployRoyaleUploadUpdates(event:Event):void
		{
			if (event.type == DatabaseJobBase.EVENT_VAGRANT_UPLOAD_COMPLETES)
			{
				deployRoyaleVagrantPopup.close();
			}
			else
			{
				deployRoyaleVagrantPopup.reset();
			}
		}

		private function onVagrantUploadUpdates(event:Event):void
		{
			if (event.type == DatabaseJobBase.EVENT_VAGRANT_UPLOAD_COMPLETES)
			{
				selectVagrantPopup.close();
			}
			else
			{
				selectVagrantPopup.reset();
			}
		}

		private function onBuildOnVagrantUploadUpdates(event:Event):void
		{
			if (event.type == DatabaseJobBase.EVENT_VAGRANT_UPLOAD_COMPLETES)
			{
				selectVagrantPopup.close();
			}
			else
			{
				selectVagrantPopup.reset();
			}
		}

		private function onTerminateConversionRequest(event:StatusBarEvent):void
		{
			dbConversionJob.stop();
			onDBConversionEnded(null);
		}

		private function onTerminateDeployDatabaseRequest(event:StatusBarEvent):void
		{
			deployDBJob.stop();
			onDeployDatabaseEnded(null);
		}

		private function onTerminateImportDocumentJSONRequest(event:StatusBarEvent):void
		{
			importDocumentJSONJob.stop();
			onImportDocumentJSONJobEnded(null);
		}

		private function onTerminateDeployRoyaleVagrantRequest(event:StatusBarEvent):void
		{
			deployRoyaleToVagrantJob.stop();
			onDeployRoyaleEnded(null);
		}

		private function onTerminateRunDatabaseVagrantRequest(event:StatusBarEvent):void
		{
			runDatabaseOnVagrantJob.stop();
			onRunDatabaseToVagrantEnded(null);
		}

		private function onTerminateBuildOnVagrantRequest(event:StatusBarEvent):void
		{
			deployBuildOnVagrantJob.stop();
			onDeployBuildOnVagrantEnded(null);
		}

		private function updateEventListeners():void
		{
			var eventName:String;
			for each (var option:String in VagrantUtil.VAGRANT_MENU_OPTIONS)
			{
				eventName = "eventVagrant"+ option;
				dispatcher.addEventListener(eventName, onVagrantOptionSelect, false, 0, true);
			}

			dispatcher.addEventListener(FTETreeItemRenderer.CONFIGURE_VAGRANT, onConfigureVagrant, false, 0, true);
		}

		private function removeMenuListeners():void
		{
			var eventName:String;
			for each (var option:String in VagrantUtil.VAGRANT_MENU_OPTIONS)
			{
				eventName = "eventVagrant"+ option;
				dispatcher.removeEventListener(eventName, onVagrantOptionSelect);
			}

			dispatcher.removeEventListener(FTETreeItemRenderer.CONFIGURE_VAGRANT, onConfigureVagrant);
		}

		private function onConfigureVagrant(event:Event):void
		{
			dispatcher.dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, NAMESPACE));
		}

		private function onVagrantOptionSelect(event:FilePluginEvent):void
		{
			startVagrantConsole();

			var optionSelected:String = event.type.replace("eventVagrant", "");
			switch (optionSelected)
			{
				case VagrantUtil.VAGRANT_UP:
					vagrantUp(event.file);
					break;
				case VagrantUtil.VAGRANT_HALT:
					vagrantHalt(event.file);
					break;
				case VagrantUtil.VAGRANT_RELOAD:
					vagrantReload(event.file);
					break;
				case VagrantUtil.VAGRANT_SSH:
					vagrantSSH(event.file);
					break;
				case VagrantUtil.VAGRANT_DESTROY:
					vagrantDestroyConfirm(event.file);
					break;
			}
		}

		private function startVagrantConsole():void
		{
			if (!vagrantConsole)
			{
				vagrantConsole = new VagrantConsolePlugin();
				vagrantConsole.addEventListener(VagrantConsolePlugin.EVENT_PLUGIN_DEACTIVATED, onConsoleDeactivated, false, 0, true);
			}
			else
			{
				vagrantConsole.show();
			}
		}

		private function onConsoleDeactivated(event:Event):void
		{
			if (vagrantConsole)
			{
				vagrantConsole.removeEventListener(VagrantConsolePlugin.EVENT_PLUGIN_DEACTIVATED, onConsoleDeactivated);
				vagrantConsole = null;
			}
		}

		private function vagrantUp(file:FileLocation):void
		{
			if (running)
			{
				Alert.show("A Vagrant process is already running. Halt the running process before starting new.", "Error!");
				return;
			}

			var binPath:String = UtilsCore.getVagrantBinPath();
			var command:String;
			if (ConstantsCoreVO.IS_MACOS)
			{
				command = '"'+ binPath +'" up 2>&1 | tee vagrant_up.log';
			}
			else
			{
				var powerShellPath:String = UtilsCore.getPowerShellExecutablePath();
				if (powerShellPath)
				{
					command = '"'+ powerShellPath +'" "'+ binPath +' up 2>&1 | tee vagrant_up.log"';	
				}
				else
				{
					error("Failed to locate PowerShell during execution.");
					return;
				}
			}
			
			warning("%s", command);
			success("Log file location: "+ file.fileBridge.parent.fileBridge.nativePath + file.fileBridge.separator +"vagrant_up.log");
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Vagrant Up", "Running "));
			dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateRunningVagrant, false, 0, true);
			
			this.start(
				new <String>[command], file.fileBridge.parent
			);
		}

		public function vagrantHalt(file:FileLocation):void
		{
			if (running)
			{
				dispatcher.removeEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateRunningVagrant);

				stop(true);
				haltMethod = new MethodDescriptor(this, "vagrantHalt", file);
				return;
			}

			var command:String = '"'+ UtilsCore.getVagrantBinPath() +'" halt';
			warning("%s", command);
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Vagrant Halt", "Running ", false));

			this.start(
					new <String>[command], file.fileBridge.parent
			);
		}

		public function vagrantReload(file:FileLocation):void
		{
			if (running)
			{
				stop(true);
				haltMethod = new MethodDescriptor(this, "vagrantReload", file);
				return;
			}

			var binPath:String = UtilsCore.getVagrantBinPath();
			var command:String;
			if (ConstantsCoreVO.IS_MACOS)
			{
				command = '"'+ binPath +'" reload 2>&1 | tee vagrant_reload.log';
			}
			else
			{
				var powerShellPath:String = UtilsCore.getPowerShellExecutablePath();
				if (powerShellPath)
				{
					command = '"'+ powerShellPath +'" "'+ binPath +' reload 2>&1 | tee vagrant_reload.log"';	
				}
				else
				{
					error("Failed to locate PowerShell during execution.");
					return;
				}
			}

			warning("%s", command);
			success("Log file location: "+ file.fileBridge.parent.fileBridge.nativePath + file.fileBridge.separator +"vagrant_reload.log");
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Vagrant Reload", "Running "));
			dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateRunningVagrant, false, 0, true);

			this.start(
					new <String>[command], file.fileBridge.parent
			);
		}

		private function onTerminateRunningVagrant(event:StatusBarEvent):void
		{
			if (running)
			{
				dispatcher.removeEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateRunningVagrant);
				stop(true);
			}
		}

		private function vagrantSSH(file:FileLocation):void
		{
			if (ConstantsCoreVO.IS_MACOS)
			{
				VagrantUtil.runVagrantSSHAt(file.fileBridge.parent.fileBridge.nativePath);
			}
			else
			{
				this.start(
					new <String>['start cmd /k "cd \"'+ file.fileBridge.parent.fileBridge.nativePath +'\" & cls & \"'+ UtilsCore.getVagrantBinPath() +'\" ssh"'],
					file.fileBridge.parent
				);
			}
		}

		public function vagrantDestroy(file:FileLocation):void
		{
			var command:String = '"'+ UtilsCore.getVagrantBinPath() +'" destroy -f';
			warning("%s", command);
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Vagrant Destroy", "Running ", true));
			dispatcher.addEventListener(StatusBarEvent.PROJECT_BUILD_TERMINATE, onTerminateRunningVagrant, false, 0, true);

			this.start(
					new <String>[command], file.fileBridge.parent
			);
		}

		private function vagrantDestroyConfirm(file:FileLocation):void
		{
			vagrantFileLocation = file;
			Alert.show(
					"Are you sure you want to destroy the Vagrant instance for:\n\n"+ file.fileBridge.parent.fileBridge.nativePath +"\n\n" +
					"The virtual machine will be permanently destroyed, and will need to be recreated for future tests.\n\nThe Vagrant template will *not* be removed.",
					"Warning!",
					Alert.YES | Alert.CANCEL,
					null,
					onDestroyConfirm, null, Alert.CANCEL
			);
		}
		
		private function onDestroyConfirm(eventObj:CloseEvent):void
		{
			// Check to see if the OK button was pressed.
			if (eventObj.detail == Alert.YES)
			{
				if (running)
				{
					stop(true);
					haltMethod = new MethodDescriptor(this, "vagrantHalt", vagrantFileLocation);
					destroyMethod = new MethodDescriptor(this, "vagrantDestroy", vagrantFileLocation);
				}
				else
				{
					vagrantHalt(vagrantFileLocation);
					destroyMethod = new MethodDescriptor(this, "vagrantDestroy", vagrantFileLocation);
				}
			}
		}

		override protected function onNativeProcessExit(event:NativeProcessExitEvent):void
		{
			super.onNativeProcessExit(event);
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));

			// run any queued process
			if (haltMethod)
			{
				haltMethod.callMethod();
				haltMethod = null;
				return;
			}
			if (destroyMethod)
			{
				destroyMethod.callMethod();
				destroyMethod = null;
			}

			vagrantFileLocation = null;
		}
	}
}