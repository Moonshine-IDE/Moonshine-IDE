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
package actionScripts.plugins.visualEditor.domino
{
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.templating.TemplatingHelper;
    import actionScripts.utils.TextUtil;
    import actionScripts.valueObjects.FileWrapper;

    import actionScripts.events.ExportVisualEditorProjectEvent;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import converter.DominoConverter;
    import surface.SurfaceMockup;
    import lookup.Lookup;
    import actionScripts.valueObjects.ProjectVO;

    public class ExportDominoToRoyalePlugin extends PluginBase
    {
        private var currentProject:AS3ProjectVO;
        private var exportedProject:AS3ProjectVO;

        private var conversionCounter:int;

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
        }

        override public function deactivate():void
        {
            super.deactivate();

            dispatcher.removeEventListener(ExportVisualEditorProjectEvent.EVENT_EXPORT_DOMINO_VISUALEDITOR_PROJECT_TO_ROYALE,
                    generateApacheRoyaleProjectHandler);
        }

        private function generateApacheRoyaleProjectHandler(event:ExportVisualEditorProjectEvent):void
        {
            currentProject = model.activeProject as AS3ProjectVO;
            if (currentProject == null || !currentProject.isDominoVisualEditorProject)
            {
                error("This is not Visual Editor Domino project");
                return;
            }

            exportedProject = event.exportedProject;

            var visualEditorFiles:Array = getVisualEditorFiles(currentProject.projectFolder);
            conversionCounter = visualEditorFiles.length;

            var convertedFiles:Array = [];

            //Convert forms and subforms
            convertToRoyale(visualEditorFiles, convertedFiles, conversionFinishedCallback);
        }

        private function convertToRoyale(visualEditorFiles:Array, convertedFiles:Array, finishCallback:Function):void
        {
            for (var i:int = 0; i < visualEditorFiles.length; i++)
            {
                var veFilePath:String = visualEditorFiles[i].file.nativePath;
                var veFile:FileLocation = new FileLocation(veFilePath);
                if (!veFile.fileBridge.isDirectory &&
                    veFile.fileBridge.extension == "xml")
                {
                    var dominoXML:XML = this.getXmlConversion(veFile);
                    var surfaceMockup:SurfaceMockup = new SurfaceMockup();

                    DominoConverter.fromXML(surfaceMockup, Lookup.DominoNonUILookup,  dominoXML);

                    convertedFiles.push({surface: surfaceMockup, file: veFile, isSubForm: visualEditorFiles[i].isSubForm});

                    finishCallback(convertedFiles);
                }
                else
                {
                    var veFiles:Array = veFile.fileBridge.getDirectoryListing();
                    if (veFiles.length > 0)
                    {
                        conversionCounter += veFiles.length - 1;
                        convertToRoyale(veFiles, convertedFiles, finishCallback);
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
            var visualEditorSubFormsSrcPath:String = visualEditorSrcPath + separator + "subforms";

            var visualEditorSrcFolder:FileLocation = destination.file.resolvePath(visualEditorSrcPath);
            var visualEditorSubFormsSrcFolder:FileLocation = destination.file.resolvePath(visualEditorSubFormsSrcPath);

            var veSrcFormsFiles:Array = visualEditorSrcFolder.fileBridge.getDirectoryListing();

            var veSrcSubFormsFiles:Array = [];
            if (visualEditorSubFormsSrcFolder.fileBridge.exists)
            {
                veSrcSubFormsFiles = visualEditorSubFormsSrcFolder.fileBridge.getDirectoryListing();
            }

            var formFiles:Array = [];
            var veFormFiles:Array = veSrcFormsFiles.filter(function(item:Object, index:int, array:Array):Boolean {
                return item.extension == "xml";
            });

            var formFile:Object = null;
            for (var i:int = 0; i < veFormFiles.length; i++)
            {
                formFile = veFormFiles[i];
                formFiles.push({file: formFile, isSubForm: false});
            }

            var veSubFormsFiles:Array = veSrcSubFormsFiles.filter(function(item:Object, index:int, array:Array):Boolean {
                return item.extension == "xml";
            });

            for (var j:int = 0; j < veSubFormsFiles.length; j++)
            {
                formFile = veSubFormsFiles[j];
                formFiles.push({file: formFile, isSubForm: true});
            }

            return formFiles;
        }

        private function getXmlConversion(file:FileLocation):XML
        {
            var data:Object = file.fileBridge.read();
            var xmlConversion:XML = new XML(data);

            return xmlConversion;
        }

        private function conversionFinishedCallback(convertedFiles:Array):void
        {
            conversionCounter--;
            if (conversionCounter == 0)
            {
                var convertedFilesForms:Array = convertedFiles.filter(function(item:Object, index:int, array:Array):Boolean {
                    return item.isSubForm == false;
                });
                var formsViews:Array = createConvertedFiles(convertedFilesForms, false);

                convertedFilesForms = convertedFiles.filter(function(item:Object, index:int, array:Array):Boolean {
                    return item.isSubForm == true;
                });
                var subFormsViews:Array = createConvertedFiles(convertedFilesForms, true);

                var formsAndSubForms:Array = formsViews.concat(subFormsViews);

                saveMainFileWithViews(formsAndSubForms);
            }
        }

        private function saveMainFileWithViews(views:Array):void
        {
            var mainFile:FileLocation = exportedProject.targets[0];
            var content:String = String(mainFile.fileBridge.read());

            var contentData:Object = {};
                contentData["$NavigationContent"] = getNavigationDp(views);
                contentData["$ApplicationMainContent"] = getMainContent(views);
                contentData["$ProjectName"] = exportedProject.name;

            content = TemplatingHelper.replace(content, contentData);

            mainFile.fileBridge.save(content);
        }

        /**
         * Save converted files to new project
         * Create an array to display converted files in main view of app
         *
         * @param convertedFiles
         * @return Array
         */
        private function createConvertedFiles(convertedFiles:Array, subForms:Boolean):Array
        {
            var views:Array = [];
            var viewFolder:FileLocation = exportedProject.sourceFolder.resolvePath(exportedProject.name +
                    exportedProject.sourceFolder.fileBridge.separator + "views");
            if (!viewFolder.fileBridge.exists)
            {
                viewFolder.fileBridge.createDirectory();
            }

            for (var i:int = 0; i < convertedFiles.length; i++)
            {
                var item:Object = convertedFiles[i];
                var viewObj:Object = {};

                var convertedFile:FileLocation = item.file;
                var destinationFileName:String = convertedFile.fileBridge.parent.name == "pages" ?
                        convertedFile.fileBridge.nativePath.replace(currentProject.visualEditorSourceFolder.fileBridge.nativePath + exportedProject.sourceFolder.fileBridge.separator +
                                "pages" + exportedProject.sourceFolder.fileBridge.separator, "") :
                        convertedFile.fileBridge.nativePath.replace(currentProject.visualEditorSourceFolder.fileBridge.nativePath + exportedProject.sourceFolder.fileBridge.separator, "");

                //Replace white spaces in file for conversion purposes
                destinationFileName = destinationFileName.replace(/[\s_\(\)-]/g, "");
                		
                var extensionIndex:int = destinationFileName.lastIndexOf(convertedFile.fileBridge.extension);
                if (extensionIndex > -1)
                {
                    var nameWithoutExt:String = destinationFileName.substring(0, extensionIndex - 1);
                    viewObj.label = nameWithoutExt;
                    viewObj.content = nameWithoutExt;
                    destinationFileName = destinationFileName.replace(".xml", ".mxml");
                }

                convertedFile = viewFolder.resolvePath(viewFolder.fileBridge.nativePath + viewFolder.fileBridge.separator + destinationFileName);
                convertedFiles[i].file = convertedFile;

                var royaleMXMLContentFile:XML = item.surface.toRoyaleConvertCode();

                var contentData:Object = {};
                contentData["$ProjectName"] = exportedProject.name;

                XML.ignoreWhitespace = true;
                var royaleMXMLContentFileString:String = royaleMXMLContentFile.toXMLString();
                royaleMXMLContentFileString = TemplatingHelper.replace(royaleMXMLContentFileString, contentData);

                item.pageContent = new XML(royaleMXMLContentFileString);

                views.push(viewObj);
            }

            var modulesPath:FileLocation = subForms ? viewFolder.resolvePath("modules" + exportedProject.sourceFolder.fileBridge.separator + "subforms") :
                                                      viewFolder.resolvePath("modules");
            new DominoRoyaleModuleExporter(
                     modulesPath,
                    exportedProject as ProjectVO, convertedFiles
            );

            return views;
        }

        private function getNavigationDp(views:Array):String
        {
            var jNamespace:Namespace = new Namespace("j", "library://ns.apache.org/royale/jewel");
            var jsNamespace:Namespace = new Namespace("js", "library://ns.apache.org/royale/basic");
            var fxNamespace:Namespace = new Namespace("fx", "http://ns.adobe.com/mxml/2009");

            var dp:XML = <dataProvider/>;
                dp.setNamespace(jNamespace);

            var dpContent:XML = <ArrayList/>;
                dpContent.setNamespace(jsNamespace);

            for (var i:int = 0; i < views.length; i++)
            {
                var item:Object = views[i];
                var obj:XML = <Object />;
                    obj.setNamespace(fxNamespace);
                    obj.@label = item.label;
                    obj.@content = item.content;

                dpContent.appendChild(obj);
            }

            dp.appendChild(dpContent);
            return dp.toXMLString();
        }

        private function getMainContent(views:Array):String
        {
            var jNamespace:Namespace = new Namespace("j", "library://ns.apache.org/royale/jewel");
            var content:XML = <ApplicationMainContent/>;
                content.@id="mainContent";
                content.@hasTopAppBar="true";
                content.@hasFooterBar="true";

                content.setNamespace(jNamespace);

            for (var i:int = 0; i < views.length; i++)
            {
                var item:Object = views[i];
                if (i == 0)
                {
                    content.@selectedContent = item.content;
                }

                var sectionContent:XML = <ScrollableSectionContent />;
                    sectionContent.setNamespace(jNamespace);
                    sectionContent.@name = item.content;
                var viewName:String = String(item.label).split(" ").join("");
                var view:XML = new XML('<' + viewName + '/>');

                sectionContent.appendChild(view);
                content.appendChild(sectionContent);
            }

            return content.toXMLString();
        }
    }
}
