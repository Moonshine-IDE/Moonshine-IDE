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
package actionScripts.ui.editor.text
{
	import actionScripts.events.ChangeEvent;
	import actionScripts.locator.IDEModel;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.editor.text.change.TextChangeBase;
	import actionScripts.ui.editor.text.change.TextChangeInsert;
	import actionScripts.ui.editor.text.change.TextChangeMulti;
	import actionScripts.ui.editor.text.change.TextChangeRemove;
	import actionScripts.utils.TextUtil;
	import actionScripts.valueObjects.Settings;

	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;

	public class EditManager extends EventDispatcher
	{
		private var editor:TextEditor;
		private var model:TextEditorModel;
		private var cm:ContextMenu;
		private var toCopy:String="";
		private var deleteItem:ContextMenuItem;
		private var saveItem:ContextMenuItem;
		
		public function EditManager(editor:TextEditor, model:TextEditorModel, readOnly:Boolean)
		{
			this.editor = editor;
			this.model = model;
			
			if (readOnly)
			{
				editor.addEventListener(KeyboardEvent.KEY_DOWN, readonlyKeyDown);
			}
			else
			{
				editor.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
				editor.addEventListener(TextEvent.TEXT_INPUT, handleTextInput);
				editor.addEventListener(ChangeEvent.TEXT_CHANGE, handleChange, false, 100);
			}
			
			//create a Context Menu for Editor
			cm = new ContextMenu();
			this.editor.addEventListener(Event.COPY,contextMenuHandler);
			this.editor.addEventListener(Event.CUT,contextMenuHandler);
			this.editor.addEventListener(Event.PASTE,contextMenuHandler);
			this.editor.addEventListener(Event.CLEAR,contextMenuHandler);
			cm.addEventListener(ContextMenuEvent.MENU_SELECT,menuActivateHandler);
		    saveItem = new ContextMenuItem('Save',false,true,true);
			saveItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,customItemHandler);
			cm.customItems.push(saveItem);
			cm.clipboardMenu = true;
			this.editor.contextMenu = cm;
		}
		
		//Context menu Handler for enable clipboard Items
		private function menuActivateHandler(e:Event):void{
			
			if(this.editor.getSelection().length>0  )
			{
				cm.clipboardItems.copy = true;
				cm.clipboardItems.cut = true;
				cm.clipboardItems.paste = true;
				cm.clipboardItems.clear = true;
			}
			else if(toCopy.length >0)
			{
				cm.clipboardItems.copy = false;
				cm.clipboardItems.cut = false;
				cm.clipboardItems.paste = true;
				cm.clipboardItems.clear = false;
			}
			else
			{
				cm.clipboardItems.copy = false;
				cm.clipboardItems.cut = false;
				cm.clipboardItems.paste = false;
				cm.clipboardItems.clear = false;
			}
		}
		
		//handler for clipboardItem
		private function contextMenuHandler(e:Event):void{
			if(e.type== "copy")
			{
				handleCopy(e);
				e.preventDefault(); 
			}
			if(e.type == "paste")
			{
				handlePaste(e);
				e.preventDefault();
			}
			if(e.type == "cut")
			{
				handleCut(e);
				e.preventDefault();
			}
			if(e.type == "clear")
			{
				removeAtCursor(true, true);
			}
			
		}
		//Handler for Custom menu item
		private function customItemHandler(e:Event):void{
			if(e.target.caption == "Save")
			{
				var IDEmodel:IDEModel = IDEModel.getInstance();
				var editor:IContentWindow = IDEmodel.activeEditor as IContentWindow;
				
				editor.save();
			}
		}
		private function readonlyKeyDown(event:KeyboardEvent):void
		{
			// Only allow copy
			if (event.keyCode == 0x43) // C
			{
				handleCopy(event);
			}
		}
		
		private function handleKeyDown(event:KeyboardEvent):void
		{
			switch (event.keyCode)
			{
				case Keyboard.ENTER:
				{
					insert("\n");
					break;
				}
				case Keyboard.BACKSPACE:
				{
					removeAtCursor(false, event[Settings.keyboard.wordModifierKey]);
					break;
				}
				case Keyboard.DELETE:
				{
					removeAtCursor(true, event[Settings.keyboard.wordModifierKey]);
					break;
				}
				case Keyboard.TAB:
				{
					indent(event.shiftKey);
					event.preventDefault();
					break;
				}
				case 0x43:		// C		
				{		
					if (event[Settings.keyboard.copyModifierKey] && !event.altKey) 
					{	
						handleCopy(event);
						event.preventDefault(); 
					}		
					break;		
				}		
				case 0x56:		// V		
				{		
					if (event[Settings.keyboard.copyModifierKey] && !event.altKey)
					{
						handlePaste(event);
						event.preventDefault();
					}
					break;		
				}		
				case 0x58:		// X		
				{		
					if (event[Settings.keyboard.copyModifierKey] && !event.altKey)
					{
						handleCut(event);
						event.preventDefault();
					} 
					break;		
				}
			}
			// Prevent COMMAND key combinations from ever triggering text input
			// CHECK COMMAND KEY VALUE FOR MAC
			if (event.keyCode == 25) event.preventDefault();
		}

		public function setCompletionData(start:int, end:int, s:String, importChange:TextChangeInsert = null):void
		{
			var lineIndex:int = model.selectedLineIndex;
			if(importChange)
			{
				lineIndex += (importChange.textLines.length - 1);
			}

			var change:TextChangeBase = new TextChangeInsert(
				lineIndex,
				start,
				Vector.<String>(s.replace(/\r\n?/g, "\n").split("\n"))
			);

			if (start < end) {
				change = new TextChangeMulti(
					new TextChangeRemove(lineIndex, start, lineIndex, end),
					change
				);
			}

			if(importChange)
			{
				change = new TextChangeMulti(
					importChange,
					change
				);
			}

			dispatchChange(change);
		}

		private function handleTextInput(event:TextEvent):void
		{
			// Insert text only if it contains non-control characters (via http://www.fileformat.info/info/unicode/category/Cc/list.htm)
			if (/[^\x00-\x1F\x7F\x80-\x9F]/.test(event.text))
			{
				insert(event.text);
			}
		}

		private function insert(s:String):void
		{
			var change:TextChangeBase;
			var line:int = model.selectedLineIndex;
			var char:int = model.caretIndex;

			if (model.hasSelection)
			{
				if (model.hasMultilineSelection)
				{
					if (line > model.selectionStartLineIndex)
					{
						line = model.selectionStartLineIndex;
						char = model.selectionStartCharIndex;
					}
				}
				else
				{
					char = Math.min(char, model.selectionStartCharIndex);
				}
			}

			change = new TextChangeInsert(
				line,
				char,
				Vector.<String>(s.replace(/\r\n?/g, "\n").split("\n"))
			);

			if (model.hasSelection) {
				change = new TextChangeMulti(
					removeSelection(),
					change
				);
			}

			dispatchChange(change);
		}
		
		private function removeAtCursor(afterCaret:Boolean=false, word:Boolean=false):void
		{
			var change:TextChangeRemove;
			
			if (model.hasSelection) {
				change = removeSelection();
			} else {
				var startLine:int = model.selectedLineIndex;
				var endLine:int = model.selectedLineIndex;
				var startChar:int = model.caretIndex;
				var endChar:int = model.caretIndex;
				
				// Backspace remove line & append to line above it
				if (startChar == 0 && !afterCaret)
				{
					// Can't remove first line with backspace
					if (startLine == 0) return;
					
					startLine--;
					startChar = model.lines[startLine].text.length;
					endChar = 0;
				}
				// Delete remove linebreak & append to line below it
				else if (startChar == model.lines[startLine].text.length && afterCaret)
				{
					if (startLine == model.lines.length-1) return;
					
					endLine++;
					startChar = model.lines[startLine].text.length;
					endChar = 0;
				}
				else if (afterCaret) // Delete
				{
					endChar += word ? TextUtil.wordBoundaryForward(model.lines[startLine].text.slice(startChar)) : 1;
				} 
				else // Backspace
				{
					startChar -= word ? TextUtil.wordBoundaryBackward(model.lines[startLine].text.slice(0, endChar)) : 1;
				}
				
				change = new TextChangeRemove(
					startLine,
					startChar,
					endLine,
					endChar
				);
			}

			dispatchChange(change);
		}
		
		private function removeSelection():TextChangeRemove
		{
			var startChar:int, endChar:int, startLine:int, endLine:int;
			
			if (model.hasMultilineSelection)
			{
				if (model.selectionStartLineIndex < model.selectedLineIndex)
				{
					startLine	= model.selectionStartLineIndex;
					endLine		= model.selectedLineIndex;
					startChar	= model.selectionStartCharIndex;
					endChar		= model.caretIndex;
				}
				else
				{
					startLine	= model.selectedLineIndex;
					endLine		= model.selectionStartLineIndex;
					startChar	= model.caretIndex;
					endChar		= model.selectionStartCharIndex;
				}
			}
			else
			{
				startLine	= model.selectedLineIndex;
				endLine		= startLine;
				startChar	= Math.min(model.selectionStartCharIndex, model.caretIndex);
				endChar		= Math.max(model.selectionStartCharIndex, model.caretIndex);
			}
			
			return new TextChangeRemove(
				startLine,
				startChar,
				endLine,
				endChar
			);
		}
		
		private function indent(decrease:Boolean = false):void
		{
			if (model.hasMultilineSelection)
			{
				var changes:Vector.<TextChangeBase> = new Vector.<TextChangeBase>();
				var startLine:int;
				var endLine:int;
				var startChar:int;
				var endChar:int;
				
				if (model.selectionStartLineIndex < model.selectedLineIndex)
				{
					startLine = model.selectionStartLineIndex;
					endLine = model.selectedLineIndex;
					startChar = model.selectionStartCharIndex;
					endChar = model.caretIndex;
				}
				else
				{
					startLine = model.selectedLineIndex;
					endLine = model.selectionStartLineIndex;
					startChar = model.caretIndex;
					endChar = model.selectionStartCharIndex;
				}
				
				if (startChar == model.lines[startLine].text.length) startLine++;
				if (endChar == 0) endLine--;
				
				for (var line:int = startLine; line <= endLine; line++)
				{
					if (decrease)
					{
						if (model.lines[line].text.charAt(0) == "\t")
						{
							changes.push(new TextChangeRemove(line, 0, line, 1));
						}
					}
					else
					{
						changes.push(new TextChangeInsert(line, 0, Vector.<String>(["\t"])));
					}
				}
				
				if (changes.length)
				{
					dispatchChange(new TextChangeMulti(changes));
					
					model.setSelection(startLine, 0, endLine+1, 0);
					editor.invalidateSelection();
				}
			}
			else if (decrease) 
			{
				line = model.selectedLineIndex;
				if (model.lines[line].text.charAt(0) == "\t")
				{
					dispatchChange( 
						new TextChangeRemove(line, 0, line, 1)
					);
				}
			}
			else if (!decrease) insert("\t");
			
		}
		
		private function handlePaste(event:Event):void
		{
			// Get data from clipboard, and insert
			var clipboardData:String = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT).toString();
			
			if (clipboardData) insert(clipboardData);
		}
		
		private function handleCopy(event:Event):void
		{
			if (!model.hasSelection) return;
			
			toCopy = editor.getSelection();
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, toCopy, false);
		}
		
		private function handleCut(event:Event):void
		{
			if (model.hasSelection)
			{
				handleCopy(event);
				removeAtCursor();
			}
		}
		
		private function dispatchChange(change:TextChangeBase):void
		{
			editor.dispatchEvent(new ChangeEvent(ChangeEvent.TEXT_CHANGE, change));
		}
		
		private function handleChange(event:ChangeEvent):void
		{
			applyChange(event.change);
		}
		
		private function applyChange(change:TextChangeBase):void
		{
			if (change) {
				if (change is TextChangeInsert) applyChangeInsert(TextChangeInsert(change));
				if (change is TextChangeRemove) applyChangeRemove(TextChangeRemove(change));
				if (change is TextChangeMulti) applyChangeMulti(TextChangeMulti(change));
			}
		}
		
		private function applyChangeInsert(change:TextChangeInsert):void
		{
			var textLines:Vector.<String> = change.textLines;
			
			if (textLines && textLines.length > 0)
			{
				var startLine:TextLineModel = model.lines[change.startLine];
				var startIndent:int = TextUtil.indentAmount(startLine.text);
				var trailText:String = startLine.text.slice(change.startChar);
				
				// Break line at change position, and append first text line
				startLine.text = startLine.text.slice(0, change.startChar) + textLines[0];
				
				// Append any additional lines to the model
				if (textLines.length > 1)
				{
					// Add indentation to last line if it's empty
					if (textLines[textLines.length - 1] == "")
					{
						// Get indentation of trailing text
						var trailIndent:int = TextUtil.indentAmount(trailText);
						// Get indentation of last line of the insert if it's a multi-line insert
						if (textLines.length > 2) startIndent = TextUtil.indentAmount(textLines[textLines.length - 2]);
						// Add required amount of indent to get the trailing text aligned with the last line
						textLines[textLines.length - 1] += TextUtil.repeatStr("\t", Math.max(startIndent - trailIndent, 0));
					}
					
					// Create line models from strings
					var newLines:Array = new Array(textLines.length - 1);
					
					for (var i:int = 0; i < textLines.length; i++)
					{
						newLines[i-1] = new TextLineModel(textLines[i]);
					}
					
					model.lines.splice.apply(model.lines, [change.startLine + 1, 0].concat(newLines));
				}
				
				// Append trailing text to the last changed line
				model.lines[change.startLine + textLines.length - 1].text += trailText;
			}
		}
		
		private function applyChangeRemove(change:TextChangeRemove):void
		{
			var startLine:TextLineModel = model.lines[change.startLine];
			var endLine:TextLineModel = model.lines[change.endLine];
			var textLines:Vector.<String> = new Vector.<String>(change.endLine - change.startLine + 1);
			
			if (change.endLine > change.startLine)
			{
				// Remove any lines after the first
				var remLines:Vector.<TextLineModel> = model.lines.splice(change.startLine + 1, change.endLine - change.startLine);
				// Store each removed line's text
				textLines[0] = startLine.text.slice(change.startChar);
				for (var i:int = 0; i < remLines.length - 1; i++)
				{
					textLines[i+1] = remLines[i].text;
				}
				textLines[remLines.length] = remLines[remLines.length - 1].text.slice(0, change.endChar);
			}
			else {
				// Store removed text
				textLines[0] = startLine.text.slice(change.startChar, change.endChar);
			}
			
			// Remove from first line, and append trailing from end line
			startLine.text = startLine.text.slice(0, change.startChar) + endLine.text.slice(change.endChar);
			
			// Store removed lines in change
			change.setTextLines(textLines);
		}
		
		private function applyChangeMulti(change:TextChangeMulti):void
		{
			for each (var subchange:TextChangeBase in change.changes)
			{
				applyChange(subchange);
			}
		}
	}
}