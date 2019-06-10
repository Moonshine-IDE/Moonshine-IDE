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

    public class GradleBuildOptions extends JavaProjectBuildOptions
    {
        public function GradleBuildOptions(defaultGradleBuildPath:String)
        {
			super(defaultGradleBuildPath);
        }

        override public function get buildActions():Array
        {
            if (!_buildActions)
            {
                _buildActions = [
                    new BuildActionVO("Clean", "clean"),
                    new BuildActionVO("Publish to Maven Local", "publishToMavenLocal"),
                    new BuildActionVO("Clean and Run", "clean run"),
                    new BuildActionVO("Clean and Build", "clean build")
                ];
            }

            return _buildActions;
        }

        override public function toXML():XML
        {
            var build:XML = <gradleBuild/>;

            var pairs:Object = {
                commandLine: SerializeUtil.serializeString(commandLine)
            }

            build.appendChild(SerializeUtil.serializePairs(pairs, <option/>));
			build.appendChild(getActionsXML());

            return build;
        }

        override protected function parseOptions(options:XMLList):void
        {
            buildPath = SerializeUtil.deserializeString(options.@gradleBuildPath);
            commandLine = SerializeUtil.deserializeString(options.@commandLine);
            settingsFilePath = SerializeUtil.deserializeString(options.@settingsFilePath);
        }
    }
}
