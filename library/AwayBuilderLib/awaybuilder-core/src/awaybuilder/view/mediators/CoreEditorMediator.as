package awaybuilder.view.mediators
{
    import flash.display.BitmapData;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.UncaughtErrorEvent;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;
    import flash.geom.Vector3D;
    import flash.ui.Keyboard;
    import flash.utils.setTimeout;
    
    import mx.collections.ArrayCollection;
    import mx.controls.Alert;
    import mx.core.FlexGlobals;
    import mx.managers.FocusManager;
    
    import spark.collections.Sort;
    
    import away3d.animators.AnimationSetBase;
    import away3d.animators.AnimatorBase;
    import away3d.animators.SkeletonAnimationSet;
    import away3d.animators.SkeletonAnimator;
    import away3d.animators.VertexAnimationSet;
    import away3d.animators.VertexAnimator;
    import away3d.animators.data.Skeleton;
    import away3d.animators.nodes.AnimationNodeBase;
    import away3d.cameras.Camera3D;
    import away3d.cameras.lenses.LensBase;
    import away3d.cameras.lenses.OrthographicLens;
    import away3d.cameras.lenses.OrthographicOffCenterLens;
    import away3d.cameras.lenses.PerspectiveLens;
    import away3d.containers.ObjectContainer3D;
    import away3d.core.base.Geometry;
    import away3d.core.base.ISubGeometry;
    import away3d.core.base.Object3D;
    import away3d.core.base.SubGeometry;
    import away3d.core.base.SubMesh;
    import away3d.entities.Mesh;
    import away3d.entities.TextureProjector;
    import away3d.errors.AnimationSetError;
    import away3d.library.assets.NamedAssetBase;
    import away3d.lights.DirectionalLight;
    import away3d.lights.LightBase;
    import away3d.lights.PointLight;
    import away3d.lights.shadowmaps.CascadeShadowMapper;
    import away3d.lights.shadowmaps.CubeMapShadowMapper;
    import away3d.lights.shadowmaps.NearDirectionalShadowMapper;
    import away3d.lights.shadowmaps.ShadowMapperBase;
    import away3d.materials.ColorMaterial;
    import away3d.materials.ColorMultiPassMaterial;
    import away3d.materials.MaterialBase;
    import away3d.materials.MultiPassMaterialBase;
    import away3d.materials.SinglePassMaterialBase;
    import away3d.materials.SkyBoxMaterial;
    import away3d.materials.TextureMaterial;
    import away3d.materials.TextureMultiPassMaterial;
    import away3d.materials.lightpickers.LightPickerBase;
    import away3d.materials.lightpickers.StaticLightPicker;
    import away3d.materials.methods.AlphaMaskMethod;
    import away3d.materials.methods.BasicAmbientMethod;
    import away3d.materials.methods.BasicDiffuseMethod;
    import away3d.materials.methods.BasicNormalMethod;
    import away3d.materials.methods.BasicSpecularMethod;
    import away3d.materials.methods.CascadeShadowMapMethod;
    import away3d.materials.methods.CelDiffuseMethod;
    import away3d.materials.methods.CelSpecularMethod;
    import away3d.materials.methods.ColorMatrixMethod;
    import away3d.materials.methods.ColorTransformMethod;
    import away3d.materials.methods.DitheredShadowMapMethod;
    import away3d.materials.methods.EffectMethodBase;
    import away3d.materials.methods.EnvMapAmbientMethod;
    import away3d.materials.methods.EnvMapMethod;
    import away3d.materials.methods.FilteredShadowMapMethod;
    import away3d.materials.methods.FogMethod;
    import away3d.materials.methods.FresnelEnvMapMethod;
    import away3d.materials.methods.FresnelSpecularMethod;
    import away3d.materials.methods.GradientDiffuseMethod;
    import away3d.materials.methods.HardShadowMapMethod;
    import away3d.materials.methods.HeightMapNormalMethod;
    import away3d.materials.methods.LightMapDiffuseMethod;
    import away3d.materials.methods.LightMapMethod;
    import away3d.materials.methods.NearShadowMapMethod;
    import away3d.materials.methods.OutlineMethod;
    import away3d.materials.methods.ProjectiveTextureMethod;
    import away3d.materials.methods.RefractionEnvMapMethod;
    import away3d.materials.methods.RimLightMethod;
    import away3d.materials.methods.ShadingMethodBase;
    import away3d.materials.methods.ShadowMapMethodBase;
    import away3d.materials.methods.SimpleShadowMapMethodBase;
    import away3d.materials.methods.SimpleWaterNormalMethod;
    import away3d.materials.methods.SoftShadowMapMethod;
    import away3d.materials.methods.SubsurfaceScatteringDiffuseMethod;
    import away3d.materials.methods.WrapDiffuseMethod;
    import away3d.primitives.CapsuleGeometry;
    import away3d.primitives.ConeGeometry;
    import away3d.primitives.CubeGeometry;
    import away3d.primitives.CylinderGeometry;
    import away3d.primitives.PlaneGeometry;
    import away3d.primitives.SkyBox;
    import away3d.primitives.SphereGeometry;
    import away3d.primitives.TorusGeometry;
    import away3d.textures.BitmapCubeTexture;
    import away3d.textures.BitmapTexture;
    import away3d.textures.CubeTextureBase;
    import away3d.textures.Texture2DBase;
    
    import awaybuilder.controller.document.ReplaceDocumentDataCommand;
    import awaybuilder.controller.events.ConcatenateDataOperationEvent;
    import awaybuilder.controller.events.DocumentModelEvent;
    import awaybuilder.controller.events.ReplaceDocumentDataEvent;
    import awaybuilder.controller.events.SceneReadyEvent;
    import awaybuilder.controller.scene.events.AnimationEvent;
    import awaybuilder.controller.scene.events.SceneEvent;
    import awaybuilder.model.AssetsModel;
    import awaybuilder.model.DocumentModel;
    import awaybuilder.model.vo.DeleteStateVO;
    import awaybuilder.model.vo.DroppedAssetVO;
    import awaybuilder.model.vo.scene.AnimationNodeVO;
    import awaybuilder.model.vo.scene.AnimationSetVO;
    import awaybuilder.model.vo.scene.AnimatorVO;
    import awaybuilder.model.vo.scene.AssetVO;
    import awaybuilder.model.vo.scene.CameraVO;
    import awaybuilder.model.vo.scene.ContainerVO;
    import awaybuilder.model.vo.scene.CubeTextureVO;
    import awaybuilder.model.vo.scene.EffectVO;
    import awaybuilder.model.vo.scene.ExtraItemVO;
    import awaybuilder.model.vo.scene.GeometryVO;
    import awaybuilder.model.vo.scene.LensVO;
    import awaybuilder.model.vo.scene.LightPickerVO;
    import awaybuilder.model.vo.scene.LightVO;
    import awaybuilder.model.vo.scene.MaterialVO;
    import awaybuilder.model.vo.scene.MeshVO;
    import awaybuilder.model.vo.scene.ObjectVO;
    import awaybuilder.model.vo.scene.ShadingMethodVO;
    import awaybuilder.model.vo.scene.ShadowMapperVO;
    import awaybuilder.model.vo.scene.ShadowMethodVO;
    import awaybuilder.model.vo.scene.SharedEffectVO;
    import awaybuilder.model.vo.scene.SharedLightVO;
    import awaybuilder.model.vo.scene.SkeletonVO;
    import awaybuilder.model.vo.scene.SkyBoxVO;
    import awaybuilder.model.vo.scene.SubGeometryVO;
    import awaybuilder.model.vo.scene.SubMeshVO;
    import awaybuilder.model.vo.scene.TextureProjectorVO;
    import awaybuilder.model.vo.scene.TextureVO;
    import awaybuilder.utils.scene.CameraManager;
    import awaybuilder.utils.scene.Scene3DManager;
    import awaybuilder.utils.scene.modes.CameraMode;
    import awaybuilder.utils.scene.modes.GizmoMode;
    import awaybuilder.view.components.CoreEditor;
    import awaybuilder.view.scene.controls.CameraGizmo3D;
    import awaybuilder.view.scene.controls.ContainerGizmo3D;
    import awaybuilder.view.scene.controls.LightGizmo3D;
    import awaybuilder.view.scene.controls.TextureProjectorGizmo3D;
    import awaybuilder.view.scene.events.Scene3DManagerEvent;
    import awaybuilder.view.scene.representations.ISceneRepresentation;
    
    import org.robotlegs.mvcs.Mediator;

    public class CoreEditorMediator extends Mediator
	{
		[Inject]
		public var view:CoreEditor;
		
		[Inject]
		public var assets:AssetsModel;
		
		[Inject]
		public var document:DocumentModel;
		
		private var _scenegraphSort:Sort = new Sort();
		private var _scenegraph:ArrayCollection;
		private var _scenegraphSelected:Vector.<Object>;
		
		private var _currentAnimation:AnimationNodeVO;
		private var _currentAnimator:AnimatorVO;
		
		override public function onRegister():void
		{
			FlexGlobals.topLevelApplication.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);
			
			addContextListener(AnimationEvent.PLAY, contect_playHandler);
			addContextListener(AnimationEvent.STOP, contect_stopHandler);
			addContextListener(AnimationEvent.SEEK, contect_seekHandler);
			addContextListener(AnimationEvent.PAUSE, contect_pauseHandler);
			
			addContextListener(SceneEvent.TRANSLATE, eventDispatcher_translateHandler);
			addContextListener(SceneEvent.TRANSLATE_PIVOT, eventDispatcher_translateHandler);
			addContextListener(SceneEvent.SCALE, eventDispatcher_translateHandler);
			addContextListener(SceneEvent.ROTATE, eventDispatcher_translateHandler);
			addContextListener(SceneEvent.CHANGE_MESH, eventDispatcher_changeMeshHandler);
			addContextListener(SceneEvent.CHANGE_SUBMESH, eventDispatcher_changeMeshHandler);
			addContextListener(SceneEvent.CHANGE_LIGHT, eventDispatcher_changeLightHandler);
			addContextListener(SceneEvent.CHANGE_MATERIAL, eventDispatcher_changeMaterialHandler);
			addContextListener(SceneEvent.CHANGE_LIGHTPICKER, eventDispatcher_changeLightPickerHandler);
			addContextListener(SceneEvent.CHANGE_CONTAINER, eventDispatcher_changeContainerHandler);
			addContextListener(SceneEvent.CHANGE_SHADOW_METHOD, eventDispatcher_changeShadowMethodHandler);
			addContextListener(SceneEvent.CHANGE_SHADING_METHOD, eventDispatcher_changeShadingMethodHandler);
			addContextListener(SceneEvent.CHANGE_EFFECT_METHOD, eventDispatcher_changeEffectMethodHandler);
			addContextListener(SceneEvent.CHANGE_SHADOW_MAPPER, eventDispatcher_changeShadowMapperHandler);
			addContextListener(SceneEvent.CHANGE_CUBE_TEXTURE, eventDispatcher_changeCubeTextureHandler);
			addContextListener(SceneEvent.CHANGE_TEXTURE, eventDispatcher_changeTextureHandler);
			addContextListener(SceneEvent.CHANGE_GEOMETRY, eventDispatcher_changeGeometryHandler);
			addContextListener(SceneEvent.CHANGE_SKYBOX, eventDispatcher_changeSkyboxHandler);
			addContextListener(SceneEvent.CHANGE_ANIMATOR, eventDispatcher_changeAnimatorHandler);
			addContextListener(SceneEvent.CHANGE_TEXTURE_PROJECTOR, eventDispatcher_changeTextureProjectorHandler);
			addContextListener(SceneEvent.CHANGE_CAMERA, eventDispatcher_changeCameraHandler);
			addContextListener(SceneEvent.CHANGE_LENS, eventDispatcher_changeLensHandler);
			addContextListener(SceneEvent.CHANGE_SKELETON, eventDispatcher_changeSkeletonHandler);
			addContextListener(SceneEvent.CHANGE_ANIMATION_SET, eventDispatcher_changeAnimationSetHandler);
			addContextListener(SceneEvent.CHANGE_ANIMATION_NODE, eventDispatcher_changeAnimationNodeHandler);
			
			addContextListener(SceneEvent.REPARENT_LIGHTS, eventDispatcher_reparentLightsHandler);
			addContextListener(SceneEvent.REPARENT_ANIMATIONS, eventDispatcher_reparentAnimationHandler);
			addContextListener(SceneEvent.REPARENT_MATERIAL_EFFECT, eventDispatcher_reparentMaterialEffectHandler);
			
			addContextListener(SceneEvent.ADD_NEW_TEXTURE, eventDispatcher_addNewTextureHandler);
			addContextListener(SceneEvent.ADD_NEW_TEXTURE_PROJECTOR, eventDispatcher_addNewTextureHandler);
			addContextListener(SceneEvent.ADD_NEW_CUBE_TEXTURE, eventDispatcher_addNewCubeTextureHandler);
			addContextListener(SceneEvent.ADD_NEW_MESH, eventDispatcher_addNewMeshHandler);
			addContextListener(SceneEvent.ADD_NEW_CONTAINER, eventDispatcher_addNewContinerHandler);
			addContextListener(SceneEvent.ADD_NEW_MATERIAL, eventDispatcher_addNewMaterialToSubmeshHandler);
			addContextListener(SceneEvent.ADD_NEW_LIGHTPICKER, eventDispatcher_addNewLightpickerToMaterialHandler);
			addContextListener(SceneEvent.ADD_NEW_SHADOW_METHOD, eventDispatcher_addNewShadowMethodHandler);
			addContextListener(SceneEvent.ADD_NEW_EFFECT_METHOD, eventDispatcher_addNewEffectMethodHandler);
			addContextListener(SceneEvent.ADD_NEW_LIGHT, eventDispatcher_addNewLightHandler);
			
			addContextListener(SceneEvent.CONTAINER_CLICKED, eventDispatcher_containerClicked);
			
			addContextListener(DocumentModelEvent.OBJECTS_UPDATED, context_objectsUpdatedHandler);
			addContextListener(DocumentModelEvent.VALIDATE_OBJECT, context_validateObjectHandler);
			
			
			Scene3DManager.instance.addEventListener(Scene3DManagerEvent.READY, scene_readyHandler);
			Scene3DManager.instance.addEventListener(Scene3DManagerEvent.MESH_SELECTED, scene_meshSelectedHandler);
            Scene3DManager.instance.addEventListener(Scene3DManagerEvent.OBJECT_SELECTED_FROM_VIEW, scene_meshSelectedFromViewHandler);
            Scene3DManager.instance.addEventListener(Scene3DManagerEvent.TRANSFORM, scene_transformHandler);
            Scene3DManager.instance.addEventListener(Scene3DManagerEvent.TRANSFORM_RELEASE, scene_transformReleaseHandler);
			Scene3DManager.instance.addEventListener(Scene3DManagerEvent.ZOOM_DISTANCE_DELTA, eventDispatcher_zoomDistanceDeltaHandler);
			Scene3DManager.instance.addEventListener(Scene3DManagerEvent.ZOOM_TO_DISTANCE, eventDispatcher_zoomToDistanceHandler);
            Scene3DManager.instance.addEventListener(Scene3DManagerEvent.SWITCH_TRANSFORM_ROTATE, eventDispatcher_itemSwitchesToRotateMode);
            Scene3DManager.instance.addEventListener(Scene3DManagerEvent.SWITCH_TRANSFORM_TRANSLATE, eventDispatcher_itemSwitchesToTranslateMode);
            Scene3DManager.instance.addEventListener(Scene3DManagerEvent.SWITCH_CAMERA_TRANSFORMS, eventDispatcher_itemSwitchesToCameraTransformMode);
            Scene3DManager.instance.addEventListener(Scene3DManagerEvent.ENABLE_TRANSFORM_MODES, eventDispatcher_enableAllTransformModes);
            Scene3DManager.instance.addEventListener(Scene3DManagerEvent.UPDATE_BREADCRUMBS, eventDispatcher_updateBreadcrumbs);
			Scene3DManager.init( view.viewScope );
			//Scene3DManager.init(FlexGlobals.topLevelApplication.abcd);
			
            addContextListener(SceneEvent.SELECT, eventDispatcher_itemsSelectHandler);
			addContextListener(SceneEvent.DELETE, eventDispatcher_itemsDeleteHandler);
            addContextListener(SceneEvent.FOCUS_SELECTION, eventDispatcher_itemsFocusHandler);

			view.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			view.stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}
		
		//----------------------------------------------------------------------
		//
		//	view handlers
		//
		//----------------------------------------------------------------------
		
		private function keyDownHandler(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ALTERNATE) CameraManager.panning = true;		
			
			switch (e.keyCode) 
			{
                case Keyboard.W:
                case Keyboard.UP:
					CameraManager.moveForward(CameraManager.speed);
					e.stopImmediatePropagation();
					break;
                case Keyboard.S:
				case Keyboard.DOWN: 
					CameraManager.moveBackward(CameraManager.speed);
					e.stopImmediatePropagation();
					break;
                case Keyboard.A:
				case Keyboard.LEFT: 
					CameraManager.moveLeft(CameraManager.speed);
					e.stopImmediatePropagation();
					break;
                case Keyboard.D:
				case Keyboard.RIGHT: 
					CameraManager.moveRight(CameraManager.speed);
					e.stopImmediatePropagation();
					break;
				case Keyboard.SHIFT: 
					CameraManager.running = true;
					e.stopImmediatePropagation();
					break;
				case Keyboard.CONTROL:
					Scene3DManager.multiSelection = true;
					e.stopImmediatePropagation();
					break;	
				
			}				
		}
		
		private function keyUpHandler(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ALTERNATE) CameraManager.panning = false;
			
			switch (e.keyCode) 
			{
                case Keyboard.W:
                case Keyboard.S:
				case Keyboard.UP: 
				case Keyboard.DOWN: 
					CameraManager.moveForward(0);
					e.stopImmediatePropagation();
					break;
                case Keyboard.A:
                case Keyboard.D:
				case Keyboard.LEFT: 
				case Keyboard.RIGHT: 
					CameraManager.moveLeft(0);
					e.stopImmediatePropagation();
					break;
				case Keyboard.SHIFT: 
					CameraManager.running = false;
					e.stopImmediatePropagation();
					break;
				case Keyboard.CONTROL:
					Scene3DManager.multiSelection = false;
					e.stopImmediatePropagation();
					break;
			}				
			
		}	
		
		
		private function view_enterFrameHandler(event:Event):void
		{
			if( _currentAnimator && _currentAnimation )
			{
				var animator:AnimatorBase;
				switch (_currentAnimator.type){
					case "SkeletonAnimator":
						animator = assets.GetObject(_currentAnimator ) as SkeletonAnimator;
						break;
					case "VertexAnimator":
						animator = assets.GetObject(_currentAnimator ) as VertexAnimator;
						break;
						
				}
				if( animator.activeState)
				{
					var time:int = animator.time*animator.playbackSpeed;
					if ( animator.time >= _currentAnimation.totalDuration ) 
					{
						time %= _currentAnimation.totalDuration;
						
					}
					if ( time < 0)
					{
						time += _currentAnimation.totalDuration;
					}
					_currentAnimation.currentPosition = time;
				}
			}
		}
		//----------------------------------------------------------------------
		//
		//	context handlers
		//
		//----------------------------------------------------------------------
		
		private function contect_playHandler(event:AnimationEvent):void
		{
			var animator:AnimatorBase;
			switch (event.animator.type){
				case "SkeletonAnimator":
					animator = assets.GetObject( event.animator ) as SkeletonAnimator;
					break;
				case "VertexAnimator":
					animator = assets.GetObject( event.animator ) as VertexAnimator;
					break;
			}
			
			animator.updatePosition = false;
			event.animation.isPlaying = true;
			
			if( event.animation == event.animator.activeAnimationNode )
			{
				animator.start();
			}
			else
			{
				switch (event.animator.type){
					case "SkeletonAnimator":
						SkeletonAnimator(animator).play(event.animation.name, null, event.animation.currentPosition);
						break;
					case "VertexAnimator":
						VertexAnimator(animator).play(event.animation.name, null, event.animation.currentPosition);
						break;
				}
				event.animator.activeAnimationNode = event.animation;
			}
			
			_currentAnimation = event.animation;
			_currentAnimator = event.animator;
			this.view.addEventListener(Event.ENTER_FRAME, view_enterFrameHandler );
		}
		private function contect_pauseHandler(event:AnimationEvent):void
		{
			var animator:AnimatorBase;
			switch (event.animator.type){
				case "SkeletonAnimator":
					animator = assets.GetObject( event.animator ) as SkeletonAnimator;
					break;
				case "VertexAnimator":
					animator = assets.GetObject( event.animator ) as VertexAnimator;
					break;
			}
			event.animation.isPlaying = false;
			animator.stop();
			this.view.removeEventListener(Event.ENTER_FRAME, view_enterFrameHandler );
		}
		
		private function contect_stopHandler(event:AnimationEvent):void
		{
			if( !_currentAnimator || !_currentAnimation ) return;
			var animator:AnimatorBase;
			switch (_currentAnimator.type){
				case "SkeletonAnimator":
					animator = assets.GetObject( _currentAnimator ) as SkeletonAnimator;
					break;
				case "VertexAnimator":
					animator = assets.GetObject( _currentAnimator ) as VertexAnimator;
					break;
			}
			_currentAnimation.isPlaying = false;
			animator.stop();
			animator.time = 0;
			this.view.removeEventListener(Event.ENTER_FRAME, view_enterFrameHandler );
			
			_currentAnimation.currentPosition = 0;
			_currentAnimator = null;
			_currentAnimation = null;
		}
		private function contect_seekHandler(event:AnimationEvent):void
		{
			var animator:AnimatorBase;
			switch (event.animator.type){
				case "SkeletonAnimator":
					animator = assets.GetObject( event.animator ) as SkeletonAnimator;
					break;
				case "VertexAnimator":
					animator = assets.GetObject( event.animator ) as VertexAnimator;
					break;
			}
			event.animation.isPlaying = false;
			if( event.animation != event.animator.activeAnimationNode )
			{
				switch (event.animator.type){
					case "SkeletonAnimator":
						SkeletonAnimator(animator).play(event.animation.name, null, event.animation.currentPosition);
						break;
					case "VertexAnimator":
						VertexAnimator(animator).play(event.animation.name, null, event.animation.currentPosition);
						break;
				}
				animator.stop();
				event.animator.activeAnimationNode = event.animation;
			}
			
			_currentAnimation = event.animation;
			_currentAnimator = event.animator;
			
			var time:int = event.animation.currentPosition;
			if ( time >= _currentAnimation.totalDuration ) 
			{
				time %= _currentAnimation.totalDuration;
			}
			if ( time < 0)
			{
				time += _currentAnimation.totalDuration;
			}
			
			animator.time = time;
		}
		
		private function context_validateObjectHandler(event:DocumentModelEvent):void
		{
			if( event.asset is MeshVO )
			{
				applyMesh( event.asset as MeshVO );
			}
		}
		private function context_objectsUpdatedHandler(event:DocumentModelEvent):void
		{
			if( _currentAnimator )
			{
				contect_stopHandler( null );
			}
		}
		private function eventDispatcher_reparentLightsHandler(event:SceneEvent):void
		{
			for each( var item:DroppedAssetVO in event.newValue ) 
			{
				if( (item.value is LightVO) && item.newParent && (item.newParent is LightPickerVO) ) {
					applyLightPicker( item.newParent as LightPickerVO );
				}
			}
		}
		
		private function eventDispatcher_reparentMaterialEffectHandler(event:SceneEvent):void
		{
			for each( var item:DroppedAssetVO in event.newValue ) 
			{
				if( (item.value is EffectVO) && item.newParent && (item.newParent is MaterialVO) ) {
					applyMaterial( item.newParent as MaterialVO );
				}
			}
		}
		
		private function eventDispatcher_reparentAnimationHandler(event:SceneEvent):void
		{
			for each( var item:DroppedAssetVO in event.newValue ) 
			{
				if( item.value is AnimationNodeVO && item.newParent && item.newParent is AnimationSetVO ) {
					var newAnimationSet:AnimationSetBase = assets.GetObject(item.newParent) as AnimationSetBase;
					try
					{
						newAnimationSet.addAnimation( assets.GetObject(item.value) as AnimationNodeBase );
					}
					catch( e:AnimationSetError )
					{
						trace( e.message );
						trace( "// TODO: handle animations update" );
					}
				}
			}
		}
		
		private function eventDispatcher_translateHandler(event:SceneEvent):void
		{
			for each( var obj:ObjectVO in event.items )
			{
				var lightObject:LightVO = obj as LightVO;
				if( lightObject ) 
				{
					applyLight( lightObject );
				} 
				else 
				{
					applyObject( obj );
				}
			}
			
			Scene3DManager.updateDefaultCameraFarPlane();
		}
		
		private function applyLens( asset:LensVO ):void
		{
			var obj:LensBase = assets.GetObject( asset ) as LensBase;
			var perspectiveLens:PerspectiveLens = obj as PerspectiveLens;
			if( perspectiveLens )
			{
				perspectiveLens.fieldOfView = asset.value;
				perspectiveLens.near = asset.near;
				perspectiveLens.far = asset.far;
			}
			var orthographicLens:OrthographicLens = obj as OrthographicLens;
			if( orthographicLens )
			{
				orthographicLens.projectionHeight = asset.value;
				orthographicLens.near = asset.near;
				orthographicLens.far = asset.far;
			}
			var orthographicOffCenterLens:OrthographicOffCenterLens = obj as OrthographicOffCenterLens;
			if( orthographicOffCenterLens )
			{
				orthographicOffCenterLens.minX = asset.minX;
				orthographicOffCenterLens.maxX = asset.maxX;
				orthographicOffCenterLens.minY = asset.minY;
				orthographicOffCenterLens.maxY = asset.maxY;
				orthographicOffCenterLens.near = asset.near;
				orthographicOffCenterLens.far = asset.far;
			}
		}
		private function applyCamera( asset:CameraVO ):void
		{
			var obj:Camera3D = assets.GetObject( asset ) as Camera3D;
			obj.lens = assets.GetObject(asset.lens) as LensBase;
			applyObject( asset );
		}
		private function applyTextureProjector( asset:TextureProjectorVO ):void
		{
			var obj:TextureProjector = assets.GetObject( asset ) as TextureProjector;
			obj.fieldOfView = asset.fov;
			obj.aspectRatio = asset.aspectRatio;
			obj.texture = assets.GetObject(asset.texture) as Texture2DBase;
			applyObject( asset );
			
			Scene3DManager.updateTextureProjectorBitmap(obj, asset.texture.bitmapData);
		}
		private function applySkyBox( asset:SkyBoxVO ):void
		{
			var obj:SkyBox = assets.GetObject( asset ) as SkyBox;
			SkyBoxMaterial(obj.material).cubeMap = assets.GetObject(asset.cubeMap) as CubeTextureBase;
			obj.name = asset.name;
		}
		private function applyEffectMethod( asset:EffectVO ):void
		{
			var obj:EffectMethodBase = assets.GetObject( asset ) as EffectMethodBase;
			applyName( obj, asset );
			if( obj is ColorMatrixMethod )
			{
				var colorMatrixMethod:ColorMatrixMethod = obj as ColorMatrixMethod;
				colorMatrixMethod.colorMatrix = [ asset.r, asset.g, asset.b, asset.a, asset.rO, asset.rG, asset.gG, asset.bG, asset.aG, asset.gO,  asset.rB, asset.gB, asset.bB, asset.aB, asset.bO, asset.rA, asset.gA, asset.bA, asset.aA, asset.aO,];
			}
			else if( obj is FogMethod )
			{
				var fogMethod:FogMethod = obj as FogMethod;
				fogMethod.fogColor = asset.color;
				fogMethod.minDistance = asset.minDistance;
				fogMethod.maxDistance = asset.maxDistance;
			}
			else if( obj is AlphaMaskMethod )
			{
				var alphaMaskMethod:AlphaMaskMethod = obj as AlphaMaskMethod;
				alphaMaskMethod.texture = assets.GetObject( asset.texture ) as Texture2DBase;
				alphaMaskMethod.useSecondaryUV = asset.useSecondaryUV;
			}
			else if( obj is ColorTransformMethod )
			{
				var colorTransformMethod:ColorTransformMethod = obj as ColorTransformMethod;
				colorTransformMethod.colorTransform = new ColorTransform( asset.r, asset.g, asset.b, asset.a, asset.rO, asset.gO, asset.bO, asset.aO );
			}
			else if( obj is EnvMapMethod )
			{
				var envMapMethod:EnvMapMethod = obj as EnvMapMethod;
				envMapMethod.mask = assets.GetObject( asset.texture ) as Texture2DBase;
				envMapMethod.alpha = asset.alpha;
				envMapMethod.envMap = assets.GetObject( asset.cubeTexture ) as CubeTextureBase;
			}
			else if( obj is FresnelEnvMapMethod )
			{
				var fresnelEnvMapMethod:FresnelEnvMapMethod = obj as FresnelEnvMapMethod;
				fresnelEnvMapMethod.envMap = assets.GetObject( asset.cubeTexture ) as CubeTextureBase;
				fresnelEnvMapMethod.alpha = asset.alpha;
			}
			else if( obj is LightMapMethod )
			{
				var lightMapMethod:LightMapMethod = obj as LightMapMethod;
				lightMapMethod.texture = assets.GetObject( asset.texture ) as Texture2DBase;
				//lightMapMethod.useSecondaryUV = assets.useSecondaryUV;
				lightMapMethod.blendMode = asset.mode;
			}
			else if( obj is OutlineMethod )
			{
				var outlineMethod:OutlineMethod = obj as OutlineMethod;
				outlineMethod.outlineColor = asset.color;
				outlineMethod.showInnerLines = asset.showInnerLines;
				outlineMethod.outlineSize = asset.size;
//				outlineMethod.dedicatedMeshes
			}
			else if( obj is ProjectiveTextureMethod )
			{
				var projectiveTextureMethod:ProjectiveTextureMethod = obj as ProjectiveTextureMethod;
			}
			else if( obj is RefractionEnvMapMethod )
			{
				var refractionEnvMapMethod:RefractionEnvMapMethod = obj as RefractionEnvMapMethod;
				refractionEnvMapMethod.envMap = assets.GetObject( asset.cubeTexture ) as CubeTextureBase;
				refractionEnvMapMethod.dispersionR = asset.r;
				refractionEnvMapMethod.dispersionG = asset.g;
				refractionEnvMapMethod.dispersionB = asset.b;
				refractionEnvMapMethod.refractionIndex = asset.refraction;
				refractionEnvMapMethod.alpha = asset.alpha;
			}
			else if( obj is RimLightMethod )
			{
				var rimLightMethod:RimLightMethod = obj as RimLightMethod;
				rimLightMethod.color = asset.color;
				rimLightMethod.power = asset.power;
				rimLightMethod.strength = asset.strength;
			}
		}
		
		private function applyShadingMethod( asset:ShadingMethodVO ):void
		{
			var obj:ShadingMethodBase = assets.GetObject( asset ) as ShadingMethodBase;
			switch( true ) 
			{	
				case(obj is EnvMapAmbientMethod):
				{
					var envMapAmbientMethod:EnvMapAmbientMethod = obj as EnvMapAmbientMethod;
					envMapAmbientMethod.envMap = assets.GetObject( asset.envMap ) as CubeTextureBase;
					break;
				}
				case(obj is GradientDiffuseMethod):
				{
					var gradientDiffuseMethod:GradientDiffuseMethod = obj as GradientDiffuseMethod;
					gradientDiffuseMethod.gradient = assets.GetObject( asset.texture ) as Texture2DBase;
					break;
				}
				case(obj is WrapDiffuseMethod):
				{
					var wrapDiffuseMethod:WrapDiffuseMethod = obj as WrapDiffuseMethod;
					wrapDiffuseMethod.wrapFactor = asset.value;
					break;
				}
				case(obj is LightMapDiffuseMethod):
				{
					var lightMapDiffuseMethod:LightMapDiffuseMethod = obj as LightMapDiffuseMethod;
					lightMapDiffuseMethod.blendMode = asset.blendMode;
					lightMapDiffuseMethod.lightMapTexture = assets.GetObject( asset.texture ) as Texture2DBase;
					lightMapDiffuseMethod.baseMethod = assets.GetObject( asset.baseMethod ) as BasicDiffuseMethod;
					break;
				}
				case(obj is CelDiffuseMethod):
				{
					var celDiffuseMethod:CelDiffuseMethod = obj as CelDiffuseMethod;
					celDiffuseMethod.levels = asset.value;
					celDiffuseMethod.smoothness = asset.smoothness;
					celDiffuseMethod.baseMethod = assets.GetObject( asset.baseMethod ) as BasicDiffuseMethod;
					break;
				}
				case(obj is SubsurfaceScatteringDiffuseMethod):
				{
					var subsurfaceScatterDiffuseMethod:SubsurfaceScatteringDiffuseMethod = obj as SubsurfaceScatteringDiffuseMethod;
					subsurfaceScatterDiffuseMethod.scattering = asset.scattering;
					subsurfaceScatterDiffuseMethod.translucency = asset.translucency;
					subsurfaceScatterDiffuseMethod.baseMethod = assets.GetObject( asset.baseMethod ) as BasicDiffuseMethod;
					break;
				}
				case(obj is CelSpecularMethod):
				{
					var celSpecularMethod:CelSpecularMethod = obj as CelSpecularMethod;
					celSpecularMethod.specularCutOff = asset.value;
					celSpecularMethod.smoothness = asset.smoothness;
					celSpecularMethod.baseMethod = assets.GetObject( asset.baseMethod ) as BasicSpecularMethod;
					break;
				}
				case(obj is FresnelSpecularMethod):
				{
					var fresnelSpecularMethod:FresnelSpecularMethod = obj as FresnelSpecularMethod;
					fresnelSpecularMethod.basedOnSurface = asset.basedOnSurface;
					fresnelSpecularMethod.normalReflectance = asset.value;
					fresnelSpecularMethod.fresnelPower = asset.fresnelPower;
					fresnelSpecularMethod.baseMethod = assets.GetObject( asset.baseMethod ) as BasicSpecularMethod;
					break;
				}
				case(obj is HeightMapNormalMethod):
				{
					var heightMapNormalMethod:HeightMapNormalMethod = obj as HeightMapNormalMethod;
					break;
				}
				case(obj is SimpleWaterNormalMethod):
				{
					var simpleWaterNormalMethod:SimpleWaterNormalMethod = obj as SimpleWaterNormalMethod;
					simpleWaterNormalMethod.normalMap = assets.GetObject( asset.texture ) as Texture2DBase;
					break;
				}
			}
		}
		private function applyShadowMethod( asset:ShadowMethodVO ):void
		{
			var obj:ShadowMapMethodBase = assets.GetObject( asset ) as ShadowMapMethodBase;
			applyName( obj, asset );
			if( obj is HardShadowMapMethod )
			{
				var hardShadowMapMethod:HardShadowMapMethod = obj as HardShadowMapMethod;
				hardShadowMapMethod.alpha = asset.alpha;
				hardShadowMapMethod.epsilon = asset.epsilon;
			}
			else if( obj is FilteredShadowMapMethod )
			{
				var filteredShadowMapMethod:FilteredShadowMapMethod = obj as FilteredShadowMapMethod;
				filteredShadowMapMethod.alpha = asset.alpha;
				filteredShadowMapMethod.epsilon = asset.epsilon;
			}
			else if( obj is SoftShadowMapMethod )
			{
				var softShadowMapMethod:SoftShadowMapMethod = obj as SoftShadowMapMethod;
				softShadowMapMethod.numSamples = asset.samples;
				softShadowMapMethod.range = asset.range;
				softShadowMapMethod.alpha = asset.alpha;
				softShadowMapMethod.epsilon = asset.epsilon;
			}
			else if( obj is DitheredShadowMapMethod )
			{
				var ditheredShadowMapMethod:DitheredShadowMapMethod = obj as DitheredShadowMapMethod;
				ditheredShadowMapMethod.numSamples = asset.samples;
				ditheredShadowMapMethod.range = asset.range;
				ditheredShadowMapMethod.alpha = asset.alpha;
				ditheredShadowMapMethod.epsilon = asset.epsilon;
			}
			else if( obj is CascadeShadowMapMethod )
			{
				var cascadeShadowMapMethod:CascadeShadowMapMethod = obj as CascadeShadowMapMethod;
				cascadeShadowMapMethod.baseMethod = assets.GetObject( asset.baseMethod ) as SimpleShadowMapMethodBase;
			}
			else if( obj is NearShadowMapMethod )
			{
				var nearShadowMapMethod:NearShadowMapMethod = obj as NearShadowMapMethod;
				nearShadowMapMethod.baseMethod = assets.GetObject( asset.baseMethod ) as SimpleShadowMapMethodBase;
			}
		}
		
		private function applyAnimator( asset:AnimatorVO ):void
		{
			var obj:AnimatorBase = assets.GetObject( asset ) as AnimatorBase;
			applyName( obj, asset );
			obj.playbackSpeed = asset.playbackSpeed;
			var newAnimatorBase:AnimatorBase;
			
			var newAnimationSet:AnimationSetBase = assets.GetObject( asset.animationSet ) as AnimationSetBase;
			
			var skeletonAnimator:SkeletonAnimator = obj as SkeletonAnimator;
			if( skeletonAnimator )
			{
				var newSkeleton:Skeleton = assets.GetObject( asset.skeleton ) as Skeleton;
				if( skeletonAnimator.skeleton != newSkeleton )
				{
					newAnimatorBase = new SkeletonAnimator( newAnimationSet as SkeletonAnimationSet, newSkeleton );
				}
			}
			else
			{
				if( obj.animationSet != newAnimationSet )
				{
					newAnimatorBase = new VertexAnimator( newAnimationSet as VertexAnimationSet );
				}
			}
			
			if( newAnimatorBase ) 
			{
				assets.ReplaceObject( obj, newAnimatorBase );
				
				// TODO: use document, not assets
				var meshes:Vector.<Object> = assets.GetObjectsByType( Mesh, "animator", obj ) as Vector.<Object>;
				for each(var mesh:Mesh in meshes)
				{
					if( newAnimatorBase is SkeletonAnimator )
						mesh.animator = SkeletonAnimator(newAnimatorBase);
					if( newAnimatorBase is VertexAnimator )
						mesh.animator = VertexAnimator(newAnimatorBase);
					
					var vo:MeshVO = assets.GetAsset( mesh ) as MeshVO;
					vo.animator = assets.GetAsset( newAnimatorBase ) as AnimatorVO;
				}
			}
		}
		private function applyContainer( asset:ContainerVO ):void
		{
			var obj:ObjectContainer3D = assets.GetObject( asset ) as ObjectContainer3D;
			applyObject( asset );
			
			obj.extra = new Object();
			
			for each( var extra:ExtraItemVO in asset.extras )
			{
				obj.extra[extra.name] = extra.value;
			}
		}
		
		private function applyObject( asset:ObjectVO ):void
		{
			var obj:Object3D = Object3D( assets.GetObject(asset) );
			obj.name = asset.name;
			
			obj.pivotPoint = new Vector3D( asset.pivotX, asset.pivotY, asset.pivotZ );
			
			obj.x = asset.x;
			obj.y = asset.y;
			obj.z = asset.z;
			
			obj.scaleX = asset.scaleX;
			obj.scaleY = asset.scaleY;
			obj.scaleZ = asset.scaleZ;
			
			obj.rotationX = asset.rotationX;
			obj.rotationY = asset.rotationY;
			obj.rotationZ = asset.rotationZ;
		}
		
		private function applyLight( asset:LightVO ):void
		{
			var light:LightBase = assets.GetObject( asset ) as LightBase;
			light.ambient = asset.ambient;
			light.ambientColor = asset.ambientColor;
			light.diffuse = asset.diffuse;
			light.color = asset.color;
			light.specular = asset.specular;
			
			if(  asset.shadowMapper )
			{
				light.shadowMapper = assets.GetObject( asset.shadowMapper ) as ShadowMapperBase;
			}
			
			applyObject( asset );
			
			var directionalLight:DirectionalLight = light as DirectionalLight;
			if( directionalLight ) 
			{
				var y:Number = -Math.sin( asset.elevationAngle*Math.PI/180);
				var x:Number =  Math.sin(Math.PI/2 - asset.elevationAngle*Math.PI/180)*Math.sin( asset.azimuthAngle*Math.PI/180);
				var z:Number =  Math.sin(Math.PI/2 - asset.elevationAngle*Math.PI/180)*Math.cos( asset.azimuthAngle*Math.PI/180);
				directionalLight.direction = new Vector3D( x, y, z);
			}
			var pointLight:PointLight = light as PointLight;
			if( pointLight ) 
			{
				pointLight.radius = asset.radius;
				pointLight.fallOff = asset.fallOff;
			}
			
		}
		private function applyMesh( asset:MeshVO ):void
		{
			var obj:Mesh = assets.GetObject( asset ) as Mesh;
			applyContainer( asset );
			obj.castsShadows = asset.castsShadows;
			obj.geometry = assets.GetObject( asset.geometry ) as Geometry;
			var animator:AnimatorBase = assets.GetObject( asset.animator ) as AnimatorBase;
			
			if( animator is SkeletonAnimator )
			{
				var skeletonAnimator:SkeletonAnimator = animator as SkeletonAnimator;
				var skeletonAnimationSet:SkeletonAnimationSet = skeletonAnimator.animationSet as SkeletonAnimationSet;
				
				if( skeletonAnimationSet && skeletonAnimationSet.jointsPerVertex != asset.jointsPerVertex )
				{
					var newSkeletonAnimationSet:SkeletonAnimationSet = new SkeletonAnimationSet( asset.jointsPerVertex );
					
					for each( var node:AnimationNodeBase in skeletonAnimationSet.animations )
					{
						newSkeletonAnimationSet.addAnimation( node );
					}
					
					assets.ReplaceObject( skeletonAnimationSet, newSkeletonAnimationSet ); 
					
					var newAnimator:SkeletonAnimator = new SkeletonAnimator( newSkeletonAnimationSet, SkeletonAnimator(animator).skeleton );
					assets.ReplaceObject( animator, newAnimator ); 
					
					skeletonAnimator = newAnimator;
				}
				
				obj.animator = skeletonAnimator;
			}
			else if( animator is VertexAnimator )
			{
				var vertexAnimator:VertexAnimator = animator as VertexAnimator;
				obj.animator = vertexAnimator;
			}
			else
			{
				obj.animator = null;
			}
			
			for( var i:int = 0; i < obj.subMeshes.length; i++ )
			{
				assets.ReplaceObject( assets.GetObject( asset.subMeshes.getItemAt(i) as AssetVO ), obj.subMeshes[i] );
			}
			for each( var sub:SubMeshVO in asset.subMeshes )
			{
				applySubMesh( sub );
			}
		}
		private function applyLightPicker( asset:LightPickerVO ):void
		{
			var picker:StaticLightPicker = assets.GetObject( asset ) as StaticLightPicker;
			var lights:Array = [];
			for each( var light:SharedLightVO in asset.lights )
			{
				lights.push( assets.GetObject(light.linkedAsset) );
			}
			picker.lights = lights;
		}
		
		private function applySubMesh( asset:SubMeshVO ):void
		{
			var submesh:SubMesh = SubMesh( assets.GetObject(asset) );
			submesh.material = MaterialBase( assets.GetObject(asset.material) );
		}
		private function applyMaterial( asset:MaterialVO ):void
		{
			var m:MaterialBase = MaterialBase( assets.GetObject(asset) );
			var classType:Class;
			var oldMaterial:MaterialBase;
			if( asset.diffuseTexture ) 
			{
				if( asset.type == MaterialVO.SINGLEPASS ) 
				{
					classType = TextureMaterial;
				}
				else
				{
					classType = TextureMultiPassMaterial;
				}
			}
			else 
			{
				if( asset.type == MaterialVO.SINGLEPASS ) 
				{
					classType = ColorMaterial;
				}
				else
				{
					classType = ColorMultiPassMaterial;
				}
			}
			if( !(m is classType) )
			{
				oldMaterial = m;
				m = new classType();
			}
			
			m.alphaPremultiplied = asset.alphaPremultiplied;
			m.repeat = asset.repeat;
			m.bothSides = asset.bothSides;
			m.extra = asset.extra;
			
			setTimeout( applyAgain, 50, asset ); // issue #200
			
			m.mipmap = asset.mipmap;
			m.smooth = asset.smooth;
			m.blendMode = asset.blendMode;
			
			if( asset.lightPicker )
			{
				m.lightPicker = assets.GetObject(asset.lightPicker) as LightPickerBase;
			}
			
			var effect:SharedEffectVO;
			var singlePassMaterialBase:SinglePassMaterialBase = m as SinglePassMaterialBase;
			if( singlePassMaterialBase ) 
			{
				singlePassMaterialBase.diffuseMethod = assets.GetObject(asset.diffuseMethod) as BasicDiffuseMethod;
				singlePassMaterialBase.ambientMethod = assets.GetObject(asset.ambientMethod) as BasicAmbientMethod;
				singlePassMaterialBase.normalMethod = assets.GetObject(asset.normalMethod) as BasicNormalMethod;
				singlePassMaterialBase.specularMethod = assets.GetObject(asset.specularMethod) as BasicSpecularMethod;
				singlePassMaterialBase.alphaBlending = asset.alphaBlending;
				singlePassMaterialBase.alphaThreshold = asset.alphaThreshold;
				singlePassMaterialBase.gloss = asset.specularGloss;
					
				if( m is ColorMaterial )
				{
					var colorMaterial:ColorMaterial = m as ColorMaterial;
					colorMaterial.color = asset.diffuseColor;
					colorMaterial.alpha = asset.alpha;
					colorMaterial.shadowMethod = assets.GetObject(asset.shadowMethod) as ShadowMapMethodBase;
					colorMaterial.normalMap = assets.GetObject(asset.normalTexture) as Texture2DBase;
					colorMaterial.specularMap = assets.GetObject(asset.specularTexture) as Texture2DBase;
					colorMaterial.ambient = asset.ambientLevel;
					colorMaterial.ambientColor = asset.ambientColor;
					colorMaterial.specular = asset.specularLevel;
					colorMaterial.specularColor = asset.specularColor;
				}
				else if( m is TextureMaterial )
				{
					var textureMaterial:TextureMaterial = m as TextureMaterial;
					textureMaterial.shadowMethod = assets.GetObject(asset.shadowMethod) as ShadowMapMethodBase;
					textureMaterial.texture = assets.GetObject(asset.diffuseTexture) as Texture2DBase;
					textureMaterial.alpha = asset.alpha;
					textureMaterial.normalMap = assets.GetObject(asset.normalTexture) as Texture2DBase;
					textureMaterial.specularMap = assets.GetObject(asset.specularTexture) as Texture2DBase;
					textureMaterial.ambientTexture = assets.GetObject(asset.ambientTexture) as Texture2DBase;
					textureMaterial.ambient = asset.ambientLevel;
					textureMaterial.ambientColor = asset.ambientColor;
					textureMaterial.specular = asset.specularLevel;
					textureMaterial.specularColor = asset.specularColor;
				}
				
				var i:int;
				while( singlePassMaterialBase.numMethods )
				{
					singlePassMaterialBase.removeMethod(singlePassMaterialBase.getMethodAt(0));
				}
				for each( effect in asset.effectMethods )
				{
					singlePassMaterialBase.addMethod(assets.GetObject( effect.linkedAsset ) as EffectMethodBase);
				}
				
			}
			var multiPassMaterialBase:MultiPassMaterialBase = m as MultiPassMaterialBase;
			if( multiPassMaterialBase ) 
			{
				multiPassMaterialBase.alphaThreshold = asset.alphaThreshold;
				multiPassMaterialBase.diffuseMethod = assets.GetObject(asset.diffuseMethod) as BasicDiffuseMethod;
				multiPassMaterialBase.ambientMethod = assets.GetObject(asset.ambientMethod) as BasicAmbientMethod;
				multiPassMaterialBase.normalMethod = assets.GetObject(asset.normalMethod) as BasicNormalMethod;
				multiPassMaterialBase.specularMethod = assets.GetObject(asset.specularMethod) as BasicSpecularMethod;
				multiPassMaterialBase.gloss = asset.specularGloss;
				
				if( m is ColorMultiPassMaterial )
				{
					var colorMultiPassMaterial:ColorMultiPassMaterial = m as ColorMultiPassMaterial;
					colorMultiPassMaterial.color = asset.diffuseColor;
					colorMultiPassMaterial.shadowMethod = assets.GetObject(asset.shadowMethod) as ShadowMapMethodBase;
					colorMultiPassMaterial.normalMap = assets.GetObject(asset.normalTexture) as Texture2DBase;
					colorMultiPassMaterial.specularMap = assets.GetObject(asset.specularTexture) as Texture2DBase;
					colorMultiPassMaterial.ambient = asset.ambientLevel;
					colorMultiPassMaterial.ambientColor = asset.ambientColor;
					colorMultiPassMaterial.specular = asset.specularLevel;
					colorMultiPassMaterial.specularColor = asset.specularColor;
				}
				else if( m is TextureMultiPassMaterial )
				{
					var textureMultiPassMaterial:TextureMultiPassMaterial = m as TextureMultiPassMaterial;
					
					textureMultiPassMaterial.shadowMethod = assets.GetObject(asset.shadowMethod) as ShadowMapMethodBase;
					textureMultiPassMaterial.texture = assets.GetObject(asset.diffuseTexture) as Texture2DBase;
					
					textureMultiPassMaterial.normalMap = assets.GetObject(asset.normalTexture) as Texture2DBase;
					textureMultiPassMaterial.specularMap = assets.GetObject(asset.specularTexture) as Texture2DBase;
					textureMultiPassMaterial.ambientTexture = assets.GetObject(asset.ambientTexture) as Texture2DBase;
					textureMultiPassMaterial.ambient = asset.ambientLevel;
					textureMultiPassMaterial.ambientColor = asset.ambientColor;
					textureMultiPassMaterial.specular = asset.specularLevel;
					textureMultiPassMaterial.specularColor = asset.specularColor;
				}
				
				while( multiPassMaterialBase.numMethods )
				{
					multiPassMaterialBase.removeMethod(multiPassMaterialBase.getMethodAt(0));
				}
				for each( effect in asset.effectMethods )
				{
					multiPassMaterialBase.addMethod(assets.GetObject( effect.linkedAsset ) as EffectMethodBase);
				}
				
			}
			
			if( !asset.lightPicker )
			{
				m.lightPicker = null;
			}
			
			if( oldMaterial ) 
			{
				assets.ReplaceObject( oldMaterial, m );
				
				// TODO use document, not assets
				var subMeshes:Vector.<Object> = assets.GetObjectsByType( SubMesh, "material", oldMaterial ) as Vector.<Object>;
				for each(var obj:SubMesh in subMeshes)
				{
					obj.material = m;
					var vo:SubMeshVO = assets.GetAsset( obj ) as SubMeshVO;
					vo.material = assets.GetAsset( m ) as MaterialVO;
				}
			}
			
		}
		private function applyAgain( asset:MaterialVO  ):void
		{
			var m:MaterialBase = MaterialBase( assets.GetObject(asset) );
			m.bothSides = asset.bothSides;
		}
		private function eventDispatcher_changeLightHandler(event:SceneEvent):void
		{
			for each( var asset:LightVO in event.items )
			{
				applyLight( asset );
			}
		}
		private function eventDispatcher_changeLightPickerHandler(event:SceneEvent):void
		{
			for each( var asset:LightPickerVO in event.items )
			{
				applyLightPicker( asset );
			}
		}
		
		private function eventDispatcher_changeMeshHandler(event:SceneEvent):void
		{
			for each( var asset:AssetVO in event.items )
			{
				if( asset is MeshVO )
				{
					applyMesh( asset as MeshVO );
				}
				else if( asset is SubMeshVO )
				{
					applyMesh( SubMeshVO(asset).parentMesh );
				}
			}
		}
		private function updateChildren( children:ArrayCollection ):void
		{
			for each( var asset:ObjectVO in children )
			{
				switch(true)
				{
					case (asset is MeshVO):
						applyMesh( asset as MeshVO );
						break;
					case (asset is LightVO):
						applyLight( asset as LightVO );
						break;
					case (asset is CameraVO):
						applyCamera( asset as CameraVO );
						break;
					case (asset is ContainerVO):
						applyContainer( asset as ContainerVO );
						break;
				}
				if( asset is ContainerVO )
				{
					updateChildren( ContainerVO(asset).children );
				}
				
			}
		}
		private function eventDispatcher_addNewLightHandler(event:SceneEvent):void
		{
			for each( var asset:LightPickerVO in event.items )
			{
				applyLightPicker( asset );
			}
		}
		private function eventDispatcher_addNewLightpickerToMaterialHandler(event:SceneEvent):void
		{
			for each( var asset:MaterialVO in event.items )
			{
				applyMaterial( asset );
			}
		}
		
		private function eventDispatcher_addNewShadowMethodHandler(event:SceneEvent):void
		{
			var asset:MaterialVO = event.items[0] as MaterialVO;
			if( asset ) 
			{
				applyMaterial( asset );
			}
		}
		private function eventDispatcher_addNewEffectMethodHandler(event:SceneEvent):void
		{
			if( event.items && event.items.length ) {
				var asset:MaterialVO = event.items[0] as MaterialVO;
				if( asset ) 
				{
					applyMaterial( asset );
				}
			}
			
		}
		private function eventDispatcher_addNewMaterialToSubmeshHandler(event:SceneEvent):void
		{
			var asset:SubMeshVO = event.items[0] as SubMeshVO;
			if( asset ) 
			{
				applySubMesh( asset );
			}
		}
		
		private function eventDispatcher_addNewTextureHandler(event:SceneEvent):void
		{
			if( event.items && event.items.length ) {
				if( event.items[0] is MaterialVO ) 
				{
					applyMaterial( event.items[0] as MaterialVO );
				}
				if( event.items[0] is EffectVO ) 
				{
					applyEffectMethod( event.items[0] as EffectVO );
				}
				if( event.items[0] is TextureProjectorVO ) 
				{
					applyTextureProjector( event.items[0] as TextureProjectorVO );
				}
				if( event.items[0] is ShadingMethodVO ) 
				{
					applyShadingMethod( event.items[0] as ShadingMethodVO );
				}
			}
		}
		
		private function eventDispatcher_addNewContinerHandler(event:SceneEvent):void
		{
			var asset:ContainerVO = event.newValue as ContainerVO;
			if( asset ) 
			{
				applyContainer( asset );
				updateChildren( asset.children );
			}
		}
		private function eventDispatcher_addNewMeshHandler(event:SceneEvent):void
		{
			var asset:MeshVO = event.newValue as MeshVO;
			if( asset ) 
			{
				applyMesh( asset );
				updateChildren( asset.children );
			}
		}
		private function eventDispatcher_addNewCubeTextureHandler(event:SceneEvent):void
		{
			if( event.items && event.items.length ) {
				if( event.items[0] is EffectVO ) 
				{
					applyEffectMethod( event.items[0] as EffectVO );
				}
				else if( event.items[0] is ShadingMethodVO ) 
				{
					applyShadingMethod( event.items[0] as ShadingMethodVO );
				}
				else if( event.items[0] is SkyBoxVO ) 
				{
					applySkyBox( event.items[0] as SkyBoxVO );
				}
			}
		}
		
		private function eventDispatcher_changeAnimatorHandler(event:SceneEvent):void
		{
			var asset:AnimatorVO = event.items[0] as AnimatorVO;
			if( asset ) 
			{
				applyAnimator( asset );
			}
		}
		private function eventDispatcher_changeContainerHandler(event:SceneEvent):void
		{
			var asset:ContainerVO = event.items[0] as ContainerVO;
			if( asset ) 
			{
				applyContainer( asset );
				updateChildren( asset.children );
			}
		}
		
		private function eventDispatcher_changeEffectMethodHandler(event:SceneEvent):void
		{
			var asset:EffectVO = event.items[0] as EffectVO;
			if( asset ) 
			{
				applyEffectMethod( asset );
			}
		}
		private function eventDispatcher_changeCameraHandler(event:SceneEvent):void
		{
			var asset:CameraVO = event.items[0] as CameraVO;
			if( asset ) 
			{
				applyCamera( asset );
			}
		}
		private function eventDispatcher_changeAnimationSetHandler(event:SceneEvent):void
		{
			var asset:AnimationSetVO = event.items[0] as AnimationSetVO;
			if( asset ) 
			{
				var obj:AnimationSetBase = assets.GetObject( asset ) as AnimationSetBase;
				applyName( obj, asset );
			}
		}
		private function eventDispatcher_changeAnimationNodeHandler(event:SceneEvent):void
		{
			var asset:AnimationNodeVO = event.items[0] as AnimationNodeVO;
			if( asset ) 
			{
				var obj:AnimationNodeBase = assets.GetObject( asset ) as AnimationNodeBase;
				applyName( obj, asset );
			}
		}
		private function eventDispatcher_changeSkeletonHandler(event:SceneEvent):void
		{
			var asset:SkeletonVO = event.items[0] as SkeletonVO;
			if( asset ) 
			{
				var obj:Skeleton = assets.GetObject( asset ) as Skeleton;
				applyName( obj, asset );
			}
		}
		private function eventDispatcher_changeLensHandler(event:SceneEvent):void
		{
			var asset:LensVO = event.items[0] as LensVO;
			if( asset ) 
			{
				applyLens( asset );
			}
		}
		
		private function eventDispatcher_changeTextureProjectorHandler(event:SceneEvent):void
		{
			var asset:TextureProjectorVO = event.items[0] as TextureProjectorVO;
			if( asset ) 
			{
				applyTextureProjector( asset );
			}
		}
		private function eventDispatcher_changeSkyboxHandler(event:SceneEvent):void
		{
			var asset:SkyBoxVO = event.items[0] as SkyBoxVO;
			if( asset ) 
			{
				applySkyBox( asset );
			}
		}
		private function eventDispatcher_changeGeometryHandler(event:SceneEvent):void
		{
			var asset:GeometryVO = event.items[0] as GeometryVO;
			if( asset ) 
			{		
				
				asset.subGeometries = new ArrayCollection();
				var obj:Geometry = assets.GetObject( asset ) as Geometry;
				obj.name = asset.name;
				if( obj is PlaneGeometry )
				{
					var planeGeometry:PlaneGeometry = obj as PlaneGeometry;
					planeGeometry.width = asset.width;
					planeGeometry.height = asset.height;
					planeGeometry.segmentsW = asset.segmentsW;
					planeGeometry.segmentsH = asset.segmentsH;
					planeGeometry.yUp = asset.yUp;
					planeGeometry.doubleSided = asset.doubleSided;
				}
				else if( obj is CubeGeometry )
				{
					var cubeGeometry:CubeGeometry = obj as CubeGeometry;
					cubeGeometry.width = asset.width;
					cubeGeometry.height = asset.height;
					cubeGeometry.depth = asset.depth;
					cubeGeometry.tile6 = asset.tile6;
					cubeGeometry.segmentsD = asset.segmentsD;
					cubeGeometry.segmentsH = asset.segmentsH;
					cubeGeometry.segmentsW = asset.segmentsW;
				}
				else if( obj is SphereGeometry )
				{
					var sphereGeometry:SphereGeometry = obj as SphereGeometry;
					sphereGeometry.radius = asset.radius;
					sphereGeometry.yUp = asset.yUp;
					sphereGeometry.segmentsW = asset.segmentsSW;
					sphereGeometry.segmentsH = asset.segmentsSH;
				}
				else if( obj is ConeGeometry )
				{
					var coneGeometry:ConeGeometry = obj as ConeGeometry;
					coneGeometry.bottomRadius = asset.radius;
					coneGeometry.height = asset.height;
					coneGeometry.segmentsW = asset.segmentsR;
					coneGeometry.segmentsH = asset.segmentsH;
					coneGeometry.bottomClosed = asset.bottomClosed;
					coneGeometry.yUp = asset.yUp;
				}
				else if( obj is CylinderGeometry )
				{
					var cylinderGeometry:CylinderGeometry = obj as CylinderGeometry;
					cylinderGeometry.bottomRadius = asset.bottomRadius;
					cylinderGeometry.topRadius = asset.topRadius;
					cylinderGeometry.height = asset.height;
					cylinderGeometry.segmentsW = asset.segmentsR;
					cylinderGeometry.segmentsH = asset.segmentsH;
					cylinderGeometry.topClosed = asset.topClosed;
					cylinderGeometry.bottomClosed = asset.bottomClosed;
					cylinderGeometry.yUp = asset.yUp;
				}
				else if( obj is CapsuleGeometry )
				{
					var capsuleGeometry:CapsuleGeometry = obj as CapsuleGeometry;
					capsuleGeometry.radius = asset.radius;
					capsuleGeometry.height = asset.height;
					capsuleGeometry.segmentsW = asset.segmentsR;
					capsuleGeometry.segmentsH = asset.segmentsC;
					capsuleGeometry.yUp = asset.yUp;
				}
				else if( obj is TorusGeometry )
				{
					var torusGeometry:TorusGeometry = obj as TorusGeometry;
					torusGeometry.radius = asset.radius;
					torusGeometry.tubeRadius = asset.tubeRadius;
					torusGeometry.segmentsR = asset.segmentsR;
					torusGeometry.segmentsT = asset.segmentsT;
					torusGeometry.yUp = asset.yUp;
				}
				
				var subGeoCounter:uint=0;
				for each( var sub:ISubGeometry in obj.subGeometries )
				{
					subGeoCounter++;
					var subGeometryVO:SubGeometryVO = assets.GetAsset(sub) as SubGeometryVO;
					subGeometryVO.name="SubGeometry #"+subGeoCounter;
					subGeometryVO.scaleU=asset.scaleU;
					subGeometryVO.scaleV=asset.scaleV;
					subGeometryVO.numTris=sub.numTriangles;
					subGeometryVO.numVerts=sub.numVertices;
					asset.subGeometries.addItem( subGeometryVO );
				}
				obj.scaleUV(asset.scaleU,asset.scaleV)
			}
			
			Scene3DManager.updateDefaultCameraFarPlane();
		}
		private function eventDispatcher_changeTextureHandler(event:SceneEvent):void
		{
			var asset:TextureVO = event.items[0] as TextureVO;
			if( asset ) 
			{
				var obj:BitmapTexture = assets.GetObject( asset ) as BitmapTexture;
				obj.name = asset.name;
				obj.bitmapData = asset.bitmapData;
			}
		}
		private function eventDispatcher_changeCubeTextureHandler(event:SceneEvent):void
		{
			var asset:CubeTextureVO = event.items[0] as CubeTextureVO;
			if( asset ) 
			{
				var obj:BitmapCubeTexture = assets.GetObject( asset ) as BitmapCubeTexture;
				
				var maxValue:Number = Math.max(asset.positiveX.width,Math.max(asset.negativeX.width,
																Math.max(asset.positiveY.width,
																Math.max(asset.negativeY.width,
																	Math.max(asset.positiveZ.width,asset.negativeZ.width)))));
				var matrix:Matrix = new Matrix ();
				var data:BitmapData;
				var k:Number
				
				k = maxValue/asset.positiveX.width;
				matrix = new Matrix();
				matrix.scale(k, k);
				data = new BitmapData(maxValue, maxValue);
				data.draw(asset.positiveX, matrix);
				obj.positiveX = data;
				
				k = maxValue/asset.negativeX.width;
				matrix = new Matrix();
				matrix.scale(k, k);
				data = new BitmapData(maxValue, maxValue);
				data.draw(asset.negativeX, matrix);
				obj.negativeX = data;
				
				k = maxValue/asset.positiveY.width;
				matrix = new Matrix();
				matrix.scale(k, k);
				data = new BitmapData(maxValue, maxValue);
				data.draw(asset.positiveY, matrix);
				obj.positiveY = data;
				
				k = maxValue/asset.negativeY.width;
				matrix = new Matrix();
				matrix.scale(k, k);
				data = new BitmapData(maxValue, maxValue);
				data.draw(asset.negativeY, matrix);
				obj.negativeY = data;
				
				k = maxValue/asset.positiveZ.width;
				matrix = new Matrix();
				matrix.scale(k, k);
				data = new BitmapData(maxValue, maxValue);
				data.draw(asset.positiveZ, matrix);
				obj.positiveZ = data;
				
				k = maxValue/asset.negativeZ.width;
				matrix = new Matrix();
				matrix.scale(k, k);
				data = new BitmapData(maxValue, maxValue);
				data.draw(asset.negativeZ, matrix);
				obj.negativeZ = data;
			}
		}
		private function eventDispatcher_changeShadowMapperHandler(event:SceneEvent):void
		{
			var asset:ShadowMapperVO = event.items[0] as ShadowMapperVO;
			if( asset ) 
			{
				var obj:ShadowMapperBase = assets.GetObject( asset ) as ShadowMapperBase;
				obj.depthMapSize = asset.depthMapSize;
				if ( obj is CubeMapShadowMapper )
				{
					obj.depthMapSize = asset.depthMapSizeCube;
				}
				else
				if( obj is NearDirectionalShadowMapper )
				{
					var nearDirectionalShadowMapper:NearDirectionalShadowMapper = obj as NearDirectionalShadowMapper;
					nearDirectionalShadowMapper.coverageRatio = asset.coverage;
				}
				else if( obj is CascadeShadowMapper )
				{
					var cascadeShadowMapper:CascadeShadowMapper = obj as CascadeShadowMapper;
					cascadeShadowMapper.numCascades = asset.numCascades;
				}
			}
		}
		private function eventDispatcher_changeShadingMethodHandler(event:SceneEvent):void
		{
			var asset:ShadingMethodVO = event.items[0] as ShadingMethodVO;
			if( asset ) 
			{
				applyShadingMethod( asset );
			}
		}
		private function eventDispatcher_changeShadowMethodHandler(event:SceneEvent):void
		{
			var asset:ShadowMethodVO = event.items[0] as ShadowMethodVO;
			if( asset ) 
			{
				applyShadowMethod( asset );
			}
		}
		
		private function eventDispatcher_changeMaterialHandler(event:SceneEvent):void
		{
			for each( var asset:MaterialVO in event.items )
			{
				applyMaterial( asset );
			}
		}
		
		private function applyName( obj:Object, asset:AssetVO ):void 
		{
			var namedAssetBase:NamedAssetBase = obj as NamedAssetBase;
			if( namedAssetBase )
			{
				namedAssetBase.name = asset.name;
			}
		}
		
		private function eventDispatcher_itemsDeleteHandler(event:SceneEvent):void
		{
			for each( var state:DeleteStateVO in event.newValue as Vector.<DeleteStateVO> ) {
				var container:ContainerVO = state.owner as ContainerVO;
				if( container )
				{
					applyContainer( container );
				}
				var lightVO:LightVO = state.owner as LightVO;
				if( lightVO )
				{
					applyLight( lightVO );
				}
				var lightPickerVO:LightPickerVO = state.owner as LightPickerVO;
				if( lightPickerVO )
				{
					applyLightPicker( lightPickerVO );
				}
				var materialVO:MaterialVO = state.owner as MaterialVO;
				if( materialVO )
				{
					applyMaterial( materialVO );
				}
			}
		}
		private function eventDispatcher_itemsSelectHandler(event:SceneEvent):void
		{
			if( event.items.length )
			{
				if( event.items.length == 1 )
				{
					if( event.items[0] is MeshVO )
					{
						var mesh:MeshVO = event.items[0] as MeshVO;
						selectObjectsScene( assets.GetObject( mesh ) as ObjectContainer3D );
					}
					else if( event.items[0] is TextureProjectorVO )
					{
						var textureProjector:TextureProjectorVO = event.items[0] as TextureProjectorVO;
						selectTextureProjectorsScene( assets.GetObject( textureProjector ) as TextureProjector );
					}
					else if( event.items[0] is ContainerVO)
					{
						var container:ContainerVO = event.items[0] as ContainerVO;
						selectContainersScene( assets.GetObject( container ) as ObjectContainer3D );
					}
					else if( event.items[0] is LightVO )
					{
						var light:LightVO = event.items[0] as LightVO;
						selectLightsScene( assets.GetObject( light ) as LightBase );
					}
					else if( event.items[0] is CameraVO )
					{
						var camera:CameraVO = event.items[0] as CameraVO;
						selectCamerasScene( assets.GetObject( camera ) as Camera3D );
					}
					else if( event.items[0] is LensVO )
					{
						var lens:LensVO = event.items[0] as LensVO;
						Scene3DManager.lensSelected = assets.GetObject( lens ) as LensBase;
					}
					else {
                        Scene3DManager.unselectAll();
					}
				}
				else
				{
                    Scene3DManager.unselectAll();
				}
			}
			else
			{
                Scene3DManager.unselectAll();
			}
			
		}
		private function selectObjectsScene( o:ObjectContainer3D ):void
		{
			for each( var objectContainer3D:ObjectContainer3D in Scene3DManager.selectedObjects )
			{
				if( objectContainer3D == o )
				{
					return;
				}
			}
			Scene3DManager.selectObject(o);
		}
		private function selectContainersScene( c:ObjectContainer3D ):void
		{
			for each( var containerGizmo:ContainerGizmo3D in Scene3DManager.containerGizmos )
			{
				if( containerGizmo.sceneObject == c )
				{
					selectObjectsScene(containerGizmo.representation);
					return;
				}
			}
			Scene3DManager.selectObject(c);
		}
		
		private function selectLightsScene( l:LightBase ):void
		{
			for each( var lightGizmo:LightGizmo3D in Scene3DManager.lightGizmos )
			{
				if( lightGizmo.sceneObject == l )
				{
					selectObjectsScene(lightGizmo.representation);
					return;
				}
			}
		}
		private function selectTextureProjectorsScene( tP:TextureProjector ):void
		{
			for each( var textureProjectorGizmo:TextureProjectorGizmo3D in Scene3DManager.textureProjectorGizmos )
			{
				if( textureProjectorGizmo.sceneObject == tP )
				{
					selectObjectsScene(textureProjectorGizmo.representation);
					return;
				}
			}
		}
		private function selectCamerasScene( cM:Camera3D ):void
		{
			for each( var cameraGizmo:CameraGizmo3D in Scene3DManager.cameraGizmos )
			{
				if( cameraGizmo.sceneObject == cM )
				{
					selectObjectsScene(cameraGizmo.representation);
					return;
				}
			}
		}
        private function eventDispatcher_itemsFocusHandler(event:SceneEvent):void
        {
			if( CameraManager.mode == CameraMode.FREE )
			{
				this.dispatch(new SceneEvent(SceneEvent.SWITCH_CAMERA_TO_TARGET));
			}
            CameraManager.focusTarget( Scene3DManager.selectedObject );
        }
	
		private function eventDispatcher_containerClicked(event:SceneEvent) : void {
			Scene3DManager.resetCurrentContainer(event.options as ObjectContainer3D);
		}
		private function eventDispatcher_zoomDistanceDeltaHandler(event:Scene3DManagerEvent):void
        {
            this.dispatch( new Scene3DManagerEvent( Scene3DManagerEvent.ZOOM_DISTANCE_DELTA, "", null, event.currentValue ) );
        }

		private function eventDispatcher_zoomToDistanceHandler(event:Scene3DManagerEvent):void
        {
            this.dispatch( new Scene3DManagerEvent( Scene3DManagerEvent.ZOOM_TO_DISTANCE, "", null, event.currentValue ) );
        }

		//----------------------------------------------------------------------
		//
		//	scene handlers
		//
		//----------------------------------------------------------------------
		
		
		private function scene_readyHandler(event:Scene3DManagerEvent):void
		{
			this.dispatch(new SceneReadyEvent(SceneReadyEvent.READY));
		}	
		
		private function scene_meshSelectedHandler(event:Scene3DManagerEvent):void
		{
			view.setFocus();
			
			var selected:Array = [];
			var mesh:Mesh;
			var asset:AssetVO;
			var isSceneRepresentation:ISceneRepresentation;
				
			for each( var objectContainer:ObjectContainer3D in Scene3DManager.selectedObjects )
			{
				mesh = objectContainer as Mesh;
				if( mesh ) 
				{
					if ((isSceneRepresentation = (mesh.parent as ISceneRepresentation))!=null)
						asset = assets.GetAsset(isSceneRepresentation.sceneObject);
					else asset = assets.GetAsset(mesh);
					selected.push(asset);
				}
			} 
			this.dispatch(new SceneEvent(SceneEvent.SELECT,selected));
			
		}

		private function scene_meshSelectedFromViewHandler(event:Scene3DManagerEvent) : void {
			if (Scene3DManager.mouseSelection) {
				var asset:AssetVO = assets.GetAsset( Scene3DManager.mouseSelection );
				this.dispatch(new SceneEvent(SceneEvent.SELECT, [ asset ]));
			}
		}

        private function scene_transformHandler(event:Scene3DManagerEvent):void
        {
			var directionalLight:DirectionalLight = event.object as DirectionalLight;
			// update model without apply and save. 
			var originalVO:ObjectVO = assets.GetAsset( event.object ) as ObjectVO;
			var vo:ObjectVO = originalVO as ObjectVO;
			var lightVO:LightVO = originalVO as LightVO;
            switch( event.gizmoMode ) 
			{
                case GizmoMode.TRANSLATE:
					vo.x = event.endValue.x;
					vo.y = event.endValue.y;
					vo.z = event.endValue.z;
                    break;
                case GizmoMode.ROTATE:
					if (lightVO && directionalLight) 
					{
						lightVO.elevationAngle = Math.round(-Math.asin( directionalLight.direction.y )*180/Math.PI);
						var a:Number = Math.atan2(directionalLight.direction.x, directionalLight.direction.z )*180/Math.PI;
						lightVO.azimuthAngle = Math.round(a<0?a+360:a);
					} 
					vo.rotationX = event.endValue.x;
					vo.rotationY = event.endValue.y;
					vo.rotationZ = event.endValue.z;
                    break;
                default:
					vo.scaleX = event.endValue.x;
					vo.scaleY = event.endValue.y;
					vo.scaleZ = event.endValue.z;
                    break;
            }
        }

        private function scene_transformReleaseHandler(event:Scene3DManagerEvent):void
        {
			var vo:ObjectVO = assets.GetAsset( event.object ) as ObjectVO;
			var newValues:Vector.<Vector3D> = new Vector.<Vector3D>();
			newValues.push( event.endValue );
			trace( event.endValue );
			var oldValues:Vector.<Vector3D> = new Vector.<Vector3D>();
			oldValues.push( event.startValue );
            switch( event.gizmoMode ) 
			{
                case GizmoMode.TRANSLATE:
                    this.dispatch(new SceneEvent(SceneEvent.TRANSLATE,[vo], newValues, false, oldValues));
                    break;
                case GizmoMode.ROTATE:
                    this.dispatch(new SceneEvent(SceneEvent.ROTATE,[vo],newValues, false, oldValues));
                    break;
                default:
                    this.dispatch(new SceneEvent(SceneEvent.SCALE,[vo],newValues, false, oldValues));
                    break;
            }
        }

        private function eventDispatcher_itemSwitchesToRotateMode(event:Scene3DManagerEvent):void
        {
			Scene3DManager.setTransformMode(GizmoMode.ROTATE);

			var sE:SceneEvent = new SceneEvent(SceneEvent.ENABLE_TRANSFORM_MODES);
			sE.options = SceneEvent.ENABLE_ROTATE_MODE_ONLY;
			this.dispatch(sE);
		}

        private function eventDispatcher_itemSwitchesToTranslateMode(event:Scene3DManagerEvent):void
        {
			Scene3DManager.setTransformMode(GizmoMode.TRANSLATE);

			var sE:SceneEvent = new SceneEvent(SceneEvent.ENABLE_TRANSFORM_MODES);
			sE.options = SceneEvent.ENABLE_TRANSLATE_MODE_ONLY;
			this.dispatch(sE);
		}
		
		private function eventDispatcher_itemSwitchesToCameraTransformMode(event:Scene3DManagerEvent):void
        {
			if (Scene3DManager.currentGizmo == Scene3DManager.scaleGizmo) Scene3DManager.setTransformMode(GizmoMode.TRANSLATE);
			
			var sE:SceneEvent = new SceneEvent(SceneEvent.ENABLE_TRANSFORM_MODES);
			sE.options = SceneEvent.DISABLE_SCALE_MODE;
			this.dispatch(sE);
		}

        private function eventDispatcher_enableAllTransformModes(event:Scene3DManagerEvent):void
        {
			this.dispatch(new SceneEvent(SceneEvent.ENABLE_TRANSFORM_MODES));
		}

        private function eventDispatcher_updateBreadcrumbs(event:Scene3DManagerEvent):void
        {
			var sE:SceneEvent = new SceneEvent(SceneEvent.UPDATE_BREADCRUMBS);
			sE.options = Scene3DManager.containerBreadCrumbs;
			this.dispatch(sE);
		}

        //----------------------------------------------------------------------
		//
		//	uncaught Error Handler
		//
		//----------------------------------------------------------------------
		
		private function uncaughtErrorHandler(event:UncaughtErrorEvent):void
		{
			event.preventDefault();
			if (event.error is Error)
			{
				var error:Error = event.error as Error;
				Alert.show( error.message, error.name );
			}
			else if (event.error is ErrorEvent)
			{
				var errorEvent:ErrorEvent = event.error as ErrorEvent;
				Alert.show( errorEvent.text, errorEvent.type );
			}
			else
			{
				Alert.show( event.text, event.type );
			}
		}
		
	}
}