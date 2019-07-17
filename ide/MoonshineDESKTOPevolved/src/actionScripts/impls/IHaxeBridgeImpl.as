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
    import actionScripts.interfaces.IHaxeBridge;
    import actionScripts.plugin.haxe.hxproject.HaxeProjectPlugin;
    import actionScripts.plugin.haxe.hxproject.importer.HaxeImporter;
    import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;
    import actionScripts.plugin.syntax.HaxeSyntaxPlugin;
    import actionScripts.plugins.core.ProjectBridgeImplBase;
    import actionScripts.plugins.haxe.HaxeBuildPlugin;

    import flash.filesystem.File;
    import actionScripts.plugin.haxe.hxproject.CreateHaxeProject;
    import actionScripts.plugins.haxelib.HaxelibPlugin;

    public class IHaxeBridgeImpl extends ProjectBridgeImplBase implements IHaxeBridge
    {
        public function IHaxeBridgeImpl()
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
				HaxeSyntaxPlugin,
                HaxeProjectPlugin,
				HaxeBuildPlugin,
                HaxelibPlugin,
            ];
        }

        public function getPluginsNotToShowInSettings():Array
        {
            return [
                HaxeSyntaxPlugin,
                HaxeProjectPlugin,
                HaxelibPlugin,
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
		
        protected var executeCreateHaxeProject:CreateHaxeProject;

		override public function createProject(event:NewProjectEvent):void
        {
			executeCreateHaxeProject = new CreateHaxeProject(event);
		}
		
		public function testHaxe(file:Object):FileLocation
		{
			return HaxeImporter.test(file as File);
		}

		public function parseHaxe(file:FileLocation):HaxeProjectVO
		{
			return HaxeImporter.parse(file);
		}
    }
}
