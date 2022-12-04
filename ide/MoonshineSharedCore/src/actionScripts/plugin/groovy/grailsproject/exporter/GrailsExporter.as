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
package actionScripts.plugin.groovy.grailsproject.exporter
{
    import actionScripts.plugin.groovy.grailsproject.vo.GrailsProjectVO;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.core.exporter.FlashDevelopExporterBase;
    import actionScripts.utils.SerializeUtil;

    public class GrailsExporter extends FlashDevelopExporterBase
    {
		private static const FILE_EXTENSION_GRAILSPROJ:String = ".grailsproj";

        public static function export(project:GrailsProjectVO):void
        {
            var projectSettings:FileLocation = project.folderLocation.resolvePath(project.projectName + FILE_EXTENSION_GRAILSPROJ);
            if (!projectSettings.fileBridge.exists)
            {
                projectSettings.fileBridge.createFile();
            }

			var projectXML:XML = toXML(project);
            projectSettings.fileBridge.save(projectXML.toXMLString());
		}

		private static function toXML(project:GrailsProjectVO):XML
		{
			var projectXML:XML = <project/>;
			
			projectXML.appendChild(
				project.grailsBuildOptions.toXML()
			);
			projectXML.appendChild(
				project.gradleBuildOptions.toXML()
			);

            var separator:String = project.folderLocation.fileBridge.separator;
            var defaultClassPaths:Vector.<FileLocation> = new Vector.<FileLocation>();
            defaultClassPaths.push(project.folderLocation.resolvePath("src" + separator + "main" + separator + "groovy"));
            defaultClassPaths.push(project.folderLocation.resolvePath("src" + separator + "main" + separator + "java"));
            defaultClassPaths.push(project.folderLocation.resolvePath("grails-app" + separator + "controllers"));
            defaultClassPaths.push(project.folderLocation.resolvePath("grails-app" + separator + "services"));
            defaultClassPaths.push(project.folderLocation.resolvePath("scripts"));
            defaultClassPaths.push(project.folderLocation.resolvePath("src" + separator + "test" + separator + "groovy"));
            defaultClassPaths.push(project.folderLocation.resolvePath("src" + separator + "test" + separator + "java"));

            var path:FileLocation = null;
            for each (path in defaultClassPaths)
            {
                if (!project.classpaths.some(function(item:FileLocation, index:int, vector:Vector.<FileLocation>):Boolean{
                    return path.fileBridge.nativePath == item.fileBridge.nativePath;
                }))
                {
                    project.classpaths.push(path);
                }
            }

            var classPathsXML:XML = new XML(<classpaths></classpaths>);
            for each (path in project.classpaths)
            {
                classPathsXML.appendChild(SerializeUtil.serializePairs(
                        {path: project.folderLocation.fileBridge.getRelativePath(path, true)},
                        <class />));
            }
            projectXML.appendChild(classPathsXML);

			var options:XML = <options />;
			var optionPairs:Object = {
				jdkType		:	SerializeUtil.serializeString(project.jdkType)
			}
			options.appendChild(SerializeUtil.serializePairs(optionPairs, <option />));
			projectXML.appendChild(options);

			return projectXML;
		}
	}
}