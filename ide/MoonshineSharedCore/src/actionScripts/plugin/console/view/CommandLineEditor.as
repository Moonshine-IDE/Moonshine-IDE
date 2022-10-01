////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
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