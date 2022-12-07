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
package actionScripts.plugins.exportToExternalProject
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
    import actionScripts.plugins.exportToExternalProject.utils.ExportContext;
    import actionScripts.plugins.exportToExternalProject.utils.TextLines;
    import actionScripts.plugins.exportToExternalProject.utils.ExportLogic;

    public class ExportToExternalProjectPlugin extends PluginBase
    {
        private var exportedProject:AS3ProjectVO;
        private var configView:ExportToRoyaleTemplatedAppConfigView;

        public var mainAppFile:String;

        public function ExportToExternalProjectPlugin()
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

            var cookie:SharedObject = SharedObject.getLocal(SharedObjectConst.MOONSHINE_IDE_LOCAL);

            configView = new ExportToRoyaleTemplatedAppConfigView();
            configView.label = "Export to Royale Templated Application";
            configView.defaultSaveLabel = "Export";

            configView.addEventListener(SettingsView.EVENT_SAVE, onExport);
            configView.addEventListener(CloseEvent.CLOSE, onCancelReport);

            addReportItems();
            dispatcher.dispatchEvent(new AddTabEvent(configView));
        }

        private function addReportItems():void
        {
            var apiReportItems:Vector.<ISetting> = Vector.<ISetting>([]);

            var mainAppFile:ISetting = getMainApplicationFileSetting();
            apiReportItems.push(mainAppFile);

            var settingsWrapper:SettingsWrapper = new SettingsWrapper("Export to Royale Templated Application", apiReportItems);

            configView.addCategory("Export");
            configView.addSetting(settingsWrapper, "Export");
        }

        private function onExport(event:Event):void
        {
        		var context:ExportContext = new ExportContext(exportedProject, mainAppFile);
        		var targetMainApp:TextLines = ExportLogic.load(context.targetMainAppLocation);
        		
        		if (!ExportLogic.hasContent(targetMainApp) || !ExportLogic.isRoyaleApp(targetMainApp))
        		{
        			error("Main application file of selected project is empty or it is not Apache Royale project.");
                return;
        		}
        		
        		if (!ExportLogic.hasSrcFolder(context.targetMainContentLocation))
        		{
       		    error("Project does not contain src folder.");
                return;
        		}
        		
        		var targetMainContent:TextLines = ExportLogic.load(context.targetMainContentLocation);
        		
        		if (!ExportLogic.hasContent(targetMainContent))
        		{
        			error("Main content application file is empty.");
                return;
        		}
        		
        		var sourceMainContent:TextLines = ExportLogic.load(context.sourceMainContentLocation);
        		
        		var cssSection:TextLines = context.cssSection();
        			
        		var mainContentSection:TextLines = sourceMainContent.getSection(
        			context.mainContentManagerStartToken, 
        			context.mainContentManagerEndToken);
        		
        		for (var i:int = 0; i < mainContentSection.lines.length; i++)
			{
				mainContentSection.lines[i] = mainContentSection.lines[i].replace("/src/", "/generated/");
			}        		
        			
        		var menuSection:TextLines = sourceMainContent.getSection(
        			context.menuStartToken, 
        			context.menuEndToken);
        			
        		var viewsSection:TextLines = sourceMainContent.getSection(
        			context.viewsStartToken, 
        			context.viewsEndToken);
			
        	    var cssCursor:int = targetMainApp.findFirstLine(ExportContext.CSS_CURSOR);
            targetMainApp.insertSection(cssSection, cssCursor);
            ExportLogic.save(targetMainApp, context.targetMainAppLocation);

            var mainContentCursor:int = targetMainContent.findFirstLine(ExportContext.GENERATED_MAINCONTENTMANAGER_CURSOR);
            targetMainContent.insertSection(mainContentSection, mainContentCursor);
            
            var menuCursor:int = targetMainContent.findFirstLine(ExportContext.GENERATED_MENU_CURSOR);
            targetMainContent.insertSection(menuSection, menuCursor);
            
            var viewsCursor:int = targetMainContent.findFirstLine(ExportContext.GENERATED_VIEWS_CURSOR);
            targetMainContent.insertSection(viewsSection, viewsCursor);
            
            ExportLogic.save(targetMainContent, context.targetMainContentLocation);

            copyFilesToNewProject(context.targetSrcLocation);

            onCancelReport(null);
        }

        private function onCancelReport(event:CloseEvent):void
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
            configView.removeEventListener(SettingsView.EVENT_CLOSE, onExport);
            configView.removeEventListener(SettingsView.EVENT_SAVE, onCancelReport);

            configView = null;
        }
    }
}
