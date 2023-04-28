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
package actionScripts.ui.editor
{
	import actionScripts.events.DiagnosticsEvent;
	import actionScripts.events.LanguageServerMenuEvent;
	import actionScripts.events.LocationsEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.SaveFileEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.languageServer.LanguageServerProjectVO;
	import actionScripts.ui.tabview.TabEvent;

	import flash.events.Event;

	import moonshine.editor.text.lsp.LspTextEditor;
	import moonshine.editor.text.lsp.events.LspTextEditorLanguageRequestEvent;
	import moonshine.lsp.LanguageClient;
	import moonshine.lsp.Position;
	import moonshine.editor.text.events.TextEditorChangeEvent;
	import moonshine.lsp.CompletionItem;
	import moonshine.editor.text.lsp.events.LspTextEditorLanguageActionEvent;
	import actionScripts.utils.applyWorkspaceEdit;
	import moonshine.lsp.WorkspaceEdit;
	import moonshine.lsp.Command;
	import moonshine.lsp.LocationLink;
	import actionScripts.events.OpenLocationEvent;

	public class LanguageServerTextEditor extends BasicTextEditor
	{
		public function LanguageServerTextEditor(languageID:String, project:LanguageServerProjectVO, readOnly:Boolean = false)
		{
			super(readOnly);

			_languageID = languageID;
			_project = project;

			populateLspServerCapabilities();

			lspEditor.addEventListener(LspTextEditorLanguageRequestEvent.REQUEST_COMPLETION, lspEditor_requestCompletionHandler);
			lspEditor.addEventListener(LspTextEditorLanguageRequestEvent.REQUEST_RESOLVE_COMPLETION, lspEditor_requestResolveCompletionHandler);
			lspEditor.addEventListener(LspTextEditorLanguageRequestEvent.REQUEST_SIGNATURE_HELP, lspEditor_requestSignatureHelpHandler);
			lspEditor.addEventListener(LspTextEditorLanguageRequestEvent.REQUEST_HOVER, lspEditor_requestHoverHandler);
			lspEditor.addEventListener(LspTextEditorLanguageRequestEvent.REQUEST_DEFINITION, lspEditor_requestDefinitionHandler);
			lspEditor.addEventListener(LspTextEditorLanguageRequestEvent.REQUEST_CODE_ACTIONS, lspEditor_requestCodeActionsHandler);
			lspEditor.addEventListener(LspTextEditorLanguageActionEvent.APPLY_WORKSPACE_EDIT, lspEditor_applyWorkspaceEditHandler);
			lspEditor.addEventListener(LspTextEditorLanguageActionEvent.OPEN_LINK, lspEditor_openLinkHandler);
			lspEditor.addEventListener(LspTextEditorLanguageActionEvent.RUN_COMMAND, lspEditor_runCommandHandler);
		}

		private function populateLspServerCapabilities():void
		{
			if(!languageClient)
			{
				return;
			}
			var serverCapabilities:Object = languageClient.serverCapabilities;
			if(!serverCapabilities)
			{
				return;
			}
			var completionProvider:Object = serverCapabilities.completionProvider;
			if(completionProvider)
			{
				var completionTriggerCharacters:Array = completionProvider.triggerCharacters;
				if(!completionTriggerCharacters)
				{
					completionTriggerCharacters = [];
				}
				lspEditor.completionTriggerCharacters = completionTriggerCharacters;
			}
			var signatureHelpProvider:Object = serverCapabilities.signatureHelpProvider;
			if(signatureHelpProvider)
			{
				var signatureHelpTriggerCharacters:Array = signatureHelpProvider.triggerCharacters;
				if(!signatureHelpTriggerCharacters)
				{
					signatureHelpTriggerCharacters = [];
				}
				lspEditor.signatureHelpTriggerCharacters = signatureHelpTriggerCharacters;
			}
		}

		protected var lspEditor:LspTextEditor;

		private var _languageID:String;

		public function get languageID():String
		{
			return _languageID;
		}

		private var _project:LanguageServerProjectVO;

		public function get project():LanguageServerProjectVO
		{
			return _project;
		}

		public function get languageClient():LanguageClient
		{
			if(!_project)
			{
				return null;
			}
			return _project.languageClient;
		}

		override public function set currentFile(value:FileLocation):void
		{
			var changed:Boolean = file != value;
			if (changed)
            {
				dispatchDidCloseEvent();
			}
			super.currentFile = value;
			if(value)
			{
				lspEditor.textDocument = {uri: value.fileBridge.url};
			}
			else
			{
				lspEditor.textDocument = null;
			}
			if(changed)
			{
				dispatchDidOpenEvent();
			}
		}

		private var _savedDiagnostics:Array;

		override protected function addGlobalListeners():void
		{
			super.addGlobalListeners();
			
			dispatcher.addEventListener(SaveFileEvent.FILE_SAVED, fileSavedHandler);
			dispatcher.addEventListener(LanguageServerMenuEvent.EVENT_MENU_GO_TO_DEFINITION, menuGoToDefinitionHandler);
			dispatcher.addEventListener(LanguageServerMenuEvent.EVENT_MENU_GO_TO_TYPE_DEFINITION, menuGoToTypeDefinitionHandler);
			dispatcher.addEventListener(LanguageServerMenuEvent.EVENT_MENU_GO_TO_IMPLEMENTATION, menuGoToImplementationHandler);
			// a higher priority ensures that the language server knows about
			// all open files before we potentially makes other queries to the
			// language server
			// example: document symbols in the outline view
			dispatcher.addEventListener(ProjectEvent.LANGUAGE_SERVER_OPENED, languageServerOpenedHandler, false, 1);
			dispatcher.addEventListener(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, showDiagnosticsHandler);
		}

		override protected function removeGlobalListeners():void
		{
			super.removeGlobalListeners();
			
			dispatcher.removeEventListener(SaveFileEvent.FILE_SAVED, fileSavedHandler);
			dispatcher.removeEventListener(LanguageServerMenuEvent.EVENT_MENU_GO_TO_DEFINITION, menuGoToDefinitionHandler);
			dispatcher.removeEventListener(LanguageServerMenuEvent.EVENT_MENU_GO_TO_TYPE_DEFINITION, menuGoToTypeDefinitionHandler);
			dispatcher.removeEventListener(LanguageServerMenuEvent.EVENT_MENU_GO_TO_IMPLEMENTATION, menuGoToImplementationHandler);
			dispatcher.removeEventListener(ProjectEvent.LANGUAGE_SERVER_OPENED, languageServerOpenedHandler);
			dispatcher.removeEventListener(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, showDiagnosticsHandler);
		}
		
		override protected function initializeChildrens():void
		{
			if(!editor)
			{
				lspEditor = new LspTextEditor(null, null, readOnly);
				editor = lspEditor;
			}
			super.initializeChildrens();
		}

		protected function closeAllPopups():void
		{
			lspEditor.clearAll();
		}

		protected function dispatchDidOpenEvent():void
		{
			if(!currentFile || !_project.languageClient || loadingFile)
			{
				return;
			}

			_documentVersion++;
			_project.languageClient.didOpen({
				textDocument: {
					uri: currentFile.fileBridge.url,
					languageId: _languageID,
					version: _documentVersion,
					text: editor.text
				}
			});
		}

		protected function dispatchDidCloseEvent():void
		{
			if(!currentFile || !_project.languageClient)
			{
				return;
			}

			_project.languageClient.didClose({
				textDocument: {
					uri: currentFile.fileBridge.url
				}
			});
		}

		private var _documentVersion:int = 0;

		protected function dispatchDidChangeEvent():void
		{
			if(!currentFile || !_project.languageClient)
			{
				return;
			}

			_documentVersion++;
			_project.languageClient.didChange({
				textDocument: {
					uri: currentFile.fileBridge.url,
					version: _documentVersion
				},
				contentChanges: [
					{
						text: editor.text
					}
				]
			});
		}

		protected function lspEditor_requestCompletionHandler(event:LspTextEditorLanguageRequestEvent):void
		{
			if(!currentFile || !_project.languageClient)
			{
				return;
			}
			_project.languageClient.completion(event.params, event.callback);
		}

		protected function lspEditor_requestResolveCompletionHandler(event:LspTextEditorLanguageRequestEvent):void
		{
			if(!currentFile || !_project.languageClient)
			{
				return;
			}
			_project.languageClient.resolveCompletion(CompletionItem(event.params), event.callback);
		}

		protected function lspEditor_requestSignatureHelpHandler(event:LspTextEditorLanguageRequestEvent):void
		{
			if(!currentFile || !_project.languageClient)
			{
				return;
			}
			_project.languageClient.signatureHelp(event.params, event.callback);
		}

		protected function lspEditor_requestHoverHandler(event:LspTextEditorLanguageRequestEvent):void
		{
			if(!currentFile || !_project.languageClient)
			{
				return;
			}
			_project.languageClient.hover(event.params, event.callback);
		}

		protected function lspEditor_requestDefinitionHandler(event:LspTextEditorLanguageRequestEvent):void
		{
			if(!currentFile || !_project.languageClient)
			{
				return;
			}
			_project.languageClient.definition(event.params, event.callback);
		}

		private function lspEditor_requestCodeActionsHandler(event:LspTextEditorLanguageRequestEvent):void
		{
			if(!currentFile || !_project.languageClient)
			{
				return;
			}
			_project.languageClient.codeAction(event.params, event.callback);
		}

		protected function dispatchGotoDefinitionEvent(line:int, char:int):void
		{
			if(!currentFile || !_project.languageClient)
			{
				return;
			}

			var self:LanguageServerTextEditor = this;

			_project.languageClient.definition({
				textDocument: {
					uri: currentFile.fileBridge.url
				},
				position: new Position(line, char)
			}, function(locations:Array /* Array<Location> | Array<LocationLink> */):void {
				dispatcher.dispatchEvent(
					new LocationsEvent(LocationsEvent.EVENT_SHOW_LOCATIONS, locations));
			});
		}

		protected function dispatchGotoTypeDefinitionEvent(line:int, char:int):void
		{
			if(!currentFile || !_project.languageClient)
			{
				return;
			}

			var self:LanguageServerTextEditor = this;

			_project.languageClient.typeDefinition({
				textDocument: {
					uri: currentFile.fileBridge.url
				},
				position: new Position(line, char)
			}, function(locations:Array /* Array<Location> | Array<LocationLink> */):void {
				dispatcher.dispatchEvent(
					new LocationsEvent(LocationsEvent.EVENT_SHOW_LOCATIONS, locations));
			});
		}

		protected function dispatchGotoImplementationEvent(line:int, char:int):void
		{
			if(!currentFile || !_project.languageClient)
			{
				return;
			}

			var self:LanguageServerTextEditor = this;

			_project.languageClient.implementation({
				textDocument: {
					uri: currentFile.fileBridge.url
				},
				position: new Position(line, char)
			}, function(locations:Array /* Array<Location> | Array<LocationLink> */):void {
				dispatcher.dispatchEvent(
					new LocationsEvent(LocationsEvent.EVENT_SHOW_LOCATIONS, locations));
			});
		}

		override protected function openFileAsStringHandler(data:String):void
		{
			super.openFileAsStringHandler(data);
			dispatchDidOpenEvent();
		}

		override protected function openHandler(event:Event):void
		{
			super.openHandler(event);
			dispatchDidOpenEvent();
		}
		
		override protected function handleTextChange(event:TextEditorChangeEvent):void
		{
			super.handleTextChange(event);
			dispatchDidChangeEvent();
		}

		protected function menuGoToDefinitionHandler(event:Event):void
		{
			if(model.activeEditor != this)
			{
				return;
			}
			var startLine:int = editor.caretLineIndex;
			var startChar:int = editor.caretCharIndex;
			dispatchGotoDefinitionEvent(startLine, startChar);
		}

		protected function menuGoToTypeDefinitionHandler(event:Event):void
		{
			if(model.activeEditor != this)
			{
				return;
			}
			var startLine:int = editor.caretLineIndex;
			var startChar:int = editor.caretCharIndex;
			dispatchGotoTypeDefinitionEvent(startLine, startChar);
		}

		protected function menuGoToImplementationHandler(event:Event):void
		{
			if(model.activeEditor != this)
			{
				return;
			}
			var startLine:int = editor.caretLineIndex;
			var startChar:int = editor.caretCharIndex;
			dispatchGotoImplementationEvent(startLine, startChar);
		}

		protected function languageServerOpenedHandler(event:ProjectEvent):void
		{
			if(!currentFile || project != event.project)
			{
				return;
			}
			populateLspServerCapabilities();
			dispatchDidOpenEvent();
		}

		override protected function closeTabHandler(event:Event):void
		{
			super.closeTabHandler(event);
			
			dispatchDidCloseEvent();
		}

		protected function fileSavedHandler(event:SaveFileEvent):void
		{
			var savedTab:LanguageServerTextEditor = event.editor as LanguageServerTextEditor;
			if(!savedTab || savedTab != this)
			{
				return;
			}
			if(!currentFile || !_project.languageClient)
			{
				return;
			}

			var uri:String = currentFile.fileBridge.url;

			_project.languageClient.willSave({
				textDocument: {
					uri: uri
				}
			});
			
			_project.languageClient.didSave({
				textDocument: {
					uri: uri
				}
			});
		}

		override protected function tabSelectHandler(event:TabEvent):void
		{
			if (event.child != this)
			{
				this.closeAllPopups();
			}
			
			super.tabSelectHandler(event);
		}

		override protected function removedFromStageHandler(event:Event):void
		{
			super.removedFromStageHandler(event);
			this.closeAllPopups();
		}

		private function showDiagnosticsHandler(event:DiagnosticsEvent):void
		{
			if(!currentFile || event.uri != currentFile.fileBridge.url)
			{
				return;
			}

			lspEditor.diagnostics = event.diagnostics;
		}

		private function lspEditor_applyWorkspaceEditHandler(event:LspTextEditorLanguageActionEvent):void
		{
			var workspaceEdit:WorkspaceEdit = WorkspaceEdit(event.data);
			applyWorkspaceEdit(workspaceEdit);
		}

		private function lspEditor_openLinkHandler(event:LspTextEditorLanguageActionEvent):void
		{
			var locationLinks:Array = event.data as Array;
			if(locationLinks.length == 0)
			{
				return;
			}
			var locationLink:LocationLink = locationLinks[0];
			dispatcher.dispatchEvent(new OpenLocationEvent(OpenLocationEvent.OPEN_LOCATION, locationLink));
		}

		private function lspEditor_runCommandHandler(event:LspTextEditorLanguageActionEvent):void
		{
			var command:Command = Command(event.data);
			languageClient.executeCommand({
				command: command.command,
				arguments: command.arguments
			}, function(result:* = null):void {});
		}
	}
}