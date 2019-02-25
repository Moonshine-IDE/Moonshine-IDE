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
    import flash.display.DisplayObject;
    import flash.events.Event;
    
    import actionScripts.events.AddTabEvent;
    import actionScripts.events.ExportVisualEditorProjectEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.plugin.settings.SettingsView;
    import actionScripts.plugin.settings.vo.AbstractSetting;
    import actionScripts.plugin.settings.vo.BooleanSetting;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.plugin.settings.vo.PathSetting;
    import actionScripts.plugin.settings.vo.SettingsWrapper;
    import actionScripts.plugin.settings.vo.StaticLabelSetting;
    import actionScripts.plugin.settings.vo.StringSetting;
    import actionScripts.ui.tabview.CloseTabEvent;

    public class ExportToPrimeFacesPlugin extends PluginBase
    {
        private var exportView:SettingsView;

        private var newProjectNameSetting:StringSetting;
        private var newProjectPathSetting:PathSetting;
        private var projectWithExistingsSourceSetting:BooleanSetting;

        private var _currentProject:AS3ProjectVO;
        private var _exportedProject:AS3ProjectVO;

        public function ExportToPrimeFacesPlugin()
        {
            super();
        }

        override public function get name():String { return "Export Visual Editor Project to PrimeFaces Plugin"; }
        override public function get author():String { return "Moonshine Project Team"; }
        override public function get description():String { return "Exports Visual Editor project to PrimeFaces."; }

        override public function activate():void
        {
            super.activate();

            dispatcher.addEventListener(ExportVisualEditorProjectEvent.EVENT_EXPORT_VISUALEDITOR_PROJECT_TO_PRIMEFACES,
                            exportVisualEditorProjectToPrimeFacesHandler);
            dispatcher.addEventListener(CloseTabEvent.EVENT_TAB_CLOSED, exportTabClosedHandler);
        }

        override public function deactivate():void
        {
            super.deactivate();

            dispatcher.removeEventListener(ExportVisualEditorProjectEvent.EVENT_EXPORT_VISUALEDITOR_PROJECT_TO_PRIMEFACES,
                    exportVisualEditorProjectToPrimeFacesHandler);
            dispatcher.addEventListener(CloseTabEvent.EVENT_TAB_CLOSED, exportTabClosedHandler);
        }

        private function exportVisualEditorProjectToPrimeFacesHandler(event:Event):void
        {
            _currentProject = model.activeProject as AS3ProjectVO;
            if (_currentProject == null || !_currentProject.isPrimeFacesVisualEditorProject)
            {
                error("This is not Visual Editor PrimeFaces project");
                return;
            }

            _exportedProject = _currentProject.clone() as AS3ProjectVO;
            _exportedProject.projectName = _exportedProject.projectName + "_exported";

            exportView = new SettingsView();
            exportView.exportProject = _exportedProject;
            exportView.Width = 150;
            exportView.defaultSaveLabel = "Export";
            exportView.isNewProjectSettings = true;

            exportView.addCategory("");

            var settings:SettingsWrapper = getProjectSettings(_exportedProject);
            exportView.addEventListener(SettingsView.EVENT_SAVE, onProjectCreateExecute);
            exportView.addEventListener(SettingsView.EVENT_CLOSE, onProjectCreateClose);
            exportView.addSetting(settings, "");

            exportView.label = "New Project";
            exportView.associatedData = _exportedProject;

            if (newProjectPathSetting.stringValue)
            {
                newProjectPathSetting.setMessage(_exportedProject.folderLocation.resolvePath(_exportedProject.projectName).fileBridge.nativePath);
            }

            dispatcher.dispatchEvent(new AddTabEvent(exportView));
        }

        private function exportTabClosedHandler(event:CloseTabEvent):void
        {
            if (event.tab == exportView)
            {
                cleanUpExportView();
            }
        }

        private function getProjectSettings(project:AS3ProjectVO):SettingsWrapper
        {
            newProjectNameSetting = new StringSetting(project, 'projectName', 'Project name', '^ ~`!@#$%\\^&*()\\-+=[{]}\\\\|:;\'",<.>/?');

            if (!_exportedProject.isExportedToExistingSource)
            {
                newProjectNameSetting.isEditable = true;
                project.visualEditorExportPath = getDefaultExportPath(project);
            }
            else
            {
                newProjectNameSetting.isEditable = false;
            }

            newProjectPathSetting = new PathSetting(project, 'visualEditorExportPath', 'Parent directory', true, null, false);
            projectWithExistingsSourceSetting = new BooleanSetting(project, "isExportedToExistingSource", "Project with existing source", true);

            newProjectNameSetting.addEventListener(StringSetting.VALUE_UPDATED, onProjectNameChanged);
            newProjectPathSetting.addEventListener(AbstractSetting.PATH_SELECTED, onProjectPathChanged);
            projectWithExistingsSourceSetting.addEventListener(BooleanSetting.VALUE_UPDATED, onProjectWithExistingSourceValueUpdated);

            return new SettingsWrapper("Name & Location", Vector.<ISetting>([
                new StaticLabelSetting('New ' + project.projectName),
                newProjectNameSetting, projectWithExistingsSourceSetting, newProjectPathSetting
            ]));
        }

        private function onProjectNameChanged(event:Event):void
        {
            _exportedProject.projectName = newProjectNameSetting.stringValue;
            var newProjectLocation:FileLocation = _exportedProject.folderLocation.resolvePath(newProjectNameSetting.stringValue);
            if (canSaveProject(newProjectLocation))
            {
                newProjectPathSetting.setMessage("(Project can not be created in an existing project directory)\n"+ newProjectLocation.fileBridge.nativePath,
					AbstractSetting.MESSAGE_CRITICAL);
            }
            else
            {
                newProjectPathSetting.setMessage(newProjectLocation.fileBridge.nativePath);
            }
        }

        private function onProjectPathChanged(event:Event):void
        {
            _exportedProject.projectFolder = null;
            _exportedProject.folderLocation = new FileLocation(newProjectPathSetting.stringValue);
            var separator:String = _currentProject.sourceFolder.fileBridge.separator;

            if (_exportedProject.isExportedToExistingSource)
            {
                if (newProjectPathSetting.stringValue)
                {
                    newProjectNameSetting.stringValue = _exportedProject.folderLocation.name;
                    newProjectPathSetting.setMessage(newProjectPathSetting.stringValue);
                }
            }
            else
            {
                newProjectPathSetting.setMessage(newProjectPathSetting.stringValue + separator + newProjectNameSetting.stringValue);
            }
        }

        private function onProjectWithExistingSourceValueUpdated(event:Event):void
        {
            if (_exportedProject.isExportedToExistingSource)
            {
                newProjectNameSetting.isEditable = false;
                newProjectNameSetting.stringValue = _exportedProject.folderLocation.name;

                if (newProjectPathSetting.stringValue)
                {
                    newProjectPathSetting.setMessage(newProjectPathSetting.stringValue);
                }
            }
            else
            {
                var separator:String = _currentProject.sourceFolder.fileBridge.separator;

                newProjectNameSetting.isEditable = true;
                newProjectNameSetting.stringValue = _currentProject.projectName + "_exported";

                if (newProjectPathSetting.stringValue)
                {
                    newProjectPathSetting.setMessage(_exportedProject.projectFolder.nativePath + separator + newProjectNameSetting.stringValue);
                }
            }
        }

        private function onProjectCreateExecute(event:Event):void
        {
            if (!newProjectPathSetting.stringValue)
            {
                error("Select path for successfully export %s.", _currentProject.projectName);
                return;
            }

            var destination:FileLocation = _exportedProject.folderLocation;
            if (!_exportedProject.isExportedToExistingSource)
            {
                destination = _exportedProject.folderLocation.resolvePath(newProjectNameSetting.stringValue);
                _exportedProject.visualEditorExportPath = destination.fileBridge.nativePath;
                destination.fileBridge.createDirectory();
            }

            copyPrimeFacesPom(destination);
            copyPrimeFacesWebFile(destination);
            copyPrimeFacesResources(destination);
            copySources(destination);

            _currentProject.isExportedToExistingSource = _exportedProject.isExportedToExistingSource;
            _currentProject.visualEditorExportPath = _exportedProject.visualEditorExportPath;
            _currentProject.saveSettings();

            success("PrimeFaces project " + newProjectNameSetting.stringValue + " has been successfully saved.");

            onProjectCreateClose(event);
        }

        private function copySources(destination:FileLocation):void
        {
            var webappFolderExported:FileLocation = destination.resolvePath("src/main/webapp");

            var sources:FileLocation = _currentProject.sourceFolder;
            var sourcesToCopy:Array = sources.fileBridge.getDirectoryListing();
            var mainApplicationFile:FileLocation = _currentProject.targets[0];
            var mainFolder:FileLocation = _currentProject.folderLocation.resolvePath("src/main");

            sourcesToCopy = sourcesToCopy.filter(function (item:Object, index:int, arr:Array):Boolean
            {
                return item.nativePath.lastIndexOf("WEB-INF") == -1 && item.nativePath != mainFolder.fileBridge.nativePath;
            });

            for each (var item:Object in sourcesToCopy)
            {
                if (item.nativePath == mainApplicationFile.fileBridge.nativePath)
                {
                    mainApplicationFile.fileBridge.copyTo(webappFolderExported.resolvePath("index.xhtml"), _exportedProject.isExportedToExistingSource);
                }
                else
                {
                    item.copyTo(webappFolderExported.resolvePath(item.name).fileBridge.getFile, _exportedProject.isExportedToExistingSource);
                }
            }
        }

        private function onProjectCreateClose(event:Event):void
        {
            cleanUpExportView();
            dispatcher.dispatchEvent(new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, event.target as DisplayObject));
        }

        private function canSaveProject(newProjectLocation:FileLocation):Boolean
        {
            if (!newProjectLocation.fileBridge.exists) return false;

            var listing:Array = newProjectLocation.fileBridge.getDirectoryListing();
            for each (var file:Object in listing)
            {
                if (file.extension == "veditorproj")
                {
                    return true;
                }
            }

            return false;
        }

        private function copyPrimeFacesPom(destination:FileLocation):void
        {
            if (_exportedProject.isExportedToExistingSource) return;

            var currentFolder:FileLocation = _currentProject.folderLocation;
            var projectPom:FileLocation = currentFolder.fileBridge.resolvePath("pom.xml");
            
            var pomForCopy:FileLocation = destination.fileBridge.resolvePath("pom.xml");
            if (!pomForCopy.fileBridge.exists)
            {
                projectPom.fileBridge.copyTo(pomForCopy, true);
                return;
            }

            XML.ignoreWhitespace = true;
            XML.ignoreComments = true;

            var pom:XML = XML(projectPom.fileBridge.read());

            var qName:QName = new QName("http://maven.apache.org/POM/4.0.0", "artifactId");
            pom.replace(qName, <artifactId>{_exportedProject.projectName}</artifactId>);

            qName = new QName("http://maven.apache.org/POM/4.0.0", "name");
            pom.replace(qName, <name>{_exportedProject.projectName}</name>);

            pomForCopy.fileBridge.save(pom.toXMLString());
        }

        private function copyPrimeFacesWebFile(destination:FileLocation):void
        {
            destination = destination.resolvePath("src/main/webapp/WEB-INF/web.xml");
            if (destination.fileBridge.exists && _exportedProject.isExportedToExistingSource) return;

            var currentFolder:FileLocation = _currentProject.folderLocation;
            var webPath:String = "src/main/webapp/WEB-INF/web.xml";
            var webForCopy:FileLocation = currentFolder.fileBridge.resolvePath(webPath);

            webForCopy.fileBridge.copyTo(destination);
        }

        private function copyPrimeFacesResources(destination:FileLocation):void
        {
            var currentFolder:FileLocation = _currentProject.folderLocation;
            var webPath:String = "src/main/resources";
            var webForCopy:FileLocation = currentFolder.fileBridge.resolvePath(webPath);
            var dest:FileLocation = destination.resolvePath("src/main/resources");

            if (_exportedProject.isExportedToExistingSource)
            {
                var grailsStylesheetDest:FileLocation = destination.resolvePath("grails-app/assets/stylesheets");
                if (grailsStylesheetDest.fileBridge.exists)
                {
                    webForCopy.fileBridge.copyInto(grailsStylesheetDest);
                }
                else
                {
                    webForCopy.fileBridge.copyInto(dest);
                }
            }
            else
            {
                webForCopy.fileBridge.copyTo(dest);
            }
        }

        private function getDefaultExportPath(project:AS3ProjectVO):String
        {
            if (project.visualEditorExportPath)
            {
                return project.visualEditorExportPath;
            }

            var parentFolder:FileLocation = new FileLocation(project.folderPath).fileBridge.parent;
            return parentFolder.fileBridge.nativePath;
        }

        private function cleanUpExportView():void
        {
            exportView.removeEventListener(SettingsView.EVENT_CLOSE, onProjectCreateClose);
            exportView.removeEventListener(SettingsView.EVENT_SAVE, onProjectCreateExecute);
            if (newProjectPathSetting)
            {
                newProjectPathSetting.removeEventListener(AbstractSetting.PATH_SELECTED, onProjectPathChanged);
                newProjectNameSetting.removeEventListener(StringSetting.VALUE_UPDATED, onProjectNameChanged);
                projectWithExistingsSourceSetting.removeEventListener(BooleanSetting.VALUE_UPDATED, onProjectWithExistingSourceValueUpdated);
            }

            newProjectNameSetting = null;
            newProjectPathSetting = null;
            projectWithExistingsSourceSetting = null;

            _currentProject = null;
            _exportedProject = null;

            exportView = null;
        }
    }
}
