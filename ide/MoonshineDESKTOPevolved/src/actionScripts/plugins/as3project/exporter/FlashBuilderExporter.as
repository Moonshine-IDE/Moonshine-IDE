////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
package actionScripts.plugins.as3project.exporter
{
	import flash.desktop.NativeApplication;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.collections.XMLListCollection;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	
	public class FlashBuilderExporter
	{
		private static var sourceFolderPath:String;
		private static const SOURCE_NODE: String = "SOURCE_NODE";
		private static const SWC_NODE: String = "SWC_NODE";
		private static const MOONSHINE_RESOURCE_NODE: String = "MOONSHINE_RESOURCE_NODE";
		private static const isMacOS: Boolean = !NativeApplication.supportsSystemTrayIcon;
		
		public static function export(p:AS3ProjectVO, file:File):void
		{
			var output:XML = toXML(p);
			
			var fw:FileStream = new FileStream();
			
			fw.open(file, FileMode.WRITE);
			// Does not prefix with a 16-bit length word like writeUTF() does
			fw.writeUTFBytes('<?xml version="1.0" encoding="utf-8" standalone="no"?>\n' + output.toXMLString());
			fw.close();
		}
		
		/*
			Serialize to FlashDevelop compatible XML project file.
		*/
		private static function toXML(p:AS3ProjectVO):XML
		{
			// custom Flex SDK
			updateAttributes(p.flashBuilderProperties.compiler, "flexSDK", p.buildOptions.customSDKPath);
			updateAttributes(p.flashBuilderProperties.compiler, "additionalCompilerArguments", p.air ? p.buildOptions.additional.replace("+configname=air", "") : p.buildOptions.additional);
			updateAttributes(p.flashBuilderProperties.compiler, "warn", p.buildOptions.warnings.toString());
			updateAttributes(p.flashBuilderProperties.compiler, "strict", p.buildOptions.strict.toString());
			
			sourceFolderPath = p.flashBuilderProperties.compiler.@sourceFolderPath;
			
			// remove any path settings in .actionScriptProperties XML first
			delete p.flashBuilderProperties.compiler.compilerSourcePath;
			// remove any SWC path
			for each (var i:XML in p.flashBuilderProperties.compiler.libraryPath.libraryPathEntry)
			{
				delete i.(@kind == "3")[0];
			}
			// remove any resource type of path
			for each (var m:XML in p.flashBuilderProperties.compiler.libraryPath.libraryPathEntry.excludedEntries.libraryPathEntry)
			{
				delete m.(@linkType == "10")[0];
			}
			
			// adds new source paths
			p.flashBuilderProperties.compiler.child[0] = exportPaths(p.classpaths, <compilerSourcePath/>, <compilerSourcePathEntry/>, p, SOURCE_NODE);
			//p.flashBuilderProperties.compiler.child[0] = exportPaths(p.resourcePaths, <compilerSourcePath/>, <compilerSourcePathEntry/>, p, MOONSHINE_RESOURCE_NODE);
			
			// resource items
			var resourceXML:Vector.<XML> = exportPaths(p.resourcePaths, null, <libraryPathEntry/>, p, MOONSHINE_RESOURCE_NODE) as Vector.<XML>;
			for each (var k:XML in resourceXML)
			{
				p.flashBuilderProperties.compiler.libraryPath.libraryPathEntry.excludedEntries.child[0] = k;	
			}
			
			// adds new SWC paths
			var swcPaths:XML = exportPaths(p.libraries, <libraryPath/>, <libraryPathEntry/>, p, SWC_NODE) as XML;
			for each (var j:XML in swcPaths.libraryPathEntry)
			{
				p.flashBuilderProperties.compiler.libraryPath.child[0] = j;
			}
			
			return p.flashBuilderProperties;
		}
		
		private static function updateAttributes(container:XMLList, attributeName:String, updateWith:String):void
		{
			if (updateWith)
			{
				delete container.@[attributeName];
				container.@[attributeName] = updateWith;
			}
		}
		
		private static function exportPaths(v:Vector.<FileLocation>, container:XML, element:XML, p:AS3ProjectVO, nodeAs:String=null):Object
		{
			var tmpList:Vector.<XML> = (!container) ? new Vector.<XML>() : null;
			for each (var f:FileLocation in v) 
			{
				var e:XML = element.copy();
				var relative:String = p.folderLocation.fileBridge.getRelativePath(f);
				// don't add sourcefolderpath again
				e.@path = relative ? relative : f.fileBridge.nativePath;
				if (e.@path != sourceFolderPath)
				{
					if (!isMacOS) 
					{
						var ptrn:RegExp = new RegExp(/\\/g);
						e.@path = e.@path.toString().replace(ptrn, "/");
					}
					if (e.@path.indexOf(p.flashBuilderDOCUMENTSPath) != -1)
					{
						e.@path = e.@path.toString().replace(p.flashBuilderDOCUMENTSPath, "${DOCUMENTS}");
					}
					if (nodeAs == SOURCE_NODE)
					{
						e.@kind = 1;
						e.@linkType = 1;
					}
					else if (nodeAs == SWC_NODE)
					{
						e.@kind = 3;
						e.@linkType = 1;
					}
					else if (nodeAs == MOONSHINE_RESOURCE_NODE)
					{
						e.@kind = 3;
						e.@linkType = 10;
						e.@useDefaultLinkType = "false"
					}
					
					if (!container) tmpList.push(e);
					else container.appendChild(e);
				}
			}
			return container ? container : tmpList;
		}
		
	}
}