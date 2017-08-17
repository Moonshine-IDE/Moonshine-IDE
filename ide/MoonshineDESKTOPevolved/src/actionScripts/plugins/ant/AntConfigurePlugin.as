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
package actionScripts.plugins.ant
{
	import flash.events.Event;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.PluginBase;

	public class AntConfigurePlugin extends PluginBase
	{
		public static const EVENT_ANTCONFIGURE:String = "antconfigureEvent";
		
		override public function get name():String			{ return "Ant Configure Plugin"; }
		override public function get author():String		{ return "Moonshine Project Team"; }
		override public function get description():String	{ return "Ant Configure Plugin. Esc exits."; }
		
		
		private var file:FileLocation;
		
		private var idemodel:IDEModel = IDEModel.getInstance();
		
		override public function activate():void
		{
			super.activate();
			dispatcher.addEventListener(EVENT_ANTCONFIGURE, handleAntConfigure);
		}
		
		protected function handleAntConfigure(event:Event):void
		{
			file = new FileLocation();
			file.fileBridge.browseForOpen("Select Build File", selectBuildFile, null, ["*.xml"]);
		}
		
		protected function selectBuildFile(fileSelected:Object):void
		{ 
			// If file is open already, just focus that editor.
			idemodel.antScriptFile = new FileLocation(fileSelected.nativePath);
		}
	}
}