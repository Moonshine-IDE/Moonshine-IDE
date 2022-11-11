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
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.SpanElement;
	import flashx.textLayout.formats.TextDecoration;
	
	import no.doomsday.console.core.events.ConsoleEvent;
	
	public class UncaughtErrorsPlugin extends PluginBase implements IMenuPlugin
	{
		override public function get name():String { return "Uncaught Error Handlers Plugin"; }
		override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
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