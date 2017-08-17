/* license section

Flash MiniBuilder is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Flash MiniBuilder is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Flash MiniBuilder.  If not, see <http://www.gnu.org/licenses/>.


Author: Victor Dramba
2009
*/


package actionScripts.ui.editor.text
{
	import __AS3__.vec.Vector;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.ShowDropDownForTypeAhead;
	import actionScripts.events.TypeAheadEvent;
	import actionScripts.locator.IDEModel;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.editor.text.TextEditor;
	import actionScripts.ui.editor.text.TextEditorModel;
	import actionScripts.utils.vectorToArray;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	
	import org.aswing.Component;
	import org.aswing.FocusManager;
	import org.aswing.JToolTip;
	import org.aswing.event.ListItemEvent;
	import org.aswing.geom.IntPoint;
	
	
	public class CodeCompletionMenu
	{
		private var menuData:Vector.<String>;
		private var scriptAreaComponent:TextEditor;
		private var menu:ScrollablePopupMenu;
		private var onComplete:Function;
		private var stage:Stage;
		private var menuStr:String;
		private var tooltip:JToolTip;
		private var tooltipCaret:int;
		private var menuRefY:int;
		private var position:int;
		private var selectedIndex:int;
		private var selectedText:String;
		private var result:Array = new Array();
		private var caret:int;
		public function CodeCompletionMenu(field:TextEditor, stage:Stage, onComplete:Function)
		{
			scriptAreaComponent = field;
			this.onComplete = onComplete;
			this.stage = stage;

			menu = new ScrollablePopupMenu(this.stage);
			menu.doubleClickEnabled = true;
			//restore the focus to the textfield, delayed
			menu.addEventListener(Event.REMOVED_FROM_STAGE, onMenuRemoved);
			//menu in action
			menu.addEventListener(KeyboardEvent.KEY_DOWN, onMenuKey);
			
			menu.addEventListener(MouseEvent.DOUBLE_CLICK, function(e:Event):void {
				caret = scriptAreaComponent.model.caretIndex;
				scriptAreaComponentReplaceText(caret-menuStr.length, caret, menu.getSelectedValue());
				menu.dispose();			
			})
			tooltip = new JToolTip;
			//used to close the tooltip
			scriptAreaComponent.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
		}
		
		private function filterMenu():Boolean
		{
			var item:Array = [];
			for each (var str:String in menuData)
				if (str.toLowerCase().indexOf(menuStr.toLowerCase())==0) item.push(str);
			/*for each (var str:int in menuData)
			if (menuData[str].label.toString().toLowerCase().indexOf(menuStr.toLowerCase())==0) item.push(menuData[str].label);*/

			if (item.length == 0) return false;
			menu.setListData(item);
			menu.setSelectedIndex(0);
			
			rePositionMenu();
			return true;
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (tooltip.isShowing())
			{
				if (e.keyCode == Keyboard.ESCAPE || e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN  ||
					String.fromCharCode(e.charCode) == ')' || scriptAreaComponent.model.caretIndex < tooltipCaret)
					tooltip.disposeToolTip();
					
			}
			
			if (String.fromCharCode(e.keyCode) == ' ' && e.ctrlKey || e.charCode  == 46 || e.charCode == 58 && e.shiftKey)
			{
				var documnet:String="";
				if (scriptAreaComponent.model.lines.length > 1)
				{
					for (var i:int = 0; i < scriptAreaComponent.model.lines.length-1; i++)
					{
						var m:TextLineModel = scriptAreaComponent.model.lines[i];
						documnet+=m.text+"\n";					
					}
				}
				var len:Number = scriptAreaComponent.model.caretIndex - scriptAreaComponent.startPos;
				/*position = scriptAreaComponent.model.caretIndex;
				selectedIndex = scriptAreaComponent.model.selectedLineIndex;
				selectedText = scriptAreaComponent.model.lines[scriptAreaComponent.model.selectedLineIndex].text;*/
				GlobalEventDispatcher.getInstance().dispatchEvent(new TypeAheadEvent(TypeAheadEvent.EVENT_TYPEAHEAD,scriptAreaComponent.startPos,scriptAreaComponent.model.selectedLineIndex,scriptAreaComponent.model.caretIndex,scriptAreaComponent.model.selectedLineIndex,documnet,len,1));
				GlobalEventDispatcher.getInstance().addEventListener(ShowDropDownForTypeAhead.EVENT_SHOWDROPDOWN,showDropDownhander);
			}
		}
		private function showDropDownhander(evt:ShowDropDownForTypeAhead):void{
			GlobalEventDispatcher.getInstance().removeEventListener(ShowDropDownForTypeAhead.EVENT_SHOWDROPDOWN,showDropDownhander);
			result = evt.result;
			triggerTypeAhead();
		}
		private function onMenuKey(e:KeyboardEvent):void
		{
			if (e.charCode != 0)
			{
				 caret = scriptAreaComponent.model.caretIndex;
				 if (e.keyCode == Keyboard.BACKSPACE)
				{
					 scriptAreaComponentReplaceText(caret-1, caret, '');
					if (menuStr.length > 0)
					{
						menuStr = menuStr.substr(0, -1);
						if (filterMenu()) return;
					}
				}
				else if (e.keyCode == Keyboard.DELETE)
				{
					scriptAreaComponentReplaceText(caret, caret+1, '');
				}
				else if (e.charCode > 31 && e.charCode < 127)
				{
					var ch:String = String.fromCharCode(e.charCode);
					menuStr += ch.toLowerCase();
					scriptAreaComponentReplaceText(caret, caret, ch);
					if (filterMenu()) return;
				}
				else if (e.keyCode == Keyboard.ENTER || e.keyCode == Keyboard.TAB)
				{
					//var len:Number = scriptAreaComponent.model.caretIndex - scriptAreaComponent.startPos;
					scriptAreaComponentReplaceText(caret - menuStr.length, caret, menu.getSelectedValue());
					//checkAddImports(menu.getSelectedValue());
				//	if(onComplete)onComplete();
				}
				menu.dispose();
			}
		}
		private function checkAddImports(name:String):void
		{
			caret = scriptAreaComponent.model.caretIndex;
			/*if (!ctrl.isInScope(name, caret-name.length))
			{
				var missing:Vector.<String> = ctrl.getMissingImports(name, caret-name.length);
				if (missing)
				{
					var sumChars:int = 0;
					for (var i:int=0; i<missing.length; i++)
					{
						//TODO make a better regexp
						var pos:int = scriptAreaComponent.text.lastIndexOf('package ', scriptAreaComponent.caretIndex);
						pos = scriptAreaComponent.text.indexOf('{', pos) + 1;
						var importStr:String = '\n\t'+(i>0?'//':'')+'import '+missing[i] + '.' + name + ';';
						sumChars += importStr.length;
						scriptAreaComponent.replaceText(pos, pos, irmportStr);
					}
					scriptAreaComponent.setSelection(caret+sumChars, caret+sumChars);
				}
			}*/
		}
		
		private function scriptAreaComponentReplaceText(begin:int, end:int, text:String):void
		{
			/*var str:String = scriptAreaComponent.model.lines[scriptAreaComponent.model.selectedLineIndex].text.substring(scriptAreaComponent.model.lines[scriptAreaComponent.model.selectedLineIndex].text.length,scriptAreaComponent.model.lines[scriptAreaComponent.model.selectedLineIndex].text.length-1);
			if(str == "." || str == ":")
			{
			  scriptAreaComponent.setTypeAheadData(begin,end,text);
			}
			else
			{
				scriptAreaComponent.replaceText(begin,end,text);
			}*/
			scriptAreaComponent.setCompletionData(begin,end,text);
       }
		
		private function onMenuRemoved(e:Event):void
		{
			setTimeout(function():void {
				stage.focus = scriptAreaComponent;
				FocusManager.getManager(stage).setFocusOwner(scriptAreaComponent as Component);
			}, 1);
		}
		
		public function triggerTypeAhead():void
		{
			var activeEdiotr:BasicTextEditor = IDEModel.getInstance().activeEditor as BasicTextEditor;
			scriptAreaComponent = activeEdiotr.editor;
			selectedText = scriptAreaComponent.model.lines[scriptAreaComponent.model.selectedLineIndex].text;
			selectedIndex = scriptAreaComponent.model.selectedLineIndex;
			var pos:int = scriptAreaComponent.model.caretIndex;
			//look back for last trigger
			var tmpStr:String = selectedText.substring(Math.max(0, pos-100), pos).split('').reverse().join('');
			var word:Array = tmpStr.match(/^(\w*?)\s*(\:|\.|\(|\bsa\b|\bwen\b)/);
			var trigger:String = word ? word[2] : '';
			
			if (tooltip.isShowing() && trigger=='(')
			{
				trigger = '';
				menuStr = word[1];
			}
			else
			{
				word= tmpStr.match(/^(\w*)\b/);
				menuStr = word ? word[1] : '';
			}
			
			menuStr = menuStr.split('').reverse().join('')
			pos -= menuStr.length + 1;
			//Replace menudata with java result
			menuData = null;
			menuData = getAllTypes();
		//	var keyword:String = trigger.split('').reverse().join('');
			
			/*if (keyword == 'new' || keyword == 'as' || keyword == 'is' || keyword == ':' || keyword == 'extends' || keyword == 'implements')
				menuData = ctrl.getTypeOptions();
			else if (trigger == '.')
				menuData = ctrl.getMemberList(pos);
			else if (trigger == '')
				menuData = ctrl.getAllOptions(pos);
			else if (trigger == '(')
			{
				var funDetail:String = ctrl.getFunctionDetails(pos);
				if (funDetail)
				{
					tooltip.setTipText(funDetail);
					var position:Point = scriptAreaComponent.getPointForIndex(model.caretIndex-1);
					position = scriptAreaComponent.localToGlobal(position);
					tooltip.showToolTip();
					tooltip.moveLocationRelatedTo(new IntPoint(position.x, position.y));
					tooltipCaret = model.caretIndex;
					return;
				}
			}*/
				
			if (!menuData || menuData.length==0) return;
			
			showMenu(pos+1);			
			if (menuStr.length) filterMenu();
		}
		public function getAllTypes():Vector.<String>
		{
			var dataVector:Vector.<String> = new Vector.<String>;
			for(var i:int=0;i<result.length;i++)
			{
				dataVector.push(result[i].label);
			}
			return dataVector;
		}
		private function showMenu(index:int):void
		{
			var position:Point;
			menu.setListData(vectorToArray(menuData));
			menu.setSelectedIndex(0);
			
			position = scriptAreaComponent.getPointForIndex(index);
			position.x += scriptAreaComponent.horizontalScrollBar.scrollPosition;
			
			menuRefY = position.y;
			
			//menu.show(stage, position.x, 0);
			menu.show(stage, position.x, position.y);
			//menu.show(stage, 100, 200);
			stage.focus = menu;
			FocusManager.getManager(stage).setFocusOwner(menu);
			
			rePositionMenu();
		}
		
		private function rePositionMenu():void
		{
			var menuH:int = Math.min(8, menu.getModel().getSize()) * 17;
			if (menuRefY +15 + menuH > stage.stageHeight)
				menu.setY(menuRefY - menuH - 2);
			else
				menu.setY(menuRefY + 15);
		}

	}
}