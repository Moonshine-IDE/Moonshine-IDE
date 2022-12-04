////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
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
package actionScripts.plugin.organizeImports
{
	import flash.events.Event;
	
	import actionScripts.events.ExecuteLanguageServerCommandEvent;
	import actionScripts.events.LanguageServerMenuEvent;
	import actionScripts.plugin.PluginBase;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.utils.getProjectForUri;
	import actionScripts.ui.editor.LanguageServerTextEditor;

	public class OrganizeImportsPlugin extends PluginBase
	{
		private static const COMMAND_ORGANIZE_IMPORTS_IN_URI:String = "as3mxml.organizeImportsInUri";

		public function OrganizeImportsPlugin() {	}

		override public function get name():String { return "Organize Imports Plugin"; }
		override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String { return "Organize imports in a file."; }

		override public function activate():void
		{
			super.activate();
			dispatcher.addEventListener(LanguageServerMenuEvent.EVENT_MENU_ORGANIZE_IMPORTS, handleOrganizeImports);
		}

		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(LanguageServerMenuEvent.EVENT_MENU_ORGANIZE_IMPORTS, handleOrganizeImports);
		}

		private function handleOrganizeImports(event:Event):void
		{
			// TODO: switch to the standardized organize imports code action
			var editor:LanguageServerTextEditor = model.activeEditor as LanguageServerTextEditor;
			if(!editor || !editor.currentFile || (editor.currentFile.fileBridge.extension != "as" && editor.currentFile.fileBridge.extension != "mxml"))
			{
				return;
			}
			var uri:String = editor.currentFile.fileBridge.url;
			var project:ProjectVO = getProjectForUri(uri);
			dispatcher.dispatchEvent(new ExecuteLanguageServerCommandEvent(
				ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND,
				project, COMMAND_ORGANIZE_IMPORTS_IN_URI, [{external: uri}]));
		}
	}
}