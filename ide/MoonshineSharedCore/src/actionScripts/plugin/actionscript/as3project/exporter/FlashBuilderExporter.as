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
package actionScripts.plugin.actionscript.as3project.exporter
{
	import flash.desktop.NativeApplication;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
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