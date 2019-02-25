package actionScripts.plugin.actionscript.as3project.vo
{
    import actionScripts.plugin.build.vo.BuildActionVO;
    import actionScripts.utils.SerializeUtil;

    import mx.utils.StringUtil;

    public class MavenBuildOptions
    {
        private var _defaultMavenBuildPath:String;
        private var _buildActions:Array;

        public function MavenBuildOptions(defaultMavenBuildPath:String)
        {
            _defaultMavenBuildPath = defaultMavenBuildPath;
            _buildActions = [
                new BuildActionVO("Build", "install"),
                new BuildActionVO("Clean", "clean"),
                new BuildActionVO("Clean and Build", "clean install"),
                new BuildActionVO("Exploded", "war:exploded")
            ];
        }

        public var commandLine:String;
        public var settingsFilePath:String;

        private var _mavenBuildPath:String;
        public function get mavenBuildPath():String
        {
            return !_mavenBuildPath ? _defaultMavenBuildPath : _mavenBuildPath;
        }

        public function set mavenBuildPath(value:String):void
        {
            _mavenBuildPath = value;
        }

        public function get buildActions():Array
        {
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
            var build:XML = <mavenBuild/>;

            var pairs:Object = {
                mavenBuildPath: SerializeUtil.serializeString(mavenBuildPath),
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

        private function parseOptions(options:XMLList):void
        {
            mavenBuildPath = SerializeUtil.deserializeString(options.@mavenBuildPath);
            commandLine = SerializeUtil.deserializeString(options.@commandLine);
            settingsFilePath = SerializeUtil.deserializeString(options.@settingsFilePath);
        }

        private function parseActions(actions:XMLList):void
        {
            if (actions.length() > 0)
            {
                _buildActions.splice(0, _buildActions.length);
                for (var i:int = 0; i < actions.length(); i++)
                {
                    if (actions[i])
                    {
                        _buildActions.push(new BuildActionVO(actions[i].@actionName, actions[i].@action));
                    }
                }
            }
        }
    }
}
