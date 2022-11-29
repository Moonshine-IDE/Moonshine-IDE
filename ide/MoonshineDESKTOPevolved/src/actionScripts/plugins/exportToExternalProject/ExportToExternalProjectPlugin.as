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
package actionScripts.plugins.exportToExternalProject
{
    import actionScripts.events.ProjectEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.PluginBase;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.locator.IDEWorker;

    import flash.events.Event;

    public class ExportToExternalProjectPlugin extends PluginBase
    {
        private var exportedProject:AS3ProjectVO;

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

            var hasFolderProjectName:Boolean = new FileLocation(exportedProject.sourceFolder.fileBridge.nativePath + "/" + exportedProject.name).fileBridge.exists;

            if (!hasFolderProjectName)
            {
                error("Project which you are trying to export externally should contains inside src folder " + exportedProject.name);
                return;
            }
            model.fileCore.browseForDirectory("Project Directory", projectsByDirectory, onFileSelectionCancelled);
        }

        private function projectsByDirectory(dir:Object):void
        {
            var projectDir:String = (dir is FileLocation) ? (dir as FileLocation).fileBridge.nativePath : dir.nativePath;
            var projectDirSrc:FileLocation = new FileLocation(projectDir + "/src");
            var projectHasSourceDir:Boolean = projectDirSrc.fileBridge.exists;

            if (!projectHasSourceDir)
            {
                error("Project does not contain src folder");
                return;
            }

            var generatedFolder:FileLocation = new FileLocation(projectDirSrc.fileBridge.nativePath + "/generated");
                generatedFolder.fileBridge.createDirectory();

            var folderProjectName:FileLocation = new FileLocation(exportedProject.sourceFolder.fileBridge.nativePath + "/" + exportedProject.name);
                folderProjectName.fileBridge.parent.fileBridge.copyInto(generatedFolder);
        }

        private function onFileSelectionCancelled():void
        {
            /*event.target.removeEventListener(Event.SELECT, openFile);
			event.target.removeEventListener(Event.CANCEL, onFileSelectionCancelled);*/
        }
    }
}
