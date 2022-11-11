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
package actionScripts.plugin.haxe.hxproject.exporter
{
    import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.core.exporter.FlashDevelopExporterBase;
    import actionScripts.utils.SerializeUtil;

    public class HaxeExporter extends FlashDevelopExporterBase
    {
		private static const FILE_EXTENSION_HXPROJ:String = ".hxproj";

        public static function export(project:HaxeProjectVO):void
        {
            var projectSettings:FileLocation = project.folderLocation.resolvePath(project.projectName + FILE_EXTENSION_HXPROJ);
            if (!projectSettings.fileBridge.exists)
            {
                projectSettings.fileBridge.createFile();
            }

			var projectXML:XML = toXML(project);
            projectSettings.fileBridge.save(projectXML.toXMLString());
		}

		private static function toXML(project:HaxeProjectVO):XML
		{
			var projectXML:XML = <project/>;
			var tmpXML:XML;
			
			// Get output node with relative paths
			var outputXML: XML = project.haxeOutput.toXML(project.folderLocation);
			projectXML.appendChild(outputXML);

			projectXML.appendChild(exportPaths(project.classpaths, <classpaths />, <class />, project));
			
			projectXML.appendChild(project.buildOptions.toXML());
		
            tmpXML = <haxelib/>;
            for each(var haxelib:String in project.haxelibs)
            {
                tmpXML.appendChild(<library name={haxelib}/>);
            }
			projectXML.appendChild(tmpXML);
			
			projectXML.appendChild(exportPaths(project.targets, <compileTargets />, <compile />, project));
			projectXML.appendChild(exportPaths(project.hiddenPaths, <hiddenPaths />, <hidden />, project));
			
			tmpXML = <preBuildCommand />;
			if (project.prebuildCommands != null)
			{
				tmpXML.appendChild(project.prebuildCommands);
			}
			projectXML.appendChild(tmpXML);
			
			tmpXML = <postBuildCommand />;
			if (project.postbuildCommands != null)
			{
				tmpXML.appendChild(project.postbuildCommands);
			}
			tmpXML.@alwaysRun = SerializeUtil.serializeBoolean(project.postbuildAlways);
			projectXML.appendChild(tmpXML);
			
			var options:XML = <options />;
			var optionPairs:Object = {
				showHiddenPaths		:	SerializeUtil.serializeBoolean(project.showHiddenPaths),
				testMovie			:	SerializeUtil.serializeString(project.testMovie),
				testMovieCommand	:	SerializeUtil.serializeString(project.testMovieCommand)
			}
			if (project.testMovieCommand && project.testMovieCommand != "") 
			{
				optionPairs.testMovieCommand = project.testMovieCommand;
			}
			options.appendChild(SerializeUtil.serializePairs(optionPairs, <option />));
			projectXML.appendChild(options);

			options = <moonshineRunCustomization />;
			if(project.isLime)
			{
				optionPairs = {
					targetPlatform:	project.limeTargetPlatform || HaxeProjectVO.LIME_PLATFORM_HTML5,
					webBrowser:   project.runWebBrowser || ""
				};
			}
			else
			{
				optionPairs = {};
			}
			options.appendChild(SerializeUtil.serializePairs(optionPairs, <option />));
			projectXML.appendChild(options);
            
            //TODO: store this on HaxeProjectVO
            projectXML.appendChild(<storage/>);

			return projectXML;
		}
	}
}