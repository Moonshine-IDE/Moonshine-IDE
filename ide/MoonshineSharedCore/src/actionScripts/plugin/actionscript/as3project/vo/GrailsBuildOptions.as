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

    public class GrailsBuildOptions extends JavaProjectBuildOptions
    {
        public function GrailsBuildOptions(defaultGrailsBuildPath:String)
        {
			super(defaultGrailsBuildPath);
        }

        override public function get buildActions():Array
        {
            if (!_buildActions)
            {
                _buildActions = [
                    new BuildActionVO("Clean", "clean"),
                    new BuildActionVO("Compile Project", "compile"),
                    new BuildActionVO("Compile and Run Project", "run-app"),
                    new BuildActionVO("Test Project", "test-app"),
					new BuildActionVO("Release Project", "war"),
					new BuildActionVO("Create a Service", "create-service <name>"),
					new BuildActionVO("Create a Domain", "create-domain <name>"),
					new BuildActionVO("Create a Controller", "create-controller <name>")
                ];
            }

            return _buildActions;
        }

        override public function toXML():XML
        {
            var build:XML = <grailsBuild/>;

            var pairs:Object = {
                commandLine: SerializeUtil.serializeString(commandLine)
            }

            build.appendChild(SerializeUtil.serializePairs(pairs, <option/>));

            return build;
        }

        override protected function parseOptions(options:XMLList):void
        {
            buildPath = SerializeUtil.deserializeString(options.@grailsBuild);
            commandLine = SerializeUtil.deserializeString(options.@commandLine);
            settingsFilePath = SerializeUtil.deserializeString(options.@settingsFilePath);
        }
    }
}
