////////////////////////////////////////////////////////////////////////////////
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
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.as3project.exporter
{
    import actionScripts.utils.SerializeUtil;

    import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.actionscript.as3project.AS3ProjectPlugin;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.core.exporter.FlashDevelopExporterBase;
	
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
                isPrimeFacesVisualEditor: SerializeUtil.serializeBoolean(p.isPrimeFacesVisualEditorProject),
                isExportedToExistingSource: SerializeUtil.serializeBoolean(p.isExportedToExistingSource),
                visualEditorExportPath: SerializeUtil.serializeString(p.visualEditorExportPath),
				isRoyale: SerializeUtil.serializeBoolean(p.isRoyale)
			}
			if (p.testMovieCommand && p.testMovieCommand != "") 
			{
				optionPairs.testMovieCommand = p.testMovieCommand;
			}
			options.appendChild(SerializeUtil.serializePairs(optionPairs, <option />));
			project.appendChild(options);
			
			var projType:int = !p.air ? AS3ProjectPlugin.AS3PROJ_AS_WEB : AS3ProjectPlugin.AS3PROJ_AS_AIR;
			if (p.isMobile) projType = AS3ProjectPlugin.AS3PROJ_AS_ANDROID;
			
			var platform:int = !p.air ? AS3ProjectPlugin.AS3PROJ_AS_WEB : AS3ProjectPlugin.AS3PROJ_AS_AIR;
			if (p.isRoyale) platform = (p.buildOptions.targetPlatform == "SWF") ? AS3ProjectPlugin.AS3PROJ_AS_WEB : AS3ProjectPlugin.AS3PROJ_JS_WEB;
			else if (p.isMobile) platform = (p.buildOptions.targetPlatform == "Android") ? AS3ProjectPlugin.AS3PROJ_AS_ANDROID : AS3ProjectPlugin.AS3PROJ_AS_IOS;
			
			options = <moonshineRunCustomization />;
			optionPairs = {
				projectType		:	projType,
				targetPlatform	:	platform,
				urlToLaunch		:	p.urlToLaunch ? p.urlToLaunch : "",
				customUrlToLaunch:	p.customHTMLPath ? p.customHTMLPath : "",
				launchMethod	:	p.buildOptions.isMobileRunOnSimulator ? "Simulator" : "Device",
				deviceSimulator	:	p.isMobileHasSimulatedDevice ? p.isMobileHasSimulatedDevice.name : null
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