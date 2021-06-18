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
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.console.ConsoleOutputEvent;

import flash.events.IEventDispatcher;

import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public function findAndCopyApplicationDescriptor(file:File, project:AS3ProjectVO, destDir:File):String
	{
		var dispatcher:IEventDispatcher = GlobalEventDispatcher.getInstance();

		var message:String = "Find and copy application descriptor where swf path is: " + file.nativePath;
		dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT,
				message, false, false, ConsoleOutputEvent.TYPE_INFO));
		// Guesstimate app-xml name
		var rootPath:String = File(project.folderLocation.fileBridge.getFile).getRelativePath(file.parent);
		var descriptorName:String = project.swfOutput.path.fileBridge.name.split(".")[0] +"-app.xml";
		var appXML:String = project.targets[0].fileBridge.parent.fileBridge.nativePath + File.separator + descriptorName;
		var descriptorFile:File = new File(appXML);

		message = "Application descriptor path: " + descriptorFile.nativePath;
		dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT,
				message, false, false, ConsoleOutputEvent.TYPE_INFO));

		// in case /src/app-xml present update to bin-debug folder
		if (descriptorFile.exists)
		{
			appXML = rootPath + File.separator + descriptorName;
			var descriptorCopyTo:File = project.folderLocation.resolvePath(appXML).fileBridge.getFile as File;

			message = "Application descriptor file: " + descriptorFile.nativePath + " copy to " + descriptorCopyTo.nativePath;
			dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT,
					message, false, false, ConsoleOutputEvent.TYPE_INFO));

			descriptorFile.copyTo(descriptorCopyTo, true);
			descriptorFile =  project.folderLocation.resolvePath(appXML).fileBridge.getFile as File;

			message = "Application descriptor file after copy: " + descriptorFile.nativePath;
			dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT,
					message, false, false, ConsoleOutputEvent.TYPE_INFO));

			var stream:FileStream = new FileStream();
			stream.open(descriptorFile, FileMode.READ);
			var data:String = stream.readUTFBytes(descriptorFile.size).toString();
			stream.close();

			// store namespace version for later probable use
			var firstNamespaceQuote:int = data.indexOf('"', data.indexOf("<application xmlns=")) + 1;
			var lastNamespaceQuote:int = data.indexOf('"', firstNamespaceQuote);
			var currentAIRNamespaceVersion:String = data.substring(firstNamespaceQuote, lastNamespaceQuote);

			// replace if appropriate
			data = data.replace(/<content>.*?<\/content>/, "<content>"+ project.swfOutput.path.fileBridge.name +"</content>");
			data = data.replace(currentAIRNamespaceVersion, "http://ns.adobe.com/air/application/"+ (
				(project.swfOutput.swfVersionStrict != 0) ? project.swfOutput.swfVersionStrict : project.swfOutput.swfVersion +".0"
			));
			if (data.indexOf("_") != -1)
			{
				// MOON-108
				// Since underscore char is not allowed in <id> we'll need to replace it
				var idFirstIndex:int = data.indexOf("<id>");
				var idLastIndex:int = data.indexOf("</id>");
				var dataIdValue:String = data.substring(idFirstIndex, idLastIndex+5);

				var pattern:RegExp = new RegExp(/(_)/g);
				var newID:String = dataIdValue.replace(pattern, "");
				data = data.replace(dataIdValue, newID);
			}

			stream = new FileStream();
			stream.open(descriptorFile, FileMode.WRITE);
			stream.writeUTFBytes(data);
			stream.close();
		}

		if (!descriptorFile.exists)
		{
			descriptorFile = project.folderLocation.resolvePath("application.xml").fileBridge.getFile as File;
			if (descriptorFile.exists) appXML = "application.xml";
		}
		return appXML;
	}
}
