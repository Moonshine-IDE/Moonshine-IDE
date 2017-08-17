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
package actionScripts.plugins.svn.commands
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.IDataOutput;
	
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	import actionScripts.plugins.core.ExternalCommandBase;
	import actionScripts.plugins.svn.view.ServerCertificateDialog;
	
	public class SVNCommandBase extends ExternalCommandBase
	{
		override public function get name():String { return "Subversion Plugin"; }
		
		public function SVNCommandBase(executable:File, root:File)
		{
			super(executable, root);
		}
		
		// Only allow one operation at a time
		protected var runningForFile:File;
		
		/*
			Handle SVN asking about Server Certificate approval/rejection 
		*/
		protected function serverCertificatePrompt(data:String):Boolean
		{
			// Server certification needs to be accepted to continue
			if (data.indexOf("Error validating server certificate for") > -1)
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
				
				return true;	
			}
			
			return false;
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
		
	}
}