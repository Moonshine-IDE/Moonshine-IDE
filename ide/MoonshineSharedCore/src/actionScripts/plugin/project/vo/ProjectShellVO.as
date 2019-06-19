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
