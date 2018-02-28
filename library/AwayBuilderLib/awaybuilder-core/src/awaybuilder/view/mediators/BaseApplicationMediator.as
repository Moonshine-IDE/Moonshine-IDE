package awaybuilder.view.mediators
{
	import awaybuilder.controller.clipboard.events.*;
	import awaybuilder.controller.events.*;
	import awaybuilder.controller.history.UndoRedoEvent;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.utils.enumerators.EMenuItem;
	import awaybuilder.utils.scene.CameraManager;
	import awaybuilder.utils.scene.Scene3DManager;
	import awaybuilder.view.components.popup.AboutPopup;
	
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import org.robotlegs.mvcs.Mediator;

	public class BaseApplicationMediator extends Mediator
	{

		protected function onKeyDown( event:KeyboardEvent ):void
		{
			if(event.keyCode == Keyboard.F1)
			{
				onItemSelect( EMenuItem.ABOUT );
			}
			else if(event.keyCode == Keyboard.DELETE)
			{
				onItemSelect( EMenuItem.DELETE );
			}
			
			if( !event.ctrlKey ) return;
			
			switch(String.fromCharCode(event.charCode))
			{
				
				case "z":
					onItemSelect( EMenuItem.UNDO );
					break;
				case "y":
					onItemSelect( EMenuItem.REDO );
					break;
				case "x":
					onItemSelect( EMenuItem.CUT );
					break;
				case "c":
					onItemSelect( EMenuItem.COPY );
					break;
				case "v":
					onItemSelect( EMenuItem.SAVE );
					break;
				case "+":
				case "=":
					onItemSelect( EMenuItem.ZOOM_IN );
					break;
				case "-":
					onItemSelect( EMenuItem.ZOOM_OUT );
					break;
					
			}
			
			if(event.keyCode == Keyboard.BACKSPACE)
			{
				onItemSelect( EMenuItem.DELETE );
			}
		}
		protected function onItemSelect( value:String ):void
		{
			switch( value )
			{
				case EMenuItem.NEW_DOCUMENT:
					this.dispatch(new DocumentRequestEvent(DocumentRequestEvent.REQUEST_NEW_DOCUMENT));
					break;
				
				case EMenuItem.OPEN:
					this.dispatch(new DocumentRequestEvent(DocumentRequestEvent.REQUEST_OPEN_DOCUMENT));
					break;
				
				case EMenuItem.IMPORT:
					this.dispatch(new DocumentRequestEvent(DocumentRequestEvent.REQUEST_IMPORT_DOCUMENT));
					break;
				
				case EMenuItem.SAVE:
					this.dispatch(new SaveDocumentEvent(SaveDocumentEvent.SAVE_DOCUMENT));
					break;
				
				case EMenuItem.SAVE_AS:
					this.dispatch(new SaveDocumentEvent(SaveDocumentEvent.SAVE_DOCUMENT_AS));
					break;
				
				case EMenuItem.EXIT:
					exit();
					break;
				
				//edit
				case EMenuItem.UNDO:
					this.dispatch(new UndoRedoEvent(UndoRedoEvent.UNDO));
					break;
				
				case EMenuItem.REDO:
					this.dispatch(new UndoRedoEvent(UndoRedoEvent.REDO));
					break;
				
				case EMenuItem.CUT:
					this.dispatch(new ClipboardEvent(ClipboardEvent.CLIPBOARD_CUT));
					break;
				
				case EMenuItem.COPY:
					this.dispatch(new ClipboardEvent(ClipboardEvent.CLIPBOARD_COPY));
					break;
				
				case EMenuItem.PASTE:
					this.dispatch(new PasteEvent(PasteEvent.CLIPBOARD_PASTE));
					break;
				
				case EMenuItem.SELECT_ALL:
					this.dispatch(new SceneEvent(SceneEvent.SELECT_ALL, null));
					break;
				
				case EMenuItem.SELECT_NONE:
					this.dispatch(new SceneEvent(SceneEvent.SELECT_NONE, null));
					break;
				
				case EMenuItem.DELETE:
					this.dispatch(new SceneEvent(SceneEvent.PERFORM_DELETION));
					break;
				
				case EMenuItem.DOCUMENT_SETTINGS:
					this.dispatch(new SettingsEvent(SettingsEvent.SHOW_DOCUMENT_SETTINGS));
					break;
				
				//tools
				case EMenuItem.FREE_CAMERA:
					this.dispatch(new SceneEvent(SceneEvent.SWITCH_CAMERA_TO_FREE, null));
					break;
				
				case EMenuItem.TARGET_CAMERA:
					this.dispatch(new SceneEvent(SceneEvent.SWITCH_CAMERA_TO_TARGET, null));
					break;
				
				case EMenuItem.TRANSLATE_MODE:
					this.dispatch(new SceneEvent(SceneEvent.SWITCH_TRANSFORM_TRANSLATE, null));
					break;
				
				case EMenuItem.ROTATE_MODE:
					this.dispatch(new SceneEvent(SceneEvent.SWITCH_TRANSFORM_ROTATE, null));
					break;
				
				case EMenuItem.SCALE_MODE:
					this.dispatch(new SceneEvent(SceneEvent.SWITCH_TRANSFORM_SCALE, null));
					break;
				
				//view
				case EMenuItem.ZOOM_OUT:
					Scene3DManager.zoomDistanceDelta( -CameraManager.ZOOM_DELTA_VALUE );
					break;
				
				case EMenuItem.ZOOM_IN:
					Scene3DManager.zoomDistanceDelta( CameraManager.ZOOM_DELTA_VALUE );
					break;
				
				case EMenuItem.FOCUS:
					this.dispatch(new SceneEvent(SceneEvent.FOCUS_SELECTION));
					break;
				
				//help
				case EMenuItem.ABOUT:
					AboutPopup.show();
					break;
				
				default:
					trace("Menu item not implemented: " +value + ".");
			}
		}
		
		protected function exit():void
		{
			throw new Error( "Abstract methid exception" );
		}
	}
}