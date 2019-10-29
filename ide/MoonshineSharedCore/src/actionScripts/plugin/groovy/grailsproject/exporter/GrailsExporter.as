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

			return projectXML;
		}
	}
}