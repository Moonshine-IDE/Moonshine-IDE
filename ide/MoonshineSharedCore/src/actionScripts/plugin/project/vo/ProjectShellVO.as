package actionScripts.plugin.project.vo
{
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.plugin.java.javaproject.importer.JavaImporter;
    import actionScripts.plugin.project.ProjectTemplateType;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.FileWrapper;
    import actionScripts.valueObjects.ProjectReferenceVO;
    import actionScripts.valueObjects.ProjectVO;

    import flash.events.Event;
    import flash.events.EventDispatcher;

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

            if (templateName.indexOf(ProjectTemplateType.VISUAL_EDITOR) != -1 ||
                templateName.indexOf(ProjectTemplateType.LIBRARY_PROJECT) != -1 ||
                templateName.indexOf(ProjectTemplateType.FEATHERS) != -1 ||
                templateName.indexOf(ProjectTemplateType.ACTIONSCRIPT) != -1 ||
                templateName.indexOf(ProjectTemplateType.MOBILE) != -1 ||
                templateName.indexOf(ProjectTemplateType.AWAY3D) != -1 ||
                templateName.indexOf("Royale") != -1 || templateName.indexOf("FlexJS") != -1)
            {
                project = new AS3ProjectVO(this.folderLocation, this.projectName, false);
            }
            else if (templateName.indexOf(ProjectTemplateType.JAVA) != -1)
            {
                project = JavaImporter.parse(this.folderLocation, this.projectName);
            }

            for (var prop:String in this)
            {
                if (project.hasOwnProperty(String(prop)))
                {
                    project[prop] = this[prop];
                }
            }

            return project;
        }
    }
}
