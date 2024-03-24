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
package actionScripts.impls
{
	import actionScripts.factory.FileLocation;
import actionScripts.interfaces.IBuildActionsProvider;
import actionScripts.interfaces.IProjectBridge;
import actionScripts.plugin.IPlugin;
import actionScripts.plugin.IProjectTypePlugin;
	import actionScripts.plugin.actionscript.as3project.AS3ProjectPlugin;
	import actionScripts.plugin.genericproj.GenericProjectPlugin;
	import actionScripts.plugin.groovy.grailsproject.GrailsProjectPlugin;
	import actionScripts.plugin.haxe.hxproject.HaxeProjectPlugin;
	import actionScripts.plugin.java.javaproject.JavaProjectPlugin;
	import actionScripts.plugin.ondiskproj.OnDiskProjectPlugin;
	import actionScripts.plugin.syntax.AS3SyntaxPlugin;
	import actionScripts.plugin.syntax.GroovySyntaxPlugin;
	import actionScripts.plugin.syntax.HaxeSyntaxPlugin;
	import actionScripts.plugin.syntax.JavaSyntaxPlugin;
	import actionScripts.plugins.actionscript.AS3LanguageServerPlugin;
import actionScripts.plugins.grails.GrailsBuildPlugin;
	import actionScripts.plugins.groovy.GroovyLanguageServerPlugin;
	import actionScripts.plugins.haxe.HaxeBuildPlugin;
	import actionScripts.plugins.haxelib.HaxelibPlugin;
	import actionScripts.plugins.haxe.HaxeLanguageServerPlugin;
	import actionScripts.plugins.java.JavaBuildPlugin;
	import actionScripts.plugins.java.JavaLanguageServerPlugin;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.ui.menu.vo.MenuItem;
	import actionScripts.plugins.tibbo.TibboBasicLanguageServerPlugin;
	import actionScripts.plugin.tibbo.tibboproject.TibboBasicProjectPlugin;
	import actionScripts.plugin.syntax.TibboBasicSyntaxPlugin;

	public class IProjectBridgeImpl implements IProjectBridge
	{
		private var _projectTypePlugins:Array = [];
		private var _actionbarTypePlugins:Array = [];

        public function getCorePlugins():Array
        {
            return [
            ];
        }

        public function getDefaultPlugins():Array
        {
            return [
				// as3/mxml
				AS3ProjectPlugin,
				AS3SyntaxPlugin,
				AS3LanguageServerPlugin,

				// java
				JavaSyntaxPlugin,
                JavaProjectPlugin,
				JavaBuildPlugin,
                JavaLanguageServerPlugin,

				// groovy/grails
				GroovySyntaxPlugin,
                GrailsProjectPlugin,
                GrailsBuildPlugin,
                GroovyLanguageServerPlugin,

				// haxe
				HaxeSyntaxPlugin,
				HaxeProjectPlugin,
				HaxeBuildPlugin,
				HaxelibPlugin,
				HaxeLanguageServerPlugin,

				// tibbo basic
				TibboBasicSyntaxPlugin,
				TibboBasicProjectPlugin,
				TibboBasicLanguageServerPlugin,

				// on disk
				OnDiskProjectPlugin,

				// generic
				GenericProjectPlugin,
            ];
        }

        public function getPluginsNotToShowInSettings():Array
        {
            return [
				// as3/mxml
				AS3ProjectPlugin,
				AS3LanguageServerPlugin, 

				// java
                JavaProjectPlugin,
				JavaBuildPlugin,
                JavaLanguageServerPlugin,

				// groovy/grails
                GrailsProjectPlugin,
                GroovyLanguageServerPlugin,

				// haxe
				HaxeSyntaxPlugin,
				HaxeProjectPlugin,
				HaxelibPlugin,
				HaxeLanguageServerPlugin,

				// on disk
				OnDiskProjectPlugin,

				// generic
				GenericProjectPlugin,
				
				// tibbo
				TibboBasicSyntaxPlugin,
				TibboBasicProjectPlugin,
				TibboBasicLanguageServerPlugin
            ];
        }

		public function registerProjectTypePlugin(plugin:IProjectTypePlugin):void
		{
			var index:int = _projectTypePlugins.indexOf(plugin);
			if (index != -1)
			{
				return;
			}
			_projectTypePlugins.push(plugin);
		}

		public function unregisterProjectTypePlugin(plugin:IProjectTypePlugin):void
		{
			var index:int = _projectTypePlugins.indexOf(plugin);
			if (index == -1)
			{
				return;
			}
			_projectTypePlugins.removeAt(index);
		}

		public function registerActionBarTypePlugin(plugin:IPlugin):void
		{
			var index:int = _actionbarTypePlugins.indexOf(plugin);
			if (index != -1)
			{
				return;
			}
			_actionbarTypePlugins.push(plugin);
		}

		public function unregisterActionBarTypePlugin(plugin:IPlugin):void
		{
			var index:int = _actionbarTypePlugins.indexOf(plugin);
			if (index == -1)
			{
				return;
			}
			_actionbarTypePlugins.removeAt(index);
		}

		public function parseProject(location:FileLocation):ProjectVO
		{
			for(var i:int = 0; i < _projectTypePlugins.length; i++)
			{
				var plugin:IProjectTypePlugin = _projectTypePlugins[i];
				var settingsFile:FileLocation = plugin.testProjectDirectory(location);
				if (!settingsFile)
				{
					continue;
				}
				return plugin.parseProject(location, null, settingsFile);
			}
			return null;
		}

		public function getProjectMenuItems(project:ProjectVO):Vector.<MenuItem>
		{
			for(var i:int = 0; i < _projectTypePlugins.length; i++)
			{
				var plugin:IProjectTypePlugin = _projectTypePlugins[i];
				if (!(project is plugin.projectClass))
				{
					continue;
				}
				return plugin.getProjectMenuItems(project);
			}
			return null;
		}

		public function startProjectBuild(project:ProjectVO):void
		{
			for(var i:int = 0; i < _actionbarTypePlugins.length; i++)
			{
				var plugin:IPlugin = _actionbarTypePlugins[i];
				if ((plugin as IBuildActionsProvider).testProjectExtension(project))
				{
					(plugin as IBuildActionsProvider).buildByActionbar();
					break;
				}
			}
		}
	}
}