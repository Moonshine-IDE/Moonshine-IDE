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
package actionScripts.plugins.svn.commands
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.IDataOutput;
	
	import mx.core.FlexGlobals;
	import mx.core.IFlexDisplayObject;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import actionScripts.locator.IDEModel;
	import actionScripts.plugins.core.ExternalCommandBase;
	import actionScripts.plugins.svn.view.ServerCertificateDialog;
	import actionScripts.plugins.versionControl.VersionControlUtils;
	import actionScripts.plugins.versionControl.event.VersionControlEvent;
	import actionScripts.ui.IContentWindowReloadable;
	import actionScripts.utils.SharedObjectUtil;
	import actionScripts.valueObjects.RepositoryItemVO;
	import actionScripts.valueObjects.VersionControlTypes;
	
	import components.popup.GitAuthenticationPopup;
	
	public class SVNCommandBase extends ExternalCommandBase
	{
		override public function get name():String { return "Subversion Plugin"; }
		
		protected var repositoryItem:RepositoryItemVO;
		protected var isTrustServerCertificateSVN:Boolean;
		
		public function SVNCommandBase(executable:File, root:File)
		{
			super(executable, root);
		}
		
		// Only allow one operation at a time
		protected var runningForFile:File;
		
		/*
			Handle SVN asking about Server Certificate approval/rejection 
		*/
		protected function serverCertificatePrompt(data:String):void
		{
			// Strip stuff we don't want
			data = data.replace("(R)eject, accept (t)emporarily or accept (p)ermanently?", "");
			
			var d:ServerCertificateDialog = new ServerCertificateDialog();
			d.prompt = data;
			d.addEventListener(ServerCertificateDialog.EVENT_ACCEPT_PERM, acceptPerm);
			d.addEventListener(ServerCertificateDialog.EVENT_ACCEPT_TEMP, acceptTemp);
			d.addEventListener(ServerCertificateDialog.EVENT_CANCEL, dontAccept);
			
			PopUpManager.addPopUp(d, FlexGlobals.topLevelApplication as DisplayObject);
			PopUpManager.centerPopUp(d);
		}
		
		// (R)eject, accept (t)emporarily or accept (p)ermanently?
		protected function acceptPerm(event:Event):void
		{
			var input:IDataOutput = customProcess.standardInput;
			input.writeUTFBytes("p\n");
			removeCertDialog(event);
		}
		
		protected function acceptTemp(event:Event):void
		{
			var input:IDataOutput = customProcess.standardInput;
			input.writeUTFBytes("t\n");
			removeCertDialog(event);
		}
		
		protected function dontAccept(event:Event):void
		{
			var input:IDataOutput = customProcess.standardInput;
			input.writeUTFBytes("r\n");
			removeCertDialog(event);
		}
		
		protected function removeCertDialog(event:Event):void
		{
			var d:ServerCertificateDialog = ServerCertificateDialog(event.target);
			PopUpManager.removePopUp(d);
			
			d.removeEventListener(ServerCertificateDialog.EVENT_ACCEPT_PERM, acceptPerm);
			d.removeEventListener(ServerCertificateDialog.EVENT_ACCEPT_TEMP, acceptTemp);
			d.removeEventListener(ServerCertificateDialog.EVENT_CANCEL, dontAccept);
		}
		
		protected function openAuthentication():void
		{
			var authWindow:GitAuthenticationPopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, GitAuthenticationPopup, true) as GitAuthenticationPopup;
			authWindow.title = "Needs Authentication";
			authWindow.type = VersionControlTypes.SVN;
			
			if (repositoryItem) 
			{
				var tmpTopLevel:RepositoryItemVO = VersionControlUtils.getRepositoryItemByUdid(repositoryItem.udid);
				if (tmpTopLevel && tmpTopLevel.userName) authWindow.userName = tmpTopLevel.userName;
			}
			
			authWindow.addEventListener(CloseEvent.CLOSE, onAuthWindowClosed);
			authWindow.addEventListener(GitAuthenticationPopup.AUTH_SUBMITTED, onAuthSubmitted);
			PopUpManager.centerPopUp(authWindow);
		}
		
		protected function onAuthWindowClosed(event:Event):void
		{
			var target:GitAuthenticationPopup = event.target as GitAuthenticationPopup;
			if (!target.userObject) 
			{
				onCancelAuthentication();
				dispatcher.dispatchEvent(new VersionControlEvent(VersionControlEvent.CLONE_CHECKOUT_COMPLETED, {hasError:true, message:"Authentication failed!"}));
			}
			
			target.removeEventListener(CloseEvent.CLOSE, onAuthWindowClosed);
			target.removeEventListener(GitAuthenticationPopup.AUTH_SUBMITTED, onAuthSubmitted);
			PopUpManager.removePopUp(target as IFlexDisplayObject);
		}
		
		protected function onAuthSubmitted(event:Event):void
		{
			var target:GitAuthenticationPopup = event.target as GitAuthenticationPopup;
			if (target.userObject)
			{
				if (target.userObject.save && repositoryItem)
				{
					repositoryItem.userName = target.userObject.userName;
					repositoryItem.userPassword = target.userObject.password;
				}
				onAuthenticationSuccess(target.userObject.userName, target.userObject.password);
			}
			onAuthWindowClosed(event);
		}
		
		protected function onAuthenticationSuccess(username:String, password:String):void
		{
		}
		
		protected function onCancelAuthentication():void
		{
		}
		
		protected function getRepositoryInfo():void
		{
			var infoCommand:InfoCommand = new InfoCommand(executable, root);
			infoCommand.addEventListener(Event.COMPLETE, handleInfoUpdateComplete);
			infoCommand.addEventListener(Event.CANCEL, handleInfoUpdateCancel);
			infoCommand.request(this.root, this.isTrustServerCertificateSVN);
		}
		
		protected function handleInfoUpdateComplete(event:Event):void
		{
			releaseListenersFromInfoCommand(event);
			
			var infoLines:Array = (event.target as InfoCommand).infoLines;
			var searchCriteria:String = "Repository Root: ";
			for each (var line:String in infoLines)
			{
				if (line.indexOf(searchCriteria) != -1)
				{
					searchCriteria = line.substr(searchCriteria.length, line.length);
					// find out relevant repository item associate to the url
					for each (var repo:RepositoryItemVO in VersionControlUtils.REPOSITORIES)
					{
						if (repo.url == searchCriteria)
						{
							this.repositoryItem = repo;
							break;
						}
					}
					break;
				}
			}
		}
		
		protected function checkCurrentEditorForModification():void
		{
			var model:IDEModel = IDEModel.getInstance();
			if (model.activeEditor && (model.activeEditor is IContentWindowReloadable))
			{
				(model.activeEditor as IContentWindowReloadable).checkFileIfChanged();
			}
		}
		
		protected function handleInfoUpdateCancel(event:Event):void
		{
			releaseListenersFromInfoCommand(event);
		}
		
		private function releaseListenersFromInfoCommand(event:Event):void
		{
			event.target.removeEventListener(Event.COMPLETE, handleInfoUpdateComplete);
			event.target.removeEventListener(Event.CANCEL, handleInfoUpdateCancel);
		}
	}
}