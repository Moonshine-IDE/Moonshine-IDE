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
			descriptorContent = descriptorContent.replace(/<content>.*?<\/content>/g, "<content>"+ project.swfOutput.path.fileBridge.name +"</content>");
			descriptorContent = descriptorContent.replace(/<application xmlns=".*?">/g, "<application xmlns=\""+ airNamespaceValue.toString() +"\">");
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
