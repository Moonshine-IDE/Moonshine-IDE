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
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import actionScripts.events.ChangeEvent;
	import actionScripts.events.CodeActionsEvent;
	import actionScripts.events.CompletionItemsEvent;
	import actionScripts.events.DiagnosticsEvent;
	import actionScripts.events.GotoDefinitionEvent;
	import actionScripts.events.HoverEvent;
	import actionScripts.events.LanguageServerEvent;
	import actionScripts.events.LanguageServerMenuEvent;
	import actionScripts.events.MenuEvent;
	import actionScripts.events.ProjectEvent;
	import actionScripts.events.SaveFileEvent;
	import actionScripts.events.SignatureHelpEvent;
	import actionScripts.ui.editor.text.TextLineModel;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.ui.tabview.TabEvent;
	import actionScripts.utils.isUriInProject;

	public class LanguageServerTextEditor extends BasicTextEditor
	{
		public function LanguageServerTextEditor(languageID:String, readOnly:Boolean = false)
		{
			super(readOnly);

			this._languageID = languageID;

			editor.addEventListener(ChangeEvent.TEXT_CHANGE, onTextChange);
			editor.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			editor.addEventListener(MouseEvent.ROLL_OVER, onRollOver);
			editor.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
			editor.model.addEventListener(Event.CHANGE, editorModel_onChange);
		}

		private var _languageID:String;

		public function get languageID():String
		{
			return this._languageID;
		}

		private var _codeActionTimeoutID:int = -1;
		private var _completionIncomplete:Boolean = false;

		override protected function addGlobalListeners():void
		{
			super.addGlobalListeners();
			
			dispatcher.addEventListener(CompletionItemsEvent.EVENT_SHOW_COMPLETION_LIST, showCompletionListHandler);
			dispatcher.addEventListener(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, showDiagnosticsHandler);
			dispatcher.addEventListener(CodeActionsEvent.EVENT_SHOW_CODE_ACTIONS, showCodeActionsHandler);
			dispatcher.addEventListener(SaveFileEvent.FILE_SAVED, fileSavedHandler);
			dispatcher.addEventListener(CompletionItemsEvent.EVENT_UPDATE_RESOLVED_COMPLETION_ITEM, updateResolvedCompletionItemHandler);
			dispatcher.addEventListener(SignatureHelpEvent.EVENT_SHOW_SIGNATURE_HELP, showSignatureHelpHandler);
			dispatcher.addEventListener(LanguageServerMenuEvent.EVENT_MENU_GO_TO_DEFINITION, menuGoToDefinitionHandler);
			dispatcher.addEventListener(LanguageServerMenuEvent.EVENT_MENU_GO_TO_TYPE_DEFINITION, menuGoToTypeDefinitionHandler);
			dispatcher.addEventListener(LanguageServerMenuEvent.EVENT_MENU_GO_TO_IMPLEMENTATION, menuGoToImplementationHandler);
			dispatcher.addEventListener(ProjectEvent.LANGUAGE_SERVER_OPENED, languageServerOpenedHandler);
		}

		override protected function removeGlobalListeners():void
		{
			super.removeGlobalListeners();
			
			dispatcher.removeEventListener(CompletionItemsEvent.EVENT_SHOW_COMPLETION_LIST, showCompletionListHandler);
			dispatcher.removeEventListener(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, showDiagnosticsHandler);
			dispatcher.removeEventListener(CodeActionsEvent.EVENT_SHOW_CODE_ACTIONS, showCodeActionsHandler);
			dispatcher.removeEventListener(SaveFileEvent.FILE_SAVED, fileSavedHandler);
			dispatcher.removeEventListener(CompletionItemsEvent.EVENT_UPDATE_RESOLVED_COMPLETION_ITEM, updateResolvedCompletionItemHandler);
			dispatcher.removeEventListener(SignatureHelpEvent.EVENT_SHOW_SIGNATURE_HELP, showSignatureHelpHandler);
			dispatcher.removeEventListener(LanguageServerMenuEvent.EVENT_MENU_GO_TO_DEFINITION, menuGoToDefinitionHandler);
			dispatcher.removeEventListener(LanguageServerMenuEvent.EVENT_MENU_GO_TO_TYPE_DEFINITION, menuGoToTypeDefinitionHandler);
			dispatcher.removeEventListener(LanguageServerMenuEvent.EVENT_MENU_GO_TO_IMPLEMENTATION, menuGoToImplementationHandler);
			dispatcher.removeEventListener(ProjectEvent.LANGUAGE_SERVER_OPENED, languageServerOpenedHandler);
		}

		protected function closeAllPopups():void
		{
			editor.showSignatureHelp(null);
			editor.showHover(null);
			editor.showDefinitionLink(null, null);
		}

		protected function dispatchDidOpenEvent():void
		{
			if(!currentFile)
			{
				return;
			}
			dispatcher.dispatchEvent(new LanguageServerEvent(LanguageServerEvent.EVENT_DIDOPEN,
				currentFile.fileBridge.url,
				0, 0, 0, 0,
				editor.dataProvider, 0));
		}

		protected function dispatchDidCloseEvent():void
		{
			if(!currentFile)
			{
				return;
			}
			dispatcher.dispatchEvent(new LanguageServerEvent(LanguageServerEvent.EVENT_DIDCLOSE,
				currentFile.fileBridge.url));
		}

		protected function dispatchDidChangeEvent():void
		{
			if(!currentFile)
			{
				return;
			}
			dispatcher.dispatchEvent(new LanguageServerEvent(
				LanguageServerEvent.EVENT_DIDCHANGE,
				currentFile.fileBridge.url,
				0, 0, 0, 0,
				editor.dataProvider, 0));
		}

		protected function dispatchCompletionEvent():void
		{
			if(!currentFile)
			{
				return;
			}
			var len:Number = editor.model.caretIndex - editor.startPos;
			var startLine:int = editor.model.selectedLineIndex;
			var startChar:int = editor.startPos;
			var endLine:int = editor.model.selectedLineIndex;
			var endChar:int = editor.model.caretIndex;
			dispatcher.dispatchEvent(new LanguageServerEvent(
				LanguageServerEvent.EVENT_COMPLETION,
				currentFile.fileBridge.url,
				startChar, startLine, endChar, endLine));
		}

		protected function dispatchSignatureHelpEvent():void
		{
			if(!currentFile)
			{
				return;
			}
			var len:Number = editor.model.caretIndex - editor.startPos;
			var startLine:int = editor.model.selectedLineIndex;
			var startChar:int = editor.startPos;
			var endLine:int = editor.model.selectedLineIndex;
			var endChar:int = editor.model.caretIndex;
			dispatcher.dispatchEvent(new LanguageServerEvent(
				LanguageServerEvent.EVENT_SIGNATURE_HELP,
				currentFile.fileBridge.url,
				startChar, startLine, endChar, endLine));
		}

		protected function dispatchHoverEvent(line:int, char:int):void
		{
			if(!currentFile)
			{
				return;
			}
			dispatcher.dispatchEvent(new LanguageServerEvent(
				LanguageServerEvent.EVENT_HOVER,
				currentFile.fileBridge.url,
				char, line, char, line));
		}

		protected function dispatchDefinitionLinkEvent(line:int, char:int):void
		{
			if(!currentFile)
			{
				return;
			}
			dispatcher.dispatchEvent(new LanguageServerEvent(
				LanguageServerEvent.EVENT_DEFINITION_LINK,
				currentFile.fileBridge.url,
				char, line, char, line));
		}

		protected function dispatchGotoDefinitionEvent(line:int, char:int):void
		{
			if(!currentFile)
			{
				return;
			}
			dispatcher.dispatchEvent(new LanguageServerEvent(
				LanguageServerEvent.EVENT_GO_TO_DEFINITION,
				currentFile.fileBridge.url,
				char, line, char, line));
		}

		protected function dispatchGotoTypeDefinitionEvent(line:int, char:int):void
		{
			if(!currentFile)
			{
				return;
			}
			dispatcher.dispatchEvent(new LanguageServerEvent(
				LanguageServerEvent.EVENT_GO_TO_TYPE_DEFINITION,
				currentFile.fileBridge.url,
				char, line, char, line));
		}

		protected function dispatchGotoImplementationEvent(line:int, char:int):void
		{
			if(!currentFile)
			{
				return;
			}
			dispatcher.dispatchEvent(new LanguageServerEvent(
				LanguageServerEvent.EVENT_GO_TO_IMPLEMENTATION,
				currentFile.fileBridge.url,
				char, line, char, line));
		}

		private function dispatchCodeActionEvent():void
		{
			_codeActionTimeoutID = -1;
			if(!currentFile)
			{
				return;
			}
			var startLine:int = editor.model.getSelectionLineStart();
			var startChar:int = editor.model.getSelectionCharStart();
			if(startChar == -1)
			{
				startChar = editor.model.caretIndex;
			}
			var endLine:int = editor.model.getSelectionLineEnd();
			var endChar:int = editor.model.getSelectionCharEnd();
			dispatcher.dispatchEvent(new LanguageServerEvent(
				LanguageServerEvent.EVENT_CODE_ACTION,
				currentFile.fileBridge.url,
				startChar, startLine, endChar, endLine));
		}

		protected function getTextDocument():String
		{
			var document:String;
            var lines:Vector.<TextLineModel> = editor.model.lines;
			var textLinesCount:int = lines.length;
            if (textLinesCount > 1)
            {
				textLinesCount -= 1;
                for (var i:int = 0; i < textLinesCount; i++)
                {
                    var textLine:TextLineModel = lines[i];
                    document += textLine.text + "\n";
                }
            }

			return document;
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
			dispatcher.addEventListener(HoverEvent.EVENT_SHOW_HOVER, showHoverHandler);
			dispatcher.addEventListener(GotoDefinitionEvent.EVENT_SHOW_DEFINITION_LINK, showDefinitionLinkHandler);
		}

		private function onRollOut(event:MouseEvent):void
		{
			dispatcher.removeEventListener(HoverEvent.EVENT_SHOW_HOVER, showHoverHandler);
			dispatcher.removeEventListener(GotoDefinitionEvent.EVENT_SHOW_DEFINITION_LINK, showDefinitionLinkHandler);
			//don't call showHover(null) here. let the manager handle it.
			//because the mouse might have moved over the tooltip instead,
			//and we don't want to clear the hover in that case
			editor.showDefinitionLink(null, null);
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			var globalXY:Point = new Point(event.stageX, event.stageY);
			var charAndLine:Point = editor.getCharAndLineForXY(globalXY, true);
			if(charAndLine !== null)
			{
				if(event.ctrlKey)
				{
					dispatchDefinitionLinkEvent(charAndLine.y, charAndLine.x);
				}
				else
				{
					editor.showDefinitionLink(null, null);
					dispatchHoverEvent(charAndLine.y, charAndLine.x);
				}
			}
			else
			{
				editor.showDefinitionLink(null, null);
				editor.showHover(null);
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
			if(_codeActionTimeoutID != -1)
			{
				//we want to "debounce" this event, so reset the timer
				clearTimeout(_codeActionTimeoutID);
				_codeActionTimeoutID = -1;
			}
			_codeActionTimeoutID = setTimeout(dispatchCodeActionEvent, 250);
		}

		protected function menuGoToDefinitionHandler(event:MenuEvent):void
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

		protected function menuGoToTypeDefinitionHandler(event:MenuEvent):void
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

		protected function menuGoToImplementationHandler(event:MenuEvent):void
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
			if(!currentFile || !isUriInProject(currentFile.fileBridge.url, event.project))
			{
				return;
			}
			dispatchDidOpenEvent();
		}

		protected function showCompletionListHandler(event:CompletionItemsEvent):void
		{
			if(model.activeEditor != this || !currentFile || event.uri !== currentFile.fileBridge.url)
			{
				return;
			}
			if (event.items.length == 0)
			{
				return;
			}
			_completionIncomplete = event.incomplete;

			editor.showCompletionList(event.items);
		}

		protected function updateResolvedCompletionItemHandler(event:CompletionItemsEvent):void
		{
			if(model.activeEditor != this || !currentFile || event.uri !== currentFile.fileBridge.url)
			{
				return;
			}
			if (event.items.length == 0)
			{
				return;
			}

			editor.resolveCompletionItem(event.items[0]);
		}

		protected function showSignatureHelpHandler(event:SignatureHelpEvent):void
		{
			if(model.activeEditor != this || !currentFile || event.uri !== currentFile.fileBridge.url)
			{
				return;
			}
			editor.showSignatureHelp(event.signatureHelp);
		}

		protected function showHoverHandler(event:HoverEvent):void
		{
			if(model.activeEditor != this || !currentFile || event.uri !== currentFile.fileBridge.url)
			{
				return;
			}
			editor.showHover(event.contents);
		}

		protected function showDefinitionLinkHandler(event:GotoDefinitionEvent):void
		{
			if(model.activeEditor != this || !currentFile || event.uri !== currentFile.fileBridge.url)
			{
				return;
			}
			editor.showDefinitionLink(event.locations, event.position);
		}

		protected function showDiagnosticsHandler(event:DiagnosticsEvent):void
		{
			if(!currentFile || event.path !== currentFile.fileBridge.nativePath)
			{
				return;
			}
			editor.showDiagnostics(event.diagnostics);
		}

		protected function showCodeActionsHandler(event:CodeActionsEvent):void
		{
			if(model.activeEditor != this || !currentFile || event.uri !== currentFile.fileBridge.url)
			{
				return;
			}
			editor.showCodeActions(event.codeActions);
		}

		override protected function closeTabHandler(event:CloseTabEvent):void
		{
			var closedTab:LanguageServerTextEditor = event.tab as LanguageServerTextEditor;
			if(!closedTab || closedTab != this)
			{
				return;
			}
			dispatchDidCloseEvent();
		}

		protected function fileSavedHandler(event:SaveFileEvent):void
		{
			var savedTab:LanguageServerTextEditor = event.editor as LanguageServerTextEditor;
			if(!savedTab || savedTab != this)
			{
				return;
			}
			if(!currentFile)
			{
				return;
			}
			dispatcher.dispatchEvent(new LanguageServerEvent(LanguageServerEvent.EVENT_WILLSAVE,
				currentFile.fileBridge.url));
			
			dispatcher.dispatchEvent(new LanguageServerEvent(LanguageServerEvent.EVENT_DIDSAVE,
				currentFile.fileBridge.url));
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
	}
}