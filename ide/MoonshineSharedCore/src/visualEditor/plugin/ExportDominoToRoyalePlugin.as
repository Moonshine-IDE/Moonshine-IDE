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
    import actionScripts.factory.FileLocation;
    import actionScripts.valueObjects.FileWrapper;

    import flash.events.Event;

    import actionScripts.events.ExportVisualEditorProjectEvent;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import converter.DominoConverter;
    import surface.SurfaceMockup;

    public class ExportDominoToRoyalePlugin extends PluginBase
    {
        private var _currentProject:AS3ProjectVO;
        private var _exportedProject:AS3ProjectVO;

        public function ExportDominoToRoyalePlugin()
        {
            super();
        }

        override public function get name():String { return "Export Domino Visual Editor Project to Apache Royale Plugin"; }
        override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
        override public function get description():String { return "Exports Domino Visual Editor project to Apache Royale."; }

        override public function activate():void
        {
            super.activate();

            dispatcher.addEventListener(ExportVisualEditorProjectEvent.EVENT_EXPORT_DOMINO_VISUALEDITOR_PROJECT_TO_ROYALE,
                    generateApacheRoyaleProjectHandler);
         //   dispatcher.addEventListener(CloseTabEvent.EVENT_TAB_CLOSED, exportTabClosedHandler);
        }

        override public function deactivate():void
        {
            super.deactivate();

            dispatcher.removeEventListener(ExportVisualEditorProjectEvent.EVENT_EXPORT_DOMINO_VISUALEDITOR_PROJECT_TO_ROYALE,
                    generateApacheRoyaleProjectHandler);
            //dispatcher.addEventListener(CloseTabEvent.EVENT_TAB_CLOSED, exportTabClosedHandler);
        }

        private function generateApacheRoyaleProjectHandler(event:Event):void
        {
            _currentProject = model.activeProject as AS3ProjectVO;
            if (_currentProject == null || !_currentProject.isDominoVisualEditorProject)
            {
                error("This is not Visual Editor PrimeFaces project");
                return;
            }

            _exportedProject = _currentProject.clone() as AS3ProjectVO;

            var visualEditorFiles:Array = getVisualEditorFiles(_currentProject.projectFolder);

            convertToRoyale(visualEditorFiles);
        }

        private function convertToRoyale(visualEditorFiles:Array):void
        {
            var dominoConverter:DominoConverter = new DominoConverter();
            for (var i:int = 0; i < visualEditorFiles.length; i++)
            {
                var veFile:FileLocation = new FileLocation(visualEditorFiles[i].nativePath);
                var dominoXML:XML = this.getXmlConversion(veFile);
                var surfaceMockup:SurfaceMockup = dominoConverter.fromXMLAutoConvert(dominoXML);
            }
        }

        private function getVisualEditorFiles(destination:FileWrapper):Array
        {
            var separator:String = destination.file.fileBridge.separator;
            var visualEditorSrcPath:String = "visualeditor-src" + separator + "main" + separator + "webapp";
            var visualEditorSrcFolder:FileLocation = destination.file.resolvePath(visualEditorSrcPath);

            var veSrcFiles:Array = visualEditorSrcFolder.fileBridge.getDirectoryListing();

            return veSrcFiles;
        }

        private function getXmlConversion(file:FileLocation):XML
        {
            var data:Object = file.fileBridge.read();
            var xmlConversion:XML = new XML(data);

            return xmlConversion;
        }
    }
}
