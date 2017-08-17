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
        private var menuPlugins:Array = [MenuPlugin];
        private var pendingPlugMenuItems:Vector.<MenuItem> = new Vector.<MenuItem>();

        public function PluginManager()
        {
            model = IDEModel.getInstance();
        }

        public function setupPlugins():void
        {
			//Need to copy asset folder into bin dir also.
        	var allPlugins:Array = corePlugins.concat(defaultPlugins);
        	
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
    }
}