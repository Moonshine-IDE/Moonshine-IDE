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
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.events.OpenFileEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.valueObjects.Position;

	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;

	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	
	import actionScripts.valueObjects.Location;

	public class GotoDefinitionManager
	{
		protected static const NON_WORD_CHARACTERS:Vector.<String> = new <String>[" ", "\t", ".", ":", ";", ",", "?", "+", "-", "*", "/", "%", "=", "!", "&", "|", "(", ")", "[", "]", "{", "}", "<", ">"];
		
		protected var editor:TextEditor;
		protected var model:TextEditorModel;

		protected var definitionOverlay:UIComponent;
		protected var savedLocation:Location;

		public function GotoDefinitionManager(editor:TextEditor, model:TextEditorModel)
		{
			this.editor = editor;
			this.model = model;

			definitionOverlay = new UIComponent();
			definitionOverlay.mouseEnabled = false;
			definitionOverlay.mouseChildren = false;
			definitionOverlay.focusEnabled = false;
			definitionOverlay.tabFocusEnabled = false;
			definitionOverlay.mouseFocusEnabled = false;
		}

		public function showDefinitionLink(locations:Vector.<Location>, position:Position):void
		{
			if(locations.length === 0)
			{
				this.closeDefinitionLink();
				return;
			}
			if(!definitionOverlay.isPopUp)
			{
				PopUpManager.addPopUp(definitionOverlay, editor, false);
				definitionOverlay.validateNow();
			}

			if(position === null)
			{
				this.closeDefinitionLink();
				return;
			}
			savedLocation = locations[0];
			var lineIndex:int = position.line;
			var charIndex:int = position.character;
			var line:TextLineModel = model.lines[lineIndex];
			var lineText:String = line.text;

			var startIndex:int = 0;
			var endIndex:int = lineText.length;
			for each(var char:String in NON_WORD_CHARACTERS)
			{
				var newStartIndex:int = lineText.lastIndexOf(char, charIndex - 1) + 1;
				if(newStartIndex > startIndex)
				{
					startIndex = newStartIndex;
				}
				var newEndIndex:int = lineText.indexOf(char, charIndex);
				if(newEndIndex !== -1 && newEndIndex < endIndex)
				{
					endIndex = newEndIndex;
				}
			}
			var startPosition:Point = editor.getXYForCharAndLine(startIndex, lineIndex);
			var endPosition:Point = editor.getXYForCharAndLine(endIndex, lineIndex);
			var lineHeight:Number = model.itemRenderersInUse[lineIndex - model.scrollPosition].height;
			definitionOverlay.move(startPosition.x, startPosition.y);
			definitionOverlay.graphics.clear();
			definitionOverlay.graphics.beginFill(0xff00ff, 0.5);
			definitionOverlay.graphics.drawRect(0, 0, endPosition.x - startPosition.x, lineHeight);
			definitionOverlay.graphics.endFill();
			editor.addEventListener(KeyboardEvent.KEY_UP, editor_onKeyUp);
			editor.addEventListener(KeyboardEvent.KEY_DOWN, editor_onKeyDown);
			editor.addEventListener(MouseEvent.ROLL_OUT, editor_onRollOut);
			editor.addEventListener(MouseEvent.MOUSE_DOWN, editor_onMouseDown);
		}

		public function closeDefinitionLink():void
		{
			if(!definitionOverlay.isPopUp)
			{
				return;
			}
			PopUpManager.removePopUp(definitionOverlay);
			editor.removeEventListener(KeyboardEvent.KEY_DOWN, editor_onKeyDown);
			editor.removeEventListener(MouseEvent.ROLL_OUT, editor_onRollOut);
			editor.removeEventListener(MouseEvent.MOUSE_DOWN, editor_onMouseDown);
		}

		private function editor_onRollOut(event:MouseEvent):void
		{
			closeDefinitionLink();
		}

		private function editor_onKeyUp(event:KeyboardEvent):void
		{
			if(event.keyCode !== Keyboard.CONTROL && event.keyCode !== Keyboard.COMMAND)
			{
				return;
			}
			closeDefinitionLink();
		}

		private function editor_onKeyDown(event:KeyboardEvent):void
		{
            if(event.keyCode === Keyboard.CONTROL || event.keyCode === Keyboard.COMMAND)
            {
				//it's possible that a key down event will repeatedly get
				//dispatched for the same key, and that will cause the link to
				//blink like crazy. seems to happen on windows, but not
				//necessarily macOS (but it won't hurt to check command too)
                return;
            }
			closeDefinitionLink();
		}

		private function editor_onMouseDown(event:MouseEvent):void
		{
			closeDefinitionLink();
			var openEvent:OpenFileEvent = new OpenFileEvent(OpenFileEvent.OPEN_FILE,
				new FileLocation(savedLocation.uri, true), savedLocation.range.start.line);
			openEvent.atChar = savedLocation.range.start.character;
			GlobalEventDispatcher.getInstance().dispatchEvent(openEvent);
		}
	}
}
