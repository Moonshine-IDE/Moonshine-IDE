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
package actionScripts.controllers
{
	import flash.events.Event;

	import actionScripts.events.AddTabEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.events.OpenLocationEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.interfaces.ILanguageServerBridge;
	import actionScripts.locator.IDEModel;
	import actionScripts.ui.editor.BasicTextEditor;
	import moonshine.editor.text.TextEditor;
	import actionScripts.valueObjects.ProjectVO;

	import moonshine.lsp.Location;
	import moonshine.lsp.LocationLink;
	import moonshine.lsp.Position;
	import moonshine.lsp.Range;

	public class OpenLocationCommand implements ICommand
	{
		public function execute(event:Event):void
		{
			var openLocationEvent:OpenLocationEvent = OpenLocationEvent(event);
			var uri:String = null;
			var range:Range = null;
			if(openLocationEvent.location is Location)
			{
				var location:Location = Location(openLocationEvent.location);
				uri = location.uri;
				range = location.range;
			}
			else if(openLocationEvent.location is LocationLink)
			{
				var locationLink:LocationLink = LocationLink(openLocationEvent.location);
				uri = locationLink.targetUri;
				range = locationLink.targetRange;
			}
			
			var lsc:ILanguageServerBridge = IDEModel.getInstance().languageServerCore;
			var project:ProjectVO = IDEModel.getInstance().activeProject;
			if(!lsc.hasCustomTextEditorForUri(uri, project))
			{
				//we should never get here, but this will save us if we do
				return;
			}
			
			var colonIndex:int = uri.indexOf(":");
			var scheme:String = uri.substr(0, colonIndex);
			if(scheme == "file")
			{
				var openEvent:OpenFileEvent = new OpenFileEvent(OpenFileEvent.OPEN_FILE,
					[new FileLocation(uri, true)], range.start.line);
				openEvent.atChar = range.start.character;
				GlobalEventDispatcher.getInstance().dispatchEvent(openEvent);
			}
			else
			{
				var editor:BasicTextEditor = lsc.getCustomTextEditorForUri(uri, project, true);
				GlobalEventDispatcher.getInstance().dispatchEvent(
					new AddTabEvent(editor)
				);
				var start:Position = range.start;
				if (start.line > -1)
				{
					var line:int = start.line;
					var char:int = start.character != -1 ? start.character : 0;
					editor.setSelection(line, char, line, char);
					editor.scrollToCaret();
				}
				editor.callLater(function():void
				{
					//for some reason this does not work immediately
					editor.setFocus();
				});
			}
		}
	}
}