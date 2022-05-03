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
package actionScripts.plugin.genericproj.exporter
{
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.core.exporter.FlashDevelopExporterBase;
	import actionScripts.plugin.genericproj.vo.GenericProjectVO;
	import actionScripts.plugin.ondiskproj.vo.OnDiskProjectVO;
    import actionScripts.utils.SerializeUtil;

    public class GenericProjectExporter extends FlashDevelopExporterBase
    {
		private static const FILE_EXTENSION_GENERICPROJ:String = ".genericproj";

        public static function export(project:GenericProjectVO):void
        {
            var projectSettings:FileLocation = project.folderLocation.resolvePath(project.projectName + FILE_EXTENSION_GENERICPROJ);
            if (!projectSettings.fileBridge.exists)
            {
                projectSettings.fileBridge.createFile();
            }

			var projectXML:XML = toXML(project);
            projectSettings.fileBridge.save(projectXML.toXMLString());
		}

		private static function toXML(project:GenericProjectVO):XML
		{
			var projectXML:XML = <project/>;
			var tmpXML:XML;
			var isGradle:Boolean = project.hasGradleBuild();

			if (project.hasGradleBuild())
			{
				projectXML.appendChild(
						project.gradleBuildOptions.toXML()
				);
			}

			if (project.hasPom())
			{
				projectXML.appendChild(
						project.mavenBuildOptions.toXML()
				);
			}

			projectXML.appendChild(exportPaths(new <FileLocation>[project.folderLocation], <classpaths />, <class />, project));

			return projectXML;
		}
	}
}