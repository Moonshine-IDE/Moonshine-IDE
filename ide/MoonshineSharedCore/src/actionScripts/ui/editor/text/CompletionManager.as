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
	import actionScripts.ui.editor.text.change.TextChangeInsert;
	import actionScripts.utils.TextUtil;
	import actionScripts.valueObjects.Command;
	import actionScripts.valueObjects.CompletionItem;
	import actionScripts.valueObjects.Position;

	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;

	import mx.collections.ArrayList;
	import mx.managers.PopUpManager;

	import spark.components.List;
	import spark.filters.DropShadowFilter;
	import spark.layouts.HorizontalAlign;
	import spark.layouts.VerticalLayout;

	public class CompletionManager
	{
		private static const COMMAND_ADD_IMPORT:String = "nextgenas.addImport";
		private static const COMMAND_ADD_MXML_NAMESPACE:String = "nextgenas.addMXMLNamespace";

		protected var editor:TextEditor;
		protected var model:TextEditorModel;

		private var completionList:List;
		private var menuStr:String;
		private var menuRefY:Number;
		private var caret:int;
		private var menuData:ArrayList;

		public function CompletionManager(editor:TextEditor, model:TextEditorModel)
		{
			this.editor = editor;
			this.model = model;

			completionList = new List();
			completionList.minWidth = 300;
			completionList.styleName = "completionList";
			var layout:VerticalLayout = new VerticalLayout();
			layout.requestedMaxRowCount = 8;
			layout.gap = 0;
			layout.horizontalAlign = HorizontalAlign.CONTENT_JUSTIFY;
			layout.useVirtualLayout = true;
			completionList.layout = layout;
			completionList.doubleClickEnabled = true;
			completionList.filters = [new DropShadowFilter(3, 90, 0, 0.2, 8, 8)];
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
			var selectedIndex:int = model.selectedLineIndex;
			var pos:int = model.caretIndex;
			//look back for last trigger
			var tmpStr:String = selectedText.substring(Math.max(0, pos-100), pos).split('').reverse().join('');
			var word:Array = tmpStr.match(/^(\w*?)\s*(\:|\.|\(|\bsa\b|\bwen\b)/);
			var trigger:String = word ? word[2] : '';

			if (editor.signatureHelpActive && trigger=='(')
			{
				trigger = '';
				menuStr = word[1];
			}
			else
			{
				word= tmpStr.match(/^(\w*)\b/);
				menuStr = word ? word[1] : '';
			}

			menuStr = menuStr.split('').reverse().join('');
			pos -= menuStr.length + 1;

			menuData = new ArrayList(items);
			completionList.dataProvider = menuData;

			var position:Point = editor.getPointForIndex(pos+1);
			position.x -= editor.horizontalScrollBar.scrollPosition;

			menuRefY = position.y;

			PopUpManager.addPopUp(completionList, editor, false);
			completionList.x = position.x;
			completionList.y = position.y;
			completionList.setFocus();
			completionList.selectedIndex = 0;
			completionList.addEventListener(Event.REMOVED_FROM_STAGE, onMenuRemoved);
			completionList.addEventListener(KeyboardEvent.KEY_DOWN, onMenuKey);
			completionList.addEventListener(FocusEvent.FOCUS_OUT, onMenuFocusOut);
			completionList.addEventListener(MouseEvent.DOUBLE_CLICK, onMenuDoubleClick);
			rePositionMenu();
			
			if (menuStr.length) filterMenu();
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
		}

		private function filterMenu():Boolean
		{
			var filteredItems:Array = [];
			var itemCount:int = menuData.length;
			for(var i:int = 0; i < itemCount; i++)
			{
				var item:CompletionItem = CompletionItem(menuData.getItemAt(i));
				if(item.label.toLowerCase().indexOf(menuStr.toLowerCase()) == 0)
				{
					filteredItems.push(item);
				}
			}
			if (filteredItems.length == 0) return false;
			completionList.dataProvider = new ArrayList(filteredItems);
			completionList.selectedIndex = 0;

			rePositionMenu();
			return true;
		}

		private function completeItem(item:CompletionItem):void
		{
			var startIndex:int = caret - menuStr.length;
			var endIndex:int = caret;
			var text:String = item.insertText;
			if(!text)
			{
				if(item.insertText)
				{
					text = item.insertText;
				}
				else
				{
					text = item.label;
				}
			}
			var change:TextChangeInsert = null;
			var command:Command = item.command;
			if(command)
			{
				switch(command.command)
				{
					case COMMAND_ADD_IMPORT:
					{
						change = getAddImportChange.apply(this, command.arguments);
						break;
					}
					case COMMAND_ADD_MXML_NAMESPACE:
					{
						change = getAddMXMLNamespaceChange.apply(this, command.arguments);
						break;
					}
					default:
					{
						trace("unknown completion command:", command.command);
					}
				}
			}
			editor.setCompletionData(startIndex, endIndex, text, change);
		}

		private function getAddImportChange(qualifiedName:String, startIndex:int, endIndex:int):TextChangeInsert
		{
			if(!qualifiedName)
			{
				return null;
			}
			var text:String = editor.dataProvider;
			var regExp:RegExp = /^([ \t]*)import ([\w\.]+)/gm;
			var matches:Array;
			var currentMatches:Array;
			if(startIndex !== -1)
			{
				regExp.lastIndex = startIndex;
			}
			do
			{
				currentMatches = regExp.exec(text);
				if(currentMatches)
				{
					if(endIndex !== -1 && currentMatches.index >= endIndex)
					{
						break;
					}
					if(currentMatches[2] === qualifiedName)
					{
						//this class is already imported!
						return null;
					}
					matches = currentMatches;
				}
			}
			while(currentMatches);
			var indent:String = "";
			var lineBreaks:String = "\n";
			var position:Position = new Position();
			if(matches)
			{
				//we found existing imports
				var lineAndChar:Point = TextUtil.charIdx2LineCharIdx(text, matches.index, editor.lineDelim); 
				position.line = lineAndChar.x;
				position.character = lineAndChar.y;
				indent = matches[1];
				position.line++;
				position.character = 0;
			}
			else //no existing imports
			{
				if(startIndex !== -1)
				{
					lineAndChar = TextUtil.charIdx2LineCharIdx(text, startIndex, editor.lineDelim);
					position.line = lineAndChar.x;
					position.character = lineAndChar.y;
					if(position.character > 0)
					{
						//go to the next line, if we're not at the start
						position.line++;
						position.character = 0;
					}
					//try to use the same indent as whatever follows
					regExp = /^([ \t]*)\w/gm;
					regExp.lastIndex = startIndex;
					matches = regExp.exec(text);
					if(matches)
					{
						indent = matches[1];
					}
					else
					{
						indent = "";
					}
				}
				else
				{
					regExp = /^package( [\w\.]+)*\s*\{[\r\n]+([ \t]*)/g;
					matches = regExp.exec(text);
					if(!matches)
					{
						return null;
					}
					lineAndChar = TextUtil.charIdx2LineCharIdx(text, regExp.lastIndex, editor.lineDelim);
					position.line = lineAndChar.x;
					position.character = lineAndChar.y;
					if(position.character > 0)
					{
						//go to the beginning of the line, if we're not there
						position.character = 0;
					}
					indent = matches[2];
				}
				lineBreaks += "\n"; //add an extra line break
			}
			var textToInsert:String = indent + "import " + qualifiedName + ";" + lineBreaks;

			var change:TextChangeInsert = new TextChangeInsert(
				position.line,
				position.character,
				Vector.<String>(textToInsert.split("\n"))
			);
			return change;
		}

		private function getAddMXMLNamespaceChange(prefix:String, uri:String, startIndex:int, endIndex:int):TextChangeInsert
		{
			if(!prefix || !uri)
			{
				return null;
			}

			//exclude the whitespace before the namespace so that finding duplicates
			//doesn't depend on it
			var textToInsert:String = "xmlns:" + prefix + "=\"" + uri + "\"";
			var text:String = editor.dataProvider;
			var index:int = text.indexOf(textToInsert, startIndex);
			if(index !== -1 && index < endIndex)
			{
				return null;
			}
			//include the whitespace here instead (see above)
			textToInsert = " " + textToInsert;
			var lineAndChar:Point = TextUtil.charIdx2LineCharIdx(text, endIndex, editor.lineDelim);
			var change:TextChangeInsert = new TextChangeInsert(
				lineAndChar.x,
				lineAndChar.y,
				Vector.<String>(textToInsert.split("\n"))
			);
			return change;
		}

		private function onMenuFocusOut(event:FocusEvent):void
		{
			this.closeCompletionList();
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
						if (filterMenu()) return;
					}
				}
				else if (e.keyCode == Keyboard.DELETE)
				{
					editor.setCompletionData(caret, caret+1, '');
				}
				else if (e.charCode > 31 && e.charCode < 127)
				{
					var ch:String = String.fromCharCode(e.charCode);
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
						var startIndex:int = caret - menuStr.length;
						var endIndex:int = caret;
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
			setTimeout(function():void {
				editor.setFocus();
				//stage.focus = editor;
				//FocusManager.getManager(stage).setFocusOwner(editor as Component);
			}, 1);
		}

		private function rePositionMenu():void
		{
			if(completionList.x + completionList.width > completionList.stage.stageWidth)
			{
				completionList.x = completionList.stage.stageWidth - completionList.width;
			}
			var menuH:int = Math.min(8, completionList.height) * 17;
			if (menuRefY +15 + menuH > completionList.stage.stageHeight)
				completionList.y = (menuRefY - menuH - 2);
			else
				completionList.y = (menuRefY + 15);
		}

	}
}