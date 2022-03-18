////////////////////////////////////////////////////////////////////////////////
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
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
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
