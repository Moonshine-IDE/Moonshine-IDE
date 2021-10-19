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

		private var _languageClient:LanguageClient;

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

			_project.languageClient.didOpen({
				textDocument: {
					uri: currentFile.fileBridge.url,
					languageId: _languageID,
					version: 0,
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

		protected function dispatchDidChangeEvent():void
		{
			if(!currentFile || !_project.languageClient)
			{
				return;
			}

			_project.languageClient.didChange({
				textDocument: {
					uri: currentFile.fileBridge.url,
					version: 0
				},
				contentChanges: {
					text: editor.text
				}
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