////////////////////////////////////////////////////////////////////////////////
// Copyright 2017 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.utils
{
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.console.ConsoleOutputEvent;

	import flash.events.IEventDispatcher;

	import flash.filesystem.File;

	public function FindAndCopyApplicationDescriptor(file:File, project:AS3ProjectVO, destDir:File):String
	{
		var dispatcher:IEventDispatcher = GlobalEventDispatcher.getInstance();

		// Guesstimate app-xml name
		var rootPath:String = File(project.folderLocation.fileBridge.getFile).getRelativePath(file.parent);
		var descriptorName:String = project.swfOutput.path.fileBridge.name.split(".")[0] +"-app.xml";
		var appXML:String = project.targets[0].fileBridge.parent.fileBridge.nativePath + File.separator + descriptorName;
		var descriptorFile:File = new File(appXML);

		// in case /src/app-xml present update to bin-debug folder
		if (descriptorFile.exists)
		{
			appXML = rootPath + File.separator + descriptorName;
			var descriptorCopyTo:File = project.folderLocation.resolvePath(appXML).fileBridge.getFile as File;

			var message:String = "Application descriptor file: " + descriptorFile.nativePath + " copy to " + descriptorCopyTo.nativePath;
			dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT,
					message, false, false, ConsoleOutputEvent.TYPE_INFO));

			descriptorFile.copyTo(descriptorCopyTo, true);
			descriptorFile =  project.folderLocation.resolvePath(appXML).fileBridge.getFile as File;

			var descriptorContent:String = FileUtils.readFromFile(descriptorFile) as String;
			var sdkDirectory:FileLocation = project.buildOptions.customSDK ? project.buildOptions.customSDK : IDEModel.getInstance().defaultSDK;
			if (!sdkDirectory || !sdkDirectory.fileBridge.exists)
			{
				throw new Error("No SDK directory found to process namespace.");
				return null;
			}

			var airConfigContent:XML = new XML(FileUtils.readFromFile(
					sdkDirectory.fileBridge.resolvePath("airsdk.xml").fileBridge.getFile as File
			) as String);
			var xmlns:Namespace = new Namespace(airConfigContent.namespace());
			var versionMapXML:XMLList = airConfigContent.xmlns::applicationNamespaces.xmlns::versionMap;
			var airNamespaceValue:Object = versionMapXML[0].xmlns::descriptorNamespace.text()[0];

			// replace if appropriate
			descriptorContent = descriptorContent.replace(/<content>.*?<\/content>/, "<content>"+ project.swfOutput.path.fileBridge.name +"</content>");
			descriptorContent = descriptorContent.replace(/<application xmlns=".*?">/, "<application xmlns=\""+ airNamespaceValue.toString() +"\">");
			if (descriptorContent.indexOf("_") != -1)
			{
				// MOON-108
				// Since underscore char is not allowed in <id> we'll need to replace it
				var idFirstIndex:int = descriptorContent.indexOf("<id>");
				var idLastIndex:int = descriptorContent.indexOf("</id>");
				var descriptorContentIdValue:String = descriptorContent.substring(idFirstIndex, idLastIndex+5);

				var pattern:RegExp = new RegExp(/(_)/g);
				var newID:String = descriptorContentIdValue.replace(pattern, "");
				descriptorContent = descriptorContent.replace(descriptorContentIdValue, newID);
			}

			FileUtils.writeToFile(descriptorFile, descriptorContent);
		}

		if (!descriptorFile.exists)
		{
			descriptorFile = project.folderLocation.resolvePath("application.xml").fileBridge.getFile as File;
			if (descriptorFile.exists) appXML = "application.xml";
		}
		return appXML;
	}
}
