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
    import actionScripts.factory.FileLocation;
    import actionScripts.valueObjects.FileWrapper;

    import actionScripts.events.ExportVisualEditorProjectEvent;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import converter.DominoConverter;

    import flash.events.Event;

    import surface.SurfaceMockup;
    import lookup.Lookup;

    public class ExportDominoJavaAgentsPlugin extends PluginBase
    {
        private var currentProject:AS3ProjectVO;
        private var conversionCounter:int;

        public function ExportDominoJavaAgentsPlugin()
        {
            super();
        }

        override public function get name():String { return "Generate Java Agents out of Domino Visual Editor Project."; }
        override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
        override public function get description():String { return "Generate Java Agents out of Domino Visual Editor Project."; }

        override public function activate():void
        {
            super.activate();

            dispatcher.addEventListener(ExportVisualEditorProjectEvent.EVENT_GENERATE_DOMINO_JAVA_AGENTS_OUT_OF_VISUALEDITOR_PROJECT,
                    generateJavaAgentsProjectHandler);
        }

        override public function deactivate():void
        {
            super.deactivate();

            dispatcher.removeEventListener(ExportVisualEditorProjectEvent.EVENT_EXPORT_DOMINO_VISUALEDITOR_PROJECT_TO_ROYALE,
                    generateJavaAgentsProjectHandler);
        }

        private function generateJavaAgentsProjectHandler(event:Event):void
        {
            currentProject = model.activeProject as AS3ProjectVO;
            if (currentProject == null || !currentProject.isDominoVisualEditorProject)
            {
                error("This is not Visual Editor Domino project");
                return;
            }

            var visualEditorFiles:Array = getVisualEditorFiles(currentProject.projectFolder);
            conversionCounter = visualEditorFiles.length;

            var convertedFiles:Array = [];

            prepareForJavaAgentsGeneration(visualEditorFiles, convertedFiles, conversionFinishedCallback);
        }

        private function prepareForJavaAgentsGeneration(visualEditorFiles:Array, convertedFiles:Array, finishCallback:Function):void
        {
            for (var i:int = 0; i < visualEditorFiles.length; i++)
            {
                var veFile:FileLocation = new FileLocation(visualEditorFiles[i].nativePath);
                if (!veFile.fileBridge.isDirectory &&
                    veFile.fileBridge.extension == "xml")
                {
                    var dominoXML:XML = this.getXmlConversion(veFile);
                    var surfaceMockup:SurfaceMockup = new SurfaceMockup();

                    DominoConverter.fromXML(surfaceMockup, Lookup.DominoNonUILookup,  dominoXML);

                    convertedFiles.push({surface: surfaceMockup, file: veFile});

                    finishCallback(convertedFiles);
                }
                else
                {
                    var veFiles:Array = veFile.fileBridge.getDirectoryListing();
                    if (veFiles.length > 0)
                    {
                        conversionCounter += veFiles.length - 1;
                        prepareForJavaAgentsGeneration(veFiles, convertedFiles, finishCallback);
                    }
                    else
                    {
                        finishCallback(convertedFiles);
                    }
                }
            }
        }

        private function getVisualEditorFiles(destination:FileWrapper):Array
        {
            var separator:String = destination.file.fileBridge.separator;
            var visualEditorSrcPath:String = "visualeditor-src" + separator + "main" + separator + "webapp";
            var visualEditorSrcFolder:FileLocation = destination.file.resolvePath(visualEditorSrcPath);

            var veSrcFiles:Array = visualEditorSrcFolder.fileBridge.getDirectoryListing();

            return veSrcFiles.filter(function(item:Object, index:int, array:Array):Boolean {
                return item.extension == "xml";
            });
        }

        private function getXmlConversion(file:FileLocation):XML
        {
            var data:Object = file.fileBridge.read();
            var xmlConversion:XML = new XML(data);

            return xmlConversion;
        }

        private function conversionFinishedCallback(components:Array):void
        {
            conversionCounter--;
            if (conversionCounter == 0)
            {
                model.flexCore.generateJavaAgentsVisualEditor(components);
            }
        }
    }
}
