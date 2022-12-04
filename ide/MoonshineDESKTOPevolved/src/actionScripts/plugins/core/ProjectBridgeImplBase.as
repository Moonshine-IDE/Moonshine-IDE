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
