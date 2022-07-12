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

            convertToRoyale(visualEditorFiles, convertedFiles, conversionFinishedCallback);
        }

        private function convertToRoyale(visualEditorFiles:Array, convertedFiles:Array, finishCallback:Function):void
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

        private function conversionFinishedCallback(convertedFiles:Array):void
        {
            conversionCounter--;
            if (conversionCounter == 0)
            {
                var views:Array = createConvertedFiles(convertedFiles);

                saveMainFileWithViews(views);
            }
        }

        private function saveMainFileWithViews(views:Array):void
        {
            var mainFile:FileLocation = exportedProject.targets[0];
            var content:String = String(mainFile.fileBridge.read());

            var contentData:Object = {};
                contentData["$NavigationContent"] = getNavigationDp(views);
                contentData["$ApplicationMainContent"] = getMainContent(views);

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
        private function createConvertedFiles(convertedFiles:Array):Array
        {
            var views:Array = [];
            var viewFolder:FileLocation = exportedProject.sourceFolder.resolvePath("view");
            if (!viewFolder.fileBridge.exists)
            {
                viewFolder.fileBridge.createDirectory();
            }

            for (var i:int = 0; i < convertedFiles.length; i++)
            {
                var item:Object = convertedFiles[i];
                var viewObj:Object = {};

                var convertedFile:FileLocation = item.file;
                var destinationFilePath:String = convertedFile.fileBridge.parent.name == "pages" ?
                        convertedFile.fileBridge.nativePath.replace(currentProject.visualEditorSourceFolder.fileBridge.nativePath + exportedProject.sourceFolder.fileBridge.separator +
                                "pages" + exportedProject.sourceFolder.fileBridge.separator, "") :
                        convertedFile.fileBridge.nativePath.replace(currentProject.visualEditorSourceFolder.fileBridge.nativePath + exportedProject.sourceFolder.fileBridge.separator, "");

                var extensionIndex:int = destinationFilePath.lastIndexOf(convertedFile.fileBridge.extension);
                if (extensionIndex > -1)
                {
                    var nameWithoutExt:String = destinationFilePath.substring(0, extensionIndex - 1);
                    viewObj.label = nameWithoutExt;
                    viewObj.content = nameWithoutExt;
                    destinationFilePath = destinationFilePath.replace(".xml", ".mxml");
                }

                convertedFile = viewFolder.resolvePath(viewFolder.fileBridge.nativePath + viewFolder.fileBridge.separator + destinationFilePath);
                var componentData:Array = item.surface.getComponentData();
                var propertyVOName:String = convertedFile.fileBridge.nameWithoutExtension.toLowerCase() + "VO";
                var propertyVOType:String = convertedFile.fileBridge.nameWithoutExtension + "VO";
                var dataProviderName:String = propertyVOName + "Items";

                var royaleMXMLContentFile:XML = null;
                var contentMXMLFile:String = "";

                if (componentData.length > 0)
                {
                    for (var k:int = 0; k < componentData.length; k++)
                    {
                        var componentDataItem:Object = componentData[k];
                        if (!componentDataItem.fields && !componentDataItem.name)
                        {
                            componentData.splice(k, 1);
                        }
                    }

                    var dataGridContent:XML = getDataGridContent(dataProviderName, propertyVOName, propertyVOType, componentData);
                    //Prepare Data for VO
                    royaleMXMLContentFile = item.surface.toRoyaleConvertCode({
                        prop: [
                            {
                                propName: propertyVOName,
                                propType: propertyVOType,
                                newInstance: false
                            }
                        ]
                    });
                    royaleMXMLContentFile.appendChild(dataGridContent);
                    contentMXMLFile = royaleMXMLContentFile.toXMLString();

                    //Save VO
                    var classContent:String = getVOClass(componentData, convertedFile.fileBridge.nameWithoutExtension);
                    saveVO(classContent, convertedFile.fileBridge.nameWithoutExtension);

                    //Apply VO to mxml
                    var re:RegExp = new RegExp(TextUtil.escapeRegex("$valueobject"), "g");
                    contentMXMLFile = contentMXMLFile.replace(re, propertyVOName);
                }
                else
                {
                    royaleMXMLContentFile = item.surface.toRoyaleConvertCode();
                    contentMXMLFile = royaleMXMLContentFile.toXMLString();
                }

                convertedFile.fileBridge.save(contentMXMLFile);

                views.push(viewObj);
            }

            return views;
        }

        private function getDataGridContent(dpName:String, propertyName:String, propertyType:String, componentData:Array):XML
        {
            var columns:Array = getDataGridColumns(componentData, []);

            var dataGridNamespace:Namespace = new Namespace("dataGrid", "classes.dataGrid.*");
            var dataGridXML:XML = new XML("<DataGrid />");
                dataGridXML.setNamespace(dataGridNamespace);
                dataGridXML.@columns = columns.length > 0 ? "{[" + columns.join(",") + "]}" : "{[]}";
                dataGridXML.@dataProvider = "{" + dpName + "}";
                dataGridXML.@localId = "dg";
                dataGridXML.@includeIn = "dataGridState";
                dataGridXML.@className = "dxDataGrid";
                dataGridXML.@percentWidth = "100";
                dataGridXML.@doubleClick = "{this." + propertyName + " = dg.selectedItem as " + propertyType + "; this.currentState = 'contentState'}";

            return dataGridXML;
        }

        private function getDataGridColumns(componentData:Array, columns:Array):Array
        {
            var data:Object = null;
            var fields:Array = null;
            var componentDataCount:int = componentData.length > 3 ? 3 : componentData.length;
            for (var i:int = 0; i < componentDataCount; i++)
            {
                data = componentData[i];
                fields = data.fields;
                if (!data.fields && !data.name)
                {
                    continue;
                }

                if (!data.fields && data.name)
                {
                    columns.push("{caption: '" + data.name + "', dataField: '"  + data.name + "'}");
                }
                else
                {
                    var fieldsCount:int = fields.length > 3 ? 3 : fields.length;
                    for (var j:int = 0; j < fieldsCount; j++)
                    {
                        var field:Object = fields[j];
                        if (!field.name)
                        {
                            if (field.fields)
                            {
                                getDataGridColumns(field.fields, columns);
                            }
                            else
                            {
                                continue;
                            }
                        }
                        else
                        {
                            columns.push("{caption: '" + field.name + "', dataField: '"  + field.name + "'}");
                        }
                    }
                }
            }

            return columns;
        }

        private function getVOClass(componentData:Array, className:String):String
        {
            if (componentData.length == 0) return "";

            var classContent:String = "package vo\n" +
                    "{\n" +
                    "   [Bindable] \n" +
                    "   public class " + className + "VO\n" +
                    "   {\n";

            classContent += getVOContentClass(componentData, "");

            classContent += "   } \n}";

            return classContent;
        }

        private function getVOContentClass(componentData:Array, content:String):String
        {
            for (var i:int = 0; i < componentData.length; i++)
            {
                var data:Object = componentData[i];
                var fields:Array = data.fields;

                var publicVar:String = "";
                if (!data.fields && data.name)
                {
                    publicVar = "       " + getContentVariable(data);
                    content += publicVar;
                }
                else
                {
                    for each (var field:Object in fields)
                    {
                        if (!field.name)
                        {
                            if (field.fields)
                            {
                                content += getVOContentClass(field.fields, "");
                            }
                            else
                            {
                                continue;
                            }
                        }
                        else
                        {
                            publicVar = "       " + getContentVariable(field);
                            content += publicVar;
                        }
                    }
                }
            }

            return content;
        }

        private function getContentVariable(data:Object):String
        {
            if (!data.name) return "";

            var fieldValue:String = data.fieldValue != null ? data.fieldValue : "";
            var fieldType:String = data.fieldType ? data.fieldType : "String";
            if (fieldType != "Boolean")
            {
                fieldValue = "\"" + fieldValue + "\"";
            }

            var publicVar:String = "public var " + data.name + ":" + fieldType + " = " +
                    fieldValue + ";\n";

            return publicVar;
        }

        private function saveVO(content:String, fileName:String):void
        {
            var voFolder:FileLocation = exportedProject.sourceFolder.resolvePath("vo");
            if (!voFolder.fileBridge.exists)
            {
                voFolder.fileBridge.createDirectory();
            }

            var voFile:FileLocation = voFolder.resolvePath(voFolder.fileBridge.nativePath + voFolder.fileBridge.separator + fileName + "VO.as");
            voFile.fileBridge.save(content);
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
            var viewNamespace:Namespace = new Namespace("view", "view.*");

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
                    view.setNamespace(viewNamespace);

                sectionContent.appendChild(view);
                content.appendChild(sectionContent);
            }

            return content.toXMLString();
        }
    }
}
