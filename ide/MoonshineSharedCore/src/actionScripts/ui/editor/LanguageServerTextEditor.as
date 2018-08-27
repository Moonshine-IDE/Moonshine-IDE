package actionScripts.ui.editor
{
	import actionScripts.ui.editor.text.TextLineModel;
	import actionScripts.events.LanguageServerEvent;
	import actionScripts.events.CompletionItemsEvent;
	import actionScripts.events.SignatureHelpEvent;
	import actionScripts.events.HoverEvent;
	import actionScripts.events.GotoDefinitionEvent;
	import actionScripts.events.DiagnosticsEvent;
	import flash.events.Event;
	import flash.geom.Point;
	import actionScripts.events.ChangeEvent;
	import flash.events.MouseEvent;
	import actionScripts.valueObjects.Location;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.events.SaveFileEvent;

	public class LanguageServerTextEditor extends BasicTextEditor
	{
		public function LanguageServerTextEditor(languageID:String)
		{
			super();

			this._languageID = languageID;

			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
			
			editor.addEventListener(ChangeEvent.TEXT_CHANGE, onTextChange);
			editor.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			editor.addEventListener(MouseEvent.ROLL_OUT, onRollOut);
		}

		private var _languageID:String;

		public function get languageID():String
		{
			return this._languageID;
		}

		protected function addGlobalListeners():void
		{
			dispatcher.addEventListener(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, showDiagnosticsHandler);
			dispatcher.addEventListener(CloseTabEvent.EVENT_CLOSE_TAB, closeTabHandler);
			dispatcher.addEventListener(SaveFileEvent.FILE_SAVED, fileSavedHandler);
		}

		protected function removeGlobalListeners():void
		{
			dispatcher.removeEventListener(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS, showDiagnosticsHandler);
			dispatcher.removeEventListener(CloseTabEvent.EVENT_CLOSE_TAB, closeTabHandler);
			dispatcher.removeEventListener(SaveFileEvent.FILE_SAVED, fileSavedHandler);
		}

		protected function dispatchCompletionEvent():void
		{
			dispatcher.addEventListener(CompletionItemsEvent.EVENT_SHOW_COMPLETION_LIST,showCompletionListHandler);

			var document:String = getTextDocument();
			var len:Number = editor.model.caretIndex - editor.startPos;
			var startLine:int = editor.model.selectedLineIndex;
			var startChar:int = editor.startPos;
			var endLine:int = editor.model.selectedLineIndex;
			var endChar:int = editor.model.caretIndex;
			dispatcher.dispatchEvent(new LanguageServerEvent(
				LanguageServerEvent.EVENT_COMPLETION,
				startChar, startLine, endChar,endLine,
				document, len, 1));
		}

		protected function dispatchSignatureHelpEvent():void
		{
			dispatcher.addEventListener(SignatureHelpEvent.EVENT_SHOW_SIGNATURE_HELP, showSignatureHelpHandler);

			var document:String = getTextDocument();			
			var len:Number = editor.model.caretIndex - editor.startPos;
			var startLine:int = editor.model.selectedLineIndex;
			var startChar:int = editor.startPos;
			var endLine:int = editor.model.selectedLineIndex;
			var endChar:int = editor.model.caretIndex;
			dispatcher.dispatchEvent(new LanguageServerEvent(
				LanguageServerEvent.EVENT_SIGNATURE_HELP,
				startChar, startLine, endChar,endLine,
				document, len, 1));
		}

		protected function dispatchHoverEvent(charAndLine:Point):void
		{
			dispatcher.addEventListener(HoverEvent.EVENT_SHOW_HOVER, showHoverHandler);

			var document:String = getTextDocument();
			var line:int = charAndLine.y;
			var char:int = charAndLine.x;
			dispatcher.dispatchEvent(new LanguageServerEvent(
				LanguageServerEvent.EVENT_HOVER,
				char, line, char, line,
				document, 0, 1));
		}

		protected function dispatchGotoDefinitionEvent(charAndLine:Point):void
		{
			dispatcher.addEventListener(GotoDefinitionEvent.EVENT_SHOW_DEFINITION_LINK, showDefinitionLinkHandler);

			var document:String = getTextDocument();
			var line:int = charAndLine.y;
			var char:int = charAndLine.x;
			dispatcher.dispatchEvent(new LanguageServerEvent(
				LanguageServerEvent.EVENT_GOTO_DEFINITION,
				char, line, char, line,
				document, 0, 1));
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

		override protected function openHandler(event:Event):void
		{
			super.openHandler(event);
			dispatcher.dispatchEvent(new LanguageServerEvent(LanguageServerEvent.EVENT_DIDOPEN,
				0, 0, 0, 0, editor.dataProvider, 0, 0, currentFile.fileBridge.url));
		}
		
		private function onMouseMove(event:MouseEvent):void
		{
			var globalXY:Point = new Point(event.stageX, event.stageY);
			var charAndLine:Point = editor.getCharAndLineForXY(globalXY, true);
			if(charAndLine !== null)
			{
				if(event.ctrlKey)
				{
					dispatchGotoDefinitionEvent(charAndLine);
				}
				else
				{
					editor.showDefinitionLink(new <Location>[], null);
					dispatchHoverEvent(charAndLine);
				}
			}
			else
			{
				editor.showDefinitionLink(new <Location>[], null);
				editor.showHover(new <String>[]);
			}
		}
		
		private function onRollOut(event:MouseEvent):void
		{
			dispatcher.removeEventListener(HoverEvent.EVENT_SHOW_HOVER, showHoverHandler);
		}

		private function onTextChange(event:ChangeEvent):void
		{
			dispatcher.dispatchEvent(new LanguageServerEvent(
				LanguageServerEvent.EVENT_DIDCHANGE, 0, 0, 0, 0, editor.dataProvider, 0, 0, currentFile.fileBridge.url));
		}

		protected function showCompletionListHandler(event:CompletionItemsEvent):void
		{
            dispatcher.removeEventListener(CompletionItemsEvent.EVENT_SHOW_COMPLETION_LIST, showCompletionListHandler);
			if (event.items.length == 0)
			{
				return;
			}

			editor.showCompletionList(event.items);
		}

		protected function showSignatureHelpHandler(event:SignatureHelpEvent):void
		{
			dispatcher.removeEventListener(SignatureHelpEvent.EVENT_SHOW_SIGNATURE_HELP, showSignatureHelpHandler);
			editor.showSignatureHelp(event.signatureHelp);
		}

		protected function showHoverHandler(event:HoverEvent):void
		{
			dispatcher.removeEventListener(HoverEvent.EVENT_SHOW_HOVER, showHoverHandler);
			editor.showHover(event.contents);
		}

		protected function showDefinitionLinkHandler(event:GotoDefinitionEvent):void
		{
			dispatcher.removeEventListener(GotoDefinitionEvent.EVENT_SHOW_DEFINITION_LINK, showDefinitionLinkHandler);
			editor.showDefinitionLink(event.locations, event.position);
		}

		protected function showDiagnosticsHandler(event:DiagnosticsEvent):void
		{
			if(event.path !== currentFile.fileBridge.nativePath)
			{
				return;
			}
			editor.showDiagnostics(event.diagnostics);
		}

		protected function closeTabHandler(event:CloseTabEvent):void
		{
			var closedTab:LanguageServerTextEditor = event.tab as LanguageServerTextEditor;
			if(!closedTab || closedTab != this)
			{
				return;
			}
			
			dispatcher.dispatchEvent(new LanguageServerEvent(LanguageServerEvent.EVENT_DIDCLOSE,
				0, 0, 0, 0, null, 0, 0, currentFile.fileBridge.url));
		}

		protected function fileSavedHandler(event:SaveFileEvent):void
		{
			var savedTab:LanguageServerTextEditor = event.editor as LanguageServerTextEditor;
			if(!savedTab || savedTab != this)
			{
				return;
			}
			
			dispatcher.dispatchEvent(new LanguageServerEvent(LanguageServerEvent.EVENT_WILLSAVE,
				0, 0, 0, 0, null, 0, 0, currentFile.fileBridge.url));
			
			dispatcher.dispatchEvent(new LanguageServerEvent(LanguageServerEvent.EVENT_DIDSAVE,
				0, 0, 0, 0, null, 0, 0, currentFile.fileBridge.url));
		}

		private function addedToStageHandler(event:Event):void
		{
			this.addGlobalListeners();
		}

		private function removedFromStageHandler(event:Event):void
		{
			this.removeGlobalListeners();
		}
	}
}