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
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.filesystem.File;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugin.core.sourcecontrol.ISourceControlProvider;
	import actionScripts.plugins.svn.commands.CheckoutCommand;
	import actionScripts.plugins.svn.commands.CommitCommand;
	import actionScripts.plugins.svn.commands.DeleteCommand;
	import actionScripts.plugins.svn.commands.UpdateCommand;
	import actionScripts.plugins.svn.commands.UpdateStatusCommand;
	import actionScripts.plugins.svn.event.SVNEvent;
	
	public class SubversionProvider extends ConsoleOutputter implements ISourceControlProvider
	{
		protected var status:Object = {};
		
		public var executable:File;
		public var root:File;
		public var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		
		override public function get name():String { return "Subversion plugin"; }
		
		public function get systemNameShort():String { return "SVN"; }
		
		public function getTreeRightClickMenu(file:FileLocation):Object
		{
			var menu:NativeMenuItem = new NativeMenuItem("Subversion");
			menu.submenu = new NativeMenu();
			
			var commit:NativeMenuItem = new NativeMenuItem("Commit");
			commit.data = file;
			commit.addEventListener(Event.SELECT, handleCommit);
			menu.submenu.addItem(commit);
			
			var update:NativeMenuItem = new NativeMenuItem("Update");
			update.addEventListener(Event.SELECT, handleUpdate);
			update.data = file;
			menu.submenu.addItem(update);
			
			return menu;
		}
		
		public function getStatus(filePath:String):String
		{
			var st:SVNStatus = status[filePath];
			if (st)
			{
				return st.shortStatus;
			}
			
			return null;
		}

		protected function handleCommit(event:Event):void
		{
			var file:File = FileLocation(event.target.data).fileBridge.getFile as File;
			
			commit(file);
		}
		
		public function commit(file:File, message:String=null):void
		{
			var commitCommand:CommitCommand = new CommitCommand(executable, root, status);
			commitCommand.commit(file, message);
		}
		
		protected function handleUpdate(event:Event):void
		{
			var f:File = FileLocation(event.target.data).fileBridge.getFile as File;
			update(f);
		}
		
		public function update(file:File):void
		{
			var updateCommand:UpdateCommand = new UpdateCommand(executable, root);
			updateCommand.update(file);
		}
		
		public function refresh(file:FileLocation):void
		{
			// Status will be updated
			var refreshCommand:UpdateStatusCommand = new UpdateStatusCommand(executable, root, status);
			refreshCommand.update(file.fileBridge.getFile as File);
		}
		
		public function remove(file:FileLocation):void
		{
			var deleteCommand:DeleteCommand = new DeleteCommand(executable, root);
			deleteCommand.remove(file.fileBridge.getFile as File);
		}
		
		public function checkout(event:SVNEvent):void
		{
			var checkoutCommand:CheckoutCommand = new CheckoutCommand(executable, root);
			checkoutCommand.checkout(event);
		}

		
	}

}