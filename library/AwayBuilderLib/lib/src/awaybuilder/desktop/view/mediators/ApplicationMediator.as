package awaybuilder.desktop.view.mediators
{

	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.InvokeEvent;
	import flash.events.KeyboardEvent;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	import mx.controls.menuClasses.MenuBarItem;
	import mx.core.DragSource;
	import mx.core.IIMESupport;
	import mx.events.DragEvent;
	import mx.events.MenuEvent;
	import mx.managers.DragManager;
	import mx.managers.IFocusManagerComponent;
	
	import awaybuilder.controller.clipboard.events.ClipboardEvent;
	import awaybuilder.controller.events.DocumentEvent;
	import awaybuilder.controller.events.DocumentModelEvent;
	import awaybuilder.controller.events.DocumentRequestEvent;
	import awaybuilder.controller.events.ErrorLogEvent;
	import awaybuilder.controller.events.TextureSizeErrorsEvent;
	import awaybuilder.controller.history.UndoRedoEvent;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.desktop.controller.events.OpenFromInvokeEvent;
	import awaybuilder.desktop.utils.ModalityManager;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.UndoRedoModel;
	import awaybuilder.model.vo.scene.AssetVO;
	import awaybuilder.model.vo.scene.ObjectVO;
	import awaybuilder.utils.enumerators.EMenuItem;
	import awaybuilder.view.mediators.BaseApplicationMediator;

	public class ApplicationMediator extends BaseApplicationMediator
	{
		
		[Inject]
		public var app:AwayBuilderApplication;
		
		[Inject]
		public var documentModel:DocumentModel;
		
		[Inject]
		public var undoRedoModel:UndoRedoModel;
		
		private var _isWin:Boolean; 
		private var _isMac:Boolean; 
		
		private var _menuCache:Dictionary;
		
		override public function onRegister():void
		{	
			_menuCache = new Dictionary();
			
			app.menu.addEventListener(MenuEvent.ITEM_CLICK, menu_itemClickHandler );
			this.updatePageTitle();
			
			addContextListener( DocumentModelEvent.DOCUMENT_NAME_CHANGED, eventDispatcher_documentNameChangedHandler);
			addContextListener( DocumentModelEvent.DOCUMENT_EDITED, eventDispatcher_documentEditedHandler);
			
            addContextListener( SceneEvent.SELECT, context_itemSelectHandler);
			addContextListener( SceneEvent.SWITCH_CAMERA_TO_FREE, eventDispatcher_switchToFreeCameraHandler);
			addContextListener( SceneEvent.SWITCH_CAMERA_TO_TARGET, eventDispatcher_switchToTargetCameraHandler);
			addContextListener( SceneEvent.SWITCH_TRANSFORM_TRANSLATE, eventDispatcher_switchTranslateHandler);
			addContextListener( SceneEvent.SWITCH_TRANSFORM_ROTATE, eventDispatcher_switchRotateHandler);
			addContextListener( SceneEvent.SWITCH_TRANSFORM_SCALE, eventDispatcher_switchScaleCameraHandler);

			addContextListener( ClipboardEvent.CLIPBOARD_COPY, context_copyHandler);
            addContextListener( UndoRedoEvent.UNDO_LIST_CHANGE, context_undoListChangeHandler);
            addContextListener( ErrorLogEvent.LOG_ENTRY_MADE, eventDispatcher_errorLogHandler);
          
			addViewListener( Event.CLOSING, awaybuilder_closingHandler );
			
			addViewListener( DragEvent.DRAG_ENTER, awaybuilder_dragEnterHandler );
			addViewListener( DragEvent.DRAG_DROP, awaybuilder_dragDropHandler );
			
			addViewListener( InvokeEvent.INVOKE, invokeHandler );
			
			this.eventMap.mapListener(this.app.stage, KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
			
			app.stage.addEventListener(FocusEvent.FOCUS_IN, focusInHandler );
			
			//fix for linux window size bug
			/*this.app.nativeWindow.height++;
			this.app.nativeWindow.height--;*/
			
			getItemByValue( EMenuItem.UNDO ).enabled = undoRedoModel.canUndo;
			getItemByValue( EMenuItem.REDO ).enabled = undoRedoModel.canRedo;
			getItemByValue( EMenuItem.FOCUS ).enabled = false;
			getItemByValue( EMenuItem.DELETE ).enabled = false;
			getItemByValue( EMenuItem.CUT ).enabled = false;
			getItemByValue( EMenuItem.COPY ).enabled = false;
			getItemByValue( EMenuItem.PASTE ).enabled = false;
			
			_isWin = (Capabilities.os.indexOf("Windows") >= 0); 
			_isMac = (Capabilities.os.indexOf("Mac OS") >= 0); 
			
			/*if( _isMac )
			{
				getItemByValue( EMenuItem.EXIT ).keyEquivalent = "q";
				getItemByValue( EMenuItem.EXIT ).keyEquivalentModifiers = [Keyboard.COMMAND];
			}*/
		}

		private function focusInHandler(event:FocusEvent):void
		{
			const focus:IFocusManagerComponent = app.focusManager.getFocus();
			/*if( focus is IIMESupport )
			{
				getItemByValue( EMenuItem.CUT ).keyEquivalentModifiers = [Keyboard.ALTERNATE, app.getCommandKey()];
				getItemByValue( EMenuItem.COPY ).keyEquivalentModifiers = [Keyboard.ALTERNATE, app.getCommandKey()];
				getItemByValue( EMenuItem.PASTE ).keyEquivalentModifiers = [Keyboard.ALTERNATE, app.getCommandKey()];
			}
			else
			{
				getItemByValue( EMenuItem.CUT ).keyEquivalentModifiers = [app.getCommandKey()];
				getItemByValue( EMenuItem.COPY ).keyEquivalentModifiers = [app.getCommandKey()];
				getItemByValue( EMenuItem.PASTE ).keyEquivalentModifiers = [app.getCommandKey()];
			}*/
		}
		
		private function getItemByValue( value:String ):MenuBarItem
		{
			if( _menuCache[value] ) return _menuCache[value];
			_menuCache[value] = findItem( value, app.menu.menuBarItems );
			return _menuCache[value];
		}
		private function findItem( value:String, items:Array ):MenuBarItem
		{
			for each( var item:MenuBarItem in items )
			{
				if( item.data && item.data.label == value ) return item;
				if( item.menuBar.menuBarItems )
				{
					var nativeMenuItem:MenuBarItem = findItem( value, item.menuBar.menuBarItems );
					if( nativeMenuItem ) return nativeMenuItem;
				}
			}
			return null;
		}
		private function invokeHandler(event:InvokeEvent):void
		{
			if(event.arguments.length == 1)
			{
				const extensions:Vector.<String> = new <String>["awd","AWD"];
				var filePath:String = event.arguments[0];
				var file:File = new File(filePath);
				if(file.exists && extensions.indexOf(file.extension) >= 0)
				{
					dispatch(new OpenFromInvokeEvent(OpenFromInvokeEvent.OPEN_FROM_INVOKE, file));
				}
			}
		}
		
        private function context_undoListChangeHandler(event:UndoRedoEvent):void
        {
			getItemByValue( EMenuItem.UNDO ).enabled = undoRedoModel.canUndo;
			getItemByValue( EMenuItem.REDO ).enabled = undoRedoModel.canRedo;
        }
	
		private function eventDispatcher_errorLogHandler(event:ErrorLogEvent):void {
			this.dispatch(new TextureSizeErrorsEvent(TextureSizeErrorsEvent.SHOW_TEXTURE_SIZE_ERRORS));
		}

		private function updatePageTitle():void
		{
			var newTitle:String = "Away Builder - " + this.documentModel.name;
			if(this.documentModel.edited)
			{
				newTitle += " *";
			}
			//this.app.title = newTitle;
		}
		
		private function eventDispatcher_documentEditedHandler(event:DocumentModelEvent):void
		{
			this.updatePageTitle();
		}
		
		private function eventDispatcher_documentNameChangedHandler(event:DocumentModelEvent):void
		{
			this.updatePageTitle();
		}
		
		private function eventDispatcher_newDocumentHandler(event:DocumentEvent):void
		{
			this.app.visible = true;
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
				
				getItemByValue( EMenuItem.FOCUS ).enabled = isSceneItemsSelected;
				getItemByValue( EMenuItem.DELETE ).enabled = true;
				getItemByValue( EMenuItem.COPY ).enabled = isSceneItemsSelected;
				getItemByValue( EMenuItem.CUT ).enabled = isSceneItemsSelected;
			}
			else 
			{
				getItemByValue( EMenuItem.FOCUS ).enabled = false;
				getItemByValue( EMenuItem.DELETE ).enabled = false;
				getItemByValue( EMenuItem.COPY ).enabled = false;
				getItemByValue( EMenuItem.CUT ).enabled = false;
			}
		}
		
		private function eventDispatcher_switchToFreeCameraHandler(event:SceneEvent):void
		{
			/*getItemByValue( EMenuItem.TARGET_CAMERA ).checked = false;
			getItemByValue( EMenuItem.FREE_CAMERA ).checked = true;*/
		}
		
		private function eventDispatcher_switchToTargetCameraHandler(event:SceneEvent):void
		{
			/*getItemByValue( EMenuItem.TARGET_CAMERA ).checked = false;
			getItemByValue( EMenuItem.FREE_CAMERA ).checked = true;*/
		}
		
		private function eventDispatcher_switchTranslateHandler(event:SceneEvent):void
		{
			/*getItemByValue( EMenuItem.TRANSLATE_MODE ).checked = true;
			getItemByValue( EMenuItem.ROTATE_MODE ).checked = false;
			getItemByValue( EMenuItem.SCALE_MODE ).checked = false;*/
		}
		
		private function eventDispatcher_switchRotateHandler(event:SceneEvent):void
		{
			/*getItemByValue( EMenuItem.TRANSLATE_MODE ).checked = false;
			getItemByValue( EMenuItem.ROTATE_MODE ).checked = true;
			getItemByValue( EMenuItem.SCALE_MODE ).checked = false;*/
		}
		
		private function eventDispatcher_switchScaleCameraHandler(event:SceneEvent):void
		{
			/*getItemByValue( EMenuItem.TRANSLATE_MODE ).checked = false;
			getItemByValue( EMenuItem.ROTATE_MODE ).checked = false;
			getItemByValue( EMenuItem.SCALE_MODE ).checked = true;*/
		}
		
		private function context_copyHandler(event:ClipboardEvent):void
		{
			getItemByValue( EMenuItem.PASTE ).enabled = true;
			getItemByValue( EMenuItem.CUT ).enabled = true;
		}
		
		private function awaybuilder_dragEnterHandler(event:DragEvent):void
		{
			const dragSource:DragSource = event.dragSource;
			if(dragSource.hasFormat("air:file list"))
			{
				var fileList:Array = dragSource.dataForFormat("air:file list") as Array;
				if(fileList.length == 1)
				{
					const extensions:Vector.<String> = new <String>["awd","3ds","obj","md2","png","jpg","atf","dae","md5"];
					for each(var file:File in fileList)
					{
						if(file.exists && extensions.indexOf(file.extension.toLowerCase()) >= 0)
						{
							DragManager.acceptDragDrop(this.app);
							break;
						}
					}
				}
			}
		}
		
		private function awaybuilder_dragDropHandler(event:DragEvent):void
		{
			var file:File = event.dragSource.dataForFormat("air:file list")[0];
			this.dispatch(new OpenFromInvokeEvent(OpenFromInvokeEvent.OPEN_FROM_INVOKE, file));
		}
		
		private function awaybuilder_closingHandler(event:Event):void
		{
			if(this.documentModel.edited)
			{
				event.preventDefault();
				this.dispatch(new DocumentRequestEvent(DocumentRequestEvent.REQUEST_CLOSE_DOCUMENT));
			}
		}
		
		private function menu_itemClickHandler(event:MenuEvent):void
		{	
			onItemSelect( event.item.value );
		}
		
		private function stage_keyDownHandler(event:KeyboardEvent):void
		{
			const focus:IFocusManagerComponent = this.app.focusManager.getFocus();
			if( focus is IIMESupport || ModalityManager.modalityManager.modalWindowCount > 0)
			{
				//if I can enter text into whatever has focus, then that takes
				//precedence over keyboard shortcuts.
				//if a modal window is open, or the menu is disabled, no
				//keyboard shortcuts are allowed
				return;
			}
			onKeyDown( event );
			
		}
		override protected function exit():void
		{
			//app.close();
		}
	}
}