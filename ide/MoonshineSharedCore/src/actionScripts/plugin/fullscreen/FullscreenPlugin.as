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
package actionScripts.plugin.fullscreen
{
	import flash.display.StageDisplayState;
	import flash.events.Event;
	
	import mx.core.FlexGlobals;
	
	import actionScripts.plugin.PluginBase;

	public class FullscreenPlugin extends PluginBase 
	{
		public static const EVENT_FULLSCREEN:String = "fullscreenEvent";
		
		override public function get name():String			{ return "Fullscreen Plugin"; }
		override public function get author():String		{ return "Moonshine Project Team"; }
		override public function get description():String	{ return "Show edit in fullscreen. Esc exits."; }
		
		override public function activate():void
		{
			super.activate();
			dispatcher.addEventListener(EVENT_FULLSCREEN, handleToggleFullscreen);
		}
		
		protected function handleToggleFullscreen(event:Event):void
		{
			var stage:Object = FlexGlobals.topLevelApplication.stage;
			if( stage.displayState == StageDisplayState.NORMAL ) 
			{
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			} 
			else 
			{
				stage.displayState = StageDisplayState.NORMAL;
			}
		}
	}
}