package actionScripts.ui.editor.text
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import flashx.textLayout.conversion.TextConverter;

	import mx.containers.VBox;
	import mx.managers.PopUpManager;

	import spark.components.RichText;

	public class EditorToolTipManager
	{
		private static const DELAY_MS:int = 350;

		private var tooltip:VBox;
		private var tooltipData:Object = {};
		private var tooltipTimeoutHandle:int = -1;

		protected var editor:TextEditor;
		protected var model:TextEditorModel;

		public function EditorToolTipManager(editor:TextEditor, model:TextEditorModel)
		{
			this.editor = editor;
			this.model = model;

			tooltip = new VBox();
			tooltip.styleName = "toolTip";
			tooltip.focusEnabled = false;
			tooltip.mouseEnabled = false;
			tooltip.mouseChildren = false;
		}

		public function setTooltip(id:String, value:String):void
		{
			if(value === null)
			{
				if(!(id in tooltipData))
				{
					return;
				}
				var text:RichText = tooltipData[id];
				tooltip.removeElement(text);
				delete tooltipData[id];
				var stillHasData:Boolean = false;
				for(var key:String in tooltipData)
				{
					stillHasData = true;
					break;
				}
				if(!stillHasData)
				{
					closeTooltip();
					return;
				}
			}
			else
			{
				if(id in tooltipData)
				{
					text = tooltipData[id];
				}
				else
				{
					text = new RichText();
					tooltip.addElement(text);
					tooltipData[id] = text;
				}
				text.textFlow = TextConverter.importToFlow(value, TextConverter.PLAIN_TEXT_FORMAT);
			}
			if(tooltip.isPopUp)
			{
				//we're already showing the tooltip, so simply reposition it,
				//if needed
				this.showTooltipAfterDelay();
				return;
			}
			//if we're still waiting to show the last one, clear it
			if(tooltipTimeoutHandle !== -1)
			{
				clearTimeout(tooltipTimeoutHandle);
			}
			tooltipTimeoutHandle = setTimeout(showTooltipAfterDelay, DELAY_MS);
		}

		public function showTooltipAfterDelay():void
		{
			tooltipTimeoutHandle = -1;
			if(!tooltip.isPopUp)
			{
				PopUpManager.addPopUp(tooltip, editor, false);
				editor.addEventListener(KeyboardEvent.KEY_DOWN, editor_onKeyDown);
				editor.addEventListener(MouseEvent.ROLL_OUT, editor_onRollOut);
			}
			tooltip.validateNow();
			var tooltipX:Number = tooltip.stage.mouseX;
			var tooltipY:Number = tooltip.stage.mouseY - (tooltip.height + 15);
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
		}

		public function closeTooltip():void
		{
			if(tooltipTimeoutHandle !== -1)
			{
				clearTimeout(tooltipTimeoutHandle);
				tooltipTimeoutHandle = -1;
			}
			if(!tooltip.isPopUp)
			{
				return;
			}
			PopUpManager.removePopUp(tooltip);
			editor.removeEventListener(KeyboardEvent.KEY_DOWN, editor_onKeyDown);
			editor.removeEventListener(MouseEvent.ROLL_OUT, editor_onRollOut);
		}

		private function editor_onRollOut(event:MouseEvent):void
		{
			closeTooltip();
		}

		private function editor_onKeyDown(event:KeyboardEvent):void
		{
			closeTooltip();
		}
	}
}