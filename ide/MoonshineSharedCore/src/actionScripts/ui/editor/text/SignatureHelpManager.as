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
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import mx.containers.HBox;
	import mx.managers.PopUpManager;
	
	import spark.components.RichText;
	
	import actionScripts.valueObjects.ParameterInformation;
	import actionScripts.valueObjects.SignatureHelp;
	import actionScripts.valueObjects.SignatureInformation;
	
	import flashx.textLayout.conversion.TextConverter;

	public class SignatureHelpManager
	{
		protected var editor:TextEditor;
		protected var model:TextEditorModel;

		private var view:SignatureHelpView;
		private var tooltipCaret:int;

		public function get isActive():Boolean
		{
			return view.isPopUp;
		}

		public function SignatureHelpManager(editor:TextEditor, model:TextEditorModel)
		{
			this.editor = editor;
			this.model = model;

			view = new SignatureHelpView();
		}

		public function showSignatureHelp(data:SignatureHelp):void
		{
			if(data == null)
			{
				closeSignatureHelp();
				return;
			}
			var signatures:Vector.<SignatureInformation> = data.signatures;
			var activeSignature:int = data.activeSignature;
			var activeParameter:int = data.activeParameter;
			view.signatures = signatures;
			view.activeSignature = activeSignature;
			view.activeParameter = activeParameter;
			if(activeSignature >= 0 && !view.isPopUp)
			{
				PopUpManager.addPopUp(view, editor, false);
				var lineText:String = model.lines[model.selectedLineIndex].text;
				tooltipCaret = lineText.lastIndexOf("(", model.caretIndex);
				view.validateNow();
				var position:Point = editor.getPointForIndex(model.caretIndex);
				var tooltipX:Number = position.x + editor.horizontalScrollBar.scrollPosition;
				var tooltipY:Number = position.y - (view.height + 15);
				var maxTooltipX:Number = view.stage.stageWidth - view.width;
				if(tooltipX > maxTooltipX)
				{
					tooltipX = maxTooltipX;
				}
				if(tooltipY < 0)
				{
					tooltipY = 0;
				}
				view.move(tooltipX, tooltipY);
				editor.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				editor.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			}
		}

		public function closeSignatureHelp():void
		{
			if(!this.isActive)
			{
				return;
			}
			editor.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			editor.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			PopUpManager.removePopUp(view);
		}

		private function onMouseDown(event:MouseEvent):void
		{
			this.closeSignatureHelp();
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ESCAPE || e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN ||
				String.fromCharCode(e.charCode) == ')' || model.caretIndex <= tooltipCaret)
			{
				this.closeSignatureHelp();
			}
		}
	}
}
