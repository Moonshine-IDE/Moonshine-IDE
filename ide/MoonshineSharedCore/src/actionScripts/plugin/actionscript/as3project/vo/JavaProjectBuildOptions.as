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
    import mx.utils.StringUtil;
    
    import actionScripts.plugin.build.vo.BuildActionVO;
    import actionScripts.utils.SerializeUtil;

    public class JavaProjectBuildOptions
    {
        protected var _defaultBuildPath:String;
        protected var _buildActions:Array;

        public function JavaProjectBuildOptions(defaultBuildPath:String)
        {
            _defaultBuildPath = defaultBuildPath;
        }

        public var commandLine:String;
        public var settingsFilePath:String;

        private var _buildPath:String;
        public function get buildPath():String
        {
            return !_buildPath ? _defaultBuildPath : _buildPath;
        }

        public function set buildPath(value:String):void
        {
            _buildPath = value;
        }

        public function get buildActions():Array
        {
            return _buildActions;
        }

		public function get selectedCommand():BuildActionVO
		{
			for each (var item:BuildActionVO in this.buildActions)
			{
				if (item.action == commandLine)
				{
					return item;
				}
			}
			
			return null;
		}
		
        public function getCommandLine():Array
        {
            var commandLineOptions:Array = [];

            if (settingsFilePath)
            {
                commandLineOptions.push("-settings ".concat("\"", settingsFilePath, "\""));
            }

            if (commandLine)
            {
                if (commandLineOptions.length > 0)
                {
                    commandLineOptions = commandLineOptions.concat(commandLine.split(" "));
                }
                else
                {
                    commandLineOptions = commandLine.split(" ");
                }
                commandLineOptions = commandLineOptions.filter(function(item:String, index:int, arr:Array):Boolean{
                    item = StringUtil.trim(item);
                    if (item)
                    {
                        return true;
                    }

                    return false;
                });
            }

            return commandLineOptions;
        }
		

        public function parse(build:XMLList):void
        {
            parseOptions(build.option);
            parseActions(build.actions.action);
        }

        public function toXML():XML
        {
            return null;
        }
		
		protected function getActionsXML():XML
		{
			var availableOptions:XML = <actions/>;
			for each (var item:BuildActionVO in this.buildActions)
			{
				availableOptions.appendChild(SerializeUtil.serializeObjectPairs(
					{action: item.action, actionName: item.actionName},
					<action />));
			}
			
			return availableOptions;
		}

        protected function parseOptions(options:XMLList):void
        {
        }

        protected function parseActions(actions:XMLList):void
        {
            if (actions.length() > 0)
            {
                buildActions.splice(0, _buildActions.length);
                for (var i:int = 0; i < actions.length(); i++)
                {
                    if (actions[i])
                    {
                        buildActions.push(new BuildActionVO(actions[i].@actionName, actions[i].@action));
                    }
                }
            }
        }
    }
}
