////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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
