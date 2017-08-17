////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.svn
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.filesystem.File;
	
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	import mx.resources.ResourceManager;
	
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.SaveFileEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.plugin.settings.vo.PathSetting;
	import actionScripts.plugins.svn.event.SVNEvent;
	import actionScripts.plugins.svn.provider.SubversionProvider;
	import actionScripts.plugins.svn.view.CheckoutDialog;

	public class SVNPlugin extends PluginBase implements ISettingsProvider
	{
		public static const CHECKOUT_REQUEST:String = "checkoutRequestEvent";
		
		override public function get name():String			{ return "Subversion Plugin"; }
		override public function get author():String		{ return "Moonshine Project Team"; }
		override public function get description():String	{ return ResourceManager.getInstance().getString('resources','plugin.desc.subversion'); }
		
		public var svnBinaryPath:String;
		
		override public function activate():void
		{
			super.activate();
			
			dispatcher.addEventListener(SaveFileEvent.FILE_SAVED, handleFileSave);
			dispatcher.addEventListener(ProjectEvent.ADD_PROJECT, handleProjectOpen);
			dispatcher.addEventListener(CHECKOUT_REQUEST, handleCheckoutRequest);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			
			dispatcher.removeEventListener(SaveFileEvent.FILE_SAVED, handleFileSave);
			dispatcher.removeEventListener(ProjectEvent.ADD_PROJECT, handleProjectOpen);
			dispatcher.removeEventListener(CHECKOUT_REQUEST, handleCheckoutRequest);
		}
		
		public function getSettingsList():Vector.<ISetting>
		{
			return Vector.<ISetting>([
				new PathSetting(this,'svnBinaryPath', 'SVN Binary', false)
			]);
		}
		
		/*public function getMenu():MenuItem
		{
			var EditMenu:MenuItem = new MenuItem('Subversion');
			EditMenu.parents = ["Subversion"];
			EditMenu.items = new Vector.<MenuItem>();
			EditMenu.items.push(new MenuItem("Checkout", null, CHECKOUT_REQUEST));
			return EditMenu;
			
		}*/
		
		protected function handleFileSave(event:SaveFileEvent):void
		{
			
		}
		
		protected function handleProjectOpen(event:ProjectEvent):void
		{
			// Check if project is versioned with SVN
			if (isVersioned(event.project.folderLocation) == false) return;
			
			// Check if we have a SVN binary
			if (!svnBinaryPath || svnBinaryPath == "") return;
			
			// Create new provider
			var provider:SubversionProvider = new SubversionProvider();
			provider.executable = new File(svnBinaryPath);
			provider.root = event.project.folderLocation.fileBridge.getFile as File;
			
			// Set it to tree data so project view can render it
			event.project.projectFolder.sourceController = provider;
			
			// Load initial data
			provider.refresh(event.project.folderLocation);
		}
		
		protected function handleCheckoutRequest(event:Event):void
		{
			// Check if we have a SVN binary
			// for Windows only
			// @note SK
			// Need to check OSX svn existence someway
			if (!svnBinaryPath || svnBinaryPath == "")
			{
				error("No SVN binary set, please check the settings.");
				return;
			}
			
			var checkoutDialog:CheckoutDialog = new CheckoutDialog();
			checkoutDialog.addEventListener('close', handleCheckoutDialogClose);
			checkoutDialog.addEventListener(SVNEvent.EVENT_CHECKOUT, handleCheckout);
			
			PopUpManager.addPopUp(checkoutDialog, FlexGlobals.topLevelApplication as DisplayObject, true);
			PopUpManager.centerPopUp(checkoutDialog);
			checkoutDialog.y -= 20;
		}
		
		protected function handleCheckout(event:SVNEvent):void
		{
			var provider:SubversionProvider = new SubversionProvider();
			provider.executable = new File(svnBinaryPath);
			provider.checkout(event);
			
			handleCheckoutDialogClose(event);
		}
		
		protected function handleCheckoutDialogClose(event:Event):void
		{
			var pop:CheckoutDialog = CheckoutDialog(event.target);
			PopUpManager.removePopUp(pop);
			pop.addEventListener('close', handleCheckoutDialogClose);
			pop.addEventListener(SVNEvent.EVENT_CHECKOUT, handleCheckout);
		}
		
		protected function isVersioned(folder:FileLocation):Boolean
		{
			if (!folder.fileBridge.exists) folder.fileBridge.createDirectory();
			
			var listing:Array = folder.fileBridge.getDirectoryListing();
			for each (var file:File in listing)
			{
				if (file.name == ".svn")
					return true;
			}
			return false;
		}
	}
}