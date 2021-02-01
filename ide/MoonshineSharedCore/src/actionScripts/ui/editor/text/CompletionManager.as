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
	import actionScripts.events.ExecuteLanguageServerCommandEvent;
	import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.ui.codeCompletionList.CodeCompletionList;
    import actionScripts.utils.CompletionListCodeTokens;
    import actionScripts.valueObjects.Command;
	import actionScripts.valueObjects.CompletionItem;
    import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
    import flash.utils.clearTimeout;
    import flash.utils.setTimeout;

	import mx.collections.ArrayCollection;
    import mx.managers.PopUpManager;
    import mx.utils.ObjectUtil;

    import spark.collections.Sort;

    import spark.collections.SortField;
    import actionScripts.valueObjects.CompletionItemKind;
    import actionScripts.valueObjects.TextEdit;
    import actionScripts.valueObjects.WorkspaceEdit;
    import actionScripts.locator.IDEModel;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.utils.applyWorkspaceEdit;
    import actionScripts.events.ResolveCompletionItemEvent;
    import actionScripts.ui.editor.LanguageServerTextEditor;
    import actionScripts.utils.getProjectForUri;
    import actionScripts.valueObjects.ProjectVO;

    public class CompletionManager
	{
		private static const MIN_CODECOMPLETION_LIST_HEIGHT:int = 8;

		protected var editor:TextEditor;
		protected var model:TextEditorModel;

		private var completionList:CodeCompletionList;
		private var menuStr:String;
		private var menuRefY:Number;
		private var caret:int;
		private var menuCollection:ArrayCollection;

		public function CompletionManager(editor:TextEditor, model:TextEditorModel)
		{
			this.editor = editor;
			this.model = model;

			completionList = new CodeCompletionList();
			menuCollection = new ArrayCollection();
			menuCollection.filterFunction = filterCodeCompletionMenu;
			menuCollection.sort = new Sort([new SortField("sortLabel")], sortCodeCompletionMenu);
			
			completionList.dataProvider = menuCollection;
		}

		public function get isActive():Boolean
		{
			return completionList.isPopUp;
		}

		public function isMouseOverList():Boolean
		{
			if (!completionList || !completionList.visible) return false;

			return completionList.hitTestPoint(editor.mouseX, editor.mouseY);
		}

		public function showCompletionList(items:Array):void
		{
			var selectedText:String = model.lines[model.selectedLineIndex].text;
			var pos:int = model.caretIndex;
			//look back for last trigger
			var tmpStr:String = selectedText.substring(Math.max(0, pos-100), pos).split('').reverse().join('');
			var word:Array = tmpStr.match(/^(\w*?)\s*(\:|\.|\(|\bsa\b|\bwen\b)/);
			var trigger:String = word ? word[2] : '';

			if (editor.signatureHelpActive && trigger=='(')
			{
				menuStr = word[1];
			}
			else
			{
				word= tmpStr.match(/^(\w*)\b/);
				menuStr = word ? word[1] : '';
			}

			menuStr = menuStr.split('').reverse().join('');
			pos -= menuStr.length + 1;

			//make sure this value is lower case for filtering
			menuStr = menuStr.toLowerCase();

			menuCollection.source = items;

            var position:Point = editor.getPointForIndex(pos+1);
			position.x -= editor.horizontalScrollBar.scrollPosition;

			menuRefY = position.y;

			if(!completionList.isPopUp)
			{
				PopUpManager.addPopUp(completionList, editor, false);
				completionList.x = position.x;
				completionList.y = position.y;
				completionList.addEventListener(Event.REMOVED_FROM_STAGE, onMenuRemoved);
				completionList.addEventListener(KeyboardEvent.KEY_DOWN, onMenuKey);
				completionList.addEventListener(FocusEvent.FOCUS_OUT, onMenuFocusOut);
				completionList.addEventListener(MouseEvent.DOUBLE_CLICK, onMenuDoubleClick);
				completionList.addEventListener(Event.CHANGE, onMenuChange);
			}
			completionList.setFocus();
			completionList.selectedIndex = 0;
			rePositionMenu();

			filterMenu();
			
			if(items.length > 0)
			{
				var activeEditor:LanguageServerTextEditor = IDEModel.getInstance().activeEditor as LanguageServerTextEditor;
				if(activeEditor.getEditorComponent() == editor)
				{
					var resolveEvent:ResolveCompletionItemEvent = new ResolveCompletionItemEvent(
						ResolveCompletionItemEvent.EVENT_RESOLVE_COMPLETION_ITEM, activeEditor.currentFile.fileBridge.url, items[0]);
					GlobalEventDispatcher.getInstance().dispatchEvent(resolveEvent);
				}
			}
		}

		public function resolveCompletionItem(resolvedItem:CompletionItem):void
		{
			menuCollection.itemUpdated(resolvedItem);
		}

		public function closeCompletionList():void
		{
			if(!this.isActive)
			{
				return;
			}
			PopUpManager.removePopUp(completionList);
			completionList.removeEventListener(Event.REMOVED_FROM_STAGE, onMenuRemoved);
			completionList.removeEventListener(KeyboardEvent.KEY_DOWN, onMenuKey);
			completionList.removeEventListener(FocusEvent.FOCUS_OUT, onMenuFocusOut);
			completionList.removeEventListener(MouseEvent.DOUBLE_CLICK, onMenuDoubleClick);
			completionList.removeEventListener(Event.CHANGE, onMenuChange);
			completionList.closeDocumentation();
		}

		private function filterMenu():Boolean
		{
			menuCollection.refresh();

            if (menuCollection.length == 0)
			{
				return false;
			}

			//validate so that the list's layout updates with the new
			//filtered items
			completionList.validateNow();
			completionList.selectedIndex = 0;
			//for some reason, we need to validate again, or the
			//verticalScrollPosition will not change
			completionList.validateNow();
			completionList.dataGroup.verticalScrollPosition = 0;

			rePositionMenu();

			return true;
		}

		private function completeItem(item:CompletionItem):void
		{
			var activeEditor:BasicTextEditor = IDEModel.getInstance().activeEditor as BasicTextEditor;
			var uri:String = (activeEditor && activeEditor.currentFile) ? activeEditor.currentFile.fileBridge.url : null;
			if(item.textEdit)
			{
				var textEdit:TextEdit = item.textEdit;
				if(textEdit.range.end.character < caret) {
					//account for the user typing more since the initial
					//completion request
					textEdit.range.end.character = caret;
				}
				var workspaceEdit:WorkspaceEdit = new WorkspaceEdit();
				var changes:Object = {};
				changes[uri] = new <TextEdit>[textEdit];
				workspaceEdit.changes = changes;
				applyWorkspaceEdit(workspaceEdit);
				var lineIndex:int = textEdit.range.start.line;
				var cursorIndex:int = textEdit.range.start.character + textEdit.newText.length;
				model.setSelection(lineIndex, cursorIndex, lineIndex, cursorIndex);
			}
			else
			{
				var startIndex:int = caret - menuStr.length;
				var endIndex:int = caret;
				var baseText:String = item.insertText;
				if(!baseText)
				{
					baseText = item.label;
				}

				var text:String = baseText;
				var hasSelectedLineAutoCloseAttr:Boolean = false;
				if (item.kind != CompletionItemKind.CLASS && item.kind != CompletionItemKind.VALUE && isPlaceInLineAllowedToAutoCloseAttr(startIndex, endIndex))
				{
					var itemWithNamespaceRegExp:RegExp = /\w+(?=:)/;
					if (!itemWithNamespaceRegExp.test(item.insertText))
					{
						hasSelectedLineAutoCloseAttr = checkSelectedLineIfItIsForAutoCloseAttr(startIndex, endIndex);
						if (item.kind == CompletionItemKind.VARIABLE && item.insertText != null)
						{
							hasSelectedLineAutoCloseAttr = false;
						}

						if (hasSelectedLineAutoCloseAttr)
						{
							text = baseText + "=\"\"";
						}
					}
				}

				if (!hasSelectedLineAutoCloseAttr && item.kind == CompletionItemKind.METHOD)
				{
					text = baseText + "()";
				}

				editor.setCompletionData(startIndex, endIndex, text);

				if ((item.kind == CompletionItemKind.METHOD || hasSelectedLineAutoCloseAttr)
						&& item.kind != CompletionItemKind.CLASS && item.kind != CompletionItemKind.VALUE)
				{
					lineIndex = model.selectedLineIndex;
					cursorIndex = startIndex + text.length - 1;
					model.setSelection(lineIndex, cursorIndex, lineIndex, cursorIndex);
				}
			}

			var additionalTextEdits:Vector.<TextEdit> = item.additionalTextEdits;
			if(additionalTextEdits)
			{
				workspaceEdit = new WorkspaceEdit();
				changes = {};
				changes[uri] = additionalTextEdits;
				workspaceEdit.changes = changes;
				applyWorkspaceEdit(workspaceEdit);
			}

			var command:Command = item.command;
			if(command)
			{
				var project:ProjectVO = getProjectForUri(uri);
				var commandEvent:ExecuteLanguageServerCommandEvent = new ExecuteLanguageServerCommandEvent(
					ExecuteLanguageServerCommandEvent.EVENT_EXECUTE_COMMAND,
					project,
					command.command,
					command.arguments);
				GlobalEventDispatcher.getInstance().dispatchEvent(commandEvent);
			}
		}

		private function onMenuFocusOut(event:FocusEvent):void
		{
			this.closeCompletionList();
		}

		private function onMenuChange(event:Event):void
		{
			if(!isActive)
			{
				return;
			}
			var item:CompletionItem = completionList.selectedItem as CompletionItem;
			if(!item)
			{
				return;
			}
			var activeEditor:LanguageServerTextEditor = IDEModel.getInstance().activeEditor as LanguageServerTextEditor;
			if(activeEditor.getEditorComponent() != editor)
			{
				return;
			}
			var resolveEvent:ResolveCompletionItemEvent = new ResolveCompletionItemEvent(
				ResolveCompletionItemEvent.EVENT_RESOLVE_COMPLETION_ITEM, activeEditor.currentFile.fileBridge.url, item);
			GlobalEventDispatcher.getInstance().dispatchEvent(resolveEvent);
		}

		private function onMenuKey(e:KeyboardEvent):void
		{
			if (e.charCode != 0)
			{
				caret = model.caretIndex;
				if (e.keyCode == Keyboard.BACKSPACE)
				{
					editor.setCompletionData(caret-1, caret, '');
					if (menuStr.length > 0)
					{
						menuStr = menuStr.substr(0, -1);
						if (filterMenu())
						{
							return;
						}
					}
				}
				else if (e.keyCode == Keyboard.DELETE)
				{
					editor.setCompletionData(caret, caret+1, '');
				}
				else if (e.charCode > 31 && e.charCode < 127)
				{
					var ch:String = String.fromCharCode(e.charCode);
					//we rely on the fact that menuStr is lower case when we
					//filter the collection elsewhere
					menuStr += ch.toLowerCase();
					editor.setCompletionData(caret, caret, ch);
					if (filterMenu())
					{
						return;
					}
					//stop the character from appearing twice
					e.preventDefault();
				}
				else if (e.keyCode == Keyboard.ENTER || e.keyCode == Keyboard.TAB)
				{
					var selectedValue:CompletionItem = CompletionItem(completionList.selectedItem);
					if(selectedValue)
					{
						completeItem(selectedValue);
					}
				}
				this.closeCompletionList();
			}
		}

		private function onMenuDoubleClick(event:MouseEvent):void
		{
			caret = model.caretIndex;
			var selectedValue:CompletionItem = CompletionItem(completionList.selectedItem);
			if(selectedValue)
			{
				completeItem(selectedValue);
			}
			this.closeCompletionList();
		}

		private function onMenuRemoved(event:Event):void
		{
			var timeoutValue:uint = setTimeout(function():void {
				editor.setFocus();
				clearTimeout(timeoutValue);
			}, 1);
			menuCollection.removeAll();
		}

		private function rePositionMenu():void
		{
			if(completionList.x + completionList.width > completionList.stage.stageWidth)
			{
				completionList.x = completionList.stage.stageWidth - completionList.width;
			}

			var completionListHeight:Number = completionList.height;
			var smallestMenuHeight:Number =
					MIN_CODECOMPLETION_LIST_HEIGHT < completionListHeight
					? MIN_CODECOMPLETION_LIST_HEIGHT : completionListHeight;
			
			var menuH:int = smallestMenuHeight * 17;
			if (menuRefY +15 + menuH > completionList.stage.stageHeight)
				completionList.y = (menuRefY - menuH - 2);
			else
				completionList.y = (menuRefY + 15);
		}

        private function checkSelectedLineIfItIsForAutoCloseAttr(startIndex:int, endIndex:int):Boolean
        {
            var line:TextLineModel = editor.model.selectedLine;
            var selectedLineText:String = line.text;
            var isLineForAutoCloseAttr:Boolean = false;
            if (line && selectedLineText)
            {
                isLineForAutoCloseAttr = selectedLineText.indexOf(CompletionListCodeTokens.XML_OPEN_TAG) != -1 &&
                        selectedLineText.lastIndexOf(CompletionListCodeTokens.XML_CLOSE_TAG) != -1 &&
                        selectedLineText.indexOf(CompletionListCodeTokens.XML_SELF_CLOSE_TAG) == -1 &&
						selectedLineText.indexOf(CompletionListCodeTokens.CDATA_OPEN) == -1 &&
						selectedLineText.indexOf(CompletionListCodeTokens.CDATA_CLOSE) == -1;

                var linesCount:int = editor.model.lines.length;
                var isNonXMLFile:Boolean;
				var lineIndex:int;
                for (lineIndex = 0; lineIndex < linesCount; lineIndex++)
                {
                    line = editor.model.lines[lineIndex];
                    if (line.text && line.text.indexOf(CompletionListCodeTokens.PACKAGE) > -1)
                    {
                        isNonXMLFile = true;
                        break;
                    }
                }

                if (!isLineForAutoCloseAttr && !isNonXMLFile)
                {
                    var searchedLinesCount:int = editor.model.selectedLineIndex - 250;
                    if (searchedLinesCount < 0)
                    {
                        searchedLinesCount = 0;
                    }

                    for (lineIndex = editor.model.selectedLineIndex; lineIndex > searchedLinesCount; lineIndex--)
                    {
                        line = editor.model.lines[lineIndex];
                        selectedLineText = line.text;

						var hasCdataOpen:Boolean = selectedLineText.indexOf(CompletionListCodeTokens.CDATA_OPEN) != -1;
						var hasCdataClose:Boolean = false;
                        if (hasCdataOpen)
                        {
							var cdataOpenIndex:int = lineIndex;
                            searchedLinesCount = editor.model.selectedLineIndex + 250;
							if (searchedLinesCount > editor.model.lines.length)
							{
								searchedLinesCount = editor.model.lines.length;
							}

                            for (lineIndex = editor.model.selectedLineIndex; lineIndex < searchedLinesCount; lineIndex++)
							{
                                line = editor.model.lines[lineIndex];
                                selectedLineText = line.text;
								hasCdataClose = selectedLineText.indexOf(CompletionListCodeTokens.CDATA_CLOSE) != -1;
								if (hasCdataClose)
								{
									break;
								}
							}

                            if (hasCdataClose)
							{
								if (lineIndex > editor.model.selectedLineIndex && cdataOpenIndex < editor.model.selectedLineIndex)
                                {
                                    return false;
                                }
							}
                        }
                    }

                    searchedLinesCount = editor.model.selectedLineIndex - 250;
					if (searchedLinesCount < 0)
					{
						searchedLinesCount = 0;
                    }

                    for (lineIndex = editor.model.selectedLineIndex; lineIndex > searchedLinesCount; lineIndex--)
                    {
                        line = editor.model.lines[lineIndex];
                        selectedLineText = line.text;
                        if (selectedLineText)
                        {
                            if (selectedLineText.indexOf(CompletionListCodeTokens.XML_SELF_CLOSE_TAG) != -1 &&
								 selectedLineText.indexOf(CompletionListCodeTokens.XML_OPEN_TAG) != -1)
                            {
                                break;
                            }

                            if (selectedLineText.indexOf(CompletionListCodeTokens.XML_OPEN_TAG) != -1 &&
								selectedLineText.indexOf(CompletionListCodeTokens.XML_SELF_CLOSE_TAG) == -1)
                            {
                                isLineForAutoCloseAttr = true;
                                break;
                            }
                        }
                    }

                    if (isLineForAutoCloseAttr)
                    {
                        searchedLinesCount = editor.model.selectedLineIndex + 250;
                        if (searchedLinesCount > linesCount)
                        {
                            searchedLinesCount = linesCount;
                        }

                        isLineForAutoCloseAttr = false;
                        for (lineIndex = editor.model.selectedLineIndex; lineIndex < searchedLinesCount; lineIndex++)
                        {
                            line = editor.model.lines[lineIndex];
                            selectedLineText = line.text;
                            if (selectedLineText.indexOf(CompletionListCodeTokens.XML_CLOSE_TAG) != -1 &&
                                selectedLineText.indexOf(CompletionListCodeTokens.XML_SELF_CLOSE_TAG) == -1)
                            {
								if (selectedLineText.indexOf(CompletionListCodeTokens.XML_OPEN_TAG) == -1)
								{
                                    isLineForAutoCloseAttr = true;
                                    break;
                                }
                            }
                        }
                    }
                }
            }

            return isLineForAutoCloseAttr;
        }

		private function isPlaceInLineAllowedToAutoCloseAttr(startIndex:int, endIndex:int):Boolean
		{
            var line:TextLineModel = editor.model.selectedLine;

			if (!line) return false;

            var partOfSelectedLine:String = line.text.substring(startIndex - 1, endIndex + 1);
			var hasQuotations:Boolean = new RegExp(/^\".+.\"/).test(partOfSelectedLine);

			return !hasQuotations;
		}

        private function filterCodeCompletionMenu(item:CompletionItem):Boolean
        {
			if(menuStr.length === 0)
			{
				//all items are visible
				return true;
			}
			return item.label.toLowerCase().indexOf(menuStr) > -1;
        }

		private function sortCodeCompletionMenu(itemA:CompletionItem, itemB:CompletionItem, fields:Array):int
		{
			if (menuStr.length == 0)
			{
				//sortLabel is already lowercase, so telling stringCompare() to
				//compare case-sensitive can be faster by avoiding a call to
				//toLowerCase()
				return ObjectUtil.stringCompare(itemA.sortText, itemB.sortText, false);
			}

			//we don't need to call toLowerCase() on sortLabel and menuStr here
			//because they are already lower case
			var indexOfLabelItemA:int = itemA.sortText.indexOf(menuStr);
            var indexOfLabelItemB:int = itemB.sortText.indexOf(menuStr);

			return ObjectUtil.numericCompare(indexOfLabelItemA, indexOfLabelItemB);
		}
    }
}