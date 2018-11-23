////////////////////////////////////////////////////////////////////////////////
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
// No warranty of merchantability or fitness of any kind.
// Use this software at your own risk.
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
        override public function get author():String { return "Moonshine Project Team"; }
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
				var newFileEvent:NewFileEvent = new NewFileEvent(NewFileEvent.EVENT_NEW_VISUAL_EDITOR_FILE, null, new FileLocation(divTemplateFile.nativePath), originWrapper);
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
