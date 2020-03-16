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
package actionScripts.plugin.ondiskproj.exporter
{
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.core.exporter.FlashDevelopExporterBase;
    import actionScripts.plugin.ondiskproj.vo.OnDiskProjectVO;
    import actionScripts.utils.SerializeUtil;

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
				showHiddenPaths		:	SerializeUtil.serializeBoolean(project.showHiddenPaths)
			}
			options.appendChild(SerializeUtil.serializePairs(optionPairs, <option />));
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