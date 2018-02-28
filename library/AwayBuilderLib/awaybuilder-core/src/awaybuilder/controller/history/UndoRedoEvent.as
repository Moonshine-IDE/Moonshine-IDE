package awaybuilder.controller.history
{
    import flash.events.Event;

    public class UndoRedoEvent extends Event {

        public static const UNDO:String = "undo";
        public static const REDO:String = "redo";

        public static const UNDO_LIST_CHANGE:String = "undoListChanged";

        public function UndoRedoEvent( type:String ) {
            super( type,  false, false );
        }
    }
}
