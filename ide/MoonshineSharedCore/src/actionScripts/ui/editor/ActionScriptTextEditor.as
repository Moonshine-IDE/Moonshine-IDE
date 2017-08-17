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
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import mx.utils.StringUtil;
	
	import actionScripts.events.ChangeEvent;
	import actionScripts.events.CompletionItemsEvent;
	import actionScripts.events.DiagnosticsEvent;
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.GotoDefinitionEvent;
	import actionScripts.events.HoverEvent;
	import actionScripts.events.SignatureHelpEvent;
	import actionScripts.events.TypeAheadEvent;
	import actionScripts.ui.editor.text.TextLineModel;
	import actionScripts.ui.editor.text.change.TextChangeInsert;
	import actionScripts.valueObjects.Diagnostic;
	import actionScripts.valueObjects.Location;

	public class ActionScriptTextEditor extends BasicTextEditor
	{
		private var dispatchTypeAheadPending:Boolean;
		private var dispatchSignatureHelpPending:Boolean;

		public function ActionScriptTextEditor()
		{
			super();
			editor.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			editor.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			editor.addEventListener(TextEvent.TEXT_INPUT, onTextInput);
			editor.addEventListener(ChangeEvent.TEXT_CHANGE, onTextChange);
			GlobalEventDispatcher.getInstance().addEventListener(DiagnosticsEvent.EVENT_SHOW_DIAGNOSTICS,showDiagnosticsHandler);
		}

		private function dispatchTypeAheadEvent():void
		{
			var document:String = "";
			var lines:Vector.<TextLineModel> = editor.model.lines;
			if (lines.length > 1)
			{
				for (var i:int = 0; i < lines.length-1; i++)
				{
					var m:TextLineModel = lines[i];
					document+=m.text+"\n";
				}
			}
			var len:Number = editor.model.caretIndex - editor.startPos;
			var startLine:int = editor.model.selectedLineIndex;
			var startChar:int = editor.startPos;
			var endLine:int = editor.model.selectedLineIndex;
			var endChar:int = editor.model.caretIndex;
			GlobalEventDispatcher.getInstance().dispatchEvent(new TypeAheadEvent(
				TypeAheadEvent.EVENT_TYPEAHEAD,
				startChar, startLine, endChar,endLine,
				document, len, 1));
			GlobalEventDispatcher.getInstance().addEventListener(CompletionItemsEvent.EVENT_SHOW_COMPLETION_LIST,showCompletionListHandler);
		}

		private function dispatchSignatureHelpEvent():void
		{
			var document:String = "";
			var lines:Vector.<TextLineModel> = editor.model.lines;
			if (lines.length > 1)
			{
				for (var i:int = 0; i < lines.length-1; i++)
				{
					var m:TextLineModel = lines[i];
					document+=m.text+"\n";
				}
			}
			var len:Number = editor.model.caretIndex - editor.startPos;
			var startLine:int = editor.model.selectedLineIndex;
			var startChar:int = editor.startPos;
			var endLine:int = editor.model.selectedLineIndex;
			var endChar:int = editor.model.caretIndex;
			GlobalEventDispatcher.getInstance().dispatchEvent(new TypeAheadEvent(
				TypeAheadEvent.EVENT_SIGNATURE_HELP,
				startChar, startLine, endChar,endLine,
				document, len, 1));
			GlobalEventDispatcher.getInstance().addEventListener(SignatureHelpEvent.EVENT_SHOW_SIGNATURE_HELP, showSignatureHelpHandler);
		}

		private function dispatchHoverEvent(charAndLine:Point):void
		{
			var document:String = "";
			var lines:Vector.<TextLineModel> = editor.model.lines;
			if (lines.length > 1)
			{
				for (var i:int = 0; i < lines.length-1; i++)
				{
					var m:TextLineModel = lines[i];
					document+=m.text+"\n";
				}
			}
			var line:int = charAndLine.y;
			var char:int = charAndLine.x;
			GlobalEventDispatcher.getInstance().dispatchEvent(new TypeAheadEvent(
				TypeAheadEvent.EVENT_HOVER,
				char, line, char, line,
				document, 0, 1));
			GlobalEventDispatcher.getInstance().addEventListener(HoverEvent.EVENT_SHOW_HOVER, showHoverHandler);
		}

		private function dispatchGotoDefinitionEvent(charAndLine:Point):void
		{
			var document:String = "";
			var lines:Vector.<TextLineModel> = editor.model.lines;
			if (lines.length > 1)
			{
				for (var i:int = 0; i < lines.length-1; i++)
				{
					var m:TextLineModel = lines[i];
					document+=m.text+"\n";
				}
			}
			var line:int = charAndLine.y;
			var char:int = charAndLine.x;
			GlobalEventDispatcher.getInstance().dispatchEvent(new TypeAheadEvent(
				TypeAheadEvent.EVENT_GOTO_DEFINITION,
				char, line, char, line,
				document, 0, 1));
			GlobalEventDispatcher.getInstance().addEventListener(GotoDefinitionEvent.EVENT_SHOW_DEFINITION_LINK, showDefinitionLinkHandler);
		}

		private function onTextInput(event:TextEvent):void
		{
			if(dispatchTypeAheadPending)
			{
				dispatchTypeAheadPending = false;
				dispatchTypeAheadEvent();
			}
			if(dispatchSignatureHelpPending)
			{
				dispatchSignatureHelpPending = false;
				dispatchSignatureHelpEvent();
			}
		}

		override protected function openHandler(event:Event):void
		{
			super.openHandler(event);
			GlobalEventDispatcher.getInstance().dispatchEvent(new TypeAheadEvent(TypeAheadEvent.EVENT_DIDOPEN,
				0, 0, 0, 0, editor.dataProvider, 0, 0, currentFile.fileBridge.url));
		}

		private function onTextChange(event:ChangeEvent):void
		{
			GlobalEventDispatcher.getInstance().dispatchEvent(new TypeAheadEvent(
				TypeAheadEvent.EVENT_DIDCHANGE, 0, 0, 0, 0, editor.dataProvider));
		}

		private function onKeyDown(event:KeyboardEvent):void
		{
			var ctrlSpace:Boolean = String.fromCharCode(event.keyCode) == " " && event.ctrlKey;
			var memberAccess:Boolean = String.fromCharCode(event.charCode) == ".";
			var typeAnnotation:Boolean = String.fromCharCode(event.charCode) == ":";
			var space:Boolean = String.fromCharCode(event.charCode) == " ";
			var openTag:Boolean = String.fromCharCode(event.charCode) == "<";
			/*var openingBracket:Boolean = String.fromCharCode(event.charCode) == "(";
			var openingSingleQuote:Boolean = String.fromCharCode(event.charCode) == "'";
			var openingDoubleQuote:Boolean = String.fromCharCode(event.charCode) == '"';*/
			var enterKey:Boolean = event.keyCode == 13;
			
			if (ctrlSpace || memberAccess || typeAnnotation || space || openTag)
			{
				if(!ctrlSpace)
				{
					//wait for the character to be input
					dispatchTypeAheadPending = true;
					return;
				}
				//don't type the space when user presses Ctrl+Space
				event.preventDefault();
				dispatchTypeAheadPending = false;
				dispatchTypeAheadEvent();
			}

			var parenOpen:Boolean = String.fromCharCode(event.charCode) == "(";
			var comma:Boolean = String.fromCharCode(event.charCode) == ",";
			var activeAndBackspace:Boolean = editor.signatureHelpActive && event.keyCode === Keyboard.BACKSPACE;
			if (parenOpen || comma)
			{
				dispatchSignatureHelpPending = true;
			}
			else if(activeAndBackspace)
			{
				dispatchSignatureHelpPending = false;
				dispatchSignatureHelpEvent();
			}
			
			var change:TextChangeInsert;
			/*if (openingBracket) 
			{
				event.preventDefault();
				change = new TextChangeInsert(
					editor.model.selectedLineIndex,
					editor.model.caretIndex,
					Vector.<String>([")"])
				);
				editor.setCompletionData(editor.model.caretIndex, editor.model.caretIndex, "(", change);
			}
			else if (openingSingleQuote) 
			{
				event.preventDefault();
				change = new TextChangeInsert(
						editor.model.selectedLineIndex,
						editor.model.caretIndex,
						Vector.<String>(["'"])
					);
				editor.setCompletionData(editor.model.caretIndex, editor.model.caretIndex, "'", change);
			}
			else if (openingDoubleQuote) 
			{
				event.preventDefault();
				change = new TextChangeInsert(
					editor.model.selectedLineIndex,
					editor.model.caretIndex,
					Vector.<String>(['"'])
				);
				editor.setCompletionData(editor.model.caretIndex, editor.model.caretIndex, '"', change);
			}
			else */if (enterKey) 
			{
				var isCurlybracesOpened:Boolean;
				var isQuotesOpened:Boolean;
				var lineText:String = StringUtil.trim(editor.model.lines[editor.model.selectedLineIndex - 1].text);
				if (lineText.charAt(lineText.length-1) == "{" && !editor.model.lines[editor.model.selectedLineIndex - 1].isQuoteTextOpen) isCurlybracesOpened = true;
				else if (editor.model.lines[editor.model.selectedLineIndex - 1].isQuoteTextOpen) isQuotesOpened = true;
				
				// for curly braces	
				if (isCurlybracesOpened)
				{
					// continue to next phase if only found an opened and non-closed
					// curly braces
					var openCount:int = text.match(/{/g).length;
					var closeCount:int = text.match(/}/g).length;
					if (openCount > closeCount)
					{
						//try to use the same indent as whatever follows
						var regExp:RegExp = /^([ \t]*)\w/gm;
						var matches:Array = null;
						var newCaretPos:int;
						var editorHasNextLine:Boolean;
						var indent:String = "";
						if (editor.model.selectedLineIndex < (editor.model.lines.length - 1))
						{
							editorHasNextLine = true;
							matches = regExp.exec(editor.model.lines[editor.model.selectedLineIndex+1].text);
							if (!matches) regExp.exec(editor.model.lines[editor.model.selectedLineIndex-1].text); 
							if (matches) 
							{
								indent = matches[1];
							}
						}
						
						if (!matches) newCaretPos = editor.model.caretIndex;
						
						editor.setCompletionData(editor.model.caretIndex, editor.model.caretIndex, '\n');
						editor.model.selectedLineIndex --;
						change = new TextChangeInsert(
							editorHasNextLine ? editor.model.selectedLineIndex+1 : editor.model.selectedLineIndex,
							newCaretPos,
							Vector.<String>([indent+"}"])
						);
						editor.setCompletionData(editor.model.caretIndex, editor.model.caretIndex, '\t', change);
					}
				}
				
				// for quotes
				if (isQuotesOpened)
				{
					change = new TextChangeInsert(
						editor.model.selectedLineIndex-1,
						editor.model.lines[editor.model.selectedLineIndex-1].text.length,
						Vector.<String>([editor.model.lines[editor.model.selectedLineIndex-1].lastQuoteText])
					);
					editor.setCompletionData(editor.model.caretIndex, editor.model.caretIndex, '+ '+ editor.model.lines[editor.model.selectedLineIndex-1].lastQuoteText, change);
				}
			}
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

		private function showCompletionListHandler(event:CompletionItemsEvent):void
		{
			GlobalEventDispatcher.getInstance().removeEventListener(CompletionItemsEvent.EVENT_SHOW_COMPLETION_LIST, showCompletionListHandler);
			editor.showCompletionList(event.items);
		}

		private function showSignatureHelpHandler(event:SignatureHelpEvent):void
		{
			GlobalEventDispatcher.getInstance().removeEventListener(SignatureHelpEvent.EVENT_SHOW_SIGNATURE_HELP, showSignatureHelpHandler);
			editor.showSignatureHelp(event.signatureHelp);
		}

		private function showHoverHandler(event:HoverEvent):void
		{
			GlobalEventDispatcher.getInstance().removeEventListener(HoverEvent.EVENT_SHOW_HOVER, showHoverHandler);
			editor.showHover(event.contents);
		}

		private function showDefinitionLinkHandler(event:GotoDefinitionEvent):void
		{
			GlobalEventDispatcher.getInstance().removeEventListener(GotoDefinitionEvent.EVENT_SHOW_DEFINITION_LINK, showDefinitionLinkHandler);
			editor.showDefinitionLink(event.locations, event.position);
		}

		private function showDiagnosticsHandler(event:DiagnosticsEvent):void
		{
			if(event.path !== currentFile.fileBridge.nativePath)
			{
				return;
			}
			editor.showDiagnostics(event.diagnostics);
		}
	}
}
