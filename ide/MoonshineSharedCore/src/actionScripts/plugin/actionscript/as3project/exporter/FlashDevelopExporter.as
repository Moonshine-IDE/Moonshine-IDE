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
package actionScripts.plugin.actionscript.as3project.exporter
{
    import actionScripts.utils.SerializeUtil;

    import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.actionscript.as3project.AS3ProjectPlugin;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.core.exporter.FlashDevelopExporterBase;
	import actionScripts.plugin.actionscript.as3project.vo.BuildOptions;
	
	public class FlashDevelopExporter extends FlashDevelopExporterBase
	{
		public static function export(p:AS3ProjectVO, file:FileLocation):void
		{
			if (!file.fileBridge.exists) file.fileBridge.createFile();
			
			var output:XML = toXML(p);
			
			var fw:FileStream = new FileStream();
			
			fw.open(file.fileBridge.getFile as File, FileMode.WRITE);
			// Does not prefix with a 16-bit length word like writeUTF() does
			fw.writeUTFBytes('<?xml version="1.0" encoding="utf-8"?>\n' + output.toXMLString());
			fw.close();
		}
		
		/*
			Serialize to FlashDevelop compatible XML project file.
		*/
		private static function toXML(p:AS3ProjectVO):XML
		{
			var project:XML = <project></project>;
			var tmpXML:XML;
			
			// Get output node with relative paths		
			var outputXML: XML = p.swfOutput.toXML(p.folderLocation);
			project.appendChild(outputXML);

			var jsOutput:XML = <jsOutput></jsOutput>;
			var jsOutputPath:Object = {
				path: SerializeUtil.serializeString(p.jsOutputPath)
			};
			jsOutput.appendChild(SerializeUtil.serializePairs(jsOutputPath, <option />));
			project.appendChild(jsOutput);

			project.insertChildAfter(outputXML, "<!-- Other classes to be compiled into your SWF -->");
			
			project.appendChild(exportPaths(p.classpaths, <classpaths />, <class />, p));
			project.appendChild(exportPaths(p.resourcePaths, <moonshineResourcePaths />, <class />, p));
			project.appendChild(exportPaths(p.nativeExtensions, <moonshineNativeExtensionPaths />, <class />, p));
			
			project.appendChild(p.buildOptions.toXML());
			project.appendChild(p.mavenBuildOptions.toXML());
			
			project.appendChild(exportPaths(p.includeLibraries, <includeLibraries />, <element />, p));
			project.appendChild(exportPaths(p.libraries, <libraryPaths />, <element />, p));
			project.appendChild(exportPaths(p.externalLibraries, <externalLibraryPaths />, <element />, p));
			project.appendChild(exportPaths(p.runtimeSharedLibraries, <rslPaths></rslPaths>, <element />, p));
			project.appendChild(exportPathString(p.intrinsicLibraries, <intrinsics />, <element />, p));
			if (p.assetLibrary && p.assetLibrary.children().length() == 0)
			{
				var libXML:XMLList = p.assetLibrary;
				libXML.child[0] = new XML(<!-- <empty/> -->);
				project.appendChild(libXML);
			}
			else if (p.assetLibrary)
			{
				project.appendChild(p.assetLibrary);
			}
			else
			{
				var tmpBlankXML:XML = <library/>;
				project.appendChild(tmpBlankXML);
			}
			
			project.appendChild(p.flashModuleOptions.toXML());
			project.appendChild(exportPaths(p.targets, <compileTargets />, <compile />, p));
			project.appendChild(exportPaths(p.hiddenPaths, <hiddenPaths />, <hidden />, p));
			
			tmpXML = <preBuildCommand />;
			tmpXML.appendChild(p.prebuildCommands);
			project.appendChild(tmpXML);
			
			tmpXML = <postBuildCommand />;
			tmpXML.appendChild(p.postbuildCommands);
			tmpXML.@alwaysRun = SerializeUtil.serializeBoolean(p.postbuildAlways);
			project.appendChild(tmpXML);
			
			tmpXML = <trustSVNCertificate />;
			tmpXML.appendChild(p.isTrustServerCertificateSVN ? 'True' : 'False');
			project.appendChild(tmpXML);
			
			var options:XML = <options />;
			var optionPairs:Object = {
				showHiddenPaths		:	SerializeUtil.serializeBoolean(p.showHiddenPaths),
				testMovie			:	SerializeUtil.serializeString(p.testMovie),
				defaultBuildTargets	:	SerializeUtil.serializeString(p.defaultBuildTargets),
				testMovieCommand	:	SerializeUtil.serializeString(p.testMovieCommand),
				isDominoVisualEditor: SerializeUtil.serializeBoolean(p.isDominoVisualEditorProject),
                isPrimeFacesVisualEditor: SerializeUtil.serializeBoolean(p.isPrimeFacesVisualEditorProject),
                isExportedToExistingSource: SerializeUtil.serializeBoolean(p.isExportedToExistingSource),
                visualEditorExportPath: SerializeUtil.serializeString(p.visualEditorExportPath),
				isRoyale: SerializeUtil.serializeBoolean(p.isRoyale),
				jdkType: SerializeUtil.serializeString(p.jdkType)
			}
			if (p.testMovieCommand && p.testMovieCommand != "") 
			{
				optionPairs.testMovieCommand = p.testMovieCommand;
			}
			options.appendChild(SerializeUtil.serializePairs(optionPairs, <option />));
			project.appendChild(options);

			if (p.isDominoVisualEditorProject)
			{
				options = <domino />;
				var dominoPairs:Object = {
					dominoBaseAgentURL	:	SerializeUtil.serializeString(p.dominoBaseAgentURL),
					localDatabase		: 	SerializeUtil.serializeString(p.localDatabase),
					targetServer		:	SerializeUtil.serializeString(p.targetServer),
					targetDatabase		:	SerializeUtil.serializeString(p.targetDatabase)
				}
				options.appendChild(SerializeUtil.serializePairs(dominoPairs, <option />));
				project.appendChild(options);
			}
			
			var projType:int = !p.air ? AS3ProjectPlugin.AS3PROJ_AS_WEB : AS3ProjectPlugin.AS3PROJ_AS_AIR;
			if (p.isMobile) projType = AS3ProjectPlugin.AS3PROJ_AS_ANDROID;
			
			var platform:int = !p.air ? AS3ProjectPlugin.AS3PROJ_AS_WEB : AS3ProjectPlugin.AS3PROJ_AS_AIR;
			if (p.isRoyale) platform = (p.buildOptions.targetPlatform == "SWF") ? AS3ProjectPlugin.AS3PROJ_AS_WEB : AS3ProjectPlugin.AS3PROJ_JS_WEB;
			else if (p.isMobile) platform = (p.buildOptions.targetPlatform == "Android") ? AS3ProjectPlugin.AS3PROJ_AS_ANDROID : AS3ProjectPlugin.AS3PROJ_AS_IOS;
			
			options = <moonshineRunCustomization />;
			optionPairs = {
				projectType			:	projType,
				targetPlatform		:	platform,
				urlToLaunch			:	p.urlToLaunch ? p.urlToLaunch : "",
				customUrlToLaunch	:	p.customHTMLPath ? p.customHTMLPath : "",
				launchMethod		:	p.buildOptions.isMobileRunOnSimulator ? "Simulator" : "Device",
				deviceConnectType	:   p.buildOptions.isMobileConnectType ? p.buildOptions.isMobileConnectType : BuildOptions.CONNECT_TYPE_USB,
				deviceSimulator		:	p.isMobileHasSimulatedDevice ? p.isMobileHasSimulatedDevice.name : null,
				webBrowser			:   p.runWebBrowser
			}
			options.appendChild(SerializeUtil.serializePairs(optionPairs, <option />));
			
			tmpXML = <deviceSimulator/>;
			tmpXML.appendChild(p.buildOptions.isMobileHasSimulatedDevice ? p.buildOptions.isMobileHasSimulatedDevice.name : null);
			options.appendChild(tmpXML);
			tmpXML = <certAndroid/>;
			tmpXML.appendChild(p.buildOptions.certAndroid);
			options.appendChild(tmpXML);
			tmpXML = <certIos/>;
			tmpXML.appendChild(p.buildOptions.certIos);
			options.appendChild(tmpXML);
			tmpXML = <certIosProvisioning/>;
			tmpXML.appendChild(p.buildOptions.certIosProvisioning);
			options.appendChild(tmpXML);
			project.appendChild(options);
			
			// update obj/*config.xml
			if (p.config.file && p.config.file.fileBridge.exists)
			{
				p.updateConfig();
			}
				
			return project;
		}
	}
}