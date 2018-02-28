package awaybuilder.controller.history
{
    import awaybuilder.controller.events.DocumentModelEvent;
    import awaybuilder.model.DocumentModel;
    import awaybuilder.model.UndoRedoModel;
    
    import org.robotlegs.mvcs.Command;

    public class HistoryCommandBase extends Command
    {
        [Inject]
        public var undoRedoModel:UndoRedoModel;
		
		[Inject]
		public var document:DocumentModel;
		
		protected function commitHistoryEvent( event:HistoryEvent ):void 
		{
			addToHistory( event );
			
			this.dispatch(new DocumentModelEvent(DocumentModelEvent.OBJECTS_UPDATED));
			document.empty = false;
			document.edited = true;
		}
		
		protected function saveOldValue( event:HistoryEvent, prevValue:Object ):void 
		{
			if( !event.oldValue ) 
			{
				event.oldValue = prevValue;
			}
		}
        protected function addToHistory(event:HistoryEvent):void 
		{
            if (!event.isUndoAction&&!event.isRedoAction)
            {
                if( event.canBeCombined )
                {
                    var lastEvent:HistoryEvent = undoRedoModel.getLastActon();
                    if( lastEvent && lastEvent.canBeCombined && (lastEvent.type==event.type) && (event.timeStamp-lastEvent.timeStamp<150) )
                    {
						lastEvent.timeStamp = event.timeStamp;
                        lastEvent.newValue = event.newValue;
                        return;
                    }
                }

                undoRedoModel.registerAction(event.clone() as HistoryEvent);
            }
        }
    }
}