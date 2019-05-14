package actionScripts.ui.menu
{
    import actionScripts.events.ExportVisualEditorProjectEvent;
    import actionScripts.events.MavenBuildEvent;
    import actionScripts.events.PreviewPluginEvent;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
    import actionScripts.plugin.core.compiler.JavaBuildEvent;
    import actionScripts.plugin.core.compiler.ProjectActionEvent;
    import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
    import actionScripts.ui.menu.vo.MenuItem;
    import actionScripts.ui.menu.vo.ProjectMenuTypes;
    import actionScripts.valueObjects.ProjectVO;

    import flash.ui.Keyboard;

    import mx.resources.IResourceManager;
    import mx.resources.ResourceManager;

    public class ProjectMenu
    {
        private var actionScriptMenu:Vector.<MenuItem>;
        private var libraryMenu:Vector.<MenuItem>;
        private var royaleMenu:Vector.<MenuItem>;
        private var vePrimeFaces:Vector.<MenuItem>;
        private var veFlex:Vector.<MenuItem>;
        private var javaMenu:Vector.<MenuItem>;

        private var currentProject:ProjectVO;

        public function getProjectMenuItems(project:ProjectVO):Vector.<MenuItem>
        {
            currentProject = project;

            var as3Project:AS3ProjectVO = project as AS3ProjectVO;
            if (as3Project)
            {
                if (as3Project.isLibraryProject)
                {
                    return getASLibraryMenuItems();
                }
                else if (as3Project.isRoyale)
                {
                    return getRoyaleMenuItems();
                }
                else if (as3Project.isVisualEditorProject)
                {
                    if (as3Project.isPrimeFacesVisualEditorProject)
                    {
                        return getVisualEditorMenuPrimeFacesItems();
                    }

                    return getVisualEditorMenuFlexItems();
                }
                else
                {
                    return getASProjectMenuItems();
                }
            }

            var javaProject:JavaProjectVO = project as JavaProjectVO;
            if (javaProject)
            {
                return getJavaMenuItems();
            }

            return null;
        }

        private function getASProjectMenuItems():Vector.<MenuItem>
        {
            if (actionScriptMenu == null)
            {
                var resourceManager:IResourceManager = ResourceManager.getInstance();
                actionScriptMenu = Vector.<MenuItem>([
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_PROJECT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.JS_ROYALE], ActionScriptBuildEvent.BUILD,
                            'b', [Keyboard.COMMAND],
                            'b', [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_AND_RUN'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE], ActionScriptBuildEvent.BUILD_AND_RUN,
                            "\n", [Keyboard.COMMAND],
                            "\n", [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_RELEASE'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], ActionScriptBuildEvent.BUILD_RELEASE),
                    new MenuItem(resourceManager.getString('resources', 'CLEAN_PROJECT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], ProjectActionEvent.CLEAN_PROJECT),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_ANT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], "selectedProjectAntBuild"),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_MAVEN'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES, ProjectMenuTypes.JAVA], MavenBuildEvent.START_MAVEN_BUILD)
                ]);
                actionScriptMenu.forEach(makeDynamic);
            }

            return actionScriptMenu;
        }

        private function getASLibraryMenuItems():Vector.<MenuItem>
        {
            if (libraryMenu == null)
            {
                var resourceManager:IResourceManager = ResourceManager.getInstance();
                libraryMenu = Vector.<MenuItem>([
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_PROJECT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.JS_ROYALE], ActionScriptBuildEvent.BUILD,
                            'b', [Keyboard.COMMAND],
                            'b', [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_RELEASE'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], ActionScriptBuildEvent.BUILD_RELEASE),
                    new MenuItem(resourceManager.getString('resources', 'CLEAN_PROJECT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], ProjectActionEvent.CLEAN_PROJECT),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_ANT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], "selectedProjectAntBuild"),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_MAVEN'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES, ProjectMenuTypes.JAVA], MavenBuildEvent.START_MAVEN_BUILD)
                ]);
                libraryMenu.forEach(makeDynamic);
            }

            return libraryMenu;
        }

        private function getRoyaleMenuItems():Vector.<MenuItem>
        {
            if (royaleMenu == null)
            {
                var resourceManager:IResourceManager = ResourceManager.getInstance();
                royaleMenu = Vector.<MenuItem>([
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_PROJECT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.JS_ROYALE], ActionScriptBuildEvent.BUILD,
                            'b', [Keyboard.COMMAND],
                            'b', [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_AND_RUN'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE], ActionScriptBuildEvent.BUILD_AND_RUN,
                            "\n", [Keyboard.COMMAND],
                            "\n", [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_AS_JS'), null, [ProjectMenuTypes.JS_ROYALE], ActionScriptBuildEvent.BUILD_AS_JAVASCRIPT,
                            'j', [Keyboard.COMMAND],
                            'j', [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_AND_RUN_AS_JS'), null, [ProjectMenuTypes.JS_ROYALE], ActionScriptBuildEvent.BUILD_AND_RUN_JAVASCRIPT),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_RELEASE'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], ActionScriptBuildEvent.BUILD_RELEASE),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_ANT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], "selectedProjectAntBuild"),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_MAVEN'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES, ProjectMenuTypes.JAVA], MavenBuildEvent.START_MAVEN_BUILD),
                    new MenuItem(resourceManager.getString('resources', 'CLEAN_PROJECT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], ProjectActionEvent.CLEAN_PROJECT)
                ]);
                royaleMenu.forEach(makeDynamic);
            }

            return royaleMenu;
        }

        private function getVisualEditorMenuFlexItems():Vector.<MenuItem>
        {
            if (veFlex == null)
            {
                var resourceManager:IResourceManager = ResourceManager.getInstance();
                veFlex = Vector.<MenuItem>([
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT'), [
                        new MenuItem(resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT_TO_FLEX'), null, [ProjectMenuTypes.VISUAL_EDITOR_FLEX], ExportVisualEditorProjectEvent.EVENT_INIT_EXPORT_VISUALEDITOR_PROJECT_TO_FLEX,
                                null, null, null, null, null, null, null, true),
                        new MenuItem(resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT_TO_PRIMEFACES'), null, [ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES], ExportVisualEditorProjectEvent.EVENT_EXPORT_VISUALEDITOR_PROJECT_TO_PRIMEFACES,
                                null, null, null, null, null, null, null, true)
                    ])
                ]);

                veFlex.forEach(makeDynamic);
            }

            return veFlex;
        }

        private function getVisualEditorMenuPrimeFacesItems():Vector.<MenuItem>
        {
            if (vePrimeFaces == null)
            {
                var resourceManager:IResourceManager = ResourceManager.getInstance();
                vePrimeFaces = Vector.<MenuItem>([
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT'), [
                        new MenuItem(resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT_TO_FLEX'), null, [ProjectMenuTypes.VISUAL_EDITOR_FLEX], ExportVisualEditorProjectEvent.EVENT_INIT_EXPORT_VISUALEDITOR_PROJECT_TO_FLEX,
                                    null, null, null, null, null, null, null, true),
                        new MenuItem(resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT_TO_PRIMEFACES'), null, [ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES], ExportVisualEditorProjectEvent.EVENT_EXPORT_VISUALEDITOR_PROJECT_TO_PRIMEFACES,
                                    null, null, null, null, null, null, null, true)
                    ]),
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'START_PREVIEW'), null, [ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES], PreviewPluginEvent.START_VISUALEDITOR_PREVIEW)
                ]);

                var as3Project:AS3ProjectVO = currentProject as AS3ProjectVO;
                var veMenuItem:MenuItem = vePrimeFaces[vePrimeFaces.length - 1];
                if (as3Project.isPreviewRunning)
                {
                    veMenuItem.label = resourceManager.getString('resources', 'STOP_PREVIEW');
                    veMenuItem.event = PreviewPluginEvent.STOP_VISUALEDITOR_PREVIEW;
                }
                else
                {
                    veMenuItem.label = resourceManager.getString('resources', 'START_PREVIEW');
                    veMenuItem.event = PreviewPluginEvent.START_VISUALEDITOR_PREVIEW;
                }

                vePrimeFaces.forEach(makeDynamic);
            }

            return vePrimeFaces;
        }

        private function getJavaMenuItems():Vector.<MenuItem>
        {
            if (javaMenu == null)
            {
                var enabledTypes:Array = (currentProject as JavaProjectVO).hasGradleBuild() ? [] : [ProjectMenuTypes.JAVA];
                var resourceManager:IResourceManager = ResourceManager.getInstance();

                javaMenu = Vector.<MenuItem>([
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_PROJECT'), null, enabledTypes, JavaBuildEvent.JAVA_BUILD,
                            'b', [Keyboard.COMMAND],
                            'b', [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_AND_RUN'), null, enabledTypes, JavaBuildEvent.BUILD_AND_RUN,
                            "\n", [Keyboard.COMMAND],
                            "\n", [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'CLEAN_PROJECT'), null, enabledTypes, ProjectActionEvent.CLEAN_PROJECT)
                ]);
                javaMenu.forEach(makeDynamic);
            }

            return javaMenu;
        }

        private function makeDynamic(item:MenuItem, index:int, vector:Vector.<MenuItem>):void
        {
            item.dynamicItem = true;
        }
    }
}
