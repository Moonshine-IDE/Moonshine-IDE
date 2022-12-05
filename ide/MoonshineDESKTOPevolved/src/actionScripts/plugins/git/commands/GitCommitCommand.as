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
package actionScripts.plugins.git.commands
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	
	import actionScripts.events.StatusBarEvent;
	import actionScripts.events.WorkerEvent;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.GenericSelectableObject;
	import actionScripts.valueObjects.NativeProcessQueueVO;

	public class GitCommitCommand extends GitCommandBase
	{
		private static const GIT_COMMIT:String = "gitCommit";
		
		public function GitCommitCommand(files:ArrayCollection, withMessage:String)
		{
			super();
			
			queue = new Vector.<Object>();
			
			for each (var i:GenericSelectableObject in files)
			{
				if (i.isSelected) 
				{
					addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +" add $'"+ UtilsCore.getEncodedForShell(i.data.path) +"'" : gitBinaryPathOSX +'&&add&&'+ UtilsCore.getEncodedForShell(i.data.path), false, GIT_COMMIT));
				}
			}
			
			addToQueue(new NativeProcessQueueVO(ConstantsCoreVO.IS_MACOS ? gitBinaryPathOSX +" commit -m $'"+ UtilsCore.getEncodedForShell(withMessage) +"'" : gitBinaryPathOSX +'&&commit&&-m&&'+ UtilsCore.convertString(withMessage), false, GIT_COMMIT));
			
			/*var customProcess:NativeProcess = new NativeProcess();
			var customInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			customInfo.executable = new File(model.gitPath);
			customInfo.workingDirectory = plugin.modelAgainstProject[model.activeProject].rootLocal;
			customInfo.arguments = Vector.<String>(["commit", "-m", withMessage]);
			customProcess.start(customInfo);*/
			
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_STARTED, "Requested", "Commit ", false));
			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory:plugin.modelAgainstProject[model.activeProject].rootLocal.nativePath}, subscribeIdToWorker);
		}
	}
}