////////////////////////////////////////////////////////////////////////////////
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
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
		
		public function commit(file:FileLocation, message:String=null, user:String=null, password:String=null, commitInfo:Object=null, isTrustServerCertificateSVN:Boolean=false):void
		{
			var commitCommand:CommitCommand = new CommitCommand(executable, root, status);
			commitCommand.commit(file, message, user, password, commitInfo, isTrustServerCertificateSVN);
		}
		
		protected function handleUpdate(event:Event):void
		{
			update(FileLocation(event.target.data).fileBridge.getFile as File);
		}
		
		public function update(file:File, user:String=null, password:String=null, isTrustServerCertificateSVN:Boolean=false):void
		{
			var updateCommand:UpdateCommand = new UpdateCommand(executable, root);
			updateCommand.update(file, user, password, isTrustServerCertificateSVN);
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