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
package actionScripts.plugin.actionscript.as3project.vo
{
	import __AS3__.vec.Vector;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.utils.SDKUtils;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.FileWrapper;
	
	public class MXMLCConfigVO extends FileWrapper
	{
		public function MXMLCConfigVO(file:FileLocation=null)
		{
			super(file);
		}
		
		public function write(pvo:AS3ProjectVO):void 
		{
			if (pvo.targets.length == 0 && !pvo.isLibraryProject) 
			{
				// No targets found for config construction.
				return;
			}
			
			if (pvo.isLibraryProject) writeLibraryConfig(pvo); 
			else writeApplicationConfig(pvo);
		}
		
		public function writeForFlashModule(pvo:AS3ProjectVO, modulePath:FileLocation):FileLocation
		{
			return writeFlashModuleConfig(pvo, modulePath);
		}
		
		private function writeApplicationConfig(pvo:AS3ProjectVO):void 
		{
			if (pvo.isVisualEditorProject) return;

			var oldIC:Boolean = XML.ignoreComments;
			XML.ignoreComments = false;
			
			var data:XML = <flex-config />;
			
			XML.ignoreComments = oldIC;
			
			// re-verify SWF version - crucial part
			if (!pvo.buildOptions.customSDK && IDEModel.getInstance().defaultSDK)
			{
				pvo.swfOutput.swfVersion = SDKUtils.getSdkSwfMajorVersion();
				pvo.swfOutput.swfMinorVersion = SDKUtils.getSdkSwfMinorVersion();
			}
			else if (pvo.buildOptions.customSDK)
			{
				pvo.swfOutput.swfVersion = SDKUtils.getSdkSwfMajorVersion(pvo.buildOptions.customSDKPath);
				pvo.swfOutput.swfMinorVersion = SDKUtils.getSdkSwfMinorVersion(pvo.buildOptions.customSDKPath);
			}
			
			data.appendChild(
				<target-player>{pvo.swfOutput.swfVersion}.{pvo.swfOutput.swfMinorVersion}.0</target-player>
			);
			
			data.appendChild(
				<compiler />
			);
			
			// TODO add locales
			
			// TODO built-in compiler constants like CONFIG::debug, CONFIG::release and CONFIG::timeStamp
			var compilerConstants:Vector.<String> = Vector.<String>([]);
			if (pvo.buildOptions.compilerConstants && pvo.buildOptions.compilerConstants != "")
				compilerConstants = Vector.<String>(pvo.buildOptions.compilerConstants.split("\n"));
			
			for each (var constant:String in compilerConstants) 
			{
				var constantSp:Array = constant.split(",");
				data.compiler.appendChild(<define><name>{constantSp[0]}</name><value>{constantSp[1]}</value></define>);
			}
			
			if (pvo.classpaths.length > 0)			data.compiler.appendChild(exportPaths(pvo.classpaths, <source-path append="true"/>, <path-element/>));
			if (pvo.libraries.length > 0)			data.compiler.appendChild(exportPaths(pvo.libraries, <library-path append="true"/>, <path-element/>));
			// TODO possibly have to iterate through all the swc files in the dir and add their paths manually?
			if (pvo.includeLibraries.length > 0)	data.compiler.appendChild(exportPaths(pvo.includeLibraries, <include-libraries append="true"/>, <library/>));
			if (pvo.externalLibraries.length > 0)	data.compiler.appendChild(exportPaths(pvo.externalLibraries, <external-library-path append="true"/>, <path-element/>));
			// TODO pvo.runtimeSharedLibraries
			
			data.appendChild(exportPaths(pvo.targets, <file-specs/>, <path-element/>));
			data.appendChild(
				<output>{getSWFOutputPath(pvo)}</output>
			);
			
			// SWF
			data.appendChild(<default-background-color>#{pvo.swfOutput.backgroundColorHex}</default-background-color>);
			data.appendChild(<default-frame-rate>{pvo.swfOutput.frameRate}</default-frame-rate>);
			data.appendChild(<default-size><width>{pvo.swfOutput.width}</width><height>{pvo.swfOutput.height}</height></default-size>);
			
			
			if (ConstantsCoreVO.IS_AIR)
			{
				var dataStr:String = 	
					"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"+
					"<!--This Adobe Flex compiler configuration file was generated by a tool.-->\n"+
					"<!--Any modifications you make may be lost.-->\n"+
					data.toXMLString();
				if (!file)
				{
					var dir:FileLocation = pvo.folderLocation.resolvePath("obj/");
					if (!dir.fileBridge.exists) dir.fileBridge.createDirectory();
					
					file = dir.resolvePath(pvo.projectName+"Config.xml");
				}
				
				// Write file
				file.fileBridge.save(dataStr);
			}
		}
		
		private function writeFlashModuleConfig(pvo:AS3ProjectVO, modulePath:FileLocation):FileLocation 
		{
			if (pvo.isVisualEditorProject) return null;
			
			var oldIC:Boolean = XML.ignoreComments;
			XML.ignoreComments = false;
			
			var data:XML = <flex-config />;
			
			XML.ignoreComments = oldIC;
			
			// re-verify SWF version - crucial part
			if (!pvo.buildOptions.customSDK && IDEModel.getInstance().defaultSDK)
			{
				pvo.swfOutput.swfVersion = SDKUtils.getSdkSwfMajorVersion();
				pvo.swfOutput.swfMinorVersion = SDKUtils.getSdkSwfMinorVersion();
			}
			else if (pvo.buildOptions.customSDK)
			{
				pvo.swfOutput.swfVersion = SDKUtils.getSdkSwfMajorVersion(pvo.buildOptions.customSDKPath);
				pvo.swfOutput.swfMinorVersion = SDKUtils.getSdkSwfMinorVersion(pvo.buildOptions.customSDKPath);
			}
			
			data.appendChild(
				<target-player>{pvo.swfOutput.swfVersion}.{pvo.swfOutput.swfMinorVersion}.0</target-player>
			);
			
			data.appendChild(
				<compiler />
			);
			
			// TODO add locales
			
			// TODO built-in compiler constants like CONFIG::debug, CONFIG::release and CONFIG::timeStamp
			var compilerConstants:Vector.<String> = Vector.<String>([]);
			if (pvo.buildOptions.compilerConstants && pvo.buildOptions.compilerConstants != "")
				compilerConstants = Vector.<String>(pvo.buildOptions.compilerConstants.split("\n"));
			
			for each (var constant:String in compilerConstants) 
			{
				var constantSp:Array = constant.split(",");
				data.compiler.appendChild(<define><name>{constantSp[0]}</name><value>{constantSp[1]}</value></define>);
			}
			
			if (pvo.classpaths.length > 0)			data.compiler.appendChild(exportPaths(pvo.classpaths, <source-path append="true"/>, <path-element/>));
			if (pvo.libraries.length > 0)			data.compiler.appendChild(exportPaths(pvo.libraries, <library-path append="true"/>, <path-element/>));
			// TODO possibly have to iterate through all the swc files in the dir and add their paths manually?
			if (pvo.includeLibraries.length > 0)	data.compiler.appendChild(exportPaths(pvo.includeLibraries, <include-libraries append="true"/>, <library/>));
			if (pvo.externalLibraries.length > 0)	data.compiler.appendChild(exportPaths(pvo.externalLibraries, <external-library-path append="true"/>, <path-element/>));
			// TODO pvo.runtimeSharedLibraries
			
			data.appendChild(exportPaths(Vector.<FileLocation>([modulePath]), <file-specs/>, <path-element/>));
			data.appendChild(
				<output>{getSWFOutputPath(pvo, false, modulePath)}</output>
			);
			
			// SWF
			data.appendChild(<default-background-color>#{pvo.swfOutput.backgroundColorHex}</default-background-color>);
			data.appendChild(<default-frame-rate>{pvo.swfOutput.frameRate}</default-frame-rate>);
			data.appendChild(<default-size><width>{pvo.swfOutput.width}</width><height>{pvo.swfOutput.height}</height></default-size>);
			
			
			if (ConstantsCoreVO.IS_AIR)
			{
				var dataStr:String = 	
					"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"+
					"<!--This Adobe Flex compiler configuration file was generated by a tool.-->\n"+
					"<!--Any modifications you make may be lost.-->\n"+
					data.toXMLString();

				var dir:FileLocation = pvo.folderLocation.resolvePath("obj/");
				if (!dir.fileBridge.exists) dir.fileBridge.createDirectory();
				
				var configFile:FileLocation = dir.resolvePath(modulePath.fileBridge.nameWithoutExtension +"Config.xml");
				configFile.fileBridge.save(dataStr);
				
				return configFile;
			}
			
			return null;
		}
		
		private function writeLibraryConfig(pvo:AS3ProjectVO):void
		{
			var oldIC:Boolean = XML.ignoreComments;
			XML.ignoreComments = false;
			
			var data:XML = <flex-config xmlns="http://www.adobe.com/2006/flex-config"/>;
			XML.ignoreComments = oldIC;
			
			// re-verify SWF version - crucial part
			var sdkPath:String;
			if (!pvo.buildOptions.customSDK && IDEModel.getInstance().defaultSDK)
			{
				pvo.swfOutput.swfVersion = SDKUtils.getSdkSwfMajorVersion();
				pvo.swfOutput.swfMinorVersion = SDKUtils.getSdkSwfMinorVersion();
				sdkPath = IDEModel.getInstance().defaultSDK.fileBridge.nativePath;
			}
			else if (pvo.buildOptions.customSDK)
			{
				pvo.swfOutput.swfVersion = SDKUtils.getSdkSwfMajorVersion(pvo.buildOptions.customSDKPath);
				pvo.swfOutput.swfMinorVersion = SDKUtils.getSdkSwfMinorVersion(pvo.buildOptions.customSDKPath);
				sdkPath = pvo.buildOptions.customSDKPath;
			}
			
			data.appendChild(
				<compiler />
			);
			
			data.compiler.appendChild(
				<warn-no-constructor>false</warn-no-constructor>
			);
			data.compiler.appendChild(
				<fonts><managers><manager-class>flash.fonts.JREFontManager</manager-class><manager-class>flash.fonts.BatikFontManager</manager-class><manager-class>flash.fonts.AFEFontManager</manager-class><manager-class>flash.fonts.CFFFontManager</manager-class></managers></fonts>
			);
			data.compiler.appendChild(exportPaths(new <FileLocation>[pvo.sourceFolder], <source-path/>, <path-element/>));
			data.compiler.appendChild(
				<debug>true</debug>
			);
			data.compiler.appendChild(
				<locale><locale-element>en_US</locale-element></locale>
			);
			
			generateLibraryConfigByProjectType(pvo, data, sdkPath, pvo.swfOutput.swfVersion);

			var lib:FileLocation;

			for each (lib in pvo.externalLibraries)
			{
				data.compiler["external-library-path"].appendChild(
					  <path-element>{lib.fileBridge.nativePath}</path-element>
					);
			}

            for each (lib in pvo.libraries)
            {
                data.compiler["library-path"].appendChild(
                        <path-element>{lib.fileBridge.nativePath}</path-element>
                );
            }

			data.appendChild(
				<target-player>{pvo.swfOutput.swfVersion}.{pvo.swfOutput.swfMinorVersion}</target-player>
			);
			data.appendChild(
				<output>{pvo.swfOutput.path.fileBridge.nativePath}</output>
			);
			data.appendChild(
				<static-link-runtime-shared-libraries>false</static-link-runtime-shared-libraries>
			);
			if (pvo.classpaths.length > 0) data.appendChild(exportPaths(pvo.classpaths, <include-sources/>, <path-element/>));
			
			if (ConstantsCoreVO.IS_AIR)
			{
				var dataStr:String = 	
					"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"+
					"<!--This Adobe Flex compiler configuration file was generated by a tool.-->\n"+
					"<!--Any modifications you make may be lost.-->\n"+
					data.toXMLString();
				if (!file)
				{
					var dir:FileLocation = pvo.folderLocation.resolvePath("obj/");
					if (!dir.fileBridge.exists) dir.fileBridge.createDirectory();
					
					file = dir.resolvePath(pvo.projectName+"Config.xml");
				}
				
				// Write file
				file.fileBridge.save(dataStr);
			}
		}
		
		private function exportPaths(v:Vector.<FileLocation>, container:XML, element:XML):XML 
		{
			if (ConstantsCoreVO.IS_AIR)
			{
				for each (var f:FileLocation in v) {
					var e:XML = element.copy();
					var nativePath: String = f.fileBridge.nativePath;
					if (f.fileBridge.nativePath.charAt(0) == "/")
					{
						var pattern:RegExp = new RegExp(/(\\)/g);
						nativePath = f.fileBridge.nativePath.replace(pattern, "/");
					}
					e.appendChild(nativePath);
					container.appendChild(e);
				}
			}
			
			return container;
		}
		
		private function generateLibraryConfigByProjectType(pvo:AS3ProjectVO, data:XML, sdkPath:String, targetPlayer:uint):void
		{
			if (pvo.isActionScriptOnly && pvo.air && pvo.isMobile)
			{
				data.compiler.appendChild(
					<mobile>true</mobile>
				);
				data.compiler.appendChild(
					<preloader>spark.preloaders.SplashScreen</preloader>
				);
				data.compiler.appendChild(
					<accessible>false</accessible>
				);
				data.compiler.appendChild(
					<theme><filename>{sdkPath}/frameworks/themes/Mobile/mobile.swc</filename></theme>
					);
				var externalLibraryPaths:Array = [
					"/frameworks/libs/air/airglobal.swc",
					"/frameworks/libs/core.swc",
					"/frameworks/libs/osmf.swc",
					"/frameworks/libs/textLayout.swc",
					"frameworks/libs/authoringsupport.swc",
					"/frameworks/libs/air/servicemonitor.swc",
				];
				var externalLibraryPath:XML = <external-library-path/>;
				for each(var currentPath:String in externalLibraryPaths)
				{
					var file:FileLocation = new FileLocation(sdkPath + currentPath);
					if (file.fileBridge.exists)
					{
						externalLibraryPath.appendChild(<path-element>{sdkPath}{currentPath}</path-element>);
					}
				}
				data.compiler.appendChild(
					externalLibraryPath
				);
				data.compiler.appendChild(
					<library-path><path-element>{sdkPath}/frameworks/locale/&#123;locale&#125;</path-element></library-path>
					);
			}
			else if (pvo.air && pvo.isMobile)
			{
				data.compiler.appendChild(
					<mobile>true</mobile>
				);
				data.compiler.appendChild(
					<preloader>spark.preloaders.SplashScreen</preloader>
				);
				data.compiler.appendChild(
					<accessible>false</accessible>
				);
				data.compiler.appendChild(
					<namespaces><namespace><uri>http://ns.adobe.com/mxml/2009</uri><manifest>{sdkPath}/frameworks/mxml-2009-manifest.xml</manifest></namespace><namespace><uri>library://ns.adobe.com/flex/spark</uri><manifest>{sdkPath}/frameworks/spark-manifest.xml</manifest></namespace></namespaces>
				);
				data.compiler.appendChild(
					<theme><filename>{sdkPath}/frameworks/themes/Mobile/mobile.swc</filename></theme>
					);
				externalLibraryPaths = [
					"/frameworks/libs/air/airglobal.swc",
					"/frameworks/libs/rpc.swc",
					"/frameworks/libs/osmf.swc",
					"/frameworks/libs/spark.swc",
					"/frameworks/libs/apache.swc",
					"/frameworks/libs/charts.swc",
					"/frameworks/libs/flatspark.swc",
					"/frameworks/libs/framework.swc",
					"/frameworks/libs/textLayout.swc",
					"/frameworks/libs/experimental.swc",
					"/frameworks/libs/authoringsupport.swc",
					"/frameworks/libs/flash-integration.swc",
					"/frameworks/libs/experimental_mobile.swc",
					"/frameworks/libs/air/servicemonitor.swc",
					"/frameworks/libs/mobile/mobilecomponents.swc",
				];
				externalLibraryPath = <external-library-path/>;
				for each(currentPath in externalLibraryPaths)
				{
					file = new FileLocation(sdkPath + currentPath);
					if (file.fileBridge.exists)
					{
						externalLibraryPath.appendChild(<path-element>{sdkPath}{currentPath}</path-element>);
					}
				}
				data.compiler.appendChild(
					externalLibraryPath
				);
				data.compiler.appendChild(
					<library-path><path-element>{sdkPath}/frameworks/locale/&#123;locale&#125;</path-element><path-element>{sdkPath}/frameworks/themes/Mobile/mobile.swc</path-element></library-path>
					);
			}
			else if (pvo.isActionScriptOnly && pvo.air && !pvo.isMobile)
			{
				data.compiler.appendChild(
					<accessible>true</accessible>
				);
				externalLibraryPaths = [
					"/frameworks/libs/air/airglobal.swc",
					"/frameworks/libs/core.swc",
					"/frameworks/libs/osmf.swc",
					"/frameworks/libs/textLayout.swc",
					"/frameworks/libs/authoringsupport.swc",
					"/frameworks/libs/air/aircore.swc",
					"/frameworks/libs/air/gamepad.swc",
					"/frameworks/libs/air/crosspromotion.swc",
					"/frameworks/libs/air/servicemonitor.swc",
					"/frameworks/libs/air/applicationupdater.swc",
					"/frameworks/libs/air/applicationupdater_ui.swc",
				];
				externalLibraryPath = <external-library-path/>;
				for each(currentPath in externalLibraryPaths)
				{
					file = new FileLocation(sdkPath + currentPath);
					if (file.fileBridge.exists)
					{
						externalLibraryPath.appendChild(<path-element>{sdkPath}{currentPath}</path-element>);
					}
				}
				data.compiler.appendChild(
					externalLibraryPath
				);
				data.compiler.appendChild(
					<library-path><path-element>{sdkPath}/frameworks/locale/&#123;locale&#125;</path-element></library-path>
					);
			}
			else if (pvo.air && !pvo.isMobile)
			{
				data.compiler.appendChild(
					<accessible>true</accessible>
				);
				data.compiler.appendChild(
					<namespaces><namespace><uri>http://ns.adobe.com/mxml/2009</uri><manifest>{sdkPath}/frameworks/mxml-2009-manifest.xml</manifest></namespace><namespace><uri>library://ns.adobe.com/flex/spark</uri><manifest>{sdkPath}/frameworks/spark-manifest.xml</manifest></namespace><namespace><uri>library://ns.adobe.com/flex/mx</uri><manifest>{sdkPath}/frameworks/mx-manifest.xml</manifest></namespace><namespace><uri>http://www.adobe.com/2006/mxml</uri><manifest>{sdkPath}/frameworks/mxml-manifest.xml</manifest></namespace></namespaces>
				);
				externalLibraryPaths = [
					"/frameworks/libs/air/airglobal.swc",
					"/frameworks/libs/rpc.swc",
					"/frameworks/libs/osmf.swc",
					"/frameworks/libs/spark.swc",
					"/frameworks/libs/apache.swc",
					"/frameworks/libs/charts.swc",
					"/frameworks/libs/flatspark.swc",
					"/frameworks/libs/framework.swc",
					"/frameworks/libs/spark_dmv.swc",
					"/frameworks/libs/sparkskins.swc",
					"/frameworks/libs/textLayout.swc",
					"/frameworks/libs/experimental.swc",
					"/frameworks/libs/advancedgrids.swc",
					"/frameworks/libs/authoringsupport.swc",
					"/frameworks/libs/flash-integration.swc",
					"/frameworks/libs/mx/mx.swc",
					"/frameworks/libs/air/aircore.swc",
					"/frameworks/libs/air/gamepad.swc",
					"/frameworks/libs/air/airspark.swc",
					"/frameworks/libs/air/airframework.swc",
					"/frameworks/libs/air/crosspromotion.swc",
					"/frameworks/libs/air/servicemonitor.swc",
					"/frameworks/libs/air/applicationupdater.swc",
					"/frameworks/libs/air/applicationupdater_ui.swc"
				];
				externalLibraryPath = <external-library-path/>;
				for each(currentPath in externalLibraryPaths)
				{
					file = new FileLocation(sdkPath + currentPath);
					if (file.fileBridge.exists)
					{
						externalLibraryPath.appendChild(<path-element>{sdkPath}{currentPath}</path-element>);
					}
				}
				data.compiler.appendChild(
					externalLibraryPath
				);
				data.compiler.appendChild(
					<library-path><path-element>{sdkPath}/frameworks/locale/&#123;locale&#125;</path-element></library-path>
					);
			}
			else if (pvo.isActionScriptOnly && !pvo.air)
			{
				data.compiler.appendChild(
					<accessible>true</accessible>
				);
				externalLibraryPaths = [
					"/frameworks/libs/player/" + targetPlayer + ".0/playerglobal.swc",
					"/frameworks/libs/core.swc",
					"/frameworks/libs/osmf.swc",
					"/frameworks/libs/textLayout.swc",
					"/frameworks/libs/authoringsupport.swc",
				];
				externalLibraryPath = <external-library-path/>;
				for each(currentPath in externalLibraryPaths)
				{
					file = new FileLocation(sdkPath + currentPath);
					if (file.fileBridge.exists)
					{
						externalLibraryPath.appendChild(<path-element>{sdkPath}{currentPath}</path-element>);
					}
				}
				data.compiler.appendChild(
					externalLibraryPath
				);
				data.compiler.appendChild(
					<library-path><path-element>{sdkPath}/frameworks/locale/&#123;locale&#125;</path-element></library-path>
					);
			}
			else if (!pvo.air)
			{
				data.compiler.appendChild(
					<accessible>true</accessible>
				);
				data.compiler.appendChild(
					<namespaces><namespace><uri>http://ns.adobe.com/mxml/2009</uri><manifest>{sdkPath}/frameworks/mxml-2009-manifest.xml</manifest></namespace><namespace><uri>library://ns.adobe.com/flex/spark</uri><manifest>{sdkPath}/frameworks/spark-manifest.xml</manifest></namespace><namespace><uri>library://ns.adobe.com/flex/mx</uri><manifest>{sdkPath}/frameworks/mx-manifest.xml</manifest></namespace><namespace><uri>http://www.adobe.com/2006/mxml</uri><manifest>{sdkPath}/frameworks/mxml-manifest.xml</manifest></namespace></namespaces>
					);
				data.compiler.appendChild(
					<theme><filename>{sdkPath}/frameworks/themes/Spark/spark.css</filename></theme>
					);
				externalLibraryPaths = [
					"/frameworks/libs/player/" + targetPlayer + ".0/playerglobal.swc",
					"/frameworks/libs/rpc.swc",
					"/frameworks/libs/osmf.swc",
					"/frameworks/libs/spark.swc",
					"/frameworks/libs/apache.swc",
					"/frameworks/libs/charts.swc",
					"/frameworks/libs/flatspark.swc",
					"/frameworks/libs/framework.swc",
					"/frameworks/libs/spark_dmv.swc",
					"/frameworks/libs/sparkskins.swc",
					"/frameworks/libs/textLayout.swc",
					"/frameworks/libs/experimental.swc",
					"/frameworks/libs/advancedgrids.swc",
					"/frameworks/libs/authoringsupport.swc",
					"/frameworks/libs/flash-integration.swc",
					"/frameworks/libs/mx/mx.swc",
				];
				externalLibraryPath = <external-library-path/>;
				for each(currentPath in externalLibraryPaths)
				{
					file = new FileLocation(sdkPath + currentPath);
					if (file.fileBridge.exists)
					{
						externalLibraryPath.appendChild(<path-element>{sdkPath}{currentPath}</path-element>);
					}
				}
				data.compiler.appendChild(
					externalLibraryPath
				);
				data.compiler.appendChild(
					<library-path><path-element>{sdkPath}/frameworks/locale/&#123;locale&#125;</path-element></library-path>
					);
			}
		}
		
		private function getSWFOutputPath(pvo:AS3ProjectVO, release:Boolean=false, modulePath:FileLocation=null):String
		{
			var tmpPath:FileLocation = modulePath ? 
				pvo.swfOutput.path.fileBridge.parent.resolvePath(modulePath.fileBridge.nameWithoutExtension +".swf") : 
				pvo.swfOutput.path;
			
			if (release)
			{
				return (pvo.folderLocation.resolvePath("bin-release/"+ tmpPath.fileBridge.name).fileBridge.nativePath);
			}
			
			return tmpPath.fileBridge.nativePath;
		}
	}
}