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
	import __AS3__.vec.Vector;
	
	import actionScripts.ui.editor.text.TextEditor;
	import actionScripts.ui.editor.text.TextLineModel;
	
	public class ConsoleHistoryTextArea extends TextEditor
	{

		public function ConsoleHistoryTextArea()
		{
			super(true);
		}
		
		public function get numLines():int
		{
			return model.lines.length;
		}
		
		public function get numVisibleLines():int
		{
			return model.renderersNeeded;
		}
		
		override public function setFocus():void
		{
			super.setFocus();
			// Never allow focus, which means no blinky cursor
			hasFocus = false;
		}
		
		public function appendText(text:*):int
		{
			invalidateLines();
			
			// Remove initial empty line (first time anything is outputted)
			if (model.lines.length == 1)
			{
				if (model.selectedLine.text == "")
				{
					model.lines = new Vector.<TextLineModel>(0);	
				}
			}
			
			if (text is String)
			{
				var lines:Array = text.split('\n');
				for (var i:int = 0; i < lines.length; i++)
				{
					model.lines.push( new TextLineModel(lines[i]) );
				}
				
				model.scrollPosition = Math.max(0, model.lines.length-model.renderersNeeded+1);
				invalidateLines();
				
				return lines.length;
			} 
			else if (text is Vector.<TextLineModel>)
			{
				for (i = 0; i < text.length; i++)
				{
					model.lines.push( text[i] );
				}
				
				model.scrollPosition = Math.max(0, model.lines.length-model.renderersNeeded+1);
				invalidateLines();
				
				return text.length;
			}
			
			
			return 0;
		}
		
	}
}