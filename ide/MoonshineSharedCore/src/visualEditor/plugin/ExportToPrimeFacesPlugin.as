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
    import actionScripts.events.AddTabEvent;
    import actionScripts.events.ExportVisualEditorProjectEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.plugin.settings.SettingsView;
    import actionScripts.plugin.settings.vo.ISetting;
    import actionScripts.plugin.settings.vo.PathSetting;
    import actionScripts.plugin.settings.vo.SettingsWrapper;
    import actionScripts.plugin.settings.vo.StaticLabelSetting;
    import actionScripts.plugin.settings.vo.StringSetting;
    import actionScripts.ui.tabview.CloseTabEvent;

    import flash.display.DisplayObject;

    import flash.events.Event;

    public class ExportToPrimeFacesPlugin extends PluginBase
    {
        private var newProjectNameSetting:StringSetting;
        private var newProjectPathSetting:PathSetting;

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
        }

        override public function deactivate():void
        {
            super.deactivate();

            dispatcher.removeEventListener(ExportVisualEditorProjectEvent.EVENT_EXPORT_VISUALEDITOR_PROJECT_TO_PRIMEFACES,
                    exportVisualEditorProjectToPrimeFacesHandler);
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

            var settingsView:SettingsView = new SettingsView();
            settingsView.exportProject = _exportedProject;
            settingsView.Width = 150;
            settingsView.defaultSaveLabel = "Export";
            settingsView.isNewProjectSettings = true;

            settingsView.addCategory("");

            var settings:SettingsWrapper = getProjectSettings(_exportedProject);
            settingsView.addEventListener(SettingsView.EVENT_SAVE, onProjectCreateExecute);
            settingsView.addEventListener(SettingsView.EVENT_CLOSE, onProjectCreateClose);
            settingsView.addSetting(settings, "");

            settingsView.label = "New Project";
            settingsView.associatedData = _exportedProject;

            dispatcher.dispatchEvent(new AddTabEvent(settingsView));
        }

        private function getProjectSettings(project:AS3ProjectVO):SettingsWrapper
        {
            newProjectNameSetting = new StringSetting(project, 'projectName', 'Project name', '^\\\\\\/?:"|<>*!@#$%^&*()+{}[]:;~');
            newProjectPathSetting = new PathSetting(project, 'folderPath', 'Parent directory', true, null, false, true);
            newProjectPathSetting.addEventListener(PathSetting.PATH_SELECTED, onProjectPathChanged);
            newProjectNameSetting.addEventListener(StringSetting.VALUE_UPDATED, onProjectNameChanged);

            return new SettingsWrapper("Name & Location", Vector.<ISetting>([
                new StaticLabelSetting('New ' + project.projectName),
                newProjectNameSetting, newProjectPathSetting
            ]));
        }

        private function onProjectNameChanged(event:Event):void
        {
            var newProjectLocation:FileLocation = _exportedProject.folderLocation.resolvePath(newProjectNameSetting.stringValue);
            if (canSaveProject(newProjectLocation))
            {
                newProjectPathSetting.setCriticalMessage("(Project can not be created in an existing project directory)\n"+ newProjectLocation.fileBridge.nativePath);
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
        }

        private function onProjectCreateExecute(event:Event):void
        {
            var destination:FileLocation = _exportedProject.folderLocation.resolvePath(newProjectNameSetting.stringValue);

            var settingsView:SettingsView = event.target as SettingsView;

            destination.fileBridge.createDirectory();
            _currentProject.sourceFolder.fileBridge.copyTo(destination.resolvePath("src"));

            copyPrimeFacesPom(destination);
            copyPrimeFacesWebFile(destination);

            success("PrimeFaces project " + newProjectNameSetting.name + " has been successfully saved.");

            onProjectCreateClose(event);
        }

        private function onProjectCreateClose(event:Event):void
        {
            var settings:SettingsView = event.target as SettingsView;

            settings.removeEventListener(SettingsView.EVENT_CLOSE, onProjectCreateClose);
            settings.removeEventListener(SettingsView.EVENT_SAVE, onProjectCreateExecute);
            if (newProjectPathSetting)
            {
                newProjectPathSetting.removeEventListener(PathSetting.PATH_SELECTED, onProjectPathChanged);
                newProjectNameSetting.removeEventListener(StringSetting.VALUE_UPDATED, onProjectNameChanged);
            }

            newProjectNameSetting = null;
            newProjectPathSetting = null;

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
            var currentFolder:FileLocation = _currentProject.folderLocation;
            var pomForCopy:FileLocation = currentFolder.fileBridge.resolvePath("pom.xml");

            var pom:XML = XML(pomForCopy.fileBridge.read());

            var qName:QName = new QName("http://maven.apache.org/POM/4.0.0", "artifactId");
            pom.replace(qName, <artifactId>{newProjectNameSetting.name}</artifactId>);

            qName = new QName("http://maven.apache.org/POM/4.0.0", "name");
            pom.replace(qName, <name>{newProjectNameSetting.name}</name>);

            XML.ignoreWhitespace = true;
            XML.ignoreComments = true;
            
            pomForCopy = destination.fileBridge.resolvePath("pom.xml");
            pomForCopy.fileBridge.save(pom.toXMLString());
        }

        private function copyPrimeFacesWebFile(destination:FileLocation):void
        {
            var currentFolder:FileLocation = _currentProject.folderLocation;
            var webPath:String = "src/main/webapp/WEB-INF/web.xml";
            var webForCopy:FileLocation = currentFolder.fileBridge.resolvePath(webPath);
            var web:XML = XML(webForCopy.fileBridge.read());
            XML.ignoreWhitespace = true;
            XML.ignoreComments = true;

            var ns:Namespace=new Namespace("http://xmlns.jcp.org/xml/ns/javaee");
            var webChildren:XMLList = web.ns::["welcome-file-list"];

            for each (var item:XML in webChildren)
            {
                var welcomeFiles:XMLList = item.ns::["welcome-file"];
                if (welcomeFiles)
                {
                    welcomeFiles[0] = newProjectNameSetting.name;
                    break;
                }
            }

            var webFile:FileLocation = destination.resolvePath("src/main/webapp/WEB-INF/web.xml");
            webFile.fileBridge.save(web.toXMLString());
        }
    }
}
