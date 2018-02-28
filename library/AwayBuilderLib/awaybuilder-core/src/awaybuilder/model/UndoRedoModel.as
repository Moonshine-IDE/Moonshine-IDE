package awaybuilder.model
{
    import awaybuilder.controller.history.HistoryEvent;
import awaybuilder.controller.history.UndoRedoEvent;

import org.robotlegs.mvcs.Actor;
	
	public class UndoRedoModel extends Actor
	{
		public function UndoRedoModel()
		{
			super();
		}
		
		private var _undoStack:Vector.<HistoryEvent> = new <HistoryEvent>[];
		private var _redoStack:Vector.<HistoryEvent> = new <HistoryEvent>[];

		public var maxUndoActions:int = 666;

		public function get canUndo():Boolean
		{
			return this._undoStack.length > 0;
		}
		
		public function get canRedo():Boolean
		{
			return this._redoStack.length > 0;
		}

        public function getLastActon():HistoryEvent
        {
            if( canUndo ) {
                return _undoStack[ _undoStack.length-1 ];
            }
            return null;
        }

		public function registerAction(event:HistoryEvent):void
		{
			this._redoStack.length = 0;
			this._undoStack.push(event);
			while(this._undoStack.length > this.maxUndoActions)
			{
				this._undoStack.shift();
			}
            dispatch( new UndoRedoEvent(UndoRedoEvent.UNDO_LIST_CHANGE) );
		}
		
		public function clear():void
		{
			this._undoStack.length = this._redoStack.length = 0;
		}
		
		public function undo():void
		{
			if(this._undoStack.length == 0)
			{
				return;
			}
            var event:HistoryEvent = this._undoStack.pop();
            var undoEvent:HistoryEvent = event.clone() as HistoryEvent;
            var undoValue:Object = undoEvent.oldValue;
            undoEvent.oldValue = undoEvent.newValue;
            undoEvent.newValue = undoValue;
			undoEvent.isRedoAction = false;
            undoEvent.isUndoAction = true;
			dispatch( undoEvent );
			this._redoStack.push(event);
            dispatch( new UndoRedoEvent(UndoRedoEvent.UNDO_LIST_CHANGE) );
		}
		
		public function redo():void
		{
			if(this._redoStack.length == 0)
			{
				return;
			}
			var event:HistoryEvent = this._redoStack.pop();
            var redoEvent:HistoryEvent = event.clone() as HistoryEvent;
			redoEvent.isRedoAction = true;
			redoEvent.isUndoAction = false;
            dispatch( redoEvent );
			this._undoStack.push(event);
            dispatch( new UndoRedoEvent(UndoRedoEvent.UNDO_LIST_CHANGE) );
		}
	}
}