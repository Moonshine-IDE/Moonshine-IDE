package awaybuilder.view.mediators
{
	import awaybuilder.controller.clipboard.events.ClipboardEvent;
	import awaybuilder.controller.clipboard.events.PasteEvent;
	import awaybuilder.controller.events.DocumentEvent;
	import awaybuilder.controller.events.DocumentModelEvent;
	import awaybuilder.controller.events.DocumentRequestEvent;
	import awaybuilder.controller.events.SaveDocumentEvent;
	import awaybuilder.controller.events.SettingsEvent;
	import awaybuilder.controller.history.UndoRedoEvent;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.UndoRedoModel;
	import awaybuilder.model.vo.scene.AssetVO;
	import awaybuilder.model.vo.scene.ObjectVO;
	import awaybuilder.utils.scene.CameraManager;
	import awaybuilder.utils.scene.Scene3DManager;
	import awaybuilder.utils.scene.modes.CameraMode;
	import awaybuilder.view.components.EditToolBar;
	import awaybuilder.view.components.events.ToolBarEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class EditToolBarMediator extends Mediator
	{
		[Inject]
		public var toolBar:EditToolBar;
		
		[Inject]
		public var document:DocumentModel;
		
		[Inject]
		public var undoRedo:UndoRedoModel;
		
		override public function onRegister():void
		{
            addContextListener( SceneEvent.SWITCH_CAMERA_TO_FREE, eventDispatcher_switchToFreeHandler);
            addContextListener( SceneEvent.SWITCH_CAMERA_TO_TARGET, eventDispatcher_switchToTargetHandler);

            addContextListener( SceneEvent.SWITCH_TRANSFORM_ROTATE, eventDispatcher_switchToRotateHandler);
            addContextListener( SceneEvent.SWITCH_TRANSFORM_TRANSLATE, eventDispatcher_switchToTranslateHandler);
            addContextListener( SceneEvent.SWITCH_TRANSFORM_SCALE, eventDispatcher_switchToScaleHandler);
            addContextListener( SceneEvent.ENABLE_TRANSFORM_MODES, eventDispatcher_enableTransformModesHandler);

            addContextListener( SceneEvent.SELECT, context_itemSelectHandler);
            addContextListener( UndoRedoEvent.UNDO_LIST_CHANGE, context_undoListChangeHandler);
			addContextListener( DocumentModelEvent.CLIPBOARD_UPDATED, context_clipboardChangeHandler);

            addViewListener( ToolBarEvent.NEW_DOCUMENT, toolBar_newDocumentHandler);
            addViewListener( ToolBarEvent.OPEN_DOCUMENT, toolBar_openDocumentHandler);
			addViewListener( ToolBarEvent.IMPORT_DOCUMENT, toolBar_importDocumentHandler);
            addViewListener( ToolBarEvent.SAVE_DOCUMENT, toolBar_saveDocumentHandler);

            addViewListener( ToolBarEvent.UNDO, toolBar_undoHandler);
            addViewListener( ToolBarEvent.REDO, toolBar_redoHandler);

            addViewListener( ToolBarEvent.DOCUMENT_SETTINGS, toolBar_documentSettingsHandler);

            addViewListener( ToolBarEvent.CLIPBOARD_CUT, toolBar_clipboardCutHandler);
            addViewListener( ToolBarEvent.CLIPBOARD_COPY, toolBar_clipboardCopyHandler);
            addViewListener( ToolBarEvent.CLIPBOARD_PASTE, toolBar_clipboardPasteHandler);

            addViewListener( ToolBarEvent.DELETE_SELECTION, toolBar_deleteSelectionHandler);

            addViewListener( ToolBarEvent.FOCUS_OBJECT, toolBar_focusObjectHandler);

            addViewListener( ToolBarEvent.SWITCH_CAMERA_TO_FREE, toolBar_switchMouseToFreeHandler);
            addViewListener( ToolBarEvent.SWITCH_CAMERA_TO_TARGET, toolBar_switchMouseToTargetHandler);

            addViewListener( ToolBarEvent.TRANSFORM_TRANSLATE, toolBar_switchTranslateHandler);
            addViewListener( ToolBarEvent.TRANSFORM_SCALE, toolBar_switchScaleHandler);
            addViewListener( ToolBarEvent.TRANSFORM_ROTATE, toolBar_switchRotateHandler);

            toolBar.undoButton.enabled = undoRedo.canUndo;
            toolBar.redoButton.enabled = undoRedo.canRedo;
		}

        private function context_undoListChangeHandler(event:UndoRedoEvent):void
        {
            toolBar.undoButton.enabled = undoRedo.canUndo;
            toolBar.redoButton.enabled = undoRedo.canRedo;
        }
		private function context_clipboardChangeHandler(event:DocumentModelEvent):void
		{
			if( document.selectedAssets && document.selectedAssets.length>0 )
			{
				toolBar.pasteButton.enabled = true;
			}
			else
			{
				toolBar.pasteButton.enabled = false;
			}
		}
		
		private function eventDispatcher_switchToScaleHandler(event:SceneEvent):void
		{
			this.toolBar.scaleButton.selected = true;
		}
		
		private function eventDispatcher_switchToRotateHandler(event:SceneEvent):void
		{
			this.toolBar.rotateButton.selected = true;
		}
		
		private function eventDispatcher_switchToTranslateHandler(event:SceneEvent):void
		{
			this.toolBar.translateButton.selected = true;
		}
		
		private function eventDispatcher_enableTransformModesHandler(event:SceneEvent):void
		{
			var options:String = event.options as String;
			switch (options) {
				case SceneEvent.ENABLE_TRANSLATE_MODE_ONLY :
					this.toolBar.translateButton.enabled = this.toolBar.translateButton.selected = true;
					this.toolBar.rotateButton.enabled = this.toolBar.scaleButton.enabled = false;
					break; 
				case SceneEvent.ENABLE_ROTATE_MODE_ONLY :
					this.toolBar.rotateButton.enabled = this.toolBar.rotateButton.selected = true;
					this.toolBar.translateButton.enabled = this.toolBar.scaleButton.enabled = false;
					break; 
				case SceneEvent.DISABLE_SCALE_MODE :
					this.toolBar.translateButton.enabled = this.toolBar.rotateButton.enabled = true;
					this.toolBar.scaleButton.enabled = false;
					if (this.toolBar.scaleButton.selected) this.toolBar.translateButton.selected = true;
					break; 
				default : 
					this.toolBar.rotateButton.enabled = this.toolBar.translateButton.enabled = this.toolBar.scaleButton.enabled = true;
					break;
			}
		}

		private function eventDispatcher_switchToFreeHandler(event:SceneEvent):void
		{
			this.toolBar.freeCameraButton.selected = true;
		}
		
		private function eventDispatcher_switchToTargetHandler(event:SceneEvent):void
		{
			this.toolBar.targetCameraButton.selected = true;
		}
		
		private function context_itemSelectHandler(event:SceneEvent):void
		{
            if( event.items && event.items.length > 0)
            {
				var isSceneItemsSelected:Boolean = true;
				for each( var asset:AssetVO in event.items )
				{
					if( !(asset is ObjectVO) )
						isSceneItemsSelected = false;
				}
					
                this.toolBar.deleteButton.enabled = true;
                this.toolBar.focusButton.enabled = isSceneItemsSelected;
				this.toolBar.copyButton.enabled = isSceneItemsSelected;
				this.toolBar.cutButton.enabled = isSceneItemsSelected;
            }
            else 
			{
                this.toolBar.deleteButton.enabled = false;
                this.toolBar.focusButton.enabled = false;
				this.toolBar.copyButton.enabled = false;
				this.toolBar.cutButton.enabled = false;
            }
		}
		
		private function toolBar_clipboardCutHandler(event:ToolBarEvent):void
		{
			this.dispatch(new ClipboardEvent(ClipboardEvent.CLIPBOARD_CUT));
		}
		
		private function toolBar_clipboardCopyHandler(event:ToolBarEvent):void
		{
			this.dispatch(new ClipboardEvent(ClipboardEvent.CLIPBOARD_COPY));
		}
		
		private function toolBar_clipboardPasteHandler(event:ToolBarEvent):void
		{
			this.dispatch(new PasteEvent(PasteEvent.CLIPBOARD_PASTE));
		}
		
		private function toolBar_deleteSelectionHandler(event:ToolBarEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.PERFORM_DELETION));
		}
		
		private function toolBar_focusObjectHandler(event:ToolBarEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.FOCUS_SELECTION));
		}
		
		private function toolBar_switchMouseToFreeHandler(event:ToolBarEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.SWITCH_CAMERA_TO_FREE));
		}
		
		private function toolBar_switchMouseToTargetHandler(event:ToolBarEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.SWITCH_CAMERA_TO_TARGET));
		}
		
		
		private function toolBar_switchTranslateHandler(event:ToolBarEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.SWITCH_TRANSFORM_TRANSLATE));
		}
		
		private function toolBar_switchScaleHandler(event:ToolBarEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.SWITCH_TRANSFORM_SCALE));
		}
		
		private function toolBar_switchRotateHandler(event:ToolBarEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.SWITCH_TRANSFORM_ROTATE));
		}
		
		private function toolBar_newDocumentHandler(event:ToolBarEvent):void
		{
			this.dispatch(new DocumentRequestEvent(DocumentRequestEvent.REQUEST_NEW_DOCUMENT));
		}
		
		private function toolBar_importDocumentHandler(event:ToolBarEvent):void
		{
			this.dispatch(new DocumentEvent(DocumentEvent.IMPORT_DOCUMENT));
		}
		
		private function toolBar_openDocumentHandler(event:ToolBarEvent):void
		{
			this.dispatch(new DocumentRequestEvent(DocumentRequestEvent.REQUEST_OPEN_DOCUMENT));
		}
		
		private function toolBar_saveDocumentHandler(event:ToolBarEvent):void
		{
			this.dispatch(new SaveDocumentEvent(SaveDocumentEvent.SAVE_DOCUMENT));
		}
		
		private function toolBar_undoHandler(event:ToolBarEvent):void
		{
            this.dispatch(new UndoRedoEvent(UndoRedoEvent.UNDO));
		}
		
		private function toolBar_redoHandler(event:ToolBarEvent):void
		{
            this.dispatch(new UndoRedoEvent(UndoRedoEvent.REDO));
		}
		
		private function toolBar_documentSettingsHandler(event:ToolBarEvent):void
		{
			this.dispatch(new SettingsEvent(SettingsEvent.SHOW_DOCUMENT_SETTINGS));
		}
		
	}
}