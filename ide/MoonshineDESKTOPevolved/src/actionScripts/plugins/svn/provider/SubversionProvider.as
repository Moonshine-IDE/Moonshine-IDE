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
	import actionScripts.plugins.svn.commands.UpdateCommand;
	import actionScripts.plugins.svn.event.SVNEvent;
	
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
			update(FileLocation(event.target.data));
		}
		
		public function update(file:FileLocation, user:String=null, password:String=null, isTrustServerCertificateSVN:Boolean=false):void
		{
			var updateCommand:UpdateCommand = new UpdateCommand(executable, root);
			updateCommand.update(file, user, password, isTrustServerCertificateSVN);
		}
		
		public function checkout(event:SVNEvent, isTrustServerCertificateSVN:Boolean):void
		{
			var checkoutCommand:CheckoutCommand = new CheckoutCommand(executable, root);
			checkoutCommand.checkout(event, isTrustServerCertificateSVN);
		}
	}
}