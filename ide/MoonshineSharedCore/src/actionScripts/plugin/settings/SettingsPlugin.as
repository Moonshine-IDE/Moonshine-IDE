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
package actionScripts.plugin.settings
{

	/**
	 *
	 * Settings Plugin - Plugin to save plugin settings
	 *
	 * Flow
	 * ---------
	 *
	 * Restoring
	 *
	 * 1)Plugins will be registered via PluginManager.registerPlugin(plug:IPlugin)
	 * 2)SettingsPlugin.initializePlugin(plug:IPlugin) will be called which reads the xml file
	 * (if any) and restores the plugin instance settings.
	 * 		A 'Proxy' we be set by ISettingsProvider.getSettings(), where each ISetting will
	 * 		either pass a string name of a public property/setter&getter
	 * 		ex : public function getSettings():Vector<ISetting>{
	 * 			return Vector.<ISetting>([
	 * 						new BooleanSetting(this,"myBooleanProperty","My Desciption")
	 * 			]);
	 * 		}
	 *
	 * 	Each render will by default have ISetting.stringValue which can take any string value,
	 * 	if the inner property value has an datatype other then String you may override this function
	 * 	to typecast to the needed property, or in use with complex objects ie. FontDescription
	 * 		ex . override public function get stringValue():String{
	 * 				var fontDescription:FontDescription = getSetting() as FontDescription;
	 * 				return [fontDescription.fontName,........,......,...].join(",");
	 * 			}
	 * 			override public function set stringValue(value:String):void{
	 * 				// Construct new FontDescription
	 * 				var args:Array = value.split(",");
	 * 				var fontDescription:FontDescription = new FontDescription(args[0],args[1],args[2],args[3]);
	 * 				applySetting(fontDescription);
	 * 			}
	 * 3) After SettingPlugin.readClassSettings(IPlugin) is called a Boolean value of true is returned
	 * 		as if the plugin settings says to activate the plugin , by default (on first plugin run) all will be
	 * 		activated.
	 *
	 *
	 * Note: Plugin Settings will be stored in File.applicationStorageDirectory+/settings in the following format
	 * 		CRC32(QualifiedClassName)_CLASSNAME.xml
	 * 		This is done to ensure that no two settings ( even if CLASSNAME is the same) will
	 * 		have the same settings file
	 *
	 * 4) IPlugin.activatedByDefault ensures if the plugin will be activated by default
	 * 		when the plugin is loaded for the first time (without settings xml file written)
	 *
	 * */
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	
	import actionScripts.events.AddTabEvent;
	import actionScripts.events.SettingsEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.PluginEvent;
	import actionScripts.plugin.PluginManager;
	import actionScripts.plugin.fullscreen.FullscreenPlugin;
	import actionScripts.plugin.settings.event.RequestSettingEvent;
	import actionScripts.plugin.settings.event.SetSettingsEvent;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PluginSetting;
	import actionScripts.plugin.settings.vo.PluginSettingsWrapper;
	import actionScripts.plugin.splashscreen.SplashScreenPlugin;
	import actionScripts.plugin.syntax.AS3SyntaxPlugin;
	import actionScripts.plugin.syntax.CSSSyntaxPlugin;
	import actionScripts.plugin.syntax.HTMLSyntaxPlugin;
	import actionScripts.plugin.syntax.JSSyntaxPlugin;
	import actionScripts.plugin.syntax.MXMLSyntaxPlugin;
	import actionScripts.plugin.syntax.XMLSyntaxPlugin;
	import actionScripts.ui.menu.MenuPlugin;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.utils.SDKUtils;
	import actionScripts.utils.moonshine_internal;
	import actionScripts.valueObjects.ConstantsCoreVO;

	use namespace moonshine_internal;

	public class SettingsPlugin extends PluginBase implements ISettingsProvider
	{
		override public function get name():String 			{ return "Project Settings Plugin"; }
		override public function get author():String 		{ return "Moonshine Project Team"; }
		override public function get description():String 	{ return "Provides settings for all plugins."; }

		public function getSettingsList():Vector.<ISetting>
		{
			return new Vector.<ISetting>();
		}

		public var pluginManager:PluginManager;

		private var settingsDirectory:FileLocation;
		private var appSettings:SettingsView;

		// NOTE: Temporary solution for hiding some plugins from the settings view
		// If the syntax plugins are combined this might be removed
		private var excludeFromSettings:Array = [MenuPlugin,MXMLSyntaxPlugin,
												 AS3SyntaxPlugin, SplashScreenPlugin,
												 XMLSyntaxPlugin,CSSSyntaxPlugin,JSSyntaxPlugin,HTMLSyntaxPlugin,
												 FullscreenPlugin];

		public function SettingsPlugin()
		{
			excludeFromSettings = excludeFromSettings.concat(model.flexCore.getPluginsNotToShowInSettings());
			
			dispatcher.addEventListener(SettingsEvent.EVENT_OPEN_SETTINGS, openAppSettings);
			dispatcher.addEventListener(CloseTabEvent.EVENT_TAB_CLOSED, handleTabClose);
			dispatcher.addEventListener(SetSettingsEvent.SET_SETTING, handleSetSettings);
			dispatcher.addEventListener(RequestSettingEvent.REQUEST_SETTING, handleRequestSetting);
			dispatcher.addEventListener(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING, handleSpecificPluginSave);
			
			if (ConstantsCoreVO.IS_AIR)
			{
				settingsDirectory = model.fileCore.resolveApplicationStorageDirectoryPath("settings");
				if (!settingsDirectory.fileBridge.exists) settingsDirectory.fileBridge.createDirectory();
			}
			else
			{
				settingsDirectory = new FileLocation();
			}
			
			var tempObj:Object = new Object();
			tempObj.callback = clearAllSettings;
			tempObj.commandDesc = "Clear application settings.";
			registerCommand("debug-clear-app-settings",tempObj);
		}


		private function getClassName(instance:*):String
		{
			return getQualifiedClassName(instance).split("::").pop();
		}

		private function handleRequestSetting(e:RequestSettingEvent):void
		{
			var className:String = getClassName(e.provider);
			var plug:IPlugin = pluginManager.getPluginByClassName(className);
			if (plug && e.name in plug)
				e.value = plug[e.name];

		}

		private function handleSetSettings(e:SetSettingsEvent):void
		{
			var className:String = getClassName(e.provider);
			var plug:IPlugin = pluginManager.getPluginByClassName(className);
			if (!plug || !(e.name in plug))
				return;
			plug[e.name] = e.value;
			var saveData:XML = getXMLSettingsForSave(plug); // retrive settings or default stub
			appendOrUpdateXML(saveData, e.name, String(e.value)); //update settings with new value
			commitClassSettings(plug, saveData, generateSettingsPath(plug)); // save value


			//var settingsObject:IHasSettings = new PluginSettingsWrapper(plug.name, setList, qualifiedClassName);
		}

		public function initializePlugin(plug:IPlugin):Boolean
		{
			if (!plug)
				return false;

			var activated:Boolean = readClassSettings(plug);
			pluginStateChanged(plug, activated);
			//if (activated)
			//	plug.activate();

			//dispatcher.dispatchEvent(new
			return activated;
		}

		private function openAppSettings(event:Event):void
		{
			var jumpToSettingQualifiedClassName:String;
			if (event is SettingsEvent && SettingsEvent(event).openSettingsByQualifiedClassName) 
			{
				jumpToSettingQualifiedClassName = SettingsEvent(event).openSettingsByQualifiedClassName;
			}
			
			if (appSettings)
			{
				model.activeEditor = appSettings;
				appSettings.forceSelectItem(jumpToSettingQualifiedClassName);
				return;
			}
			
			var settings:SettingsView = new SettingsView();
			settings.Width = 230;
			// Save it so we don't open multiple instances of app settings
			appSettings = settings;

			var catPlugins:String = "Plugins";
			settings.addCategory(catPlugins);

			var plugins:Vector.<IPlugin> = pluginManager.moonshine_internal::getPlugins();

			var qualifiedClassName:String;
			var provider:ISettingsProvider
			for each (var plug:IPlugin in plugins)
			{
				if (plug == this)
					continue; // omit Settings Plugin from showing up
				
				// Omit plugins defined in excludeFromSettings
				//  questionable flow control
				var skip:Boolean = false;
				for each (var omit:Class in excludeFromSettings)
				{
					if (plug is omit) 
					{
						skip = true;
						continue;
					}
				}
				if (skip) continue;
				
					
				provider = plug as ISettingsProvider;

				qualifiedClassName = getQualifiedClassName(plug);

				var setList:Vector.<ISetting> = provider ? provider.getSettingsList() : new Vector.<ISetting>();

				var p:PluginSetting = new PluginSetting(plug.name, plug.author, plug.description, plug.activated);
				setList.unshift(p);

				var settingsObject:IHasSettings = new PluginSettingsWrapper(plug.name, setList, qualifiedClassName);
				if (settingsObject)
				{
					settings.addSetting(settingsObject, catPlugins);
				}
				
				if (jumpToSettingQualifiedClassName && (jumpToSettingQualifiedClassName == qualifiedClassName)) settings.currentRequestedSelectedItem = settingsObject as PluginSettingsWrapper;
			}

			dispatcher.dispatchEvent(
				new AddTabEvent(settings)
				);

			settings.addEventListener(SettingsView.EVENT_SAVE, handleAppSettingsSave, false, 0, true);
			settings.addEventListener(SettingsView.EVENT_CLOSE, handleAppSettingsClose, false, 0, true);
		}

		// Save clicked in the view 
		//  or save() called by trying to close unsaved tab & saving from the popup
		private function handleAppSettingsSave(e:Event):void
		{
			var catPlugins:String = "Plugins";
			var allSettings:Array = appSettings.getSettings(catPlugins);

			for each (var settingObject:IHasSettings in allSettings)
			{
				saveClassSettings(settingObject);
			}
		}

		// Close clicked in the view
		private function handleAppSettingsClose(e:Event):void
		{
			dispatcher.dispatchEvent(
				new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, appSettings as DisplayObject)
				);
		}

		// Did the app settings view close?
		private function handleTabClose(event:CloseTabEvent):void
		{
			if (event.tab == appSettings)
			{
				appSettings.removeEventListener(SettingsView.EVENT_SAVE, handleAppSettingsSave);
				appSettings.removeEventListener(SettingsView.EVENT_CLOSE, handleAppSettingsClose);
				appSettings = null;
			}
		}

		private function getXMLSettingsForSave(content:Object):XML
		{
			var saveData:XML
			if (content) saveData = retriveXMLSettings(content);
				
			if (!saveData)
			{
				saveData = <settings>
								<properties></properties>
						   </settings>;
			}
			return saveData;
		}

		private function appendOrUpdateXML(xml:XML, name:String, value:String):void
		{
			if (xml.properties.hasOwnProperty(name))
			{
				xml.properties[name] = value;
			}
			else
			{
				xml.properties.appendChild(<{name}>{value}</{name}>);
			}
		}

		private function mergeSaveDataFromList(settingsList:Vector.<ISetting>, content:Object=null):XML
		{

			var saveData:XML = getXMLSettingsForSave(content);

			var settingsClassName:String;
			var propName:String;
			var propValue:String;
			for each (var setting:ISetting in settingsList)
			{
				propName = (setting is PluginSetting) ? "activated" : setting.name;
				propValue = setting.stringValue;
				appendOrUpdateXML(saveData, propName, propValue);

			}

			return saveData;
		}

		private function retriveXMLSettings(content:Object):XML
		{
			var settingsFile:FileLocation = generateSettingsPath(content);
			if (!settingsFile.fileBridge.exists) return null;
			
			var saveData:XML;
			if (ConstantsCoreVO.IS_AIR)
			{
				saveData = new XML(settingsFile.fileBridge.read());
			}
			else
			{
				saveData = new XML();
			}
			
			return saveData;
		}

		public function readClassSettings(plug:IPlugin):Boolean
		{
			var provider:ISettingsProvider = plug as ISettingsProvider;
			var saveData:XML =  retriveXMLSettings(plug);
			if (!saveData) // file not found so check plugin to see if we should activate by default
				return plug.activatedByDefault;

			var settingsList:Vector.<ISetting> = provider ? provider.getSettingsList() : new Vector.<ISetting>();
			var propName:String

			for each (var setting:ISetting in settingsList)
			{
				propName = setting.name;
				if (!saveData.properties.hasOwnProperty(propName))
					continue;

				setting.stringValue = String(saveData.properties[propName].text());
				setting.commitChanges();
			}

			return (saveData.properties.hasOwnProperty("activated") &&
				String(saveData.properties["activated"].text()) == "false") ? false : true;
		}

		public function saveClassSettings(wrapper:IHasSettings):Boolean
		{
			if (!wrapper)
				return true;

			var settingsList:Vector.<ISetting> = wrapper.getSettingsList();

			var qualifiedClassName:String = (wrapper as PluginSettingsWrapper).qualifiedClassName;
			var saveData:XML = mergeSaveDataFromList(settingsList,
				retriveXMLSettings(qualifiedClassName));
			if (!saveData.length())
				return true;


			var settingsFile:FileLocation = generateSettingsPath(qualifiedClassName);
			var className:String = qualifiedClassName.split("::").pop();
			use namespace moonshine_internal;
			var plug:IPlugin = pluginManager.getPluginByClassName(className);
			return commitClassSettings(plug, saveData, settingsFile);
		}
		
		private function handleSpecificPluginSave(event:SetSettingsEvent):void
		{
			var settingsList:Vector.<ISetting> = event.value as Vector.<ISetting>;
			
			var saveData:XML = mergeSaveDataFromList(settingsList,
				retriveXMLSettings(event.name));
			if (!saveData.length()) return;
			
			var settingsFile:FileLocation = generateSettingsPath(event.name);
			var className:String = event.name.split("::").pop();
			use namespace moonshine_internal;
			var plug:IPlugin = pluginManager.getPluginByClassName(className);
			commitClassSettings(plug, saveData, settingsFile);
		}

		private function commitClassSettings(plug:IPlugin, saveData:XML, settingsFile:FileLocation):Boolean
		{
			if (plug)
			{
				// Check to see what the current state of the plugin is
				var activated:Boolean = String(saveData.properties.activated.text()) == "true";

				pluginStateChanged(plug, activated);
			}
			
			if (ConstantsCoreVO.IS_AIR)
			{
				settingsFile.fileBridge.save(saveData.toXMLString());
				return settingsFile.fileBridge.getFile.size > 0;
			}

			return false;
		}

		private function pluginStateChanged(plug:IPlugin, activated:Boolean):void
		{
			if (plug.activated && !activated)
			{
				plug.deactivate();

			}
			else if (!plug.activated && activated)
			{
				plug.activate();
			}

			var type:String = activated ? PluginEvent.PLUGIN_ACTIVATED : PluginEvent.PLUGIN_DEACTIVATED;
			dispatcher.dispatchEvent(
				new PluginEvent(type, plug)
			);

		}

		/**
		 * Generates a file instance pointing to the correct settings file
		 * @param content Content can be of a class instance, class or String
		 * @return
		 *
		 */
		private function generateSettingsPath(content:Object):FileLocation
		{
			if (!ConstantsCoreVO.IS_AIR) return settingsDirectory;
			
			var qualifiedClassName:String = content is String ? String(content) : getQualifiedClassName(content)
			//var uniqueID:uint = generateUniqueID(qualifiedClassName);
			var realClassName:String = qualifiedClassName.split("::").pop();
			return settingsDirectory.resolvePath(realClassName + ".xml");
		}

		// Remove all settings (in case of emergency while developing)
		private function clearAllSettings(...args):void
		{
			if (!settingsDirectory || !settingsDirectory.fileBridge.exists) return;
			
			if (ConstantsCoreVO.IS_AIR)
			{
				settingsDirectory.fileBridge.deleteDirectory(true);
				settingsDirectory.fileBridge.createDirectory();
			}
		}

	}
}
