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
package actionScripts.plugin.java.javaproject.exporter
{
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.build.vo.BuildActionVO;
    import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
    import actionScripts.utils.MavenPomUtil;
    import actionScripts.utils.SerializeUtil;

    public class JavaExporter
    {
        public static function export(project:JavaProjectVO, existingSource:Boolean = false):void
        {
            XML.ignoreWhitespace = true;
            XML.ignoreComments = false;

			var isGradle:Boolean = project.hasGradleBuild();
            var projectXML:XML = new XML("<project></project>");

            projectXML.appendChild(
				isGradle ? project.gradleBuildOptions.toXML() : project.mavenBuildOptions.toXML()
			);
			
			var classPathsXML:XML = new XML(<classpaths></classpaths>);
			for each (var path:FileLocation in project.classpaths)
			{
				classPathsXML.appendChild(SerializeUtil.serializePairs(
					{path: project.folderLocation.fileBridge.getRelativePath(path, true)},
					<class />));
			}
			
			projectXML.appendChild(classPathsXML);

            var buildXML:XML = new XML(<build></build>);
            var build:Object = {
                mainclass: project.mainClassName,
                mainClassPath: project.mainClassPath
            };
            buildXML.appendChild(SerializeUtil.serializePairs(build, <option/>));
            projectXML.appendChild(buildXML);
			
			var options:XML = <options />;
			var optionPairs:Object = {
				jdkType		:	SerializeUtil.serializeString(project.jdkType),
				projectType	:	SerializeUtil.serializeString(project.projectType)
			}
			options.appendChild(SerializeUtil.serializePairs(optionPairs, <option />));
			projectXML.appendChild(options);

            var projectSettings:FileLocation = project.folderLocation.resolvePath(project.projectName + ".javaproj");
            if (!projectSettings.fileBridge.exists)
            {
                projectSettings.fileBridge.createFile();
            }

            projectSettings.fileBridge.save(projectXML.toXMLString());

            if (!project.hasPom() || existingSource) return;

            var separator:String = project.projectFolder.file.fileBridge.separator;
            var pomFile:FileLocation = new FileLocation(project.mavenBuildOptions.buildPath.concat(separator,"pom.xml"));
            var fileContent:Object = pomFile.fileBridge.read();
            var pomXML:XML = new XML(fileContent);

            var sourceFolder:String = project.projectFolder.file.fileBridge.getRelativePath(project.sourceFolder);
            pomXML = MavenPomUtil.getPomWithProjectSourceDirectory(pomXML, sourceFolder);
            pomXML = MavenPomUtil.getPomWithMainClass(pomXML, project.mainClassName);

            pomFile.fileBridge.save(pomXML.toXMLString());
        }
    }
}
