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
package actionScripts.plugin.actionscript.as3project.vo
{
    import actionScripts.plugin.build.vo.BuildActionVO;
    import actionScripts.utils.SerializeUtil;

    public class MavenBuildOptions extends JavaProjectBuildOptions
    {
        public function MavenBuildOptions(defaultMavenBuildPath:String)
        {
            super(defaultMavenBuildPath);
        }

        override public function get buildActions():Array
        {
            if (!_buildActions)
            {
                _buildActions = [
                    new BuildActionVO("Build", "install"),
                    new BuildActionVO("Clean and package", "clean package"),
                    new BuildActionVO("Clean", "clean"),
                    new BuildActionVO("Clean and Build", "clean install"),
                    new BuildActionVO("Exploded", "war:exploded")
                ];
            }

            return _buildActions;
        }

        override public function toXML():XML
        {
            var build:XML = <mavenBuild/>;

            var pairs:Object = {
                mavenBuildPath: SerializeUtil.serializeString(buildPath),
                commandLine: SerializeUtil.serializeString(commandLine),
                settingsFilePath: SerializeUtil.serializeString(settingsFilePath)
            }

            build.appendChild(SerializeUtil.serializePairs(pairs, <option/>));

            var availableOptions:XML = <actions/>;
            for each (var item:BuildActionVO in this.buildActions)
            {
                availableOptions.appendChild(SerializeUtil.serializeObjectPairs(
                        {action: item.action, actionName: item.actionName},
                        <action />));
            }

            build.appendChild(availableOptions);

            return build;
        }

        override protected function parseOptions(options:XMLList):void
        {
            buildPath = SerializeUtil.deserializeString(options.@mavenBuildPath);
            commandLine = SerializeUtil.deserializeString(options.@commandLine);
            settingsFilePath = SerializeUtil.deserializeString(options.@settingsFilePath);
        }
    }
}
