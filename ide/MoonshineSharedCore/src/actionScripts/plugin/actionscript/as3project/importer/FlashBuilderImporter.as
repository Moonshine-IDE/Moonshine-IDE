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
package actionScripts.plugin.actionscript.as3project.importer
{
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.plugin.actionscript.as3project.vo.BuildOptions;
    import actionScripts.plugin.core.importer.FlashBuilderImporterBase;
    import actionScripts.utils.SDKUtils;
    import actionScripts.utils.SerializeUtil;
    import actionScripts.utils.UtilsCore;
	
	public class FlashBuilderImporter extends FlashBuilderImporterBase
	{
		public static function test(file:FileLocation):FileLocation
		{
			var ret:Boolean = true;
			if (file.resolvePath(".actionScriptProperties").fileBridge.exists == false) 
				ret = false;
			if (file.resolvePath(".project").fileBridge.exists == false)
				ret = false;
			
			return ((ret) ? new FileLocation(file.fileBridge.nativePath) : null);
		}
		
		public static function parse(file:FileLocation):AS3ProjectVO
		{
			var p:AS3ProjectVO = new AS3ProjectVO(file);
			
			var libSettings:File = file.resolvePath(".flexLibProperties").fileBridge.getFile as File;
			if (libSettings.exists) p.isLibraryProject = true;
			
			var projectSettings:File = file.resolvePath(".project").fileBridge.getFile as File;
			readProjectSettings(projectSettings, p);
			
			var actionscriptProperties:File = file.resolvePath(".actionScriptProperties").fileBridge.getFile as File;
			readActionScriptSettings(actionscriptProperties, p);
			
			// For AIR projects we need to meddle with the projectname-app.xml file
			if (p.air == true)
			{
				if (p.targets.length > 0)
				{
					var targetApp:File = p.targets[0].fileBridge.getFile as File;
					var appConfig:File = targetApp.parent.resolvePath(p.projectName+"-app.xml");
					if (appConfig.exists) updateAppConfigXML(appConfig, p);
				}
			}
			
			UtilsCore.setProjectMenuType(p);
			
			return p;
		}
		
		protected static function readProjectSettings(file:File, p:AS3ProjectVO):void
		{
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			var data:XML = XML(stream.readUTFBytes(file.size));
			stream.close();
			
			p.projectName = data.name;
		}
		
		protected static function readActionScriptSettings(file:File, p:AS3ProjectVO):void
		{
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			var dataString:String = stream.readUTFBytes(file.size);
			var data:XML = XML(dataString);
			p.flashBuilderProperties = data;
			stream.close();
			
			var isDocumentsPathExists: Boolean = (dataString.indexOf("${DOCUMENTS}") != -1);
			if (isDocumentsPathExists)
			{
				var folderToSearch: String = ".metadata";
				for (var i:int = 0; i < 6; i++)
				{
					var m:File;
					try
					{
						if (i == 0) m = p.folderLocation.fileBridge.getFile.parent.resolvePath(folderToSearch);
						else if (i == 1) m = p.folderLocation.fileBridge.getFile.parent.parent.resolvePath(folderToSearch);
						else if (i == 2) m = p.folderLocation.fileBridge.getFile.parent.parent.parent.resolvePath(folderToSearch);
						else if (i == 3) m = p.folderLocation.fileBridge.getFile.parent.parent.parent.parent.resolvePath(folderToSearch);
						else if (i == 4) m = p.folderLocation.fileBridge.getFile.parent.parent.parent.parent.resolvePath(folderToSearch);
						else if (i == 5) m = p.folderLocation.fileBridge.getFile.parent.parent.parent.parent.parent.resolvePath(folderToSearch);
					}
					catch (e:Error)
					{
						break;
					}
					if (m.exists)
					{
						m = m.resolvePath(".plugins/org.eclipse.core.runtime/.settings/org.eclipse.core.resources.prefs");
						if (m.exists)
						{
							CONFIG::OSX
							{
								if (!checkOSXBookmarked(m.nativePath)) break;
							}
							
							stream = new FileStream();
							stream.open(m, FileMode.READ);
							dataString = stream.readUTFBytes(m.size);
							stream.close();
							
							var allLines:Array = dataString.split(/\n/);
							for each (var j:Object in allLines)
							{
								if (j.toString().indexOf("pathvariable.DOCUMENTS") != -1)
								{
									allLines = j.toString().split("=");
									p.flashBuilderDOCUMENTSPath = allLines[1];
									p.flashBuilderDOCUMENTSPath = p.flashBuilderDOCUMENTSPath.replace("\r", "");
									p.flashBuilderDOCUMENTSPath = p.flashBuilderDOCUMENTSPath.replace("\\:", ":"); // for Windows settlement. i.e. C\:/Users/
									break;
								}
							}
						}
						break;
					}
				}
			}
			
			var sourceFolder:FileLocation = p.folderLocation.resolvePath(data.compiler.@sourceFolderPath);
			var outputFolder:FileLocation = p.folderLocation.resolvePath(data.compiler.@outputFolderPath);
			
			parsePaths(data.compiler.compilerSourcePath["compilerSourcePathEntry"], p.classpaths, p, "path", p.flashBuilderDOCUMENTSPath);
			//parsePaths(data.compiler.moonshineResourcePath["moonshineResourcePathEntry"], p.resourcePaths, p, "path", p.flashBuilderDOCUMENTSPath);
			parsePaths(data.compiler.libraryPath.libraryPathEntry.excludedEntries.libraryPathEntry.(@linkType == "10"), p.resourcePaths, p, "path", p.flashBuilderDOCUMENTSPath);
			parsePaths(data.compiler.libraryPath.libraryPathEntry.(@kind == "3"), p.libraries, p, "path", p.flashBuilderDOCUMENTSPath);
			
			// flash modules
			if ((data.modules as XMLList).children().length() != 0)
			{
				p.flashModuleOptions.parse(data.modules);
			}

			p.buildOptions.parse(data.compiler, BuildOptions.TYPE_FB);
			var target:FileLocation = sourceFolder.resolvePath(data.@mainApplicationPath); 
			p.targets.push(target);
			
			p.air = SerializeUtil.deserializeBoolean(data.compiler.@useApolloConfig);
			p.isActionScriptOnly = SerializeUtil.deserializeBoolean(data.compiler.@useFlashSDK);

			// FB doesn't seem to have a notion of output filename, so we guesstimate it
			p.swfOutput.path = outputFolder.resolvePath(p.targets[0].fileBridge.name.split(".")[0] + ".swf");
			// lets update SWF version too per current SDK version (if setup a default SDK)
			p.swfOutput.swfVersion = SDKUtils.getSdkSwfMajorVersion(p.buildOptions.customSDKPath);
			p.swfOutput.swfMinorVersion = SDKUtils.getSdkSwfMinorVersion(p.buildOptions.customSDKPath);
			
			p.classpaths.push(sourceFolder);
			p.isFlashBuilderProject = true;
			p.sourceFolder = sourceFolder;
			p.isMobile = UtilsCore.isMobile(p);
		}
		
		protected static function updateAppConfigXML(file:File, p:AS3ProjectVO):void
		{
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.READ);
			var data:String = stream.readUTFBytes(file.size).toString();
			stream.close();
			
			var replacement:String = p.projectName + ".swf";
			p.isMobile = UtilsCore.isMobile(p);
			
			// Try to not mess up the formatting of the XML first
			//  by just string replacing
			if (data.indexOf("<content>") > -1)
			{
				data = data.replace(/<content>.*?<\/content>/, "<content>"+ replacement +"</content>");
			}
			// If that fails we change up the XML
			else
			{
				XML.ignoreComments = false;
				XML.ignoreWhitespace = false;
			
				var dataXML:XML = XML(data);

				var ns:Namespace = dataXML.namespaceDeclarations()[0];
				dataXML.ns::initialWindow.ns::content = replacement;
			
				data = dataXML.toXMLString();
			
				XML.ignoreComments = true;
				XML.ignoreWhitespace = true;				
			}
						
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes(data);
			stream.close();
		}
	}
}