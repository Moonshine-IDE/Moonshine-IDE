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
package actionScripts.plugin.errors
{
	import flash.events.ErrorEvent;
	import flash.events.UncaughtErrorEvent;
	
	import mx.collections.ArrayList;
	import mx.core.FlexGlobals;

	import actionScripts.plugin.IMenuPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.ui.menu.vo.MenuItem;
	
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.formats.TextDecoration;
	
	import no.doomsday.console.core.events.ConsoleEvent;
	
	public class UncaughtErrorsPlugin extends PluginBase implements IMenuPlugin
	{
		override public function get name():String { return "Uncaught Error Handlers Plugin"; }
		override public function get author():String { return "Moonshine Project Team"; }
		override public function get description():String { return "Catch any uncaught errors in the application"; }
		
		private var _problemList:ArrayList;
		public function get problemList():ArrayList
		{
			return _problemList;
		}
		
		public function UncaughtErrorsPlugin() {}
		
		override public function activate():void
		{
			super.activate();
			
			// add event listeners
			FlexGlobals.topLevelApplication.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);
			dispatcher.addEventListener(ConsoleEvent.REPORT_A_BUG, reportBugFromConsole, false, 0, true);
		}
		
		override public function deactivate():void
		{
			super.deactivate();
			
			// remove event listeners
			FlexGlobals.topLevelApplication.loaderInfo.uncaughtErrorEvents.removeEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);
			dispatcher.removeEventListener(ConsoleEvent.REPORT_A_BUG, reportBugFromConsole);
		}
		
		public function getMenu():MenuItem
		{
			// shall be a place to menu to open list of details
			return null;
		}
		
		private function uncaughtErrorHandler(event:UncaughtErrorEvent):void
		{
			if (!_problemList) _problemList = new ArrayList();
			
			var errorString:String;
			// print to console only for now
			if (event.error is Error)
			{
				errorString = (event.error as Error).message +"\n"+ (event.error as Error).getStackTrace();
				error(errorString);
			}
			else if (event.error is ErrorEvent)
			{
				errorString = (event.error as ErrorEvent).text;
				error(errorString);
			}
			else
			{
				// a non-Error, non-ErrorEvent type was thrown and uncaught
				errorString = event.toString();
				error(errorString);
			}
			
			generateReportLink(errorString);
			_problemList.addItem(errorString);
		}
		
		private function generateReportLink(errorMessage:String):void
		{
			var p:ParagraphElement = new ParagraphElement();
			var span1:SpanElement = new SpanElement();
			var link:LinkElement = new LinkElement();
			
			p.color = 0xFA8072;
			span1.text = ":\n: Click here to ";
			
			link.href = "event:"+ ConsoleEvent.REPORT_A_BUG;
			var inf:Object = {color:0xc165b8, textDecoration:TextDecoration.UNDERLINE};   
			link.linkNormalFormat = inf;
			
			var linkSpan:SpanElement = new SpanElement();
			linkSpan.text = "Report a Bug";
			link.addChild(linkSpan);
			
			p.addChild(span1);
			p.addChild(link);
			
			dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, p));
		}
		
		private function reportBugFromConsole(event:ConsoleEvent):void 
		{
			var tmpEvent:ConsoleEvent = new ConsoleEvent(ConsoleEvent.OPEN_REPORT_A_BUG_WINDOW);
			tmpEvent.text = _problemList.source.join("\n\n");
			dispatcher.dispatchEvent(tmpEvent);
		}
	}
}