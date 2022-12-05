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
package actionScripts.plugin.project.vo
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.plugin.groovy.grailsproject.importer.GrailsImporter;
    import actionScripts.plugin.java.javaproject.importer.JavaImporter;
    import actionScripts.plugin.project.ProjectTemplateType;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.FileWrapper;
    import actionScripts.valueObjects.ProjectReferenceVO;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.plugin.haxe.hxproject.importer.HaxeImporter;

    public dynamic class ProjectShellVO extends EventDispatcher
    {
        public var folderLocation:FileLocation;
        public var _folderPath:String;
        public var projectName:String;
        private var _projectFolder:FileWrapper;
        private var projectReference:ProjectReferenceVO;

        public function ProjectShellVO(folderLocation:FileLocation, projectName:String)
        {
            this.folderLocation = folderLocation;
            this.projectName = projectName;

            projectReference = new ProjectReferenceVO();
            projectReference.name = projectName;
            projectReference.path = folderLocation.fileBridge.nativePath;

            this.folderLocation.fileBridge.name = projectName;
        }

        public function get folderPath():String
        {
            return folderLocation.fileBridge.nativePath;
        }

        public function set folderPath(value:String):void
        {
            folderLocation.fileBridge.nativePath = value;
        }

        [Bindable(event="projectFolderChanged")]
        public function get projectFolder():FileWrapper
        {
            if (ConstantsCoreVO.IS_AIR && (!_projectFolder ||
                    _projectFolder.file.fileBridge.nativePath != folderLocation.fileBridge.nativePath))
            {
                _projectFolder = new FileWrapper(folderLocation, true, projectReference, false);
            }

            return _projectFolder;
        }

        public function set projectFolder(value:FileWrapper):void
        {
            if (_projectFolder != value)
            {
                _projectFolder = value;
                dispatchEvent(new Event("projectFolderChanged"));
            }
        }

        public function getProjectOutOfShell(templateName:String):ProjectVO
        {
            var project:ProjectVO = null;

			if (templateName.indexOf(ProjectTemplateType.JAVA) != -1)
			{
				project = JavaImporter.parse(this.folderLocation, this.projectName);
			}
			else if (templateName.indexOf(ProjectTemplateType.GRAILS) != -1)
			{
				project = GrailsImporter.parse(this.folderLocation, this.projectName);
			}
			else if (templateName.indexOf(ProjectTemplateType.HAXE) != -1)
			{
				project = HaxeImporter.parse(this.folderLocation, this.projectName);
			}
			else
            {
                project = new AS3ProjectVO(this.folderLocation, this.projectName, false);
            }

            for (var prop:String in this)
            {
                if (project.hasOwnProperty(prop))
                {
                    project[prop] = this[prop];
                }

                if (prop == "projectWithExistingSourcePaths")
                {
                    var sourceFolder:FileLocation = this.getSourceFolder();
                    var classPathsProp:String = "classpaths";

                    if (sourceFolder && project.hasOwnProperty(classPathsProp))
                    {
                        if(!project[classPathsProp])
                        {
                            project[classPathsProp] = Vector.<FileLocation>([]);
                            project[classPathsProp].push(sourceFolder);
                        }
                        else if (project[classPathsProp].length == 0)
                        {
                            project[classPathsProp].push(sourceFolder);
                        }
                        else
                        {
                            project[classPathsProp][0] = sourceFolder;
                        }
                    }

                    if (project.hasOwnProperty("mainClassName"))
                    {
                        project["mainClassName"] = this.getMainClass();
                    }
                }
            }

            return project;
        }

        private function getMainClass():String
        {
            var sourcePaths:Vector.<FileLocation> = this.projectWithExistingSourcePaths;

            if (sourcePaths.length == 2)
            {
                if (!sourcePaths[1].fileBridge.isDirectory)
                {
                    return sourcePaths[1].fileBridge.nameWithoutExtension;
                }
            }

            return null;
        }

        private function getSourceFolder():FileLocation
        {
            var sourcePaths:Vector.<FileLocation> = this.projectWithExistingSourcePaths;

            if (sourcePaths.length >= 1)
            {
                if (sourcePaths[0].fileBridge.isDirectory)
                {
                    return sourcePaths[0];
                }
            }

            return null;
        }
    }
}
