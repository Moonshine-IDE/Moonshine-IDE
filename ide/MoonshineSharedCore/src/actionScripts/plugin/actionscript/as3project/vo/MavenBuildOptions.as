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
    import actionScripts.plugin.build.vo.BuildActionVO;
import actionScripts.plugin.ondiskproj.exporter.OnDiskMavenSettingsExporter;
import actionScripts.utils.SerializeUtil;
import actionScripts.utils.UtilsCore;

    public class MavenBuildOptions extends JavaProjectBuildOptions
    {
        public static const CONFIG_NSFODP_SETTINGS_SPECIFIER:String = "%NSFODP_SETTINGS_FILE%";

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
                mavenBuildPath: UtilsCore.getRelativePathAgainstProject(
                        _defaultBuildPath,
                        buildPath
                ),
                commandLine: SerializeUtil.serializeString(commandLine),
                dominoNotesProgram: SerializeUtil.serializeString(dominoNotesProgram),
                dominoNotesPlatform: SerializeUtil.serializeString(dominoNotesPlatform)
            }

            var moonshineMavenSettingsPath:String = OnDiskMavenSettingsExporter.mavenSettingsPath ? OnDiskMavenSettingsExporter.mavenSettingsPath.fileBridge.nativePath : null;
            if (moonshineMavenSettingsPath == settingsFilePath)
            {
                pairs.settingsFilePath = CONFIG_NSFODP_SETTINGS_SPECIFIER;
            }
            else
            {
                pairs.settingsFilePath = UtilsCore.getRelativePathAgainstProject(
                    _defaultBuildPath,
                    settingsFilePath
                );
            }

            build.appendChild(SerializeUtil.serializePairs(pairs, <option/>));
			build.appendChild(getActionsXML());

            return build;
        }

        override protected function parseOptions(options:XMLList):void
        {
            buildPath = UtilsCore.getAbsolutePathAgainstProject(
                    _defaultBuildPath,
                    options.@mavenBuildPath
            );
            commandLine = SerializeUtil.deserializeString(options.@commandLine);
            if (options.@settingsFilePath == CONFIG_NSFODP_SETTINGS_SPECIFIER && OnDiskMavenSettingsExporter.mavenSettingsPath)
            {
                settingsFilePath = OnDiskMavenSettingsExporter.mavenSettingsPath.fileBridge.nativePath;
            }
            else
            {
                settingsFilePath = UtilsCore.getAbsolutePathAgainstProject(
                        _defaultBuildPath,
                        options.@settingsFilePath
                );
            }

            dominoNotesProgram = SerializeUtil.deserializeString(options.@dominoNotesProgram);
            dominoNotesPlatform = SerializeUtil.deserializeString(options.@dominoNotesPlatform);
                        
        }
        // public var dominoNotesProgram:String;
        // public var dominoNotesPlatform:String;
    }
}
