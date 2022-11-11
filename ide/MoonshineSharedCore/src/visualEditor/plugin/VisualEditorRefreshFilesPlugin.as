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
package visualEditor.plugin
{
    import actionScripts.events.NewFileEvent;
    import actionScripts.events.RefreshTreeEvent;
    import actionScripts.events.RefreshVisualEditorSourcesEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.FileWrapper;

    public class VisualEditorRefreshFilesPlugin extends PluginBase
    {
        private const VISUALEDITOR_SRC_FOLDERNAME:String = "visualeditor-src";
        private const VISUALEDITOR_FILE_EXTENSION:String = "xml";

        public function VisualEditorRefreshFilesPlugin()
        {
            super();
        }

        override public function get name():String { return "Refresh Visual Editor project files"; }
        override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
        override public function get description():String { return "Translate and copy manually added Visual Editor XML project files to visualeditor-src folder"; }

        override public function activate():void
        {
            super.activate();

            dispatcher.addEventListener(RefreshVisualEditorSourcesEvent.REFRESH_VISUALEDITOR_SRC, visualEditorRefreshSrcHandler);
        }

        override public function deactivate():void
        {
            super.deactivate();

            dispatcher.removeEventListener(RefreshVisualEditorSourcesEvent.REFRESH_VISUALEDITOR_SRC, visualEditorRefreshSrcHandler);
        }

        private function visualEditorRefreshSrcHandler(event:RefreshVisualEditorSourcesEvent):void
        {
            var fileWrapper:FileWrapper = event.fileWrapper;
            var project:AS3ProjectVO = event.project;
            var destinationPath:String = fileWrapper.nativePath;

            var isValidSourcePath:Boolean = isPathValidForRefresh(fileWrapper.nativePath, project);
            var visualEditorPathForRefresh:String = getFullVisualEditorPathForRefresh(fileWrapper, project);

            if (!isValidSourcePath || fileWrapper.nativePath == project.folderPath)
            {
                destinationPath = project.sourceFolder.fileBridge.nativePath;
                fileWrapper = new FileWrapper(new FileLocation(destinationPath), fileWrapper.isRoot,
                        fileWrapper.projectReference, fileWrapper.shallUpdateChildren);
                isValidSourcePath = false;
            }

            var newVisualEditorFiles:Array = getNewVisualEditorSourceFiles(visualEditorPathForRefresh, destinationPath);

            var newFilesCreated:Boolean = createNewVisualEditorFiles(newVisualEditorFiles, fileWrapper, project);
            if (newFilesCreated || isValidSourcePath)
            {
                dispatcher.dispatchEvent(new RefreshTreeEvent(new FileLocation(fileWrapper.nativePath)));
            }
        }

        private function createNewVisualEditorFiles(newVisualEditorFiles:Array, originWrapper:FileWrapper, ofProject:AS3ProjectVO):Boolean
        {
            var newFilesCreated:Boolean = false;

            newVisualEditorFiles = validateNewVisualEditorFiles(newVisualEditorFiles);
            if (newVisualEditorFiles.length == 0)
            {
                return newFilesCreated;
            }

            for each (var file:Object in newVisualEditorFiles)
            {
				var divTemplateFile:Object = ConstantsCoreVO.TEMPLATES_VISUALEDITOR_FILES_PRIMEFACES[0];
				var newFileEvent:NewFileEvent = new NewFileEvent(NewFileEvent.EVENT_NEW_VISUAL_EDITOR_FILE, 
					null, 
					new FileLocation(divTemplateFile.nativePath), 
					originWrapper, 
					{relayEvent: false});
				newFileEvent.ofProject = ofProject;
				newFileEvent.fileName = getVisualEditorFileNameWithoutExtension(file.name);
				newFileEvent.isOpenAfterCreate = false; // important in this place
				
				dispatcher.dispatchEvent(newFileEvent);

                newFilesCreated = true;
            }

            return newFilesCreated;
        }

        private function validateNewVisualEditorFiles(newVisualEditorFiles:Array):Array
        {
            var validatedFiles:Array = [];
            for each (var item:Object in newVisualEditorFiles)
            {
                var visualEditorFile:FileLocation = item.file;
                var visualEditorXML:XML = new XML(visualEditorFile.fileBridge.read());

                var rootDiv:XMLList = visualEditorXML.RootDiv;

                if (rootDiv.length() > 0)
                {
                    visualEditorXML.RootDiv.@save = true;
                    visualEditorFile.fileBridge.save(visualEditorXML.toXMLString());

                    validatedFiles.push(item.file);
                }
            }

            return validatedFiles;
        }

        private function getFullVisualEditorPathForRefresh(fileWrapper:FileWrapper, project:AS3ProjectVO):String
        {
            var isValidSourcePath:Boolean = isPathValidForRefresh(fileWrapper.nativePath, project);
            var pathForRefresh:String = fileWrapper.nativePath;
            if (!isValidSourcePath)
            {
                pathForRefresh = project.sourceFolder.fileBridge.nativePath;
            }

            var separator:String = project.sourceFolder.fileBridge.separator;
            if (pathForRefresh != project.folderPath)
            {
                pathForRefresh = separator + getExtractedPathForRefresh(separator, pathForRefresh);
            }
            else
            {
                pathForRefresh = separator + "main" + separator + "webapp";
            }

            return project.folderPath.concat(separator, VISUALEDITOR_SRC_FOLDERNAME, pathForRefresh);
        }

        private function getNewVisualEditorSourceFiles(visualEditorPathForRefresh:String, destinationPath:String):Array
        {
            var pathForRefreshLocation:FileLocation = new FileLocation(visualEditorPathForRefresh);
            var separator:String = pathForRefreshLocation.fileBridge.separator;

            var dirs:Array = pathForRefreshLocation.fileBridge.getDirectoryListing();
            var newFiles:Array = [];

            for each (var file:Object in dirs)
            {
                if (!file.isDirectory && file.extension == VISUALEDITOR_FILE_EXTENSION)
                {
                    var destinationFilePath:String = destinationPath + separator + getVisualEditorFileNameWithoutExtension(file.name) + ".xhtml";
                    var destinationFileLocation:FileLocation = new FileLocation(destinationFilePath);
                    if (!destinationFileLocation.fileBridge.exists)
                    {
                        newFiles.push({file: new FileLocation(file.nativePath), newFile: destinationFileLocation});
                    }
                }
            }

            return newFiles;
        }

        private function getExtractedPathForRefresh(separator:String, fullPath:String):String
        {
            var src:String = separator + "src" + separator;
            var srcIndex:int = fullPath.indexOf(src) + src.length;

            return fullPath.substr(srcIndex);
        }

        private function isPathValidForRefresh(pathForRefresh:String, project:AS3ProjectVO):Boolean
        {
            return pathForRefresh.indexOf(project.sourceFolder.fileBridge.nativePath) != -1 ||
                   pathForRefresh == project.folderPath;
        }

        private function getVisualEditorFileNameWithoutExtension(name:String):String
        {
            var indexOfFileExtension:int = name.lastIndexOf(VISUALEDITOR_FILE_EXTENSION);
            return name.substr(0, indexOfFileExtension - 1);
        }
    }
}
