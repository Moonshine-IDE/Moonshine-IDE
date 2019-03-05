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
package actionScripts.utils
{
	import flash.events.Event;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.SettingsEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.settings.event.SetSettingsEvent;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugins.git.GitHubPlugin;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.SDKReferenceVO;
	import actionScripts.valueObjects.SDKTypes;

	public class PathSetupHelperUtil
	{
		private static var model:IDEModel = IDEModel.getInstance();
		private static var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		
		public static function openSettingsViewFor(type:String):void
		{
			var pluginClass:String;
			switch (type)
			{
				case SDKTypes.FLEX:
				case SDKTypes.ROYALE:
				case SDKTypes.FLEXJS:
				case SDKTypes.FEATHERS:
				case SDKTypes.OPENJAVA:
					pluginClass = "actionScripts.plugins.as3project.mxmlc::MXMLCPlugin";
					break;
				case SDKTypes.ANT:
					pluginClass = "actionScripts.plugins.ant::AntBuildPlugin";
					break;
				case SDKTypes.GIT:
					pluginClass = "actionScripts.plugins.git::GitHubPlugin";
					break;
				case SDKTypes.MAVEN:
					pluginClass = "actionScripts.plugins.maven::MavenBuildPlugin";
					break;
				case SDKTypes.SVN:
					pluginClass = "actionScripts.plugins.svn::SVNPlugin";
					break;
			}
			
			if (pluginClass) GlobalEventDispatcher.getInstance().dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, pluginClass));
		}
		
		public static function updateFieldPath(type:String, path:String):void
		{
			switch (type)
			{
				case SDKTypes.FLEX:
				case SDKTypes.ROYALE:
				case SDKTypes.FLEXJS:
				case SDKTypes.FEATHERS:
					addProgramingSDK(path);
					break;
				case SDKTypes.OPENJAVA:
					updateJavaPath(path);
					break;
				case SDKTypes.ANT:
					updateAntPath(path);
					break;
				case SDKTypes.GIT:
					updateGitPath(path);
					break;
				case SDKTypes.MAVEN:
					updateMavenPath(path);
					break;
				case SDKTypes.SVN:
					updateSVNPath(path);
					break;
			}
		}
		
		public static function updateAntPath(path:String):void
		{
			// update only if ant path not set
			// or the existing ant path does not exists
			if (!model.antHomePath || !model.antHomePath.fileBridge.exists)
			{
				model.antHomePath = new FileLocation(path);
				var settings:Vector.<ISetting> = Vector.<ISetting>([
					new PathSetting({antHomePath: path}, 'antHomePath', 'Ant Home', true, path)
				]);
				
				// save as moonshine settings
				dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING,
					null, "actionScripts.plugins.ant::AntBuildPlugin", settings));
			}
		}
		
		public static function updateMavenPath(path:String):void
		{
			// update only if ant path not set
			// or the existing ant path does not exists
			if (!model.mavenPath)
			{
				model.mavenPath = path;
				var settings:Vector.<ISetting> = Vector.<ISetting>([
					new PathSetting({mavenPath: path}, 'mavenPath', 'Maven Home', true, path)
				]);
				
				// save as moonshine settings
				dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING,
					null, "actionScripts.plugins.maven::MavenBuildPlugin", settings));
			}
		}
		
		public static function updateJavaPath(path:String):void
		{
			// update only if ant path not set
			// or the existing ant path does not exists
			if (!model.javaPathForTypeAhead || !model.javaPathForTypeAhead.fileBridge.exists)
			{
				model.javaPathForTypeAhead = new FileLocation(path);
				var settings:Vector.<ISetting> = Vector.<ISetting>([
					new PathSetting({currentJavaPath: path}, 'currentJavaPath', 'Java Development Kit Path', true, path)
				]);
				
				// save as moonshine settings
				dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING,
					null, "actionScripts.plugins.as3project.mxmlc::MXMLCPlugin", settings));
			}
		}
		
		public static function updateSVNPath(path:String):void
		{
			// update only if ant path not set
			// or the existing ant path does not exists
			if (!model.svnPath)
			{
				if (ConstantsCoreVO.IS_MACOS)
				{
					dispatcher.dispatchEvent(new Event(GitHubPlugin.RELAY_SVN_XCODE_REQUEST));
				}
				else
				{
					model.svnPath = path;
					var settings:Vector.<ISetting> = Vector.<ISetting>([
						new PathSetting({svnBinaryPath: path}, 'svnBinaryPath', 'SVN Binary', false)
					]);
					
					// save as moonshine settings
					dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING,
						null, "actionScripts.plugins.svn::SVNPlugin", settings));
				}
			}
		}
		
		public static function updateGitPath(path:String):void
		{
			// update only if ant path not set
			// or the existing ant path does not exists
			if (!model.gitPath)
			{
				if (ConstantsCoreVO.IS_MACOS)
				{
					dispatcher.dispatchEvent(new Event(GitHubPlugin.RELAY_SVN_XCODE_REQUEST));
				}
				else
				{
					model.gitPath = path;
					var settings:Vector.<ISetting> = Vector.<ISetting>([
						new PathSetting({gitBinaryPathOSX: path}, 'gitBinaryPathOSX', 'Git Path', true)
					]);
					
					// save as moonshine settings
					dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING,
						null, "actionScripts.plugins.git::GitHubPlugin", settings));
				}
			}
		}
		
		public static function addProgramingSDK(path:String):void
		{
			var sdkPath:FileLocation = new FileLocation(path);
			var tmpSDK:SDKReferenceVO = SDKUtils.getSDKReference(sdkPath);
			SDKUtils.isSDKAlreadySaved(tmpSDK);
			
			// if only not already set
			if (!model.defaultSDK || !model.defaultSDK.fileBridge.exists)
			{
				model.defaultSDK = sdkPath;
				
				var settings:Vector.<ISetting> = Vector.<ISetting>([
					new PathSetting({defaultFlexSDK: path}, 'defaultFlexSDK', 'Default Apache Flex®, Apache Royale® or Feathers SDK', true)
				]);
				
				// save as moonshine settings
				dispatcher.dispatchEvent(new SetSettingsEvent(SetSettingsEvent.SAVE_SPECIFIC_PLUGIN_SETTING,
					null, "actionScripts.plugins.as3project.mxmlc::MXMLCPlugin", settings));
			}
		}
	}
}