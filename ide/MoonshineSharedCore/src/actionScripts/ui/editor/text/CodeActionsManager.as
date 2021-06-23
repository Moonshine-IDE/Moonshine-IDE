package actionScripts.ui.editor.text
{
	import flash.events.FocusEvent;

	import moonshine.lsp.CodeAction;

	public class CodeActionsManager
	{
		protected var editor:TextEditor;
		protected var model:TextEditorModel;
		
		private var savedCodeActions:Vector.<CodeAction>;

		public function CodeActionsManager(editor:TextEditor, model:TextEditorModel)
		{
			this.editor = editor;
			this.model = model;
			editor.addEventListener(FocusEvent.FOCUS_OUT, editor_onFocusOut);
		}

		public function showCodeActions(codeActions:Vector.<CodeAction>):void
		{
			this.savedCodeActions = codeActions;

			var lines:Vector.<TextLineModel> = model.lines;
			var linesCount:int = lines.length;
			for(var i:int = 0; i < linesCount; i++)
			{
				var line:TextLineModel = lines[i];
				if(!line.codeActions)
				{
					line.codeActions = new <CodeAction>[];
				}
				else
				{
					line.codeActions.length = 0;
				}
			}
			if (model.selectedLine)
			{
				model.selectedLine.codeActions = codeActions.filter(function(codeAction:CodeAction, index:int, original:Vector.<CodeAction>):Boolean
				{
					if(codeAction.kind == "source.organizeImports")
					{
						//we don't display this one in the light bulb
						return false;
					}
					return true;
				});
			}
			editor.invalidateLines();
		}

		private function editor_onFocusOut(event:FocusEvent):void
		{
			this.showCodeActions(new <CodeAction>[]);
		}
	}
}
