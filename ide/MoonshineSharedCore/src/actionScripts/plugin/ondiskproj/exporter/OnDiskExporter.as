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
package actionScripts.plugin.ondiskproj.exporter
{
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.core.exporter.FlashDevelopExporterBase;
    import actionScripts.plugin.ondiskproj.vo.OnDiskProjectVO;
    import actionScripts.utils.SerializeUtil;
    import actionScripts.utils.UtilsCore;

    public class OnDiskExporter extends FlashDevelopExporterBase
    {
		private static const FILE_EXTENSION_ONDISKPROJ:String = ".ondiskproj";

        public static function export(project:OnDiskProjectVO):void
        {
            var projectSettings:FileLocation = project.folderLocation.resolvePath(project.projectName + FILE_EXTENSION_ONDISKPROJ);
            if (!projectSettings.fileBridge.exists)
            {
                projectSettings.fileBridge.createFile();
            }

			var projectXML:XML = toXML(project);
            projectSettings.fileBridge.save(projectXML.toXMLString());
		}

		private static function toXML(project:OnDiskProjectVO):XML
		{
			var projectXML:XML = <project/>;
			var tmpXML:XML;
			
			projectXML.appendChild(exportPaths(project.classpaths, <classpaths />, <class />, project));
			
			projectXML.appendChild(project.buildOptions.toXML());
			projectXML.appendChild(project.mavenBuildOptions.toXML());
		
			projectXML.appendChild(exportPaths(project.hiddenPaths, <hiddenPaths />, <hidden />, project));
			
			tmpXML = <preBuildCommand />;
			tmpXML.appendChild(project.prebuildCommands);
			projectXML.appendChild(tmpXML);
			
			tmpXML = <postBuildCommand />;
			tmpXML.appendChild(project.postbuildCommands);
			tmpXML.@alwaysRun = SerializeUtil.serializeBoolean(project.postbuildAlways);
			projectXML.appendChild(tmpXML);
			
			var options:XML = <options />;
			var optionPairs:Object = {
				showHiddenPaths		:	SerializeUtil.serializeBoolean(project.showHiddenPaths),
				jdkType				:	SerializeUtil.serializeString(project.jdkType)
			}
			options.appendChild(SerializeUtil.serializePairs(optionPairs, <option />));
			projectXML.appendChild(options);

			options = <domino />;
			var dominoPairs:Object = {
				dominoBaseAgentURL	:	SerializeUtil.serializeString(project.dominoBaseAgentURL),
				localDatabase		: 	UtilsCore.getRelativePathAgainstProject(project.folderLocation, project.localDatabase),
				targetServer		:	SerializeUtil.serializeString(project.targetServer),
				targetDatabase		:	SerializeUtil.serializeString(project.targetDatabase)
			}
			options.appendChild(SerializeUtil.serializePairs(dominoPairs, <option />));
			projectXML.appendChild(options);

			options = <moonshineRunCustomization />;
			options.appendChild(SerializeUtil.serializePairs(optionPairs, <option />));
			projectXML.appendChild(options);
            
            //TODO: store this on HaxeProjectVO
            projectXML.appendChild(<storage/>);

			return projectXML;
		}
	}
}