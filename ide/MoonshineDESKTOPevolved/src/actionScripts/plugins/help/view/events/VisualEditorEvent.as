package actionScripts.plugins.help.view.events
{
    import flash.events.Event;

    public class VisualEditorEvent extends Event
    {
        public static const DUPLICATE_ELEMENT:String = "duplicateElement";

        public function VisualEditorEvent(type:String)
        {
            super(type, false, false);
        }

        override public function clone():Event
        {
            return new VisualEditorEvent(type);
        }
    }
}
