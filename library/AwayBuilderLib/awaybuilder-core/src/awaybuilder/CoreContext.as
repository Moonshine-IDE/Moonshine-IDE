package awaybuilder
{
	import awaybuilder.controller.ReadDocumentDataFaultCommand;
	import awaybuilder.controller.ShowTextureSizeErrorsCommand;
	import awaybuilder.controller.StartupCommand;
	import awaybuilder.controller.clipboard.CopyCommand;
	import awaybuilder.controller.clipboard.PasteCommand;
	import awaybuilder.controller.clipboard.events.ClipboardEvent;
	import awaybuilder.controller.clipboard.events.PasteEvent;
	import awaybuilder.controller.document.ChangeGlobalOptionsCommand;
	import awaybuilder.controller.document.ConcatenateDocumentDataCommand;
	import awaybuilder.controller.document.ImportBitmapCommand;
	import awaybuilder.controller.document.ImportDocumentCommand;
	import awaybuilder.controller.document.ImportTextureForMaterialCommand;
	import awaybuilder.controller.document.NewDocumentCommand;
	import awaybuilder.controller.document.OpenDocumentCommand;
	import awaybuilder.controller.document.ReplaceDocumentDataCommand;
	import awaybuilder.controller.document.SaveDocumentCommand;
	import awaybuilder.controller.document.SaveDocumentFailCommand;
	import awaybuilder.controller.document.SaveDocumentSuccessCommand;
	import awaybuilder.controller.document.ShowDocumentSettingsCommand;
	import awaybuilder.controller.document.events.ImportTextureEvent;
	import awaybuilder.controller.events.ConcatenateDataOperationEvent;
	import awaybuilder.controller.events.DocumentEvent;
	import awaybuilder.controller.events.ReadDocumentDataResultEvent;
	import awaybuilder.controller.events.ReplaceDocumentDataEvent;
	import awaybuilder.controller.events.SaveDocumentEvent;
	import awaybuilder.controller.events.SettingsEvent;
	import awaybuilder.controller.events.TextureSizeErrorsEvent;
	import awaybuilder.controller.history.RedoCommand;
	import awaybuilder.controller.history.UndoCommand;
	import awaybuilder.controller.history.UndoRedoEvent;
	import awaybuilder.controller.scene.AddNewAnimationSetCommand;
	import awaybuilder.controller.scene.AddNewAnimatorCommand;
	import awaybuilder.controller.scene.AddNewCameraCommand;
	import awaybuilder.controller.scene.AddNewContainerCommand;
	import awaybuilder.controller.scene.AddNewCubeTextureCommand;
	import awaybuilder.controller.scene.AddNewEffectMethodCommand;
	import awaybuilder.controller.scene.AddNewGeometryCommand;
	import awaybuilder.controller.scene.AddNewLightCommand;
	import awaybuilder.controller.scene.AddNewLightPickerCommand;
	import awaybuilder.controller.scene.AddNewMaterialCommand;
	import awaybuilder.controller.scene.AddNewMeshCommand;
	import awaybuilder.controller.scene.AddNewShadowMethodCommand;
	import awaybuilder.controller.scene.AddNewSkyBoxCommand;
	import awaybuilder.controller.scene.AddNewTextureCommand;
	import awaybuilder.controller.scene.AddNewTextureProjectorCommand;
	import awaybuilder.controller.scene.ChangeAnimationNodeCommand;
	import awaybuilder.controller.scene.ChangeAnimationSetCommand;
	import awaybuilder.controller.scene.ChangeAnimatorCommand;
	import awaybuilder.controller.scene.ChangeCameraCommand;
	import awaybuilder.controller.scene.ChangeContainerCommand;
	import awaybuilder.controller.scene.ChangeCubeTextureCommand;
	import awaybuilder.controller.scene.ChangeEffectMethodCommand;
	import awaybuilder.controller.scene.ChangeGeometryCommand;
	import awaybuilder.controller.scene.ChangeLensCommand;
	import awaybuilder.controller.scene.ChangeLightCommand;
	import awaybuilder.controller.scene.ChangeLightPickerCommand;
	import awaybuilder.controller.scene.ChangeMaterialCommand;
	import awaybuilder.controller.scene.ChangeMeshCommand;
	import awaybuilder.controller.scene.ChangeShadingMethodCommand;
	import awaybuilder.controller.scene.ChangeShadowMapperCommand;
	import awaybuilder.controller.scene.ChangeShadowMethodCommand;
	import awaybuilder.controller.scene.ChangeSkeletonCommand;
	import awaybuilder.controller.scene.ChangeSkyBoxCommand;
	import awaybuilder.controller.scene.ChangeSubMeshCommand;
	import awaybuilder.controller.scene.ChangeTextureCommand;
	import awaybuilder.controller.scene.ChangeTextureProjectorCommand;
	import awaybuilder.controller.scene.DeleteCommand;
	import awaybuilder.controller.scene.ReparentAnimationCommand;
	import awaybuilder.controller.scene.ReparentLightCommand;
	import awaybuilder.controller.scene.ReparentMaterialEffectCommand;
	import awaybuilder.controller.scene.ReparentObjectCommand;
	import awaybuilder.controller.scene.RotateCommand;
	import awaybuilder.controller.scene.ScaleCommand;
	import awaybuilder.controller.scene.SelectCommand;
	import awaybuilder.controller.scene.SwitchFreeCameraModeCommand;
	import awaybuilder.controller.scene.SwitchTargetCameraModeCommand;
	import awaybuilder.controller.scene.SwitchTransformRotateModeCommand;
	import awaybuilder.controller.scene.SwitchTransformScaleModeCommand;
	import awaybuilder.controller.scene.SwitchTransformTranslateModeCommand;
	import awaybuilder.controller.scene.TranslateCommand;
	import awaybuilder.controller.scene.TranslatePivotCommand;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.ApplicationModel;
	import awaybuilder.model.AssetsModel;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.UndoRedoModel;
	import awaybuilder.view.components.CoreEditor;
	import awaybuilder.view.components.EditStatusBar;
	import awaybuilder.view.components.EditToolBar;
	import awaybuilder.view.components.LibraryPanel;
	import awaybuilder.view.components.PropertiesPanel;
	import awaybuilder.view.mediators.CoreEditorMediator;
	import awaybuilder.view.mediators.EditStatusBarMediator;
	import awaybuilder.view.mediators.EditToolBarMediator;
	import awaybuilder.view.mediators.LibraryPanelMediator;
	import awaybuilder.view.mediators.PropertiesPanelMediator;
	
	import flash.display.DisplayObjectContainer;
	
	import org.robotlegs.base.ContextEvent;
	import org.robotlegs.mvcs.Context;

	public class CoreContext extends Context
	{
		public function CoreContext()
		{
			super(contextView);
		}
		
		override public function startup():void
		{
			super.startup();
			
			this.commandMap.mapEvent(ContextEvent.STARTUP, StartupCommand);

			this.commandMap.mapEvent(DocumentEvent.NEW_DOCUMENT, NewDocumentCommand);
			this.commandMap.mapEvent(DocumentEvent.OPEN_DOCUMENT, OpenDocumentCommand);
			this.commandMap.mapEvent(DocumentEvent.IMPORT_DOCUMENT, ImportDocumentCommand);
			
			this.commandMap.mapEvent(ConcatenateDataOperationEvent.CONCAT_DOCUMENT_DATA, ConcatenateDocumentDataCommand);
			
			this.commandMap.mapEvent(ReplaceDocumentDataEvent.REPLACE_DOCUMENT_DATA, ReplaceDocumentDataCommand);
			
			this.commandMap.mapEvent(ReadDocumentDataResultEvent.READ_DOCUMENT_DATA_FAULT, ReadDocumentDataFaultCommand);
			
			this.commandMap.mapEvent(SaveDocumentEvent.SAVE_DOCUMENT, SaveDocumentCommand);
			this.commandMap.mapEvent(SaveDocumentEvent.SAVE_DOCUMENT_AS, SaveDocumentCommand);
			this.commandMap.mapEvent(SaveDocumentEvent.SAVE_DOCUMENT_SUCCESS, SaveDocumentSuccessCommand);
			this.commandMap.mapEvent(SaveDocumentEvent.SAVE_DOCUMENT_FAIL, SaveDocumentFailCommand);
			
			this.commandMap.mapEvent(SceneEvent.SWITCH_CAMERA_TO_FREE, SwitchFreeCameraModeCommand);
			this.commandMap.mapEvent(SceneEvent.SWITCH_CAMERA_TO_TARGET, SwitchTargetCameraModeCommand);
			
			this.commandMap.mapEvent(SceneEvent.SWITCH_TRANSFORM_ROTATE, SwitchTransformRotateModeCommand);
			this.commandMap.mapEvent(SceneEvent.SWITCH_TRANSFORM_SCALE, SwitchTransformScaleModeCommand);
			this.commandMap.mapEvent(SceneEvent.SWITCH_TRANSFORM_TRANSLATE, SwitchTransformTranslateModeCommand);

            this.commandMap.mapEvent(SceneEvent.ROTATE, RotateCommand);
            this.commandMap.mapEvent(SceneEvent.TRANSLATE, TranslateCommand);
			this.commandMap.mapEvent(SceneEvent.TRANSLATE_PIVOT, TranslatePivotCommand);
            this.commandMap.mapEvent(SceneEvent.SCALE, ScaleCommand);
			
			this.commandMap.mapEvent(SceneEvent.DELETE, DeleteCommand);
			this.commandMap.mapEvent(SceneEvent.SELECT, SelectCommand);
			
			this.commandMap.mapEvent(ImportTextureEvent.IMPORT_AND_ADD, ImportTextureForMaterialCommand);
			
			this.commandMap.mapEvent(ImportTextureEvent.IMPORT_AND_BITMAP_REPLACE, ImportBitmapCommand);
			
			commandMap.mapEvent(SceneEvent.CHANGE_GLOBAL_OPTIONS, ChangeGlobalOptionsCommand);
			
			commandMap.mapEvent(SceneEvent.REPARENT_OBJECTS, ReparentObjectCommand);
			commandMap.mapEvent(SceneEvent.REPARENT_LIGHTS, ReparentLightCommand);
			commandMap.mapEvent(SceneEvent.REPARENT_ANIMATIONS, ReparentAnimationCommand);
			commandMap.mapEvent(SceneEvent.REPARENT_MATERIAL_EFFECT, ReparentMaterialEffectCommand);
			
            commandMap.mapEvent(SceneEvent.CHANGE_MESH, ChangeMeshCommand);
			commandMap.mapEvent(SceneEvent.CHANGE_SUBMESH, ChangeSubMeshCommand);
			commandMap.mapEvent(SceneEvent.CHANGE_CONTAINER, ChangeContainerCommand);
            commandMap.mapEvent(SceneEvent.CHANGE_MATERIAL, ChangeMaterialCommand);
			commandMap.mapEvent(SceneEvent.CHANGE_LIGHT, ChangeLightCommand);
			commandMap.mapEvent(SceneEvent.CHANGE_LIGHTPICKER, ChangeLightPickerCommand);
			commandMap.mapEvent(SceneEvent.CHANGE_SHADOW_METHOD, ChangeShadowMethodCommand);
			commandMap.mapEvent(SceneEvent.CHANGE_EFFECT_METHOD, ChangeEffectMethodCommand);
			commandMap.mapEvent(SceneEvent.CHANGE_SKYBOX, ChangeSkyBoxCommand);
			commandMap.mapEvent(SceneEvent.CHANGE_SHADOW_MAPPER, ChangeShadowMapperCommand);
			commandMap.mapEvent(SceneEvent.CHANGE_GEOMETRY, ChangeGeometryCommand);
			commandMap.mapEvent(SceneEvent.CHANGE_SHADING_METHOD, ChangeShadingMethodCommand);
			commandMap.mapEvent(SceneEvent.CHANGE_CUBE_TEXTURE, ChangeCubeTextureCommand);
			commandMap.mapEvent(SceneEvent.CHANGE_TEXTURE, ChangeTextureCommand);
			commandMap.mapEvent(SceneEvent.CHANGE_TEXTURE_PROJECTOR, ChangeTextureProjectorCommand);
			commandMap.mapEvent(SceneEvent.CHANGE_SKELETON, ChangeSkeletonCommand);
			commandMap.mapEvent(SceneEvent.CHANGE_ANIMATOR, ChangeAnimatorCommand);
			commandMap.mapEvent(SceneEvent.CHANGE_ANIMATION_NODE, ChangeAnimationNodeCommand);
			commandMap.mapEvent(SceneEvent.CHANGE_ANIMATION_SET, ChangeAnimationSetCommand);
			commandMap.mapEvent(SceneEvent.CHANGE_CAMERA, ChangeCameraCommand);
			commandMap.mapEvent(SceneEvent.CHANGE_LENS, ChangeLensCommand);
			
			commandMap.mapEvent(SceneEvent.ADD_NEW_MATERIAL, AddNewMaterialCommand);
			commandMap.mapEvent(SceneEvent.ADD_NEW_TEXTURE, AddNewTextureCommand);
			commandMap.mapEvent(SceneEvent.ADD_NEW_LIGHT, AddNewLightCommand);
			commandMap.mapEvent(SceneEvent.ADD_NEW_LIGHTPICKER, AddNewLightPickerCommand);
			commandMap.mapEvent(SceneEvent.ADD_NEW_SHADOW_METHOD, AddNewShadowMethodCommand);
			commandMap.mapEvent(SceneEvent.ADD_NEW_SKYBOX, AddNewSkyBoxCommand);
			commandMap.mapEvent(SceneEvent.ADD_NEW_CUBE_TEXTURE, AddNewCubeTextureCommand);
			commandMap.mapEvent(SceneEvent.ADD_NEW_EFFECT_METHOD, AddNewEffectMethodCommand);
			commandMap.mapEvent(SceneEvent.ADD_NEW_GEOMETRY, AddNewGeometryCommand);
			commandMap.mapEvent(SceneEvent.ADD_NEW_MESH, AddNewMeshCommand);
			commandMap.mapEvent(SceneEvent.ADD_NEW_CONTAINER, AddNewContainerCommand);
			commandMap.mapEvent(SceneEvent.ADD_NEW_TEXTURE_PROJECTOR, AddNewTextureProjectorCommand);
			commandMap.mapEvent(SceneEvent.ADD_NEW_ANIMATION_SET, AddNewAnimationSetCommand);
			commandMap.mapEvent(SceneEvent.ADD_NEW_ANIMATOR, AddNewAnimatorCommand);
			
			commandMap.mapEvent(SceneEvent.ADD_NEW_CAMERA, AddNewCameraCommand);
			
			this.commandMap.mapEvent(ClipboardEvent.CLIPBOARD_CUT, CopyCommand);
			this.commandMap.mapEvent(ClipboardEvent.CLIPBOARD_COPY, CopyCommand);
			this.commandMap.mapEvent(PasteEvent.CLIPBOARD_PASTE, PasteCommand);
			
			commandMap.mapEvent(SettingsEvent.SHOW_DOCUMENT_SETTINGS, ShowDocumentSettingsCommand);
			
            commandMap.mapEvent( UndoRedoEvent.REDO, RedoCommand );
            commandMap.mapEvent( UndoRedoEvent.UNDO, UndoCommand );

			commandMap.mapEvent(TextureSizeErrorsEvent.SHOW_TEXTURE_SIZE_ERRORS, ShowTextureSizeErrorsCommand);
			
			this.injector.mapSingleton(DocumentModel);
			this.injector.mapSingleton(AssetsModel);
			this.injector.mapSingleton(UndoRedoModel);
			this.injector.mapSingleton(ApplicationModel);
			
			this.mediatorMap.mapView(CoreEditor, CoreEditorMediator);
            this.mediatorMap.mapView(PropertiesPanel, PropertiesPanelMediator);
			this.mediatorMap.mapView(LibraryPanel, LibraryPanelMediator);
			this.mediatorMap.mapView(EditToolBar, EditToolBarMediator);
			this.mediatorMap.mapView(EditStatusBar, EditStatusBarMediator);
		}
	}
}