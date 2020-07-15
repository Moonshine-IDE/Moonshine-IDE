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
		private var _dominoNotesProgram:String;
		public function get dominoNotesProgram():String
		{
			return _dominoNotesProgram;
		}
		public function set dominoNotesProgram(value:String):void
		{
			_dominoNotesProgram = value;
		}

		private var _dominoNotesPlatform:String;
		public function get dominoNotesPlatform():String
		{
			return _dominoNotesPlatform;
		}
		public function set dominoNotesPlatform(value:String):void
		{
			_dominoNotesPlatform = value;
		}
		
        public function MavenBuildOptions(defaultMavenBuildPath:String)
        {
            super(defaultMavenBuildPath);
            //this only for test 
            //this.dominoNotesProgram="/Users/prominic2";
            //this.dominoNotesPlatform="/Users/prominic2";
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
                settingsFilePath: SerializeUtil.serializeString(settingsFilePath),

                dominoNotesProgram: SerializeUtil.serializeString(dominoNotesProgram),
                dominoNotesPlatform: SerializeUtil.serializeString(dominoNotesPlatform)
				dominoNotesProgram: SerializeUtil.serializeString(dominoNotesProgram),
				dominoNotesPlatform: SerializeUtil.serializeString(dominoNotesPlatform)
            }

            build.appendChild(SerializeUtil.serializePairs(pairs, <option/>));
			build.appendChild(getActionsXML());

            return build;
        }

        override protected function parseOptions(options:XMLList):void
        {
            buildPath = SerializeUtil.deserializeString(options.@mavenBuildPath);
            commandLine = SerializeUtil.deserializeString(options.@commandLine);
            settingsFilePath = SerializeUtil.deserializeString(options.@settingsFilePath);
			dominoNotesProgram = SerializeUtil.deserializeString(options.@dominoNotesProgram);
			dominoNotesPlatform = SerializeUtil.deserializeString(options.@dominoNotesPlatform);
        }
        public var dominoNotesProgram:String;
        public var dominoNotesPlatform:String;
    }
}
