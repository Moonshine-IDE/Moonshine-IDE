package awaybuilder.view.components.events
{
	import flash.events.Event;
	
	public class ToolBarEvent extends Event
	{
		public static const NEW_DOCUMENT:String = "newDocument";
		public static const OPEN_DOCUMENT:String = "openDocument";
		public static const IMPORT_DOCUMENT:String = "importDocument";
		public static const SAVE_DOCUMENT:String = "saveDocument";
		
		public static const APPLICATION_SETTINGS:String = "settings";
		public static const DOCUMENT_SETTINGS:String = "documentSettings";
		
		public static const UNDO:String = "undo";
		public static const REDO:String = "redo";
		
//		public static const DOWNLOAD:String = "download";
//		public static const HOME:String = "home";
		
//		public static const SWITCH_MOUSE_TO_PAN:String = "switchMouseToPan";
//		public static const SWITCH_MOUSE_TO_SELECT:String = "switchMouseToSelect";
		
		public static const SWITCH_CAMERA_TO_FREE:String = "switchCameraToFree";
		public static const SWITCH_CAMERA_TO_TARGET:String = "switchCameraToTarget";
		
		public static const TRANSFORM_TRANSLATE:String = "transformTranslate";
		public static const TRANSFORM_SCALE:String = "transformScale";
		public static const TRANSFORM_ROTATE:String = "transformRotate";
		
		public static const CLIPBOARD_CUT:String = "clipboardCut";
		public static const CLIPBOARD_COPY:String = "clipboardCopy";
		public static const CLIPBOARD_PASTE:String = "clipboardPaste";
		
		public static const DELETE_SELECTION:String = "deleteSelection";
		public static const FOCUS_OBJECT:String = "focusOnObject";
		
		public function ToolBarEvent(type:String)
		{
			super(type, false, false);
		}
		
		override public function clone():Event
		{
			return new ToolBarEvent(this.type);
		}
	}
}