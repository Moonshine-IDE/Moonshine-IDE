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
	import spark.components.TextArea;
	import spark.components.VScrollBar;
	import spark.utils.TextFlowUtil;
	
	import actionScripts.ui.editor.text.TextEditorModel;
	import actionScripts.ui.editor.text.TextLineModel;
	
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.ParagraphElement;
	import flashx.textLayout.elements.TextFlow;
	
	public class ConsoleViewTextArea extends TextArea
	{
		protected var model:TextEditorModel;
		
		public function ConsoleViewTextArea()
		{
			super();
			this.setStyle("contentBackgroundColor",0x373737);
			this.setStyle("contentBackgroundAlpha",0.9);
			this.setStyle("borderVisible",false)
			this.percentHeight = 100;
			this.percentWidth = 100;
		}
		
		public function get numLines():int
		{
			return this.heightInLines;
		}
		
		public function get numVisibleLines():int
		{
			return 0;
		}
		
		override public function setFocus():void
		{
			super.setFocus();
			// Never allow focus, which means no blinky cursor
		}
		public function appendtext(text:*):int
		{
			if (text is String)
			{
				var lines:Array = text.split('\n');
				var p:ParagraphElement;
				var tf:TextFlow;
				var pe:ParagraphElement;
				var fe:FlowElement;
				for (var i:int = 0; i < lines.length; i++)
				{
					p = new ParagraphElement();
					tf = TextConverter.importToFlow(String(lines[i]) + "\n", TextConverter.TEXT_FIELD_HTML_FORMAT);
					pe = tf.mxmlChildren[0];
					for each (fe in pe.mxmlChildren)
					p.addChild(fe);
					
					this.textFlow.addChild(p);
					//model.lines.push( new TextLineModel(lines[i]) );
					//this.appendText(lines[i] + "\n");
				}
				
				/*model.scrollPosition = Math.max(0, model.lines.length-model.renderersNeeded+1);
				invalidateLines();*/
				callLater(setScroll);
				return this.numLines;
			} 
			else if (text is Vector.<TextLineModel>)
			{
				for (i = 0; i < text.length; i++)
				{
					p = new ParagraphElement();
					tf = TextConverter.importToFlow(String(text[i]) + "\n", TextConverter.PLAIN_TEXT_FORMAT);
					//tf = TextFlowUtil.importFromString(String("<p>"+text[i])+"</p>");
					pe = tf.mxmlChildren[0];
					for each (fe in pe.mxmlChildren)
					p.addChild(fe);
					this.textFlow.addChild(p);
					//model.lines.push( text[i] );
					//this.appendText( String(text[i]) +"\n");
				}
				
				/*model.scrollPosition = Math.max(0, model.lines.length-model.renderersNeeded+1);
				invalidateLines();*/
				callLater(setScroll);
				return this.numLines;
			}
			// Remove initial empty line (first time anything is outputted)
			return 0;
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