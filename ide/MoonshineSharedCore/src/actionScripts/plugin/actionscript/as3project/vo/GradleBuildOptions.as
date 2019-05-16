package actionScripts.plugin.actionscript.as3project.vo
{
    import actionScripts.plugin.build.vo.BuildActionVO;
    import actionScripts.utils.SerializeUtil;

    import mx.utils.StringUtil;

    public class GradleBuildOptions
    {
        private var _defaultGradleBuildPath:String;
        private var _buildActions:Array;

        public function GradleBuildOptions(defaultGradleBuildPath:String)
        {
            _defaultGradleBuildPath = defaultGradleBuildPath;
        }

        public var commandLine:String;
        public var settingsFilePath:String;

        private var _gradleBuildPath:String;
        public function get gradleBuildPath():String
        {
            return !_gradleBuildPath ? _defaultGradleBuildPath : _gradleBuildPath;
        }

        public function set gradleBuildPath(value:String):void
        {
            _gradleBuildPath = value;
        }

        public function get buildActions():Array
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
            var build:XML = <gradleBuild/>;

            var pairs:Object = {
                commandLine: SerializeUtil.serializeString(commandLine)
            }

            build.appendChild(SerializeUtil.serializePairs(pairs, <option/>));

            return build;
        }

        private function parseOptions(options:XMLList):void
        {
            gradleBuildPath = SerializeUtil.deserializeString(options.@gradleBuildPath);
            commandLine = SerializeUtil.deserializeString(options.@commandLine);
            settingsFilePath = SerializeUtil.deserializeString(options.@settingsFilePath);
        }

        private function parseActions(actions:XMLList):void
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
