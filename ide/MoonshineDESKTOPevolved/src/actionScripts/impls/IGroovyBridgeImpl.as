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
package actionScripts.impls
{
    import actionScripts.events.NewProjectEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.interfaces.IGroovyBridge;
    import actionScripts.plugin.groovy.grailsproject.CreateGrailsProject;
    import actionScripts.plugin.groovy.grailsproject.GrailsProjectPlugin;
    import actionScripts.plugin.groovy.grailsproject.importer.GrailsImporter;
    import actionScripts.plugin.groovy.grailsproject.vo.GrailsProjectVO;
    import actionScripts.plugin.syntax.GroovySyntaxPlugin;
    import actionScripts.plugins.core.ProjectBridgeImplBase;

    import flash.filesystem.File;
    import actionScripts.plugins.grails.GrailsBuildPlugin;

    public class IGroovyBridgeImpl extends ProjectBridgeImplBase implements IGroovyBridge
    {
        public function IGroovyBridgeImpl()
        {
            super();
        }

        public function getCorePlugins():Array
        {
            return [
            ];
        }

        public function getDefaultPlugins():Array
        {
            return [
				GroovySyntaxPlugin,
                GrailsProjectPlugin,
                GrailsBuildPlugin,
            ];
        }

        public function getPluginsNotToShowInSettings():Array
        {
            return [
                GrailsProjectPlugin,
            ];
        }

        public function get runtimeVersion():String
        {
            return "";
        }

        public function get version():String
        {
            return "";
        }
		
        protected var executeCreateGroovyProject:CreateGrailsProject;

		override public function createProject(event:NewProjectEvent):void
        {
			executeCreateGroovyProject = new CreateGrailsProject(event);
		}
		
		public function testGrails(file:Object):FileLocation
		{
			return GrailsImporter.test(file as File);
		}

		public function parseGrails(file:FileLocation, projectName:String=null, settingsFileLocation:FileLocation = null):GrailsProjectVO
		{
			return GrailsImporter.parse(file, projectName, settingsFileLocation);
		}
    }
}
