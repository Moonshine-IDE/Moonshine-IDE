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
package actionScripts.plugins.core
{
    import flash.desktop.NativeApplication;
    
    import actionScripts.events.NewProjectEvent;
    import actionScripts.plugins.as3project.CreateProject;
    import actionScripts.valueObjects.FileWrapper;

    public class ProjectBridgeImplBase
    {
        protected var executeCreateProject:CreateProject;

        public function createProject(event:NewProjectEvent):void
        {
            executeCreateProject = new CreateProject(event);
        }

        public function deleteProject(projectWrapper:FileWrapper, finishHandler:Function, isDeleteRoot:Boolean=false):void
        {
			if (isDeleteRoot)
			{
				projectWrapper.file.fileBridge.deleteDirectory(true);
			}
			else
			{
				// go for only one level of file/folder deletion
				for each (var wrapper:FileWrapper in projectWrapper.children)
				{
					if (wrapper.file.fileBridge.isDirectory) wrapper.file.fileBridge.deleteDirectory(true);
					else wrapper.file.fileBridge.deleteFile();
				}
				
				// when done check if the root folder is empty
				// if it is, go delete it irrespective of 'isDeleteRoot' value
				if (projectWrapper.file.fileBridge.getDirectoryListing().length == 0)
				{
					projectWrapper.file.fileBridge.deleteDirectory(true);
				}
			}

            // when done call the finish handler
            finishHandler(projectWrapper);
        }

        public function exitApplication():void
        {
            NativeApplication.nativeApplication.exit();
        }
    }
}
