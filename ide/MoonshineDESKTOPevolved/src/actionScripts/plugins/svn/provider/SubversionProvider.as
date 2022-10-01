////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
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
package actionScripts.plugins.svn.provider
{
	import flash.events.Event;
	import flash.filesystem.File;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugins.svn.commands.CheckoutCommand;
	import actionScripts.plugins.svn.commands.CommitCommand;
	import actionScripts.plugins.svn.commands.LoadRemoteListCommand;
	import actionScripts.plugins.svn.commands.RepositoryTestCommand;
	import actionScripts.plugins.svn.commands.UpdateCommand;
	import actionScripts.plugins.svn.event.SVNEvent;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.RepositoryItemVO;
	
	public class SubversionProvider extends ConsoleOutputter
	{
		protected var status:Object = {};
		
		public var executable:File;
		public var root:File;
		public var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		
		override public function get name():String { return "Subversion plugin"; }

		protected function handleCommit(event:Event):void
		{
			commit(FileLocation(event.target.data));
		}
		
		public function commit(file:FileLocation, message:String=null, user:String=null, password:String=null, commitInfo:Object=null, isTrustServerCertificateSVN:Boolean=false, repositoryItem:RepositoryItemVO=null):void
		{
			var commitCommand:CommitCommand = new CommitCommand(executable, root, status);
			commitCommand.commit(file, message, user, password, commitInfo, isTrustServerCertificateSVN, repositoryItem);
		}
		
		protected function handleUpdate(event:Event):void
		{
			update(FileLocation(event.target.data).fileBridge.getFile as File);
		}
		
		public function update(file:File, user:String=null, password:String=null, isTrustServerCertificateSVN:Boolean=false, repositoryItem:RepositoryItemVO=null):void
		{
			var updateCommand:UpdateCommand = new UpdateCommand(executable, root);
			updateCommand.update(file, user, password, isTrustServerCertificateSVN, repositoryItem);
		}
		
		public function checkout(url:String, rootDirectory:File, targetFolder:String, isTrustServerCertificateSVN:Boolean, repository:RepositoryItemVO, userName:String=null, userPassword:String=null):void
		{
			var checkoutCommand:CheckoutCommand = new CheckoutCommand(executable, root);
			checkoutCommand.checkout(url, rootDirectory, targetFolder, isTrustServerCertificateSVN, repository, userName, userPassword);
		}
		
		public function loadRemoteList(repository:RepositoryItemVO, completion:Function, userName:String=null, userPassword:String=null):void
		{
			var remoteListCommand:LoadRemoteListCommand = new LoadRemoteListCommand(executable, root);
			remoteListCommand.loadList(repository, completion, userName, userPassword);
		}
		
		public function checkIfSVNRepository(project:ProjectVO):void
		{
			var testCommand:RepositoryTestCommand = new RepositoryTestCommand(project, executable, project.folderLocation.fileBridge.getFile as File);
		}
	}
}