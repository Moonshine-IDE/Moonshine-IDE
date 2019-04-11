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
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.filesystem.File;
    
    import mx.controls.Alert;
    
    import actionScripts.events.NewProjectEvent;
    import actionScripts.plugins.as3project.CreateProject;
    import actionScripts.plugins.as3project.ImportArchiveProject;
    import actionScripts.valueObjects.FileWrapper;

    public class ProjectBridgeImplBase
    {
        protected var executeCreateProject:CreateProject;
		
		private var filesToBeDeleted:Array;
		private var deletableProjectWrapper:FileWrapper;
		private var projectDeleteCompletionMethod:Function;

        public function createProject(event:NewProjectEvent):void
        {
            executeCreateProject = new CreateProject(event);
        }
		
		public function importArchiveProject():void
		{
			new ImportArchiveProject();
		}

        public function deleteProject(projectWrapper:FileWrapper, finishHandler:Function, isDeleteRoot:Boolean=false):void
        {
			if (isDeleteRoot)
			{
				projectWrapper.file.fileBridge.deleteDirectory(true);
				finishHandler(projectWrapper);
			}
			else
			{
				filesToBeDeleted = projectWrapper.children;
				deletableProjectWrapper = projectWrapper;
				projectDeleteCompletionMethod = finishHandler;
				
				deleteFilesAsync();
			}
        }
		
		private function deleteFilesAsync():void
		{
			if (filesToBeDeleted && filesToBeDeleted.length != 0)
			{
				var tmpWrapper:FileWrapper = filesToBeDeleted[0] as FileWrapper;
				addRemoveListeners(tmpWrapper.file.fileBridge.getFile, true);
				
				if (tmpWrapper.file.fileBridge.isDirectory) tmpWrapper.file.fileBridge.deleteDirectoryAsync(true);
				else tmpWrapper.file.fileBridge.deleteFileAsync();
				
				return;
			}
			else if (deletableProjectWrapper.file.fileBridge.exists && deletableProjectWrapper.file.fileBridge.getDirectoryListing().length == 0)
			{
				// remove root only if children is 0
				addRemoveListeners(deletableProjectWrapper.file.fileBridge.getFile, true);
				deletableProjectWrapper.file.fileBridge.deleteDirectoryAsync(true);
			}
			
			// confirm to the caller
			projectDeleteCompletionMethod([deletableProjectWrapper]);
			
			// remove footprint
			filesToBeDeleted = null;
			deletableProjectWrapper = null;
			projectDeleteCompletionMethod = null;
		}
		
		private function onFileFolderDeleted(event:Event):void
		{
			onFileFolderDeletionError(event, false);
			if (filesToBeDeleted) 
			{
				filesToBeDeleted.shift();
				deleteFilesAsync();
			}
		}
		
		private function onFileFolderDeletionError(event:Event, showError:Boolean=true):void
		{
			if (showError) Alert.show(event.toString());
			
			if (event) addRemoveListeners(event.target, false);
			else addRemoveListeners(filesToBeDeleted[0].file.fileBridge.getFile, false);
		}
		
		private function addRemoveListeners(file:Object, isAdd:Boolean):void
		{
			if (isAdd)
			{
				file.addEventListener(Event.COMPLETE, onFileFolderDeleted);
				file.addEventListener(IOErrorEvent.IO_ERROR, onFileFolderDeletionError);
				file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onFileFolderDeletionError);
			}
			else if (file)
			{
				file.removeEventListener(Event.COMPLETE, onFileFolderDeleted);
				file.removeEventListener(IOErrorEvent.IO_ERROR, onFileFolderDeletionError);
				file.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onFileFolderDeletionError);
			}
		}
    }
}
