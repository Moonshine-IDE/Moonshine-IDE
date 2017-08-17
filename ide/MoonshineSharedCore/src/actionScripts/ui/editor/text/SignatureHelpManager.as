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

		private var tooltip:HBox;
		private var tooltipText:RichText;
		private var tooltipCaret:int;

		public function get isActive():Boolean
		{
			return tooltip.isPopUp;
		}

		public function SignatureHelpManager(editor:TextEditor, model:TextEditorModel)
		{
			this.editor = editor;
			this.model = model;

			tooltip = new HBox();
			tooltip.styleName = "toolTip";
			tooltipText = new RichText();
			tooltip.focusEnabled = false;
			tooltip.mouseEnabled = false;
			tooltip.mouseChildren = false;
			tooltip.addElement(tooltipText);
		}

		public function showSignatureHelp(data:SignatureHelp):void
		{
			var signatures:Vector.<SignatureInformation> = data.signatures;
			var activeSignature:int = data.activeSignature;
			var activeParameter:int = data.activeParameter;
			if(activeSignature >= 0)
			{
				var signature:SignatureInformation = signatures[activeSignature];
				var parameters:Vector.<ParameterInformation> = signature.parameters;
				var signatureParts:Array = signature.label.split(/[\(\)]/);
				var signatureHelpText:String = signatureParts[0] + "(";
				var parametersText:String = signatureParts[1];
				var parameterParts:Array = parametersText.split(",");
				var parameterCount:int = parameters.length;
				for(var i:int = 0; i < parameterCount; i++)
				{
					if(i > 0)
					{
						signatureHelpText += ",";
					}
					var partText:String = parameterParts[i];
					if(i === activeParameter)
					{
						signatureHelpText += "<b>";
					}
					signatureHelpText += partText;
					if(i === activeParameter)
					{
						signatureHelpText += "</b>";
					}
				}
				signatureHelpText += ")";
				if(signatureParts.length > 2)
				{
					signatureHelpText += signatureParts[2];
				}
				tooltipText.textFlow = TextConverter.importToFlow(signatureHelpText, TextConverter.TEXT_FIELD_HTML_FORMAT);
				if(!tooltip.isPopUp)
				{
					PopUpManager.addPopUp(tooltip, editor, false);
					var lineText:String = model.lines[model.selectedLineIndex].text;
					tooltipCaret = lineText.lastIndexOf("(", model.caretIndex);
					tooltip.validateNow();
					var position:Point = editor.getPointForIndex(model.caretIndex);
					var tooltipX:Number = position.x + editor.horizontalScrollBar.scrollPosition;
					var tooltipY:Number = position.y - (tooltip.height + 15);
					var maxTooltipX:Number = tooltip.stage.stageWidth - tooltip.width;
					if(tooltipX > maxTooltipX)
					{
						tooltipX = maxTooltipX;
					}
					if(tooltipY < 0)
					{
						tooltipY = 0;
					}
					tooltip.move(tooltipX, tooltipY);
					editor.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
					editor.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				}
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
			PopUpManager.removePopUp(tooltip);
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
