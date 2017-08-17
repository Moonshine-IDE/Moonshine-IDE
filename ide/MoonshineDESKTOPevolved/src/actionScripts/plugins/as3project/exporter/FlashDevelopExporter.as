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
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.utils.UtilsCore;
	
	public class FlashDevelopExporter
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
			
			// Get output node with relative paths		
			var outputXML: XML = p.swfOutput.toXML(p.folderLocation);
			project.appendChild(outputXML);
			
			project.insertChildAfter(outputXML, "<!-- Other classes to be compiled into your SWF -->");
			
			project.appendChild(exportPaths(p.classpaths, <classpaths />, <class />, p));
			project.appendChild(exportPaths(p.resourcePaths, <moonshineResourcePaths />, <class />, p));
			
			project.appendChild(p.buildOptions.toXML());
			
			project.appendChild(exportPaths(p.includeLibraries, <includeLibraries />, <element />, p));
			project.appendChild(exportPaths(p.libraries, <libraryPaths />, <element />, p));
			project.appendChild(exportPaths(p.externalLibraries, <externalLibraryPaths />, <element />, p));
			project.appendChild(exportPaths(p.runtimeSharedLibraries, <rslPaths></rslPaths>, <element />, p));
			project.appendChild(exportPaths(p.intrinsicLibraries, <intrinsics />, <element />, p));
			if (p.assetLibrary && p.assetLibrary.children().length() == 0)
			{
				var libXML:XMLList = p.assetLibrary;
				var tmpXML:XML = <!-- <empty/> -->
				libXML.child[0] = tmpXML;
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
			
			var prebuildXML:XML = <preBuildCommand />;
			prebuildXML.appendChild(p.prebuildCommands);
			project.appendChild(prebuildXML);
			
			var postbuildXML:XML = <postBuildCommand />;
			postbuildXML.appendChild(p.postbuildCommands);
			postbuildXML.@alwaysRun = UtilsCore.serializeBoolean(p.postbuildAlways);
			project.appendChild(postbuildXML);
			
			var options:XML = <options />;
			var optionPairs:Object = {
				showHiddenPaths		:	UtilsCore.serializeBoolean(p.showHiddenPaths),
				testMovie			:	UtilsCore.serializeString(p.testMovie),
				defaultBuildTargets	:	UtilsCore.serializeString(p.defaultBuildTargets),
				testMovieCommand	:	UtilsCore.serializeString(p.testMovieCommand)
			}
			if (p.testMovieCommand && p.testMovieCommand != "") 
			{
				optionPairs.testMovieCommand = p.testMovieCommand;
			}
			options.appendChild(UtilsCore.serializePairs(optionPairs, <option />));
			project.appendChild(options);
			
			// update obj/*config.xml
			if (p.config.file && p.config.file.fileBridge.exists)
			{
				p.updateConfig();
			}
				
			return project;
		}
		
		private static function exportPaths(v:Vector.<FileLocation>, container:XML, element:XML, p:AS3ProjectVO, absolutePath:Boolean=false, appendAsValue:Boolean=false, nullValue:String=null):XML
		{
			for each (var f:FileLocation in v) 
			{
				var e:XML = element.copy();
				var relative:String = p.folderLocation.fileBridge.getRelativePath(f, true);
				if (absolutePath) relative = null;
				if (appendAsValue) e.appendChild(relative ? relative : f.fileBridge.nativePath);
				else e.@path = relative ? relative : f.fileBridge.nativePath;
				container.appendChild( e );
			}
			
			if (v.length == 0 && nullValue)
			{
				element.appendChild(nullValue);
				container.appendChild(nullValue);
			}
			else if (v.length == 0)
			{
				var tmpXML:XML = <!-- <empty/> -->
				container.appendChild(tmpXML);
			}
			
			return container;
		}
		
	}
}