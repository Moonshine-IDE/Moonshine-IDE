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
package actionScripts.ui.menu
{
    import actionScripts.events.DominoEvent;
    import actionScripts.events.GenesisEvent;
    import actionScripts.events.ProjectEvent;
    import actionScripts.plugin.genericproj.vo.GenericProjectVO;
    import actionScripts.plugin.java.javaproject.vo.JavaProjectTypes;

    import flash.ui.Keyboard;
    
    import mx.resources.IResourceManager;
    import mx.resources.ResourceManager;
    
    import actionScripts.events.ExportVisualEditorProjectEvent;
    import actionScripts.events.GradleBuildEvent;
    import actionScripts.events.MavenBuildEvent;
    import actionScripts.events.OnDiskBuildEvent;
    import actionScripts.events.PreviewPluginEvent;
    import actionScripts.events.RoyaleApiReportEvent;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.plugin.core.compiler.ActionScriptBuildEvent;
    import actionScripts.plugin.core.compiler.GrailsBuildEvent;
    import actionScripts.plugin.core.compiler.HaxeBuildEvent;
    import actionScripts.plugin.core.compiler.JavaBuildEvent;
    import actionScripts.plugin.core.compiler.ProjectActionEvent;
    import actionScripts.plugin.groovy.grailsproject.vo.GrailsProjectVO;
    import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;
    import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
    import actionScripts.plugin.ondiskproj.vo.OnDiskProjectVO;
    import actionScripts.ui.menu.vo.MenuItem;
    import actionScripts.ui.menu.vo.ProjectMenuTypes;
    import actionScripts.valueObjects.ProjectVO;

    public class ProjectMenu
    {
        private var actionScriptMenu:Vector.<MenuItem>;
        private var libraryMenu:Vector.<MenuItem>;
        private var royaleMenu:Vector.<MenuItem>;
        private var vePrimeFaces:Vector.<MenuItem>;
        private var veFlex:Vector.<MenuItem>;
        private var javaMenu:Vector.<MenuItem>;
        private var dominoMenu:Vector.<MenuItem>;
		private var javaMenuGradle:Vector.<MenuItem>;
        private var grailsMenu:Vector.<MenuItem>;
        private var haxeMenu:Vector.<MenuItem>;
		private var onDiskMenu:Vector.<MenuItem>;
        private var genericMenu:Vector.<MenuItem>;

        private var currentProject:ProjectVO;
        private var resourceManager:IResourceManager = ResourceManager.getInstance();

        public function getProjectMenuItems(project:ProjectVO):Vector.<MenuItem>
        {
            currentProject = project;

            if (project is AS3ProjectVO)
            {
                var as3Project:AS3ProjectVO = currentProject as AS3ProjectVO;
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
                    else if(as3Project.isDominoVisualEditorProject)
                    {
                        return getDominoMenuItems();
                    }

                    return getVisualEditorMenuFlexItems();
                }
                else
                {
                    return getASProjectMenuItems();
                }
            }

            if (project is JavaProjectVO)
            {
                return getJavaMenuItems();
            }

            if (project is GrailsProjectVO)
            {
                return getGrailsMenuItems();
            }

            if (project is HaxeProjectVO)
            {
                return getHaxeMenuItems();
            }
			
			if (project is OnDiskProjectVO)
			{
				return getOnDiskMenuItems();
			}

            if (project is GenericProjectVO)
            {
                return getGenericMenuIems();
            }

            return null;
        }

        private function getASProjectMenuItems():Vector.<MenuItem>
        {
            if (actionScriptMenu == null)
            {
                actionScriptMenu = Vector.<MenuItem>([
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_PROJECT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.LIBRARY_FLEX_AS, ProjectMenuTypes.JS_ROYALE], ProjectActionEvent.BUILD,
                            'b', [Keyboard.COMMAND],
                            'b', [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_AND_RUN'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE], ProjectActionEvent.BUILD_AND_RUN,
                            "\r\n", [Keyboard.COMMAND],
                            "\n", [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_RELEASE'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], ProjectActionEvent.BUILD_RELEASE),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_ANT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], "selectedProjectAntBuild"),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_MAVEN'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES, ProjectMenuTypes.JAVA], MavenBuildEvent.START_MAVEN_BUILD),
                    new MenuItem(resourceManager.getString('resources', 'ROYALE_API_REPORT'), null, [ProjectMenuTypes.FLEX_AS], RoyaleApiReportEvent.LAUNCH_REPORT_CONFIGURATION),
                    new MenuItem(resourceManager.getString('resources', 'CLEAN_PROJECT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], ProjectActionEvent.CLEAN_PROJECT)
                ]);
                actionScriptMenu.forEach(makeDynamic);
            }

            return actionScriptMenu;
        }

        private function getASLibraryMenuItems():Vector.<MenuItem>
        {
            if (libraryMenu == null)
            {
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
                royaleMenu = Vector.<MenuItem>([
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_PROJECT'), null, [ProjectMenuTypes.JS_ROYALE], ProjectActionEvent.BUILD,
                            'b', [Keyboard.COMMAND],
                            'b', [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_AND_RUN'), null, [ProjectMenuTypes.JS_ROYALE], ProjectActionEvent.BUILD_AND_RUN,
                            "\r\n", [Keyboard.COMMAND],
							"\n", [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_RELEASE'), null, [ProjectMenuTypes.JS_ROYALE], ProjectActionEvent.BUILD_RELEASE),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_ANT'), null, [ProjectMenuTypes.JS_ROYALE], "selectedProjectAntBuild"),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_MAVEN'), null, [ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES, ProjectMenuTypes.JAVA], MavenBuildEvent.START_MAVEN_BUILD),
                    new MenuItem(resourceManager.getString('resources', 'CLEAN_PROJECT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS], ProjectActionEvent.CLEAN_PROJECT),
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'DEPLOY_ROYALE_TO_VAGRANT'), null, [ProjectMenuTypes.JS_ROYALE], OnDiskBuildEvent.DEPLOY_ROYALE_TO_VAGRANT),
                    new MenuItem(resourceManager.getString('resources', 'EXPORT_TO_EXTERNAL_PROJECT'), null, [ProjectMenuTypes.JS_ROYALE], ProjectEvent.EVENT_EXPORT_TO_EXTERNAL_PROJECT)
                ]);
                royaleMenu.forEach(makeDynamic);
            }

            return royaleMenu;
        }

        private function getVisualEditorMenuFlexItems():Vector.<MenuItem>
        {
            if (veFlex == null)
            {
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

			// for gradle project type
			if ((currentProject as JavaProjectVO).hasGradleBuild())
			{
				//if (!javaMenuGradle)
				//{
					javaMenuGradle = Vector.<MenuItem>([
						new MenuItem(null),
						new MenuItem(resourceManager.getString('resources', 'RUN_GRADLE_TASKS'), null, enabledTypes, JavaBuildEvent.JAVA_BUILD,
							'b', [Keyboard.COMMAND],
							'b', [Keyboard.CONTROL]),
						new MenuItem(resourceManager.getString('resources', 'CLEAN_PROJECT'), null, enabledTypes, ProjectActionEvent.CLEAN_PROJECT)
					]);

                    if ((currentProject as JavaProjectVO).projectType == JavaProjectTypes.JAVA_DOMINO)
                    {
                        javaMenuGradle.insertAt(
                                2,
                                new MenuItem(resourceManager.getString('resources', 'RUN_ON_VAGRANT'), null, enabledTypes, DominoEvent.EVENT_RUN_DOMINO_ON_VAGRANT)
                        );
                        addNSDKillOption(javaMenuGradle);
                    }
				//}

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
                        "\r\n", [Keyboard.COMMAND],
                        "\n", [Keyboard.CONTROL]),
                new MenuItem(resourceManager.getString('resources', 'CLEAN_PROJECT'), null, enabledTypes, ProjectActionEvent.CLEAN_PROJECT)
            ]);

            if ((currentProject as JavaProjectVO).projectType == JavaProjectTypes.JAVA_DOMINO)
            {
                addNSDKillOption(javaMenuGradle);
            }
            javaMenu.forEach(makeDynamic);
            return javaMenu;
        }

        private function getDominoMenuItems():Vector.<MenuItem>
        {
            if (dominoMenu == null)
            {           
                dominoMenu = Vector.<MenuItem>([
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources','GENERATE_JAVA_AGENTS'), null, null, ExportVisualEditorProjectEvent.EVENT_GENERATE_DOMINO_JAVA_AGENTS_OUT_OF_VISUALEDITOR_PROJECT),
                    new MenuItem(resourceManager.getString('resources', 'DEPLOY_DOMINO_DATABASE'), null, null, OnDiskBuildEvent.DEPLOY_DOMINO_DATABASE),
                    new MenuItem(resourceManager.getString('resources','GENERATE_APACHE_ROYALE_PROJECT'), null, null, ProjectEvent.EVENT_GENERATE_APACHE_ROYALE_PROJECT),
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_MAVEN'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.VISUAL_EDITOR_PRIMEFACES, ProjectMenuTypes.JAVA,ProjectMenuTypes.VISUAL_EDITOR_DOMINO], MavenBuildEvent.START_MAVEN_BUILD),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_ON_VAGRANT'), null, null, DominoEvent.EVENT_BUILD_ON_VAGRANT),
                    new MenuItem(resourceManager.getString('resources', 'CLEAN_PROJECT'), null, [ProjectMenuTypes.FLEX_AS, ProjectMenuTypes.PURE_AS, ProjectMenuTypes.JS_ROYALE, ProjectMenuTypes.LIBRARY_FLEX_AS,ProjectMenuTypes.JAVA,ProjectMenuTypes.VISUAL_EDITOR_DOMINO], ProjectActionEvent.CLEAN_PROJECT)
                ]);
                addNSDKillOption(dominoMenu);
                dominoMenu.forEach(makeDynamic);
            }

            return dominoMenu;
        }
        private function getGrailsMenuItems():Vector.<MenuItem>
        {
            if (grailsMenu == null)
            {
                var enabledTypes:Array = [ProjectMenuTypes.GRAILS];

                grailsMenu = Vector.<MenuItem>([
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_AND_RUN'), null, enabledTypes, GrailsBuildEvent.BUILD_AND_RUN,
						'b', [Keyboard.COMMAND],
						'b', [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_RELEASE'), null, enabledTypes, GrailsBuildEvent.BUILD_RELEASE,
						"\r\n", [Keyboard.COMMAND],
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

                haxeMenu = Vector.<MenuItem>([
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_PROJECT'), null, enabledTypes, HaxeBuildEvent.BUILD_DEBUG,
                        'b', [Keyboard.COMMAND],
                        'b', [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_AND_RUN'), null, enabledTypes, HaxeBuildEvent.BUILD_AND_RUN,
						"\r\n", [Keyboard.COMMAND],
						"\n", [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_RELEASE'), null, enabledTypes, HaxeBuildEvent.BUILD_RELEASE),
                    new MenuItem(resourceManager.getString('resources', 'CLEAN_PROJECT'), null, enabledTypes, ProjectActionEvent.CLEAN_PROJECT)
                ]);
                haxeMenu.forEach(makeDynamic);
            }

            return haxeMenu;
        }
		
		private function getOnDiskMenuItems():Vector.<MenuItem>
		{
			if (onDiskMenu == null)
			{
				onDiskMenu = Vector.<MenuItem>([
					new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'DEPLOY_DOMINO_DATABASE'), null, [ProjectMenuTypes.ON_DISK], OnDiskBuildEvent.DEPLOY_DOMINO_DATABASE),
                    new MenuItem(resourceManager.getString('resources', 'GENERATE_JAVA_AGENTS'), null, [ProjectMenuTypes.ON_DISK], OnDiskBuildEvent.GENERATE_JAVA_AGENTS),
					new MenuItem(resourceManager.getString('resources', 'GENERATE_CRUD_ROYALE'), null, [ProjectMenuTypes.ON_DISK], OnDiskBuildEvent.GENERATE_CRUD_ROYALE),
					new MenuItem(null),
					new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_MAVEN'), null, [ProjectMenuTypes.ON_DISK], MavenBuildEvent.START_MAVEN_BUILD),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_ON_VAGRANT'), null, [ProjectMenuTypes.ON_DISK], DominoEvent.EVENT_BUILD_ON_VAGRANT),
					new MenuItem(resourceManager.getString('resources', 'CLEAN_PROJECT'), null, [ProjectMenuTypes.ON_DISK], ProjectActionEvent.CLEAN_PROJECT)
				]);

				addNSDKillOption(onDiskMenu);
				onDiskMenu.forEach(makeDynamic);
			}
			
			return onDiskMenu;
		}

        private function getGenericMenuIems():Vector.<MenuItem>
        {
            // re-generate every time based on
            // project's availabilities
            genericMenu = new Vector.<MenuItem>();
            if ((currentProject as GenericProjectVO).hasPom())
            {
                genericMenu.push(
                        new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_MAVEN'), null, [ProjectMenuTypes.GENERIC], MavenBuildEvent.START_MAVEN_BUILD)
                );
            }
            if ((currentProject as GenericProjectVO).hasGradleBuild())
            {
                genericMenu.push(
                    new MenuItem(resourceManager.getString('resources', 'RUN_GRADLE_TASKS'), null, [ProjectMenuTypes.GENERIC], GradleBuildEvent.START_GRADLE_BUILD,
                        'b', [Keyboard.COMMAND],
                        'b', [Keyboard.CONTROL])
                );
            }
            if ((currentProject as GenericProjectVO).isAntFileAvailable)
            {
                genericMenu.push(
                    new MenuItem(resourceManager.getString('resources', 'BUILD_WITH_APACHE_ANT'), null, [ProjectMenuTypes.GENERIC], "selectedProjectAntBuild")
                );
            }

            if (genericMenu.length > 0)
            {
                genericMenu.insertAt(0, new MenuItem(null));
            }

            genericMenu.forEach(makeDynamic);

            return genericMenu;
        }

        private function makeDynamic(item:MenuItem, index:int, vector:Vector.<MenuItem>):void
        {
            item.dynamicItem = true;
        }

        private function addNSDKillOption(menu:Vector.<MenuItem>):void
        {
            menu.push(new MenuItem(null));
            menu.push(new MenuItem(resourceManager.getString('resources', 'NSD_KILL'), null, [ProjectMenuTypes.VISUAL_EDITOR_DOMINO, ProjectMenuTypes.ON_DISK, ProjectMenuTypes.JAVA], DominoEvent.NDS_KILL))
        }
    }
}
