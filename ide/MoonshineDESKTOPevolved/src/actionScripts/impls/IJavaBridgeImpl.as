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
    import actionScripts.interfaces.IJavaBridge;
    import actionScripts.plugin.java.javaproject.JavaProjectPlugin;
    import actionScripts.plugins.core.ProjectBridgeImplBase;
    import actionScripts.plugin.syntax.JavaSyntaxPlugin;
    import actionScripts.events.NewProjectEvent;
    import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
    import actionScripts.plugin.java.javaproject.CreateJavaProject;
    import actionScripts.factory.FileLocation;
    import flash.filesystem.File;
    import actionScripts.plugin.java.javaproject.importer.JavaImporter;

    public class IJavaBridgeImpl extends ProjectBridgeImplBase implements IJavaBridge
    {
        public function IJavaBridgeImpl()
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
				JavaSyntaxPlugin,
                JavaProjectPlugin,
            ];
        }

        public function getPluginsNotToShowInSettings():Array
        {
            return [
                JavaProjectPlugin,
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
		
        protected var executeCreateJavaProject:CreateJavaProject;

		override public function createProject(event:NewProjectEvent):void
        {
			executeCreateJavaProject = new CreateJavaProject(event);
		}
		
		public function testJava(file:Object):FileLocation
		{
			return JavaImporter.test(file as File);
		}

		public function parseJava(projectFolder:FileLocation, projectName:String=null, settingsFileLocation:FileLocation = null):JavaProjectVO
		{
			return JavaImporter.parse(projectFolder, projectName, settingsFileLocation);
		}

		public function getSettingsFile(projectFolder:Object):FileLocation
		{
			return JavaImporter.getSettingsFile(projectFolder as File);
		}
    }
}
