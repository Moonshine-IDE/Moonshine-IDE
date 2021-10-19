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
	import actionScripts.plugin.console.ConsoleCommandEvent;

	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import moonshine.editor.text.TextEditor;
	import moonshine.editor.text.changes.TextEditorChange;
	import moonshine.editor.text.events.TextEditorChangeEvent;
	import moonshine.editor.text.lines.TextLineModel;

	import mx.utils.StringUtil;
	import moonshine.editor.text.lines.TextLineRenderer;
	import haxe.IMap;
	import haxe.ds.IntMap;
	import flash.text.TextFormat;
	import actionScripts.valueObjects.Settings;
	import feathers.skins.RectangleSkin;
	import feathers.graphics.FillStyle;
	import feathers.controls.ScrollPolicy;
	
	public class CommandLineEditor extends TextEditor
	{
		private var history:Array = [];
		private var historyIndex:int = -1;
		
		public function CommandLineEditor()
		{
			super();
			backgroundSkin = null;
			showLineNumbers = false;
			var textStyles:IntMap = new IntMap();
			textStyles.set(0, new TextFormat(Settings.font.defaultFontFamily, Settings.font.defaultFontSize, 0xdddddd));
			setParserAndTextStyles(null, textStyles);
			embedFonts = Settings.font.defaultFontEmbedded;

			this.addEventListener(TextEditorChangeEvent.TEXT_CHANGE, handleChange);
			this.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown, false, 10);
		}

		override public function initialize():void {
			super.initialize();
			_listView.scrollPolicyX = ScrollPolicy.OFF;
			_listView.scrollPolicyY = ScrollPolicy.OFF;
		}

		override public function createTextLineRenderer():TextLineRenderer {
			var textLineRenderer:TextLineRenderer = super.createTextLineRenderer();
			textLineRenderer.backgroundSkin = null;
			textLineRenderer.gutterBackgroundSkin = null;
			textLineRenderer.focusedBackgroundSkin = null;
			textLineRenderer.selectedTextBackgroundSkin = new RectangleSkin(FillStyle.SolidColor(0x676767));
			textLineRenderer.gutterPaddingLeft = 0.0;
			textLineRenderer.gutterPaddingRight = 0.0;
			return textLineRenderer;
		}
		
		private function handleChange(event:TextEditorChangeEvent):void
		{
			var changes:Array = event.changes;
			for(var i:int = 0 ; i < changes.length; i++) {
				var change:TextEditorChange = changes[i];
				if(change.newText != null && change.newText.length > 0) {
					applyChangeInsert(change);
				}
			}
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
						text = "";
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
					var line:String = lines.get(0).text;
					exec(line);
					
					// Reset the console
					text = "";
					
					break;
				}
			}
		}

        private function applyHistory():void
		{
			if (history.length == 0) return;
			text = history[historyIndex];
			setSelection(caretLineIndex, caretLine.text.length, caretLineIndex, caretLine.text.length);
		}
		
		// Used for pasting multi-line commands.
		private function applyChangeInsert(change:TextEditorChange):void
		{
			// Loop all lines and exec them in order
			if (lines.length > 1)
			{
				//run all but the last command
				for (var i:int = 0; i < lines.length - 1; i++)
				{
					var m:TextLineModel = TextLineModel(lines.get(i));
					exec(m.text);
				}
				
				//display the last command
				var lastLineText:String = lines.get(lines.length - 1).text;
				text = lastLineText;
				//and set selection at the end
				setSelection(0, lastLineText.length, 0, lastLineText.length)
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