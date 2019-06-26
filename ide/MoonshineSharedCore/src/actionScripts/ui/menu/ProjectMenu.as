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
package actionScripts.ui.menu
{
    import flash.ui.Keyboard;
    
    import mx.resources.IResourceManager;
    import mx.resources.ResourceManager;
    
    import actionScripts.events.ExportVisualEditorProjectEvent;
    import actionScripts.events.GradleBuildEvent;
    import actionScripts.events.MavenBuildEvent;
    import actionScripts.events.PreviewPluginEvent;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
    import actionScripts.plugin.core.compiler.GrailsBuildEvent;
    import actionScripts.plugin.core.compiler.JavaBuildEvent;
    import actionScripts.plugin.core.compiler.ProjectActionEvent;
    import actionScripts.plugin.groovy.grailsproject.vo.GrailsProjectVO;
    import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
    import actionScripts.ui.menu.vo.MenuItem;
    import actionScripts.ui.menu.vo.ProjectMenuTypes;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;
    import actionScripts.plugin.core.compiler.HaxeBuildEvent;

    public class ProjectMenu
    {
        private var actionScriptMenu:Vector.<MenuItem>;
        private var libraryMenu:Vector.<MenuItem>;
        private var royaleMenu:Vector.<MenuItem>;
        private var vePrimeFaces:Vector.<MenuItem>;
        private var veFlex:Vector.<MenuItem>;
        private var javaMenu:Vector.<MenuItem>;
		private var javaMenuGradle:Vector.<MenuItem>;
        private var grailsMenu:Vector.<MenuItem>;
        private var haxeMenu:Vector.<MenuItem>;

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

            var grailsProject:GrailsProjectVO = project as GrailsProjectVO;
            if (grailsProject)
            {
                return getGrailsMenuItems();
            }

            var haxeProject:HaxeProjectVO = project as HaxeProjectVO;
            if (haxeProject)
            {
                return getHaxeMenuItems();
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
            var enabledTypes:Array = [ProjectMenuTypes.JAVA];
            var resourceManager:IResourceManager = ResourceManager.getInstance();
			
			// for gradle project type
			if ((currentProject as JavaProjectVO).hasGradleBuild())
			{
				if (!javaMenuGradle)
				{
					javaMenuGradle = Vector.<MenuItem>([
						new MenuItem(null),
						new MenuItem(resourceManager.getString('resources', 'RUN_GRADLE_TASKS'), null, enabledTypes, JavaBuildEvent.JAVA_BUILD,
							'b', [Keyboard.COMMAND],
							'b', [Keyboard.CONTROL]),
						new MenuItem(resourceManager.getString('resources', 'CLEAN_PROJECT'), null, enabledTypes, ProjectActionEvent.CLEAN_PROJECT),
						new MenuItem(null),
						new MenuItem(resourceManager.getString('resources', 'REFRESH_GRADLE_CLASSPATH'), null, enabledTypes, GradleBuildEvent.REFRESH_GRADLE_CLASSPATH)
					]);
				}
				
				javaMenuGradle.forEach(makeDynamic);
				return javaMenuGradle;
			}
			
			// for usual project type
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
            return javaMenu;
        }

        private function getGrailsMenuItems():Vector.<MenuItem>
        {
            if (grailsMenu == null)
            {
                var enabledTypes:Array = [ProjectMenuTypes.GRAILS];
                var resourceManager:IResourceManager = ResourceManager.getInstance();

                grailsMenu = Vector.<MenuItem>([
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_AND_RUN'), null, enabledTypes, GrailsBuildEvent.BUILD_AND_RUN,
						'b', [Keyboard.COMMAND],
						'b', [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_RELEASE'), null, enabledTypes, GrailsBuildEvent.BUILD_RELEASE,
						"\n", [Keyboard.COMMAND],
						"\n", [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'CLEAN_PROJECT'), null, enabledTypes, ProjectActionEvent.CLEAN_PROJECT),
					new MenuItem(null),
					new MenuItem(resourceManager.getString('resources', 'RUN_GRAILS_TASKS'), null, enabledTypes, GrailsBuildEvent.RUN_COMMAND),
					new MenuItem(resourceManager.getString('resources', 'RUN_GRADLE_TASKS'), null, enabledTypes, GradleBuildEvent.RUN_COMMAND),
					new MenuItem(resourceManager.getString('resources', 'REFRESH_GRADLE_CLASSPATH'), null, enabledTypes, GradleBuildEvent.REFRESH_GRADLE_CLASSPATH)
                ]);
                grailsMenu.forEach(makeDynamic);
            }

            return grailsMenu;
        }

        private function getHaxeMenuItems():Vector.<MenuItem>
        {
            if (haxeMenu == null)
            {
                var enabledTypes:Array = [ProjectMenuTypes.HAXE];
                var resourceManager:IResourceManager = ResourceManager.getInstance();

                haxeMenu = Vector.<MenuItem>([
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_PROJECT'), null, enabledTypes, HaxeBuildEvent.BUILD_DEBUG,
                        'b', [Keyboard.COMMAND],
                        'b', [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_AND_RUN'), null, enabledTypes, HaxeBuildEvent.BUILD_AND_RUN,
						'\n', [Keyboard.COMMAND],
						'\n', [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_RELEASE'), null, enabledTypes, HaxeBuildEvent.BUILD_RELEASE),
                ]);
                haxeMenu.forEach(makeDynamic);
            }

            return haxeMenu;
        }

        private function makeDynamic(item:MenuItem, index:int, vector:Vector.<MenuItem>):void
        {
            item.dynamicItem = true;
        }
    }
}
