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
package actionScripts.plugin.console.view
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.utils.StringUtil;
	
	import actionScripts.events.ChangeEvent;
	import actionScripts.plugin.console.ConsoleCommandEvent;
	import actionScripts.ui.editor.text.TextEditor;
	import actionScripts.ui.editor.text.TextLineModel;
	import actionScripts.ui.editor.text.change.TextChangeBase;
	import actionScripts.ui.editor.text.change.TextChangeInsert;
	import actionScripts.ui.editor.text.change.TextChangeMulti;
	
	public class CommandLineEditor extends TextEditor
	{
		private var history:Array = [];
		private var historyIndex:int = -1;
		
		public function CommandLineEditor()
		{
			super(false);
			
			this.addEventListener(ChangeEvent.TEXT_CHANGE, handleChange);
			this.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown, false, 10);
		}
		
		private function handleChange(event:ChangeEvent):void
		{
			var change:TextChangeBase = event.change;
			
			if (change is TextChangeInsert) applyChangeInsert(TextChangeInsert(change));
			else if (change is TextChangeMulti) applyChangeMulti(TextChangeMulti(change));
		}
		
		private function handleKeyDown(event:KeyboardEvent):void
		{
			switch (event.keyCode)
			{
				case Keyboard.DOWN:
				{
					historyIndex--;
					if (historyIndex < 0)
					{ 
						// Cap to -1. Next 'up' action will bring it to 0 & the first history item. 
						historyIndex = -1;
						dataProvider = "";
					}
					else
					{
						applyHistory();
					}
					event.preventDefault();
					break;
				}
				case Keyboard.UP:
				{
					historyIndex++;
					if (historyIndex >= history.length)
					{ 
						historyIndex = history.length-1
					}
					
					applyHistory();	
					
					event.preventDefault();
					break;
				}
				case Keyboard.ENTER:
				{
					// Don't let TextEditor handle this,
					//  it'll split the line where the cursor is, which isn't console-standard.
					event.stopImmediatePropagation();
					
					// Get the line & exec it
					var line:String = model.selectedLine.text;
					exec(line);
					
					// Reset the console
					dataProvider = "";
					
					break;
				}
			}
		}
		
		private function applyHistory():void
		{
			if (history.length == 0) return;
			dataProvider = history[historyIndex];
			model.caretIndex = model.selectedLine.text.length;
		}
		
		private function applyChangeMulti(change:TextChangeMulti):void
		{
			for each (var subchange:TextChangeBase in change.changes)
			{
				if (subchange is TextChangeInsert) applyChangeInsert(TextChangeInsert(subchange));
			}
		}
		
		// Used for pasting multi-line commands.
		private function applyChangeInsert(change:TextChangeInsert):void
		{
			// Loop all lines and exec them in order
			if (model.lines.length > 1)
			{
				for (var i:int = 0; i < model.lines.length-1; i++)
				{
					var m:TextLineModel = model.lines[i];
					
					exec(m.text);					
				}
				
				dataProvider = "";
			}
		}
		
		private function exec(line:String):void
		{
			var cmd:String = StringUtil.trim(line);
			if (cmd == "") return;
			
			// reset history index
			historyIndex = -1;
			// add to history
			history.unshift(line);
			
			var split:Array = cmd.split(' ');
			var c:String = split[0];
			var args:Array = split.splice(1);
			
			dispatchEvent( new ConsoleCommandEvent(c, args) );
		}
	}
}