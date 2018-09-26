package actionScripts.ui.editor.text
{
	import actionScripts.utils.TextUtil;
	import actionScripts.valueObjects.Diagnostic;
	import actionScripts.valueObjects.Position;
	import actionScripts.valueObjects.Range;

	import flash.events.MouseEvent;
	import flash.geom.Point;
	import actionScripts.valueObjects.Command;
	import actionScripts.valueObjects.CodeAction;

	public class CodeActionsManager
	{
		protected var editor:TextEditor;
		protected var model:TextEditorModel;
		
		private var savedCodeActions:Vector.<CodeAction>;

		public function CodeActionsManager(editor:TextEditor, model:TextEditorModel)
		{
			this.editor = editor;
			this.model = model;
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
				model.selectedLine.codeActions = codeActions.slice();
			}
			editor.invalidateLines();
		}
	}
}
