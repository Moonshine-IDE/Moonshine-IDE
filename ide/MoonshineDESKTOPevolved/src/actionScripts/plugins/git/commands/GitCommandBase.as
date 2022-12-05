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
	import actionScripts.plugins.git.model.GitProjectVO;

	import flash.display.DisplayObject;
	import flash.events.Event;

	import flashx.textLayout.elements.LinkElement;

	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.formats.TextDecoration;

	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	import mx.utils.UIDUtil;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.StatusBarEvent;
	import actionScripts.events.WorkerEvent;
	import actionScripts.interfaces.IWorkerSubscriber;
	import actionScripts.locator.IDEModel;
	import actionScripts.locator.IDEWorker;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugin.settings.event.RequestSettingByNameEvent;
	import actionScripts.plugins.git.GitHubPlugin;
	import actionScripts.ui.IContentWindowReloadable;
	import actionScripts.utils.MethodDescriptor;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.VersionControlTypes;
	import actionScripts.valueObjects.WorkerNativeProcessResult;
	
	import components.popup.GitAuthenticationPopup;

	import no.doomsday.console.core.events.ConsoleEvent;

	public class GitCommandBase extends ConsoleOutputter implements IWorkerSubscriber
	{
		override public function get name():String { return "Git Plugin"; }

		public static const PRIVATE_REPO_SANDBOX_ERROR_MESSAGE:String = "Git authentication is not supported in the App Store version of Moonshine. Download the full version at https://moonshine-ide.com";
		
		public var gitBinaryPathOSX:String;
		public var pendingProcess:Array /* of MethodDescriptor */ = [];
		public var methodStamp:MethodDescriptor;
		
		protected var plugin:GitHubPlugin;
		protected var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		protected var model:IDEModel = IDEModel.getInstance();
		protected var processType:String;
		protected var queue:Vector.<Object> = new Vector.<Object>();
		protected var subscribeIdToWorker:String;
		protected var worker:IDEWorker = IDEWorker.getInstance();
		protected var isErrorEncountered:Boolean;
		
		public function GitCommandBase()
		{
			getGitPluginReference();
			gitBinaryPathOSX = plugin.gitBinaryPathOSX;
			subscribeIdToWorker = UIDUtil.createUID();
			
			worker.subscribeAsIndividualComponent(subscribeIdToWorker, this);
			worker.sendToWorker(WorkerEvent.SET_IS_MACOS, ConstantsCoreVO.IS_MACOS, subscribeIdToWorker);
		}
		
		protected function unsubscribeFromWorker():void
		{
			worker.unSubscribeComponent(subscribeIdToWorker);
			worker = null;
			queue = null;
			methodStamp = null;
		}
		
		protected function getPlatformMessage(value:String):String
		{
			if (!gitBinaryPathOSX)
			{
				//the path isn't set at all, so we can't build a command
				return null;
			}

			if (ConstantsCoreVO.IS_MACOS)
			{
				return gitBinaryPathOSX + value;
			}
			
			value = value.replace(/( )/g, "&&");
			return gitBinaryPathOSX + value;
		}
		
		public function onWorkerValueIncoming(value:Object):void
		{
			var tmpValue:Object = value.value;
			switch (value.event)
			{
				case WorkerEvent.RUN_NATIVEPROCESS_OUTPUT:
					if (tmpValue.type == WorkerNativeProcessResult.OUTPUT_TYPE_DATA) shellData(tmpValue);
					else if (tmpValue.type == WorkerNativeProcessResult.OUTPUT_TYPE_CLOSE) shellExit(tmpValue);
					else shellError(tmpValue);
					break;
				case WorkerEvent.RUN_LIST_OF_NATIVEPROCESS_PROCESS_TICK:
					if (queue.length != 0) queue.shift();
					processType = tmpValue.processType;
					shellTick(tmpValue);
					break;
				case WorkerEvent.RUN_LIST_OF_NATIVEPROCESS_ENDED:
					listOfProcessEnded();
					dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
					// starts checking pending process here
					if (pendingProcess.length > 0)
					{
						for each (var pp:MethodDescriptor in pendingProcess)
						{
							//var process:MethodDescriptor = pendingProcess.shift();
							pp.callMethod();
						}
					}
					unsubscribeFromWorker();
					break;
				case WorkerEvent.CONSOLE_MESSAGE_NATIVEPROCESS_OUTPUT:
					debug("%s", value.value);
					break;
			}
		}
		
		protected function addToQueue(value:Object):void
		{
			queue.push(value);
		}
		
		protected function listOfProcessEnded():void
		{
		}
		
		protected function shellError(value:Object /** type of WorkerNativeProcessResult **/):void 
		{
			var match:Array = value.output.toLowerCase().match(/'git' is not recognized as an internal or external command/);
			if (match)
			{
				plugin.setGitAvailable(false);
			}
			
			if (!match) error(value.output);
			isErrorEncountered = true;
			dispatcher.dispatchEvent(new StatusBarEvent(StatusBarEvent.PROJECT_BUILD_ENDED));
			unsubscribeFromWorker();
		}
		
		protected function shellExit(value:Object /** type of WorkerNativeProcessResult **/):void 
		{
			//unsubscribeFromWorker();
		}
		
		protected function shellTick(value:Object /** type of NativeProcessQueueVO **/):void
		{
		}
		
		protected function shellData(value:Object /** type of WorkerNativeProcessResult **/):void 
		{
			var match:Array;
			var isFatal:Boolean;
			
			match = value.output.match(/fatal: .*/);
			if (match) isFatal = true;
			
			if (isFatal)
			{
				shellError(value);
				return;
			}
			else
			{
				notice(value.output);
			}
		}
		
		protected function refreshProjectTree():void
		{
			// refreshing project tree
			GlobalEventDispatcher.getInstance().dispatchEvent(new ProjectEvent(ProjectEvent.PROJECT_FILES_UPDATES, model.activeProject.projectFolder));
		}
		
		protected function checkCurrentEditorForModification():void
		{
			if (model.activeEditor && (model.activeEditor is IContentWindowReloadable))
			{
				(model.activeEditor as IContentWindowReloadable).checkFileIfChanged();
			}
		}
		
		protected function testMessageIfNeedsAuthentication(value:String):Boolean
		{
			if (value.toLowerCase().match(/fatal: .*username/) || 
				value..toLowerCase().match(/fatal: .*could not read password/) ||
				value.toLowerCase().match(/fatal: .*could not read password/) ||
					value.toLowerCase().match(/fatal: authentication failed/))
			{
				return true;
			}
			
			return false;
		}
		
		protected function openAuthentication(username:String=null):void
		{
			var gitAuthWindow:GitAuthenticationPopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, GitAuthenticationPopup, true) as GitAuthenticationPopup;
			gitAuthWindow.title = "Git Needs Authentication";
			gitAuthWindow.isGitAvailable = true;
			gitAuthWindow.type = VersionControlTypes.GIT;
			gitAuthWindow.userName = username;
			gitAuthWindow.addEventListener(CloseEvent.CLOSE, onGitAuthWindowClosed);
			gitAuthWindow.addEventListener(GitAuthenticationPopup.AUTH_SUBMITTED, onAuthSubmitted);
			PopUpManager.centerPopUp(gitAuthWindow);
		}
		
		protected function onAuthenticationSuccess(username:String, password:String):void
		{
			if (username && password)
			{
				var tmpModel:GitProjectVO = plugin.modelAgainstProject[model.activeProject];
				if (tmpModel)
				{
					tmpModel.sessionUser = username;
					tmpModel.sessionPassword = password;
				}
			}
		}

		private function onGitAuthWindowClosed(event:Event):void
		{
			var target:GitAuthenticationPopup = event.target as GitAuthenticationPopup;
			target.removeEventListener(CloseEvent.CLOSE, onGitAuthWindowClosed);
			target.removeEventListener(GitAuthenticationPopup.AUTH_SUBMITTED, onAuthSubmitted);
		}
		
		private function onAuthSubmitted(event:Event):void
		{
			var target:GitAuthenticationPopup = event.target as GitAuthenticationPopup;
			PopUpManager.removePopUp(target);
			onGitAuthWindowClosed(event);

			if (target.userObject)
			{
				onAuthenticationSuccess(target.userObject.userName, target.userObject.password);
			}
		}
		
		private function getGitPluginReference():void
		{
			var tmpEvent:RequestSettingByNameEvent = new RequestSettingByNameEvent(GitHubPlugin.NAMESPACE);
			dispatcher.dispatchEvent(tmpEvent);
			
			plugin = tmpEvent.value as GitHubPlugin;
		}

		protected function showPrivateRepositorySandboxError():void
		{
			var p:ParagraphElement = new ParagraphElement();
			var span1:SpanElement = new SpanElement();
			var link:LinkElement = new LinkElement();

			p.color = 0xff6666;
			span1.text = ": Git authentication is not supported in the App Store version of Moonshine. Download the full version at ";

			link.href = "https://moonshine-ide.com";
			var inf:Object = {color:0xc165b8, textDecoration:TextDecoration.UNDERLINE};
			link.linkNormalFormat = inf;

			var linkSpan:SpanElement = new SpanElement();
			linkSpan.text = "https://moonshine-ide.com";
			link.addChild(linkSpan);

			p.addChild(span1);
			p.addChild(link);

			outputMsg(p);
		}
	}
}