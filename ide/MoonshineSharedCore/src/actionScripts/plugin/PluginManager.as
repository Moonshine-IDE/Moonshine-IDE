////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
package actionScripts.plugin
{
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.settings.SettingsPlugin;
	import actionScripts.ui.menu.MenuPlugin;
	import actionScripts.ui.menu.vo.MenuItem;
	import actionScripts.utils.moonshine_internal;

    use namespace moonshine_internal;

    public class PluginManager
    {
		private var model:IDEModel = IDEModel.getInstance();
		
        // Core plugins
        private var corePlugins:Array = model.flexCore.getCorePlugins();

		// Plugins shipped with Moonshine
		private var defaultPlugins:Array = model.flexCore.getDefaultPlugins();
        private var registeredPlugins:Vector.<IPlugin> = new Vector.<IPlugin>();
        private var settingsPlugin:SettingsPlugin;
        private var pendingPlugMenuItems:Vector.<MenuItem> = new Vector.<MenuItem>();

        public function PluginManager()
        {
            model = IDEModel.getInstance();
        }

        public function setupPlugins():void
        {
			//Need to copy asset folder into bin dir also.
        	var allPlugins:Array = mergePlugins(
                    corePlugins,
                    defaultPlugins,
                    model.visualEditorCore.getDefaultPlugins(),
                    model.javaCore.getDefaultPlugins(),
                    model.groovyCore.getDefaultPlugins(),
                    model.haxeCore.getDefaultPlugins(),
					model.ondiskCore.getDefaultPlugins(),
					model.genericCore.getDefaultPlugins());
        	
            var plug:Class;
            for each (plug in allPlugins)
            {
                var instance:IPlugin = new plug() as IPlugin;
                if (!instance)
                {
                    throw new Error("Can't add plugin that doesn't implement IPlugin.");
					break;
                }

                registerPlugin(instance);
            }           
			
			var menuInstance:MenuPlugin = new MenuPlugin();
			for each (var menuItem:MenuItem in pendingPlugMenuItems)
			{
				menuInstance.addPluginMenu(menuItem);
			}
			settingsPlugin.initializePlugin(menuInstance);
			registeredPlugins.push(menuInstance);
			registeredPlugins.sort(order);
			
			/*
			* @local
			*/
			function order(a:Object, b:Object):Number
			{ 
				if (a.name < b.name) { return -1; } 
				else if (a.name > b.name) { return 1; }
				return 0;
			}
        }
		
		private var index:int;
        public function registerPlugin(plug:IPlugin):void
        {
            if (!plug)
                return;
			
			index++;
			
            if (registeredPlugins.indexOf(plug) != -1)
            {
                throw Error("Plugin " + plug.name + " has already been registered");
            }
            registeredPlugins.push(plug);
			
            if (settingsPlugin) // nasty hack for now
            {
                settingsPlugin.initializePlugin(plug);
            }
			
            if (plug is IMenuPlugin)
            {
                var menu:MenuItem = IMenuPlugin(plug).getMenu();
                if (menu)
                    pendingPlugMenuItems.push(menu);
            }

            if (plug is SettingsPlugin)
            {
                SettingsPlugin(plug).pluginManager = this;
                settingsPlugin = SettingsPlugin(plug);
            }
        }

        moonshine_internal function getPluginByClassName(className:String):IPlugin
        {
            var plugins:Vector.<IPlugin> = getPlugins();
            var plug:IPlugin
            for each (plug in plugins)
            {
                if (String(plug).indexOf(className) != -1)
                {
                    return plug;
                }
            }
            return null;
        }

        moonshine_internal function getPlugins():Vector.<IPlugin>
        {
            return registeredPlugins;
        }

        private function mergePlugins(...rest:Array):Array
        {
            var result:Array = [];
            for each(var pluginSet:Array in rest)
            {
                for each(var pluginClass:Class in pluginSet)
                {
                    var index:int = result.indexOf(pluginClass);
                    if(index != -1)
                    {
                        //skip duplicate plugin
                        continue;
                    }
                    result.push(pluginClass);
                }
            }
            return result;
        }
    }
}