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
	import actionScripts.ui.editor.text.change.TextChangeInsert;
	import actionScripts.ui.editor.text.change.TextChangeMulti;

	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.ui.Keyboard;

	import mx.utils.StringUtil;

	public class GroovyTextEditor extends LanguageServerTextEditor
	{
		public static const LANGUAGE_ID_GROOVY:String = "groovy";
		
		private var dispatchCompletionPending:Boolean;
		private var dispatchSignatureHelpPending:Boolean;
		private var mouseOverForHover:Boolean = false;

		public function GroovyTextEditor(readOnly:Boolean = false)
		{
			super(LANGUAGE_ID_GROOVY, readOnly);
			editor.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			editor.addEventListener(TextEvent.TEXT_INPUT, onTextInput);
		}

		private function onTextInput(event:TextEvent):void
		{
			if(dispatchCompletionPending)
			{
				dispatchCompletionPending = false;
				dispatchCompletionEvent();
			}
			if(dispatchSignatureHelpPending)
			{
				dispatchSignatureHelpPending = false;
				dispatchSignatureHelpEvent();
			}
		}

		private function onKeyDown(event:KeyboardEvent):void
		{
			var fromCharCode:String = String.fromCharCode(event.charCode);
			var ctrlSpace:Boolean = event.keyCode == Keyboard.SPACE && event.ctrlKey;
			var memberAccess:Boolean = fromCharCode == ".";
			var enterKey:Boolean = event.keyCode == 13;
			
			if (ctrlSpace || memberAccess)
			{
				if(!ctrlSpace)
				{
					//wait for the character to be input
					dispatchCompletionPending = true;
					return;
				}
				//don't type the space when user presses Ctrl+Space
				event.preventDefault();
				dispatchCompletionPending = false;
				dispatchCompletionEvent();
			}

			var parenOpen:Boolean = fromCharCode == "(";
			var comma:Boolean = fromCharCode == ",";
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

            var minusOneSelectedLineIndex:int = editor.model.selectedLineIndex - 1;
			var plusOneSelectedLineIndex:int = editor.model.selectedLineIndex + 1;
			
			if (enterKey)
			{
				var isCurlybracesOpened:Boolean;
				var isQuotesOpened:Boolean;
				var lineText:String = StringUtil.trim(editor.model.lines[minusOneSelectedLineIndex].text);
				if (lineText.charAt(lineText.length-1) == "{" && !editor.model.lines[minusOneSelectedLineIndex].isQuoteTextOpen)
				{
					isCurlybracesOpened = true;
                }
				else if (editor.model.lines[minusOneSelectedLineIndex].isQuoteTextOpen)
				{
					isQuotesOpened = true;
                }
				
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
						var newCaretPos:int;
						var editorHasNextLine:Boolean;
						var indent:String = "";
						if (editor.model.selectedLineIndex < (editor.model.lines.length - 1))
						{
                            var regExp:RegExp = /^([ \t]*)\w/gm;
							editorHasNextLine = true;
                            var matches:Array = regExp.exec(editor.model.lines[plusOneSelectedLineIndex].text);
							if (!matches) regExp.exec(editor.model.lines[minusOneSelectedLineIndex].text);
							if (matches) 
							{
								indent = matches[1];
							}
						}
						
						if (!matches) newCaretPos = editor.model.caretIndex;

						editor.setCompletionData(editor.model.caretIndex, editor.model.caretIndex, '\n');
						editor.model.selectedLineIndex--;
						var curlyBraceChange:TextChangeMulti = new TextChangeMulti(
							new TextChangeInsert(
								editorHasNextLine ? plusOneSelectedLineIndex : editor.model.selectedLineIndex,
								newCaretPos,
								new <String>[indent + "}"]),
							new TextChangeInsert(
								editor.model.selectedLineIndex,
								editor.model.caretIndex,
								new <String>["\t"])
						);
						editor.dispatchEvent(new ChangeEvent(ChangeEvent.TEXT_CHANGE, curlyBraceChange));
					}
				}
				
				// for quotes
				if (isQuotesOpened)
				{
					var quotesChange:TextChangeMulti = new TextChangeMulti(
						new TextChangeInsert(
							minusOneSelectedLineIndex,
							editor.model.lines[minusOneSelectedLineIndex].text.length,
							new <String>[editor.model.lines[minusOneSelectedLineIndex].lastQuoteText]),
						new TextChangeInsert(
							editor.model.selectedLineIndex,
							editor.model.caretIndex,
							new <String>["+ " + editor.model.lines[minusOneSelectedLineIndex].lastQuoteText])
					);
					editor.dispatchEvent(new ChangeEvent(ChangeEvent.TEXT_CHANGE, quotesChange));
				}
			}
		}
	}
}