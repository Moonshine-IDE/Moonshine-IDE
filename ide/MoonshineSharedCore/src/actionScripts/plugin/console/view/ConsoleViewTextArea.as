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
    import spark.components.RichEditableText;
    import spark.components.TextArea;
    import spark.components.VScrollBar;
    
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.plugin.console.ConsoleTextLineModel;
    import actionScripts.ui.editor.text.TextLineModel;
    
    import flashx.textLayout.conversion.TextConverter;
    import flashx.textLayout.elements.FlowElement;
    import flashx.textLayout.elements.ParagraphElement;
    import flashx.textLayout.elements.TextFlow;
    import flashx.textLayout.events.FlowElementMouseEvent;
    
    import no.doomsday.console.core.events.ConsoleEvent;
	
	public class ConsoleViewTextArea extends TextArea
	{	
		public function ConsoleViewTextArea()
		{
			super();
			this.setStyle("contentBackgroundColor",0x373737);
			this.setStyle("contentBackgroundAlpha",0.9);
			this.setStyle("borderVisible",false);
			
			this.percentHeight = 100;
			this.percentWidth = 100;
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			if (instance == textDisplay)
			{
				(textDisplay as RichEditableText).textFlow.addEventListener(ConsoleEvent.REPORT_A_BUG, onReportBugFromConsole, false, 0, true);
			}
		}
		
		public function get numLines():int
		{
			return this.heightInLines;
		}
		
		public function get numVisibleLines():int
		{
			return 0;
		}

		public function appendtext(text:*):int
		{
            var linesCount:int;
			if (text is String)
			{
				var lines:Array = text.split('\n');
				linesCount = lines.length;
				var p:ParagraphElement;
				var tf:TextFlow;
				var pe:ParagraphElement;
				var fe:FlowElement;
				for (var i:int = 0; i < linesCount; i++)
				{
					p = new ParagraphElement();
					tf = TextConverter.importToFlow(String(lines[i]) + "\n", TextConverter.TEXT_FIELD_HTML_FORMAT);
					pe = tf.mxmlChildren[0];
					for each (fe in pe.mxmlChildren)
                    {
                        p.addChild(fe);
                    }

					this.textFlow.addChild(p);
				}
				
				callLater(setScroll);
				return this.numLines;
			} 
			else if (text is Vector.<TextLineModel>)
			{
                linesCount = text.length;
				for (i = 0; i < linesCount; i++)
				{
					p = new ParagraphElement();
					if (text[i] is ConsoleTextLineModel)
					{
						p.color = (text[i] as ConsoleTextLineModel).getTextColor();
					}

					tf = TextConverter.importToFlow(String(text[i]) + "\n", TextConverter.PLAIN_TEXT_FORMAT);
					pe = tf.mxmlChildren[0];
					for each (fe in pe.mxmlChildren)
					{
						p.addChild(fe);
					}
					this.textFlow.addChild(p);
				}
				
				callLater(setScroll);
				return this.numLines;
			}
			else if (text is ParagraphElement)
			{
				this.textFlow.addChild(text);
				callLater(setScroll);
			}
			
			// Remove initial empty line (first time anything is outputted)
			return 0;
		}
		
		private function onReportBugFromConsole(event:FlowElementMouseEvent):void
		{
			GlobalEventDispatcher.getInstance().dispatchEvent(new ConsoleEvent(ConsoleEvent.REPORT_A_BUG));
		}
		
		private function setScroll():void
		{
			var scrollBar:VScrollBar = this.scroller.verticalScrollBar;
			scrollBar.value = scrollBar.maximum;
			this.validateNow();
			if (scrollBar.value != scrollBar.maximum) {
				scrollBar.value = scrollBar.maximum;
				this.validateNow();
			}
		}
	}
}