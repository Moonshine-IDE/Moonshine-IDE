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
	import actionScripts.events.ChangeEvent;
	import actionScripts.events.DiagnosticsEvent;
	import actionScripts.events.LanguageServerMenuEvent;
	import actionScripts.events.LocationsEvent;
	import actionScripts.events.MenuEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.SaveFileEvent;
	import actionScripts.languageServer.LanguageServerProjectVO;
	import actionScripts.ui.editor.text.TextLineModel;
	import actionScripts.ui.tabview.TabEvent;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import moonshine.lsp.CompletionList;
	import moonshine.lsp.Diagnostic;
	import moonshine.lsp.Hover;
	import moonshine.lsp.LanguageClient;
	import moonshine.lsp.Position;
	import moonshine.lsp.Range;
	import moonshine.lsp.SignatureHelp;
	import moonshine.lsp.utils.RangeUtil;
	import moonshine.lsp.CodeAction;
	import actionScripts.factory.FileLocation;

	public class LanguageServerTextEditor extends BasicTextEditor
	{
		public function LanguageServerTextEditor(languageID:String, project:LanguageServerProjectVO, readOnly:Boolean = false)
		{
			super(readOnly);

			_languageID = languageID;
			_project = project;

			editor.addEventListener(ChangeEvent.TEXT_CHANGE, onTextChange);
			editor.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			editor.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			editor.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			editor.model.addEventListener(Event.CHANGE, editorModel_onChange);
		}

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
			if(changed)
			{
				dispatchDidOpenEvent();
			}
		}

		private var _savedDiagnostics:Array;

		private var _codeActionTimeoutID:int = -1;
		private var _completionIncomplete:Boolean = false;
		private var _hoverTimeoutID:int = -1;
		private var _definitionTimeoutID:int = -1;
		private var _previousCharAndLine:Point;

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

		protected function closeAllPopups():void
		{
			editor.showSignatureHelp(null);
			clearHover();
			clearDefinitionLink();
		}

		protected function startOrResetCodeActionTimer():void
		{
			if(_codeActionTimeoutID != -1)
			{
				//we want to "debounce" this event, so reset the timer
				clearTimeout(_codeActionTimeoutID);
				_codeActionTimeoutID = -1;
			}
			_codeActionTimeoutID = setTimeout(dispatchCodeActionEvent, 250);
		}

		protected function startOrResetHoverTimer(line:int, char:int):void
		{
			if(_hoverTimeoutID != -1)
			{
				//we want to "debounce" this event, so reset the timer
				clearTimeout(_hoverTimeoutID);
				_hoverTimeoutID = -1;
			}
			_hoverTimeoutID = setTimeout(dispatchHoverEvent, 250, line, char)
		}

		protected function startOrResetDefinitionLinkTimer(line:int, char:int):void
		{
			if(_definitionTimeoutID != -1)
			{
				//we want to "debounce" this event, so reset the timer
				clearTimeout(_definitionTimeoutID);
				_definitionTimeoutID = -1;
			}
			_definitionTimeoutID = setTimeout(dispatchDefinitionLinkEvent, 250, line, char)
		}

		private function clearDefinitionLink():void
		{
			editor.showDefinitionLink(null, null);
			if(_definitionTimeoutID != -1)
			{
				clearTimeout(_definitionTimeoutID);
				_definitionTimeoutID = -1;
			}
		}

		private function clearHover():void
		{
			editor.showHover(null);
			if(_hoverTimeoutID != -1)
			{
				clearTimeout(_hoverTimeoutID);
				_hoverTimeoutID = -1;
			}
		}

		protected function dispatchDidOpenEvent():void
		{
			if(!currentFile || !_project.languageClient)
			{
				return;
			}

			_project.languageClient.didOpen({
				textDocument: {
					uri: currentFile.fileBridge.url,
					languageId: _languageID,
					version: 0,
					text: editor.dataProvider
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
					text: editor.dataProvider
				}
			});
		}

		protected function dispatchCompletionEvent():void
		{
			if(!currentFile || !_project.languageClient)
			{
				return;
			}

			var self:LanguageServerTextEditor = this;
			var startLine:int = editor.model.selectedLineIndex;
			var startChar:int = editor.model.caretIndex;

			_project.languageClient.completion({
				textDocument: {
					uri: currentFile.fileBridge.url
				},
				position: new Position(startLine, startChar)
			}, function(completionList:CompletionList):void {
				if(model.activeEditor != self || !currentFile)
				{
					return;
				}
				if (!completionList || completionList.items.length == 0)
				{
					_completionIncomplete = false;
					return;
				}

				_completionIncomplete = completionList.isIncomplete;
				editor.showCompletionList(completionList.items);
			});
		}

		protected function dispatchSignatureHelpEvent():void
		{
			if(!currentFile || !_project.languageClient)
			{
				return;
			}

			var self:LanguageServerTextEditor = this;
			var startLine:int = editor.model.selectedLineIndex;
			var startChar:int = editor.model.caretIndex;

			_project.languageClient.signatureHelp({
				textDocument: {
					uri: currentFile.fileBridge.url
				},
				position: new Position(startLine, startChar)
			}, function(signatureHelp:SignatureHelp):void {
				if(model.activeEditor != self || !currentFile)
				{
					return;
				}
				editor.showSignatureHelp(signatureHelp);
			});
		}

		protected function dispatchHoverEvent(line:int, char:int):void
		{
			_hoverTimeoutID = -1;
			if(!currentFile || !_project.languageClient)
			{
				return;
			}

			var self:LanguageServerTextEditor = this;

			_project.languageClient.hover({
				textDocument: {
					uri: currentFile.fileBridge.url
				},
				position: new Position(line, char)
			}, function(hover:Hover):void {
				if(model.activeEditor != self || !currentFile)
				{
					return;
				}
				editor.showHover(hover);
			});
		}

		protected function dispatchDefinitionLinkEvent(line:int, char:int):void
		{
			_definitionTimeoutID = -1;
			if(!currentFile || !_project.languageClient)
			{
				return;
			}

			var self:LanguageServerTextEditor = this;
			var position:Position = new Position(line, char);

			_project.languageClient.definition({
				textDocument: {
					uri: currentFile.fileBridge.url
				},
				position: position
			}, function(locations:Array /* Array<Location> | Array<LocationLink> */):void {
				if(model.activeEditor != self || !currentFile)
				{
					return;
				}
				editor.showDefinitionLink(locations, position);
			});
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

		private function dispatchCodeActionEvent():void
		{
			_codeActionTimeoutID = -1;
			if(!currentFile || !_project.languageClient)
			{
				return;
			}

			var self:LanguageServerTextEditor = this;
			var startLine:int = editor.model.getSelectionLineStart();
			var startChar:int = editor.model.getSelectionCharStart();
			if(startChar == -1)
			{
				startChar = editor.model.caretIndex;
			}
			var endLine:int = editor.model.getSelectionLineEnd();
			var endChar:int = editor.model.getSelectionCharEnd();

			var range:Range = new Range(new Position(startLine, startChar), new Position(endLine, endChar));

			var diagnostics:Array = [];
			if(_savedDiagnostics)
			{
				//we need to filter out diagnostics that don't apply to the
				//current selection range
				diagnostics = _savedDiagnostics.filter(function(diagnostic:Diagnostic, index:int, original:Array):Boolean
				{
					var diagnosticRange:Range = new Range(
						new Position(diagnostic.range.start.line, diagnostic.range.start.character),
						new Position(diagnostic.range.end.line, diagnostic.range.end.character));
					return RangeUtil.rangesIntersect(range, diagnosticRange);
				});
			}

			_project.languageClient.codeAction({
				textDocument: {
					uri: currentFile.fileBridge.url
				},
				range: range,
				context: {
					diagnostics: diagnostics
				}
			}, function(result:Array /* Array<CodeAction> */):void {
				if(model.activeEditor != self || !currentFile)
				{
					return;
				}
				editor.showCodeActions(Vector.<CodeAction>(result));
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

		private function onRollOver(event:MouseEvent):void
		{
			_previousCharAndLine = null;
		}

		private function onRollOut(event:MouseEvent):void
		{
			//don't call showHover(null) here. let the manager handle it.
			//because the mouse might have moved over the tooltip instead,
			//and we don't want to clear the hover in that case
			if(_hoverTimeoutID != -1)
			{
				clearTimeout(_hoverTimeoutID);
				_hoverTimeoutID = -1;
			}
			clearDefinitionLink();
		}

		private function isInsideSameWord(cl1:Point, cl2:Point):Boolean
		{
			if(!cl1 || !cl2)
			{
				return false;
			}
			var line1:Number = cl1.y;
			var line2:Number = cl2.y;
			if(line1 != line2)
			{
				//can't be the same word on different lines
				return false;
			}
			var char1:Number = cl1.x;
			var char2:Number = cl2.x;
			if(char1 == char2)
			{
				//must be the same word when the character hasn't changed
				return true;
			}
			var model:TextLineModel = editor.model.lines[line1];
			var startIndex:int = char1;
			var endIndex:int = char2;
			if(startIndex > endIndex)
			{
				startIndex = char2;
				endIndex = char1;
			}
			if((endIndex + 1) < model.text.length)
			{
				//include the later character when possible
				endIndex++;
			}
			//look for non-word characters between the two
			var substr:String = model.text.substr(startIndex, endIndex - startIndex);
			return /^\w+$/g.test(substr);
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			var globalXY:Point = new Point(event.stageX, event.stageY);
			var charAndLine:Point = editor.getCharAndLineForXY(globalXY, true);
			if(charAndLine !== null)
			{
				if(!isInsideSameWord(charAndLine, _previousCharAndLine))
				{
					clearHover();
					clearDefinitionLink();
				}
				_previousCharAndLine = charAndLine.clone();

				if(event.ctrlKey)
				{
					startOrResetDefinitionLinkTimer(charAndLine.y, charAndLine.x);
				}
				else
				{
					clearDefinitionLink();
				}
				startOrResetHoverTimer(charAndLine.y, charAndLine.x);
				
			}
			else
			{
				clearDefinitionLink();
				clearHover();
			}
		}

		private function onTextChange(event:ChangeEvent):void
		{
			var completionIncomplete:Boolean = _completionIncomplete && editor.completionActive;
			_completionIncomplete = false;
			dispatchDidChangeEvent();
			if(completionIncomplete)
			{
				dispatchCompletionEvent();
			}
		}

		private function editorModel_onChange(event:Event):void
		{
			startOrResetCodeActionTimer();
		}

		protected function menuGoToDefinitionHandler(event:Event):void
		{
			if(model.activeEditor != this)
			{
				return;
			}
			var startLine:int = editor.model.getSelectionLineStart();
			var startChar:int = editor.model.getSelectionCharStart();
			if(startChar == -1)
			{
				startChar = editor.model.caretIndex;
			}
			dispatchGotoDefinitionEvent(startLine, startChar);
		}

		protected function menuGoToTypeDefinitionHandler(event:Event):void
		{
			if(model.activeEditor != this)
			{
				return;
			}
			var startLine:int = editor.model.getSelectionLineStart();
			var startChar:int = editor.model.getSelectionCharStart();
			if(startChar == -1)
			{
				startChar = editor.model.caretIndex;
			}
			dispatchGotoTypeDefinitionEvent(startLine, startChar);
		}

		protected function menuGoToImplementationHandler(event:Event):void
		{
			if(model.activeEditor != this)
			{
				return;
			}
			var startLine:int = editor.model.getSelectionLineStart();
			var startChar:int = editor.model.getSelectionCharStart();
			if(startChar == -1)
			{
				startChar = editor.model.caretIndex;
			}
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

		override protected function addedToStageHandler(event:Event):void
		{
			super.addedToStageHandler(event);
		}

		override protected function removedFromStageHandler(event:Event):void
		{
			super.removedFromStageHandler(event);
			this.closeAllPopups();
		}

		private function showDiagnosticsHandler(event:DiagnosticsEvent):void
		{
			var uri:String = event.uri;
			if(uri != currentFile.fileBridge.url)
			{
				return;
			}

			_savedDiagnostics = event.diagnostics;
			editor.showDiagnostics(Vector.<Diagnostic>(_savedDiagnostics));
		}
	}
}