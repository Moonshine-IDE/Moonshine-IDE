package actionScripts.ui.editor.text
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.Configuration;
	import flashx.textLayout.elements.LinkElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.FlowElementMouseEvent;
	import flashx.textLayout.formats.TextDecoration;
	import flashx.textLayout.formats.TextLayoutFormat;

	import mx.containers.VBox;
	import mx.managers.PopUpManager;

	import spark.components.Group;
	import spark.components.RichEditableText;
	import spark.layouts.VerticalLayout;

	public class EditorToolTipManager
	{
		private static const DELAY_MS:int = 350;

		private var tooltip:VBox;
		private var tooltipGroup:Group;
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
			tooltip.maxWidth = 450;
			tooltip.addEventListener(MouseEvent.ROLL_OUT, tooltip_onRollOut);

			//RichText won't wrap correctly if added to the VBox above, for some
			//reason, so we're going to add it to this internal Group instead
			tooltipGroup = new Group();
			tooltipGroup.percentWidth = 100;
			tooltipGroup.maxWidth = 450;
			var groupLayout:VerticalLayout = new VerticalLayout();
			groupLayout.gap = 20;
			tooltipGroup.layout = groupLayout;
			tooltip.addElement(tooltipGroup);
		}

		public function setTooltip(id:String, value:String, html:Boolean = false):void
		{
			if(value === null)
			{
				if(!(id in idToValue))
				{
					//there's nothing to clear
					return;
				}
				var richText:RichEditableText = RichEditableText(idToRichText[id]);
				tooltipGroup.removeElement(richText);
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
					richText = RichEditableText(idToRichText[id]);
				}
				else
				{
					richText = new RichEditableText();
					richText.editable = false;
					richText.percentWidth = 100;
					tooltipGroup.addElement(richText);
					idToRichText[id] = richText;
				}
				var config:Configuration = new Configuration();
				var linkFormat:TextLayoutFormat = new TextLayoutFormat();
				//we can't set this in CSS, apparently, so do it manually here
				linkFormat.color = 0xffffff;
				linkFormat.textDecoration = TextDecoration.UNDERLINE;
				config.defaultLinkNormalFormat = linkFormat;
				config.defaultLinkHoverFormat = linkFormat;
				config.defaultLinkActiveFormat = linkFormat;
				var format:String = html ? TextConverter.TEXT_FIELD_HTML_FORMAT : TextConverter.PLAIN_TEXT_FORMAT;
				var textFlow:TextFlow = TextConverter.importToFlow(value, format, config);
				textFlow.addEventListener(FlowElementMouseEvent.CLICK, function(event:FlowElementMouseEvent):void
				{
    				var link:LinkElement = event.flowElement as LinkElement;
					if(!link)
					{
						return;
					}
					var href:String = link.href;
					if(href.indexOf("http://") == 0 || href.indexOf("https://") == 0)
					{
						//let this link work normally
						return;
					}
					//might be a special URI scheme defined by a language server
					event.preventDefault();
				});
				richText.textFlow = textFlow;
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

			//to get an accurate width/height, we need to validate first
			tooltip.maxHeight = NaN;
			tooltip.explicitWidth = NaN;
			tooltip.validateNow();
			//for some reason, it can start wrapping at max - 1...
			if(tooltip.width >= 449) {
				//if we reached the maxWidth, we should also set a maxHeight
				//however, if both maxWidth and maxHeight are set, it might set
				//the width smaller than the maxWidth, so set an explicitWidth
				//instead to force it to work like we want -JT
				tooltip.explicitWidth = 450;
				tooltip.maxHeight = 450;
				tooltip.validateNow();
			}

			var tooltipX:Number = tooltip.stage.mouseX - 30;
			var tooltipY:Number = tooltip.stage.mouseY - (tooltip.height + 10);
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

				var text:RichEditableText = RichEditableText(idToRichText[id]);
				tooltipGroup.removeElement(text);
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

		private function tooltip_onRollOut(event:MouseEvent):void
		{
			closeTooltip();
		}

		private function editor_onRollOut(event:MouseEvent):void
		{
			if(event.relatedObject != null && (tooltip == event.relatedObject || tooltip.contains(event.relatedObject)))
			{
				//if we're over the tooltip, don't close it!
				//we'll close the tooltip when the mouse rolls out of it
				return;
			}
			closeTooltip();
		}

		private function editor_onKeyDown(event:KeyboardEvent):void
		{
			closeTooltip();
		}
	}
}