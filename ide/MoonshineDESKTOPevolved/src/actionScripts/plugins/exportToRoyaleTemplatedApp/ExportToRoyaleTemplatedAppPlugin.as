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
package actionScripts.plugins.exportToRoyaleTemplatedApp
{
    import actionScripts.events.AddTabEvent;
    import actionScripts.events.ProjectEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.PluginBase;
    import actionScripts.ui.tabview.CloseTabEvent;
    import actionScripts.utils.SharedObjectConst;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.locator.IDEWorker;
    import actionScripts.plugin.exportToExternalProject.ExportToRoyaleTemplatedAppConfigView;
    import actionScripts.plugin.settings.SettingsView;
    import actionScripts.plugin.settings.vo.PathSetting;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.plugin.settings.vo.SettingsWrapper;

    import flash.display.DisplayObject;

    import flash.events.Event;
    import flash.net.SharedObject;

    import mx.events.CloseEvent;
    import actionScripts.plugins.exportToRoyaleTemplatedApp.utils.ExportConstants;
    import actionScripts.plugins.exportToRoyaleTemplatedApp.utils.TextLines;
    import actionScripts.plugins.exportToRoyaleTemplatedApp.utils.ExportContext;
    import flash.text.engine.TextLine;

    public class ExportToRoyaleTemplatedAppPlugin extends PluginBase
    {
        private var exportedProject:AS3ProjectVO;
        private var configView:ExportToRoyaleTemplatedAppConfigView;

        public var mainAppFile:String;

        public function ExportToRoyaleTemplatedAppPlugin()
        {
            super();
        }

        override public function get name():String { return "Export Apache Royale project to another external project."; }
        override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
        override public function get description():String { return "Export Apache Royale project to another external project."; }

        override public function activate():void
        {
            super.activate();

            dispatcher.addEventListener(ProjectEvent.EVENT_EXPORT_TO_EXTERNAL_PROJECT,
                    exportToExternalProjectHandler);
        }

        override public function deactivate():void
        {
            super.deactivate();

            dispatcher.removeEventListener(ProjectEvent.EVENT_EXPORT_TO_EXTERNAL_PROJECT,
                    exportToExternalProjectHandler);
        }

        private function exportToExternalProjectHandler(event:Event):void
        {
            exportedProject = model.activeProject as AS3ProjectVO;
            if (exportedProject == null || !exportedProject.isRoyale)
            {
                error("This is not Apache Royale project");
                return;
            }

            configView = new ExportToRoyaleTemplatedAppConfigView();
            configView.label = "Export to Royale Templated Application";
            configView.defaultSaveLabel = "Export";

            configView.addEventListener(SettingsView.EVENT_SAVE, onExport);
            configView.addEventListener(SettingsView.EVENT_CLOSE, onCancelReport);

            addReportItems();
            dispatcher.dispatchEvent(new AddTabEvent(configView));
        }

        private function addReportItems():void
        {
            var apiReportItems:Vector.<ISetting> = Vector.<ISetting>([]);

            var mainAppFile:ISetting = getMainApplicationFileSetting();
            apiReportItems.push(mainAppFile);

            var settingsWrapper:SettingsWrapper = new SettingsWrapper("Export to Royale Templated Application", apiReportItems);

            configView.addCategory(exportedProject.name);
            configView.addSetting(settingsWrapper, exportedProject.name);
        }

        private function onExport(event:Event):void
        {
			var constants:ExportConstants = new ExportConstants(exportedProject.name);
			var context:ExportContext = new ExportContext(mainAppFile, exportedProject);
        		
			if (!context.targetSrcFolder)
			{
				printErrorAndCloseExport("Project does not contain src folder: " + mainAppFile);
				return;
			}
        		
			var targetMainApp:TextLines = TextLines.load(context.targetMainAppLocation);

			if (!targetMainApp.hasContent() || targetMainApp.findLine(constants.royaleJewelApplication) < 0)
			{
				printErrorAndCloseExport("Main application file of selected project is empty or it is not Apache Royale project.");
				return;
			}

			var targetMainContent:TextLines = TextLines.load(context.targetMainContentLocation);

			if (!targetMainContent.hasContent())
			{
				printErrorAndCloseExport("MainContent file does not exist or is empty.");
				return;
			}

			var sourceMainContent:TextLines = TextLines.load(context.sourceMainContentLocation);
			
			exportCssSection(targetMainApp, constants);
			exportMenuSection(sourceMainContent, targetMainContent, constants);
			
			var vst:Array = sourceMainContent.findAllLines(constants.viewsStartToken);
			var vet:Array = sourceMainContent.findAllLines(constants.viewsEndToken);
			exportViewsSection(sourceMainContent, targetMainContent, constants);
        			
            targetMainApp.save(context.targetMainAppLocation);            
            targetMainContent.save(context.targetMainContentLocation);

            copyFilesToNewProject(context.targetSrcFolder);

			success("Export " + exportedProject.name + " to Apache Royale Templated Application successfully finished.");
        }
        
        private function exportCssSection(target:TextLines, constants:ExportConstants):void
        {
        		var cssSection:TextLines = constants.getCssSection();
			target.replaceOrInsert(
				cssSection,
				constants.cssCursor);        		
        }
        
        private function exportMenuSection(source:TextLines, target:TextLines, constants:ExportConstants):void
        {
        		var menuSectionRanges:Array = source.findAllSections(
        			constants.menuStartToken, 
        			constants.menuEndToken);
        			
        		var menuSections:Array = [];
        		for each (var range:Array in menuSectionRanges)
        		{
        			menuSections.push(source.getSection(range[0], range[1]));
        		}
        		
        		for each (var section:TextLines in menuSections)
			target.replaceOrInsert(
				section,
				constants.menuCursor);		
        }
        
        private function exportViewsSection(source:TextLines, target:TextLines, constants:ExportConstants):void
        {
        		var viewSectionRanges:Array = source.findAllSections(
        			constants.viewsStartToken, 
        			constants.viewsEndToken);
        			
        		var viewSections:Array = [];
        		for each (var range:Array in viewSectionRanges)
        		{
        			viewSections.push(source.getSection(range[0], range[1]));
        		}
        		
        		for each (var section:TextLines in viewSections)
			target.replaceOrInsert(
				section,
				constants.viewsCursor);		
        }

        private function onCancelReport(event:Event):void
        {
			dispatcher.dispatchEvent(new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, configView as DisplayObject));
			cleanUp();
        }

        private function copyFilesToNewProject(projectDirSource:FileLocation):void
        {
            var separator:String = projectDirSource.fileBridge.separator;
            var generatedFolder:FileLocation = new FileLocation(projectDirSource.fileBridge.nativePath + separator + "generated");
            generatedFolder.fileBridge.createDirectory();

            var folderProjectName:FileLocation = new FileLocation(exportedProject.sourceFolder.fileBridge.nativePath + separator + exportedProject.name);
            folderProjectName.fileBridge.parent.fileBridge.copyInto(generatedFolder);
        }

        private function getMainApplicationFileSetting():ISetting
        {
            return new PathSetting(this, "mainAppFile", "Main application file", false, "", false, false, exportedProject.sourceFolder.fileBridge.parent.fileBridge.nativePath);
        }

        private function cleanUp():void
        {
            configView.removeEventListener(SettingsView.EVENT_SAVE, onExport);
            configView.removeEventListener(SettingsView.EVENT_CLOSE, onCancelReport);

            configView = null;
        }

		private function printErrorAndCloseExport(errorMessage:String):void
		{
			error(errorMessage);
			onCancelReport(null);
		}
    }
}
