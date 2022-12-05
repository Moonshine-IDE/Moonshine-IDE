////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
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
