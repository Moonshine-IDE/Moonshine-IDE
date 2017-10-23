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
		private var idToRichText:Object = {};
		private var idToValue:Object = {};
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
				if(!(id in idToValue))
				{
					//there's nothing to clear
					return;
				}
				var richText:RichText = idToRichText[id];
				tooltip.removeElement(richText);
				delete idToRichText[id];
				delete idToValue[id];
				var stillHasData:Boolean = false;
				for(var key:String in idToValue)
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
				var oldValue:String = idToValue[id];
				if(oldValue === value)
				{
					//the value has not changed, so ignore it
					return;
				}
				idToValue[id] = value;
				if(id in idToRichText)
				{
					richText = idToRichText[id];
				}
				else
				{
					richText = new RichText();
					tooltip.addElement(richText);
					idToRichText[id] = richText;
				}
				richText.textFlow = TextConverter.importToFlow(value, TextConverter.PLAIN_TEXT_FORMAT);
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
			
			//previously, we listened for these events after the timeout, but
			//it's actually better to listen immediately so that we can clear
			//the timeout because it's possible for the mouse to move away or
			//a key to be pressed before the timeout and that could show the
			//tooltip unexpectedly
			editor.addEventListener(KeyboardEvent.KEY_DOWN, editor_onKeyDown);
			editor.addEventListener(MouseEvent.ROLL_OUT, editor_onRollOut);
		}

		public function showTooltipAfterDelay():void
		{
			tooltipTimeoutHandle = -1;
			if(!tooltip.isPopUp)
			{
				PopUpManager.addPopUp(tooltip, editor, false);
			}

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
			for(var id:String in idToValue)
			{
				delete idToValue[id];

				var text:RichText = idToRichText[id];
				tooltip.removeElement(text);
				delete idToRichText[id];
			}
			//previously, these listeners were only removed if the tooltip was a
			//popup, but now they are added before the tooltip is displayed, so
			//they always need to be removed
			editor.removeEventListener(KeyboardEvent.KEY_DOWN, editor_onKeyDown);
			editor.removeEventListener(MouseEvent.ROLL_OUT, editor_onRollOut);
			if(!tooltip.isPopUp)
			{
				return;
			}
			PopUpManager.removePopUp(tooltip);
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