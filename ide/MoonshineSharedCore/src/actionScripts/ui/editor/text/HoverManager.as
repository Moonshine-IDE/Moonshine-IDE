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
	import com.dogcatfishdish.markdown.Markdown;
	import moonshine.lsp.Hover;

	public class HoverManager
	{
		private static const TOOL_TIP_ID:String = "HoverManagerToolTip";

		protected var editor:TextEditor;
		protected var model:TextEditorModel;

		public function HoverManager(editor:TextEditor, model:TextEditorModel)
		{
			this.editor = editor;
			this.model = model;
		}

		public function showHover(hover:Hover):void
		{
			if(!hover || !hover.contents)
			{
				this.closeHover();
				return;
			}

			var hoverText:String = "";
			if(hover.contents is Array)
			{
				var contents:Array = hover.contents;
				var contentsCount:int = contents.length;
				for(var i:int = 0; i < contentsCount; i++)
				{
					if(i > 0)
					{
						hoverText += "\n\n";
					}
					var content:String = parseHoverText(contents[i]);
					content = Markdown.MakeHtml(content, true);
					hoverText += content;
				}
			}
			else
			{
				content = parseHoverText(hover.contents);
				content = Markdown.MakeHtml(content, true);
				hoverText += content;
			}
			if(hoverText.length == 0)
			{
				//nothing to display
				this.closeHover();
				return;
			}
			editor.setTooltip(TOOL_TIP_ID, hoverText, true);
		}

		private function parseHoverText(contents:Object):String
		{
			if(contents == null)
			{
				return null;
			}
			if(contents is String)
			{
				return contents as String;
			}
			return contents.value;
		}

		public function closeHover():void
		{
			editor.setTooltip(TOOL_TIP_ID, null);
		}
	}
}
