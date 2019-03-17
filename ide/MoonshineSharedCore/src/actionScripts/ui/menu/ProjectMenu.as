package actionScripts.ui.menu
{
    import actionScripts.events.ExportVisualEditorProjectEvent;
    import actionScripts.events.MavenBuildEvent;
    import actionScripts.events.PreviewPluginEvent;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
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
        private var veMenu:Vector.<MenuItem>;

        public function getProjectMenuItems(project:ProjectVO):Vector.<MenuItem>
        {
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
                    return getVisualEditorMenuItems();
                }
                else
                {
                    return getASProjectMenuItems();
                }
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
                    new MenuItem(resourceManager.getString('resources', 'CLEAN_PROJECT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], ActionScriptBuildEvent.CLEAN_PROJECT),
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
                    new MenuItem(resourceManager.getString('resources', 'CLEAN_PROJECT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], ActionScriptBuildEvent.CLEAN_PROJECT),
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
                    new MenuItem(resourceManager.getString('resources', 'CLEAN_PROJECT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], ActionScriptBuildEvent.CLEAN_PROJECT),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_ANT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], "selectedProjectAntBuild"),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_MAVEN'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES, ProjectMenuTypes.JAVA], MavenBuildEvent.START_MAVEN_BUILD)
                ]);
                royaleMenu.forEach(makeDynamic);
            }

            return royaleMenu;
        }

        private function getVisualEditorMenuItems():Vector.<MenuItem>
        {
            if (veMenu == null)
            {
                var resourceManager:IResourceManager = ResourceManager.getInstance();
                veMenu = Vector.<MenuItem>([
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT'), [
                        new MenuItem(resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT_TO_FLEX'), null, [ProjectMenuTypes.VISUAL_EDITOR_FLEX], ExportVisualEditorProjectEvent.EVENT_INIT_EXPORT_VISUALEDITOR_PROJECT_TO_FLEX),
                        new MenuItem(resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT_TO_PRIMEFACES'), null, [ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES], ExportVisualEditorProjectEvent.EVENT_EXPORT_VISUALEDITOR_PROJECT_TO_PRIMEFACES)
                    ]),
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'STOP_PREVIEW'), null, [ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES], PreviewPluginEvent.STOP_VISUALEDITOR_PREVIEW)
                ]);
                veMenu.forEach(makeDynamic);
            }

            return veMenu;
        }

        private function makeDynamic(item:MenuItem, index:int, vector:Vector.<MenuItem>):void
        {
            item.dynamicItem = true;
        }

        /*new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT'), [
                        new MenuItem(resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT_TO_FLEX'), null, [ProjectMenuTypes.VISUAL_EDITOR_FLEX], ExportVisualEditorProjectEvent.EVENT_INIT_EXPORT_VISUALEDITOR_PROJECT_TO_FLEX),
                        new MenuItem(resourceManager.getString('resources', 'EXPORT_VISUALEDITOR_PROJECT_TO_PRIMEFACES'), null, [ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES], ExportVisualEditorProjectEvent.EVENT_EXPORT_VISUALEDITOR_PROJECT_TO_PRIMEFACES)
                    ]),
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
                    new MenuItem(resourceManager.getString('resources', 'CLEAN_PROJECT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], ActionScriptBuildEvent.CLEAN_PROJECT),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_ANT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], "selectedProjectAntBuild"),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_MAVEN'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES, ProjectMenuTypes.JAVA], MavenBuildEvent.START_MAVEN_BUILD),
                    new MenuItem(resourceManager.getString('resources', 'STOP_PREVIEW'), null, [ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES], PreviewPluginEvent.STOP_VISUALEDITOR_PREVIEW)*/
    }
}
