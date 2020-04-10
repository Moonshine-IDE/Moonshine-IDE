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
    import flash.filesystem.File;
    
    import actionScripts.events.NewProjectEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.interfaces.IOnDiskBridge;
    import actionScripts.plugin.ondiskproj.CreateOnDiskProject;
    import actionScripts.plugin.ondiskproj.OnDiskProjectPlugin;
    import actionScripts.plugin.ondiskproj.importer.OnDiskImporter;
    import actionScripts.plugin.ondiskproj.vo.OnDiskProjectVO;
    import actionScripts.plugins.core.ProjectBridgeImplBase;

    public class IOnDiskBridgeImpl extends ProjectBridgeImplBase implements IOnDiskBridge
    {
        public function IOnDiskBridgeImpl()
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
                OnDiskProjectPlugin
            ];
        }

        public function getPluginsNotToShowInSettings():Array
        {
            return [
				OnDiskProjectPlugin
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
		
		override public function createProject(event:NewProjectEvent):void
        {
			new CreateOnDiskProject(event);
		}
		
		public function testOnDisk(file:Object):FileLocation
		{
			return OnDiskImporter.test(file as File);
		}

		public function parseOnDisk(file:FileLocation):OnDiskProjectVO
		{
			return OnDiskImporter.parse(file);
		}
    }
}
