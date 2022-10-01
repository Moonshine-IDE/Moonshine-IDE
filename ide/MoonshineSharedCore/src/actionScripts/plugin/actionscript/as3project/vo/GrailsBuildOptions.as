////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
			build.appendChild(getActionsXML());
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
