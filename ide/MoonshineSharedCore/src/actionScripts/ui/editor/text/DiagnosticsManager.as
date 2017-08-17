package actionScripts.ui.editor.text
{
	import actionScripts.utils.TextUtil;
	import actionScripts.valueObjects.Diagnostic;
	import actionScripts.valueObjects.Position;
	import actionScripts.valueObjects.Range;

	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class DiagnosticsManager
	{
		private static const TOOL_TIP_ID:String = "DiagnosticsManagerToolTip";
		
		protected var editor:TextEditor;
		protected var model:TextEditorModel;
		
		private var savedDiagnostics:Vector.<Diagnostic>;
		private var lastDiagnostic:Diagnostic;

		public function DiagnosticsManager(editor:TextEditor, model:TextEditorModel)
		{
			this.editor = editor;
			this.model = model;
		}

		public function showDiagnostics(diagnostics:Vector.<Diagnostic>):void
		{
			this.savedDiagnostics = diagnostics;
			this.closeTooltip();
			editor.validateNow();
			var lines:Vector.<TextLineModel> = model.lines;
			var linesCount:int = lines.length;
			for(var i:int = 0; i < linesCount; i++)
			{
				var line:TextLineModel = lines[i];
				if(!line.diagnostics)
				{
					line.diagnostics = new <Diagnostic>[];
				}
				else
				{
					line.diagnostics.length = 0;
				}
			}
			var diagnosticsCount:int = diagnostics.length;
			for(i = 0; i < diagnosticsCount; i++)
			{
				var diagnostic:Diagnostic = diagnostics[i];
				var range:Range = diagnostic.range;
				var start:Position = range.start;
				var end:Position = range.end;
				var startLine:int = start.line;
				var endLine:int = end.line;
				var startChar:int = start.character;
				var endChar:int = end.character;
				if(startLine === endLine && endChar === startChar)
				{
					//if the start and end are the same, try to extend the
					//underline to the end of the current word

					//default to the end of the line, since we might not
					//find a character that ends the word
					line = lines[startLine];
					//update the end character so that it matches what is
					//displayed in the UI
					end.character = TextUtil.endOfWord(line.text, startChar);
				}

				line = lines[startLine];
				line.diagnostics.push(diagnostic);
				if(startLine !== endLine)
				{
					//the diagnostic is on two lines!
					line = lines[endLine];
					line.diagnostics.push(diagnostic);
				}
			}
			editor.invalidateLines();

			if(savedDiagnostics && savedDiagnostics.length > 0)
			{
				editor.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
			else
			{
				editor.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
		}

		public function closeTooltip():void
		{
			lastDiagnostic = null;
			editor.setTooltip(TOOL_TIP_ID, null);
		}

		private function onMouseMove(event:MouseEvent):void
		{
			var globalXY:Point = new Point(event.stageX, event.stageY);
			var charAndLine:Point = editor.getCharAndLineForXY(globalXY, false);
			if(!charAndLine)
			{
				this.closeTooltip();
				return;
			}
			var line:int = charAndLine.y;
			var char:int = charAndLine.x;
			var filtered:Vector.<Diagnostic> = savedDiagnostics.filter(function(item:Diagnostic, index:int, source:Vector.<Diagnostic>):Boolean
			{
				var range:Range = item.range;
				var start:Position = range.start;
				var end:Position = range.end;
				var startLine:int = start.line;
				var endLine:int = end.line;
				if(line < startLine || line > endLine)
				{
					return false;
				}
				if(startLine === endLine)
				{
					return char >= start.character && char <= end.character; 
				}
				if(line === startLine)
				{
					return char > start.character;
				}
				return char < end.character;
			});
			if(filtered.length === 0)
			{
				this.closeTooltip();
				return;
			}
			var diagnostic:Diagnostic = filtered[0];
			if(lastDiagnostic === diagnostic)
			{
				//it's the same one so do nothing!
				return;
			}
			lastDiagnostic = diagnostic;

			editor.setTooltip(TOOL_TIP_ID, diagnostic.message);
		}
	}
}
