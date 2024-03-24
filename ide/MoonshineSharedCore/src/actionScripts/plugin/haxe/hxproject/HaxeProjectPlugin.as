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
package actionScripts.plugin.haxe.hxproject
{
    import actionScripts.events.NewProjectEvent;
import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.project.ProjectTemplateType;
    import actionScripts.plugin.project.ProjectType;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.plugin.IProjectTypePlugin;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.haxe.hxproject.importer.HaxeImporter;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;
    import actionScripts.ui.menu.vo.MenuItem;
    import actionScripts.ui.menu.vo.ProjectMenuTypes;
    import flash.ui.Keyboard;
    import mx.resources.IResourceManager;
    import mx.resources.ResourceManager;
    import actionScripts.plugin.core.compiler.HaxeBuildEvent;
	
	public class HaxeProjectPlugin extends PluginBase implements IProjectTypePlugin
	{	
		public var activeType:uint = ProjectType.HAXE;
		private var executeCreateHaxeProject:CreateHaxeProject;
		private var _projectMenu:Vector.<MenuItem>;
        private var resourceManager:IResourceManager = ResourceManager.getInstance();
		
		override public function get name():String 			{ return "Haxe Project Plugin"; }
		override public function get author():String 		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL + " Project Team"; }
		override public function get description():String 	{ return "Haxe project importing, exporting & scaffolding."; }

		public function get projectClass():Class
		{
			return HaxeProjectVO;
		}

		public function getProjectMenuItems(project:ProjectVO):Vector.<MenuItem>
		{
            if (_projectMenu == null)
            {
                var enabledTypes:Array = [ProjectMenuTypes.HAXE];

                _projectMenu = Vector.<MenuItem>([
                    new MenuItem(null),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_PROJECT'), null, enabledTypes, HaxeBuildEvent.BUILD_DEBUG,
                        'b', [Keyboard.COMMAND],
                        'b', [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_AND_RUN'), null, enabledTypes, HaxeBuildEvent.BUILD_AND_RUN,
						"\r\n", [Keyboard.COMMAND],
						"\n", [Keyboard.CONTROL]),
                    new MenuItem(resourceManager.getString('resources', 'BUILD_RELEASE'), null, enabledTypes, HaxeBuildEvent.BUILD_RELEASE),
                    new MenuItem(resourceManager.getString('resources', 'CLEAN_PROJECT'), null, enabledTypes, HaxeBuildEvent.CLEAN)
                ]);
                _projectMenu.forEach(function(item:MenuItem, index:int, vector:Vector.<MenuItem>):void
				{
					item.dynamicItem = true;
				});
            }

            return _projectMenu;
		}
		
		override public function activate():void
		{
			dispatcher.addEventListener(NewProjectEvent.CREATE_NEW_PROJECT, createNewProjectHandler);
			
			super.activate();
		}
		
		override public function deactivate():void
		{
			dispatcher.removeEventListener(NewProjectEvent.CREATE_NEW_PROJECT, createNewProjectHandler);
			
			super.deactivate();
		}

		public function testProjectDirectory(dir:FileLocation):FileLocation
		{
			return HaxeImporter.test(dir);
		}

		public function parseProject(projectFolder:FileLocation, projectName:String = null, settingsFileLocation:FileLocation = null):ProjectVO
		{
			return HaxeImporter.parse(projectFolder, projectName, settingsFileLocation);
		}
		
		private function createNewProjectHandler(event:NewProjectEvent):void
		{
			if(!canCreateProject(event))
			{
				return;
			}
			
			executeCreateHaxeProject = new CreateHaxeProject(event);
		}

        private function canCreateProject(event:NewProjectEvent):Boolean
        {
            var projectTemplateName:String = event.templateDir.fileBridge.name;
            return projectTemplateName.indexOf(ProjectTemplateType.HAXE) != -1;
        }
	}
}