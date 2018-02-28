package awaybuilder.controller.history
{
    import awaybuilder.model.DocumentModel;
    import awaybuilder.model.UndoRedoModel;

    import org.robotlegs.mvcs.Command;

    public class UndoCommand extends Command
    {
        [Inject]
        public var undoRedoModel:UndoRedoModel;

        [Inject]
        public var event:UndoRedoEvent;

        [Inject]
        public var document:DocumentModel;

        override public function execute():void
        {
            undoRedoModel.undo();
            document.edited = true;
        }
    }
}