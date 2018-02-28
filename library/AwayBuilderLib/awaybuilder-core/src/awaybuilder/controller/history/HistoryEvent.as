package awaybuilder.controller.history
{
    import flash.events.Event;
    import flash.utils.getTimer;

    public class HistoryEvent extends Event
    {
        public function HistoryEvent( type:String, newValue:Object, oldValue:Object = null ) {
            super( type, false, false);
            this.newValue = newValue;
			this.oldValue = oldValue;
        }

        public var oldValue:Object; // items that we have to remove
        public var newValue:Object; // items that we have to add
		
        public var isUndoAction:Boolean = false;
		public var isRedoAction:Boolean = false;
		
		public var timeStamp:int = getTimer();

        public var canBeCombined:Boolean = false;

        override public function clone():Event
        {
            return new HistoryEvent(this.type, this.newValue, this.oldValue);
        }
    }
}
