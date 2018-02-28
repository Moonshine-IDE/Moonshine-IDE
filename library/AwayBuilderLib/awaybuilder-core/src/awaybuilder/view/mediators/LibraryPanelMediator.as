package awaybuilder.view.mediators
{
	import awaybuilder.controller.document.events.ImportTextureEvent;
	import awaybuilder.controller.events.DocumentModelEvent;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.AssetsModel;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.DeleteStateVO;
	import awaybuilder.model.vo.DocumentVO;
	import awaybuilder.model.vo.scene.AnimationNodeVO;
	import awaybuilder.model.vo.scene.AnimationSetVO;
	import awaybuilder.model.vo.scene.AssetVO;
	import awaybuilder.model.vo.scene.CameraVO;
	import awaybuilder.model.vo.scene.ContainerVO;
	import awaybuilder.model.vo.scene.CubeTextureVO;
	import awaybuilder.model.vo.scene.EffectVO;
	import awaybuilder.model.vo.scene.GeometryVO;
	import awaybuilder.model.vo.scene.LightPickerVO;
	import awaybuilder.model.vo.scene.LightVO;
	import awaybuilder.model.vo.scene.MaterialVO;
	import awaybuilder.model.vo.scene.MeshVO;
	import awaybuilder.model.vo.scene.ObjectVO;
	import awaybuilder.model.vo.scene.ShadingMethodVO;
	import awaybuilder.model.vo.scene.ShadowMethodVO;
	import awaybuilder.model.vo.scene.SkeletonVO;
	import awaybuilder.model.vo.scene.SkyBoxVO;
	import awaybuilder.model.vo.scene.TextureProjectorVO;
	import awaybuilder.model.vo.scene.TextureVO;
	import awaybuilder.view.components.LibraryPanel;
	import awaybuilder.view.components.controls.tree.TreeDataProvider;
	import awaybuilder.view.components.events.LibraryPanelEvent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	import org.robotlegs.mvcs.Mediator;

	public class LibraryPanelMediator extends Mediator
	{
		
		private var _animations:ArrayCollection;
		private var _geometry:ArrayCollection;
		private var _materials:ArrayCollection;
		private var _scene:ArrayCollection;
		private var _skeletons:ArrayCollection;
		private var _textures:ArrayCollection;
		private var _lights:ArrayCollection;
		private var _methods:ArrayCollection;
		
		[Inject]
		public var view:LibraryPanel;
		
		[Inject]
		public var document:DocumentModel;
		
		[Inject]
		public var assets:AssetsModel;
		
		private var _model:DocumentVO;
		
		private var _selectedSceneItems:Vector.<Object> = new Vector.<Object>();
		
		private var _alreadySelected:Boolean = false;
		
		override public function onRegister():void
		{
			addViewListener(LibraryPanelEvent.TREE_CHANGE, view_treeChangeHandler);
			addViewListener(LibraryPanelEvent.ADD_DIRECTIONAL_LIGHT, view_addDirectionalLightHandler);
			addViewListener(LibraryPanelEvent.ADD_POINT_LIGHT, view_addPointLightHandler);
			addViewListener(LibraryPanelEvent.ADD_LIGHTPICKER, view_addLightPickerHandler);
			addViewListener(LibraryPanelEvent.ADD_TEXTURE, view_addTextureHandler);
			addViewListener(LibraryPanelEvent.ADD_CUBE_TEXTURE, view_addCubeTextureHandler);
			addViewListener(LibraryPanelEvent.ADD_GEOMETRY, view_addGeometryHandler);
			addViewListener(LibraryPanelEvent.ADD_MESH, view_addMeshHandler);
			addViewListener(LibraryPanelEvent.ADD_CONTAINER, view_addContainerHandler);
			addViewListener(LibraryPanelEvent.ADD_TEXTURE_PROJECTOR, view_addTextureProjectorHandler);
			addViewListener(LibraryPanelEvent.ADD_SKYBOX, view_addSkyBoxHandler);
			addViewListener(LibraryPanelEvent.ADD_EFFECTMETHOD, view_addEffectMethodHandler);
			addViewListener(LibraryPanelEvent.ADD_MATERIAL, view_addMaterialHandler);
			addViewListener(LibraryPanelEvent.ADD_ANIMATOR, view_addAnimatorHandler);
			addViewListener(LibraryPanelEvent.ADD_CAMERA, view_addCameraHandler);
			
			addViewListener(LibraryPanelEvent.LIGHT_DROPPED, view_lightDroppedHandler);
			addViewListener(LibraryPanelEvent.SCENEOBJECT_DROPPED, view_sceneObjectDroppedHandler);
			addViewListener(LibraryPanelEvent.ANIMATIONS_DROPPED, view_animationsDroppedHandler);
			addViewListener(LibraryPanelEvent.MATERIALS_DROPPED, view_materialsDroppedHandler);
			
			
			addContextListener(DocumentModelEvent.OBJECTS_COLLECTION_UPDATED, eventDispatcher_objectsCollectionHandler);
			
			addContextListener(DocumentModelEvent.DOCUMENT_CREATED, eventDispatcher_documentCreatedHandler);
			addContextListener(DocumentModelEvent.OBJECTS_FILLED, eventDispatcher_objectsFilledHandler);
			
			addContextListener(SceneEvent.PERFORM_DELETION, context_validateDeletionHandler);
			
			addContextListener(SceneEvent.SELECT, context_itemsSelectHandler);
			
			updateScenegraph();
		}
		
		//----------------------------------------------------------------------
		//
		//	view handlers
		//
		//----------------------------------------------------------------------
		
		
		private function view_materialsDroppedHandler(event:LibraryPanelEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.REPARENT_MATERIAL_EFFECT,[], event.data));		
		}
		private function view_animationsDroppedHandler(event:LibraryPanelEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.REPARENT_ANIMATIONS,[], event.data));		
		}
		private function view_sceneObjectDroppedHandler(event:LibraryPanelEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.REPARENT_OBJECTS,[], event.data));		
		}
		private function view_lightDroppedHandler(event:LibraryPanelEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.REPARENT_LIGHTS,[], event.data));
		}
		
		private function itemIsInList( collection:ArrayCollection, asset:AssetVO ):Boolean
		{
			for each( var a:AssetVO in collection )
			{
				if( a.equals( asset ) ) return true;
			}
			return false;
		}
		private function view_addMaterialHandler(event:LibraryPanelEvent):void
		{
			var asset:MaterialVO = assets.CreateMaterial()
			this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_MATERIAL,[], asset));
			this.dispatch(new SceneEvent(SceneEvent.SELECT,[asset]));
		}
		
		private function view_addCameraHandler(event:LibraryPanelEvent):void
		{
			var asset:CameraVO = assets.CreateCamera();
			this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_CAMERA,[], asset));
			this.dispatch(new SceneEvent(SceneEvent.SELECT,[asset]));
		}
		private function view_addAnimatorHandler(event:LibraryPanelEvent):void
		{
			var animation:AnimationSetVO
			switch( event.data )
			{
				case "VertexAnimationSet":
					animation = assets.CreateAnimationSet( event.data as String );
					break;
				case "SkeletonAnimationSet":
					animation = assets.CreateAnimationSet( event.data as String );
					break;
			}
			if( animation )
			{
				this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_ANIMATION_SET,[], animation));
				this.dispatch(new SceneEvent(SceneEvent.SELECT,[animation]));
			}
		}
		private function view_addEffectMethodHandler(event:LibraryPanelEvent):void
		{
			if( event.data == "ProjectiveTextureMethod" )
			{
				Alert.show( "To create a ProjectiveTextureMethod, you need TextureProjector", "TextureProjector is missing" );
				return;
			}
			var method:EffectVO = assets.CreateEffectMethod( event.data as String );
			this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_EFFECT_METHOD, null, method));
			this.dispatch(new SceneEvent(SceneEvent.SELECT,[method]));
		}
		private function view_addTextureHandler(event:LibraryPanelEvent):void
		{
			this.dispatch(new ImportTextureEvent(ImportTextureEvent.IMPORT_AND_ADD, null));
		}
		
		private function view_addGeometryHandler(event:LibraryPanelEvent):void
		{
			var asset:GeometryVO = assets.CreateGeometry( event.data as String );
			this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_GEOMETRY,null,asset));
			this.dispatch(new SceneEvent(SceneEvent.SELECT,[asset]));
		}
		
		private function view_addSkyBoxHandler(event:LibraryPanelEvent):void
		{
			var asset:SkyBoxVO = assets.CreateSkyBox();
			this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_SKYBOX,null,asset));
			this.dispatch(new SceneEvent(SceneEvent.SELECT,[asset]));
		}
		
		private function view_addContainerHandler(event:LibraryPanelEvent):void
		{
			var asset:ContainerVO = assets.CreateContainer();
			this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_CONTAINER,null,asset));
			this.dispatch(new SceneEvent(SceneEvent.SELECT,[asset]));
		}
		private function view_addMeshHandler(event:LibraryPanelEvent):void
		{
			if( !document.geometry.length )
			{
				Alert.show( "To create a Mesh, you need Geometry", "Cancelled" );
				return;
			}
			var asset:MeshVO = assets.CreateMesh( document.geometry.getItemAt(0) as GeometryVO );
			this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_MESH,null,asset));
			this.dispatch(new SceneEvent(SceneEvent.SELECT,[asset]));
		}
		private function view_addTextureProjectorHandler(event:LibraryPanelEvent):void
		{
			var asset:TextureProjectorVO = assets.CreateTextureProjector();
			this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_TEXTURE_PROJECTOR,null,asset));
			this.dispatch(new SceneEvent(SceneEvent.SELECT,[asset]));
		}
		
		private function view_addCubeTextureHandler(event:LibraryPanelEvent):void
		{
			var asset:CubeTextureVO = assets.CreateCubeTexture();
			this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_CUBE_TEXTURE,null,asset));
			this.dispatch(new SceneEvent(SceneEvent.SELECT,[asset]));
		}
		
		
		private function view_addDirectionalLightHandler(event:LibraryPanelEvent):void
		{
			var asset:LightVO = assets.CreateDirectionalLight();
			this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_LIGHT,null,asset));
			this.dispatch(new SceneEvent(SceneEvent.SELECT,[asset]));
		}
		private function view_addPointLightHandler(event:LibraryPanelEvent):void
		{
			var asset:LightVO = assets.CreatePointLight()
			this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_LIGHT,null,asset));
			this.dispatch(new SceneEvent(SceneEvent.SELECT,[asset]));
		}
		
		private function view_addLightPickerHandler(event:LibraryPanelEvent):void
		{
			var asset:LightPickerVO = assets.CreateLightPicker();
			this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_LIGHTPICKER,null,asset));
			this.dispatch(new SceneEvent(SceneEvent.SELECT,[asset]));
		}
		
		private function view_treeChangeHandler(event:LibraryPanelEvent):void
		{
			if( event.data )
			{
				_alreadySelected = true;
				
				var items:Array = [];
				var selectedItems:Vector.<Object> = event.data as Vector.<Object>;
				
				for (var i:int=0;i<selectedItems.length;i++)
				{
					items.push(selectedItems[i]);
				}
				this.dispatch(new SceneEvent(SceneEvent.SELECT,items));
			}
			
		}
		
		//----------------------------------------------------------------------
		//
		//	context handlers
		//
		//----------------------------------------------------------------------
		
		private function context_validateDeletionHandler(event:SceneEvent):void
		{
			var states:Vector.<DeleteStateVO> = new Vector.<DeleteStateVO>();
			var asset:AssetVO;
			for each( asset in view.sceneTree.selectedItems )
			{
				states.push( new DeleteStateVO( asset, TreeDataProvider(view.sceneTree.dataProvider).getItemParent( asset ) as AssetVO ) );
			}
			for each( asset in view.materialTree.selectedItems )
			{
				states.push( new DeleteStateVO( asset, TreeDataProvider(view.materialTree.dataProvider).getItemParent( asset ) as AssetVO ) );
			}
			for each( asset in view.texturesTree.selectedItems )
			{
				states.push( new DeleteStateVO( asset, TreeDataProvider(view.texturesTree.dataProvider).getItemParent( asset ) as AssetVO ) );
			}
			for each( asset in view.geometryTree.selectedItems )
			{
				states.push( new DeleteStateVO( asset, TreeDataProvider(view.sceneTree.dataProvider).getItemParent( asset ) as AssetVO ) );
			}
			for each( asset in view.animationsTree.selectedItems )
			{
				states.push( new DeleteStateVO( asset, TreeDataProvider(view.animationsTree.dataProvider).getItemParent( asset ) as AssetVO ) );
			}
			for each( asset in view.lightsTree.selectedItems )
			{
				states.push( new DeleteStateVO( asset, TreeDataProvider(view.lightsTree.dataProvider).getItemParent( asset ) as AssetVO ) );
			}
			
			var additionalStates:Vector.<DeleteStateVO> = new Vector.<DeleteStateVO>();
			var assetsList:Vector.<AssetVO>;
			for each( var state:DeleteStateVO in states )
			{
				if( state.asset is EffectVO )
				{
					assetsList = document.getAssetsByType( MaterialVO, materialsWithEffectFilterFunciton, state.asset );
					for each( asset in assetsList )
					{
						additionalStates.push( new DeleteStateVO( state.asset, asset ) );
					}
				}
				else if( state.asset is ShadowMethodVO )
				{
					assetsList = document.getAssetsByType( MaterialVO, materialsWithShadowMethodFilterFunciton, state.asset );
					for each( asset in assetsList )
					{
						additionalStates.push( new DeleteStateVO( state.asset, asset ) );
					}
					
				}
				else if( state.asset is LightVO )
				{
					assetsList = document.getAssetsByType( LightPickerVO, lightPickersWithLightFilterFunciton, state.asset );
					for each( asset in assetsList )
					{
						additionalStates.push( new DeleteStateVO( state.asset, asset ) );
					}
					assetsList = document.getAssetsByType( MaterialVO, materialsWithLightFilterFunciton, state.asset );
					for each( asset in assetsList )
					{
						additionalStates.push( new DeleteStateVO( state.asset, asset ) );
						if( MaterialVO(asset).shadowMethod )
						{
							additionalStates.push( new DeleteStateVO( MaterialVO(asset).shadowMethod, asset ) );
						}
						
					}
				}
				else if( state.asset is LightPickerVO )
				{
					assetsList = document.getAssetsByType( MaterialVO, materialsWithLightPickerFilterFunciton, state.asset );
					for each( asset in assetsList )
					{
						additionalStates.push( new DeleteStateVO( state.asset, asset ) );
						if( MaterialVO(asset).light )
						{
							additionalStates.push( new DeleteStateVO( MaterialVO(asset).light, asset ) );
						}
						if( MaterialVO(asset).shadowMethod )
						{
							additionalStates.push( new DeleteStateVO( MaterialVO(asset).shadowMethod, asset ) );
						}
					}
				}
			}
			
			this.dispatch(new SceneEvent(SceneEvent.DELETE, null, states.concat( additionalStates )));
			
		}
		
		private function materialsWithEffectFilterFunciton( asset:MaterialVO, filter:AssetVO ):Boolean
		{
			for each( var effect:EffectVO in asset.effectMethods )
			{
				if( effect.equals( filter ) )  return true;
			}
			return false;
		}
		private function materialsWithShadowMethodFilterFunciton( asset:MaterialVO, filter:AssetVO ):Boolean
		{
			return (asset.shadowMethod == filter);
		}
		private function materialsWithLightFilterFunciton( asset:MaterialVO, filter:AssetVO ):Boolean
		{
			return (asset.light == filter);
		}
		private function materialsWithLightPickerFilterFunciton( asset:MaterialVO, filter:AssetVO ):Boolean
		{
			return (asset.lightPicker == filter);
		}
		private function lightPickersWithLightFilterFunciton( asset:LightPickerVO, filter:AssetVO ):Boolean
		{
			for each( var light:LightVO in asset.lights )
			{
				if( light.equals( filter ) )  return true;
			}
			return false;
		}
		
		public function removeAsset( source:ArrayCollection, oddItem:AssetVO ):void
		{
			for (var i:int = 0; i < source.length; i++) 
			{
				if( source[i].id == oddItem.id )
				{
					source.removeItemAt( i );
					i--;
				}
			}
		}
		
		private function eventDispatcher_objectsFilledHandler(event:DocumentModelEvent):void
		{
			updateScenegraph();
			view.sceneTree.expandAll();
		}
		private function eventDispatcher_documentCreatedHandler(event:DocumentModelEvent):void
		{
			updateScenegraph();
		}
		
		private function eventDispatcher_objectsCollectionHandler(event:DocumentModelEvent):void
		{
//			updateScenegraph();
		}
		
		private function context_itemsSelectHandler(event:SceneEvent):void
		{
			if( _alreadySelected ) 
			{
				_alreadySelected = false;
				return;
			}
			
			_selectedSceneItems = new Vector.<Object>();
			for each( var asset:AssetVO in event.items )
			{
				_selectedSceneItems.push( asset );
			}
			view.selectedItems = _selectedSceneItems;
			view.callLater( ensureIndexIsVisible );
		}
		
		//----------------------------------------------------------------------
		//
		//	private methods
		//
		//----------------------------------------------------------------------
		
		private function ensureIndexIsVisible():void 
		{
			if( view.sceneTree.selectedIndex )
			{
				view.callLater( view.sceneTree.ensureIndexIsVisible, [view.sceneTree.selectedIndex] );	
			}
			if( view.materialTree.selectedIndex )
			{
				view.callLater( view.materialTree.ensureIndexIsVisible, [view.materialTree.selectedIndex] );	
			}
			if( view.texturesTree.selectedIndex )
			{
				view.callLater( view.texturesTree.ensureIndexIsVisible, [view.texturesTree.selectedIndex] );	
			}
			
		}
		private function getItemIsSelected( id:String, selectedItems:Array ):Boolean
		{
			for each( var object:AssetVO in selectedItems )
			{
				if( object.id == id )
				{
					return true;
				}
			}
			return false;
		}
		private function updateScenegraph():void
		{
			view.model.scene = document.scene;
			view.model.materials = document.materials;
			view.model.textures = document.textures;
			view.model.geometry = document.geometry;
			view.model.lights = document.lights;
			view.model.animations = document.animations;
		}
		
	}
}