package awaybuilder.view.mediators
{
    import awaybuilder.controller.document.events.ImportTextureEvent;
    import awaybuilder.controller.events.DocumentModelEvent;
    import awaybuilder.controller.history.UndoRedoEvent;
    import awaybuilder.controller.scene.events.AnimationEvent;
    import awaybuilder.controller.scene.events.SceneEvent;
    import awaybuilder.model.ApplicationModel;
    import awaybuilder.model.AssetsModel;
    import awaybuilder.model.DocumentModel;
    import awaybuilder.model.vo.scene.AnimationNodeVO;
    import awaybuilder.model.vo.scene.AnimationSetVO;
    import awaybuilder.model.vo.scene.AnimatorVO;
    import awaybuilder.model.vo.scene.AssetVO;
    import awaybuilder.model.vo.scene.CameraVO;
    import awaybuilder.model.vo.scene.ContainerVO;
    import awaybuilder.model.vo.scene.CubeTextureVO;
    import awaybuilder.model.vo.scene.EffectVO;
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
    import awaybuilder.model.vo.scene.SkeletonVO;
    import awaybuilder.model.vo.scene.SkyBoxVO;
    import awaybuilder.model.vo.scene.SubGeometryVO;
    import awaybuilder.model.vo.scene.SubMeshVO;
    import awaybuilder.model.vo.scene.TextureProjectorVO;
    import awaybuilder.model.vo.scene.TextureVO;
    import awaybuilder.view.components.PropertiesPanel;
    import awaybuilder.view.components.editors.events.PropertyEditorEvent;
    
    import flash.events.Event;
    import flash.geom.Vector3D;
    
    import mx.charts.AreaChart;
    import mx.collections.ArrayCollection;
    import mx.controls.Alert;
    import mx.events.CloseEvent;
    
    import org.robotlegs.base.ContextEvent;
    import org.robotlegs.mvcs.Mediator;

    public class PropertiesPanelMediator extends Mediator
    {
        [Inject]
        public var view:PropertiesPanel;

		[Inject]
		public var assets:AssetsModel;
		
        [Inject]
        public var document:DocumentModel;

		[Inject]
		public var applicationModel:ApplicationModel;
		
        override public function onRegister():void
        {
			view.embedTexturesOptionEnabled = !applicationModel.webRestrictionsEnabled;
			
            addContextListener(SceneEvent.SELECT, context_itemsSelectHandler);
			addContextListener(UndoRedoEvent.UNDO, context_undoHandler);
			addContextListener(SceneEvent.DELETE, context_deleteHandler);
			
			addContextListener(DocumentModelEvent.OBJECTS_COLLECTION_UPDATED, context_documentUpdatedHandler);
			addContextListener(DocumentModelEvent.OBJECTS_FILLED, context_documentUpdatedHandler);
			addContextListener(DocumentModelEvent.OBJECTS_UPDATED, context_objectsUpdatedHandler);
			addContextListener(DocumentModelEvent.DOCUMENT_CREATED, context_documentUpdatedHandler);

            addViewListener( PropertyEditorEvent.TRANSLATE, view_translateHandler );
			addViewListener( PropertyEditorEvent.TRANSLATE_PIVOT, view_translatePivotHandler );
            addViewListener( PropertyEditorEvent.ROTATE, view_rotateHandler );
            addViewListener( PropertyEditorEvent.SCALE, view_scaleHandler );
			
            addViewListener( PropertyEditorEvent.MESH_CHANGE, view_meshChangeHandler );
            addViewListener( PropertyEditorEvent.MESH_STEPPER_CHANGE, view_meshStepperChangeHandler );
            addViewListener( PropertyEditorEvent.MESH_SUBMESH_CHANGE, view_meshSubmeshChangeHandler );
			addViewListener( PropertyEditorEvent.MESH_SUBMESH_ADD_NEW_MATERIAL, view_submeshAddNewMaterialHandler );
			
			addViewListener( PropertyEditorEvent.CONTAINER_CHANGE, view_containerChangeHandler );
			addViewListener( PropertyEditorEvent.CONTAINER_STEPPER_CHANGE, view_containerStepperChangeHandler );
			
			addViewListener( PropertyEditorEvent.GEOMETRY_CHANGE, view_geometryChangeHandler );
			addViewListener( PropertyEditorEvent.GEOMETRY_STEPPER_CHANGE, view_geometryStepperChangeHandler );
			
            addViewListener( PropertyEditorEvent.MATERIAL_CHANGE, view_materialChangeHandler );
            addViewListener( PropertyEditorEvent.MATERIAL_STEPPER_CHANGE, view_materialNameChangeHandler );
			addViewListener( PropertyEditorEvent.MATERIAL_AMBIENT_METHOD_CHANGE, view_materialAmbientMethodHandler );
			addViewListener( PropertyEditorEvent.MATERIAL_DIFFUSE_METHOD_CHANGE, view_materialDiffuseMethodHandler );
			addViewListener( PropertyEditorEvent.MATERIAL_NORMAL_METHOD_CHANGE, view_materialNormalMethodHandler );
			addViewListener( PropertyEditorEvent.MATERIAL_SPECULAR_METHOD_CHANGE, view_materialSpecularMethodHandler );
			addViewListener( PropertyEditorEvent.MATERIAL_ADD_TEXTURE, view_materialAddNewTextureHandler );
			addViewListener( PropertyEditorEvent.MATERIAL_ADD_EFFECT_METHOD, view_materialAddEffectMetodHandler );
			addViewListener( PropertyEditorEvent.MATERIAL_ADD_LIGHTPICKER, view_materialAddLightpickerHandler );
			addViewListener( PropertyEditorEvent.MATERIAL_REMOVE_EFFECT_METHOD, view_materialRemoveEffectMetodHandler );
			
			addViewListener( PropertyEditorEvent.SHADOWMETHOD_CHANGE, view_shadowmethodChangeHandler );
			addViewListener( PropertyEditorEvent.SHADOWMETHOD_STEPPER_CHANGE, view_shadowmethodChangeStepperHandler );
			addViewListener( PropertyEditorEvent.SHADOWMETHOD_BASE_METHOD_CHANGE, view_shadowmethodBaseMethodChangeHandler );
			
			addViewListener( PropertyEditorEvent.SKYBOX_CHANGE, view_skyboxChangeHandler );
			addViewListener( PropertyEditorEvent.SKYBOX_STEPPER_CHANGE, view_skyboxChangeStepperHandler );
			addViewListener( PropertyEditorEvent.SKYBOX_ADD_CUBE_TEXTURE, view_skyboxAddCubeTextureHandler );
			
			addViewListener( PropertyEditorEvent.SHADINGMETHOD_CHANGE, view_shadingmethodChangeHandler );
			addViewListener( PropertyEditorEvent.SHADINGMETHOD_ADD_TEXTURE, view_shadingmethodAddTextureHandler );
			addViewListener( PropertyEditorEvent.SHADINGMETHOD_ADD_CUBE_TEXTURE, view_shadingmethodAddCubeTextureHandler );
			addViewListener( PropertyEditorEvent.SHADINGMETHOD_BASE_METHOD_CHANGE, view_shadingmethodBaseMethodChangeHandler );
			addViewListener( PropertyEditorEvent.SHADINGMETHOD_STEPPER_CHANGE, view_shadingmethodChangeStepperHandler );
			
			addViewListener( PropertyEditorEvent.SHADOWMAPPER_CHANGE, view_shadowmapperChangeHandler );
			addViewListener( PropertyEditorEvent.SHADOWMAPPER_STEPPER_CHANGE, view_shadowmapperChangeStepperHandler );
			
			addViewListener( PropertyEditorEvent.TEXTURE_PROJECTOR_CHANGE, view_textureProjectorChangeHandler );
			addViewListener( PropertyEditorEvent.TEXTURE_PROJECTOR_ADD_TEXTURE, view_textureProjectorAddTextureHandler );
			addViewListener( PropertyEditorEvent.TEXTURE_PROJECTOR_STEPPER_CHANGE, view_textureProjectorChangeStepperHandler );
			
			addViewListener( PropertyEditorEvent.CAMERA_CHANGE, view_cameraChangeHandler );
			addViewListener( PropertyEditorEvent.CAMERA_LENS_CHANGE, view_cameraLensChangeHandler );
			addViewListener( PropertyEditorEvent.CAMERA_STEPPER_CHANGE, view_cameraChangeStepperHandler );
			
			addViewListener( PropertyEditorEvent.LENS_CHANGE, view_lensChangeHandler );
			addViewListener( PropertyEditorEvent.LENS_STEPPER_CHANGE, view_lensChangeStepperHandler );
			
			addViewListener( PropertyEditorEvent.EFFECTMETHOD_CHANGE, view_effectmethodChangeHandler );
			addViewListener( PropertyEditorEvent.EFFECTMETHOD_ADD_TEXTURE, view_effectmethodAddTextureHandler );
			addViewListener( PropertyEditorEvent.EFFECTMETHOD_ADD_CUBE_TEXTURE, view_effectmethodAddCubeTextureHandler );
			addViewListener( PropertyEditorEvent.EFFECTMETHOD_STEPPER_CHANGE, view_effectmethodChangeStepperHandler );
			
			addViewListener( PropertyEditorEvent.TEXTURE_STEPPER_CHANGE, view_textureChangeStepperHandler );
			addViewListener( PropertyEditorEvent.CUBETEXTURE_STEPPER_CHANGE, view_cubetextureChangeStepperHandler );
			
			addViewListener( PropertyEditorEvent.REPLACE_TEXTURE, view_replaceTextureHandler );
			addViewListener( PropertyEditorEvent.REPLACE_CUBE_TEXTURE, view_replaceCubeTextureHandler );
			
			addViewListener( PropertyEditorEvent.LIGHT_STEPPER_CHANGE, view_lightStepperChangeHandler );
			addViewListener( PropertyEditorEvent.LIGHT_CHANGE, view_lightChangeHandler );
			addViewListener( PropertyEditorEvent.LIGHT_MAPPER_CHANGE, view_lightMapperChangeHandler );
			
			addViewListener( PropertyEditorEvent.LIGHT_ADD_FilteredShadowMapMethod, view_lightAddFilteredShadowMapMethodHandler );
			addViewListener( PropertyEditorEvent.LIGHT_ADD_CascadeShadowMapMethod, view_lightAddCascadeShadowMapMethodHandler );
			addViewListener( PropertyEditorEvent.LIGHT_ADD_DitheredShadowMapMethod, view_lightAddDitheredShadowMapHandler );
			addViewListener( PropertyEditorEvent.LIGHT_ADD_HardShadowMapMethod, view_lightAddHardShadowMapMethodHandler );
			addViewListener( PropertyEditorEvent.LIGHT_ADD_NearShadowMapMethod, view_lightAddNearShadowMapMethodHandler );
			addViewListener( PropertyEditorEvent.LIGHT_ADD_SoftShadowMapMethod, view_lightAddSoftShadowMapMethodHandler );
			
			addViewListener( PropertyEditorEvent.LIGHTPICKER_CHANGE, view_lightPickerChangeHandler );
			addViewListener( PropertyEditorEvent.LIGHTPICKER_STEPPER_CHANGE, view_lightPickerStepperChangeHandler );
			addViewListener( PropertyEditorEvent.LIGHTPICKER_ADD_DIRECTIONAL_LIGHT, view_lightPickerAddDirectionalLightHandler );
			addViewListener( PropertyEditorEvent.LIGHTPICKER_ADD_POINT_LIGHT, view_lightPickerAddPointLightHandler );
			
			addViewListener( PropertyEditorEvent.ANIMATOR_CHANGE, view_animatorChangeHandler );
			addViewListener( PropertyEditorEvent.ANIMATOR_STEPPER_CHANGE, view_animatorStepperChangeHandler );
			addViewListener( PropertyEditorEvent.ANIMATOR_PLAY, view_animatorPlayHandler );
			addViewListener( PropertyEditorEvent.ANIMATOR_STOP, view_animatorStopHandler );
			addViewListener( PropertyEditorEvent.ANIMATOR_SEEK, view_animatorSeekHandler );
			addViewListener( PropertyEditorEvent.ANIMATOR_PAUSE, view_animatorPauseHandler );
			
			addViewListener( PropertyEditorEvent.SKELETON_STEPPER_CHANGE, view_skeletonChangeHandler );
			
			addViewListener( PropertyEditorEvent.ANIMATION_NODE_CHANGE, view_animationNodeChangeHandler );
			addViewListener( PropertyEditorEvent.ANIMATION_NODE_STEPPER_CHANGE, view_animationNodeStepperChangeHandler );
			
			addViewListener( PropertyEditorEvent.ANIMATION_SET_CHANGE, view_animationSetChangeHandler );
			addViewListener( PropertyEditorEvent.ANIMATION_SET_STEPPER_CHANGE, view_animationSetStepperChangeHandler );
			addViewListener( PropertyEditorEvent.ANIMATION_SET_ADD_ANIMATOR, view_animationAddAnimatorHandler );
			addViewListener( PropertyEditorEvent.ANIMATION_SET_REMOVE_ANIMATOR, view_animationRemoveAnimatorHandler );
			
			addViewListener( PropertyEditorEvent.SHOW_CHILD_PROPERTIES, view_showChildObjectPropertiesHandler );
			
			addViewListener( PropertyEditorEvent.SHOW_PARENT_PROPERTIES, view_showParentHandler );
			
			addViewListener( PropertyEditorEvent.GLOBAL_OPTIONS_CHANGE, view_globalOptionsChangeHandler );
			addViewListener( PropertyEditorEvent.GLOBAL_OPTIONS_STEPPER_CHANGE, view_globalOptionsStepperChangeHandler );
			
			view.currentState = "global";
			view.data = document.globalOptions;
			
        }

        //----------------------------------------------------------------------
        //
        //	view handlers
        //
        //----------------------------------------------------------------------


        private function view_translateHandler(event:PropertyEditorEvent):void
        {
			var items:Array = (view.data is Array)?(view.data as Array):[view.data];
			var newValues:Vector.<Vector3D> = new Vector.<Vector3D>();
			for each( var asset:ObjectVO in items )
			{
				newValues.push( event.data );
			}
            this.dispatch(new SceneEvent(SceneEvent.TRANSLATE, items, newValues, true));
        }
		private function view_translatePivotHandler(event:PropertyEditorEvent):void
		{
			var items:Array = (view.data is Array)?(view.data as Array):[view.data];
			var newValues:Vector.<Vector3D> = new Vector.<Vector3D>();
			for each( var asset:ObjectVO in items )
			{
				newValues.push( event.data );
			}
			this.dispatch(new SceneEvent(SceneEvent.TRANSLATE_PIVOT, items, newValues, true));
		}
		
        private function view_rotateHandler(event:PropertyEditorEvent):void
        {
			var items:Array = (view.data is Array)?(view.data as Array):[view.data];
			var newValues:Vector.<Vector3D> = new Vector.<Vector3D>();
			for each( var asset:ObjectVO in items )
			{
				newValues.push( event.data );
			}
            this.dispatch(new SceneEvent(SceneEvent.ROTATE,items, newValues, true));
        }
        private function view_scaleHandler(event:PropertyEditorEvent):void
        {
			var items:Array = (view.data is Array)?(view.data as Array):[view.data];
			var newValues:Vector.<Vector3D> = new Vector.<Vector3D>();
			for each( var asset:ObjectVO in items )
			{
				newValues.push( event.data );
			}
            this.dispatch(new SceneEvent(SceneEvent.SCALE,items, newValues, true));
        }
		private function view_containerChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_CONTAINER,[view.data], event.data));
		}
		private function view_containerStepperChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_CONTAINER,[view.data], event.data, true));
		}
		private function view_geometryChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_GEOMETRY,[view.data], event.data));
		}
		private function view_geometryStepperChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_GEOMETRY,[view.data], event.data, true));
		}
		
        private function view_meshChangeHandler(event:PropertyEditorEvent):void
        {
			var items:Array = (view.data is Array)?(view.data as Array):[view.data];
			var newValues:Vector.<MeshVO> = new Vector.<MeshVO>();
			for each( var asset:MeshVO in items )
			{
				newValues.push( event.data );
			}
            this.dispatch(new SceneEvent(SceneEvent.CHANGE_MESH,items, newValues));
        }
        private function view_meshStepperChangeHandler(event:PropertyEditorEvent):void
        {
			var items:Array = (view.data is Array)?(view.data as Array):[view.data];
			var newValues:Vector.<MeshVO> = new Vector.<MeshVO>();
			for each( var asset:MeshVO in items )
			{
				newValues.push( event.data );
			}
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_MESH,items, newValues, true));
        }
		private function view_globalOptionsChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_GLOBAL_OPTIONS,[view.data], event.data));
		}
		private function view_globalOptionsStepperChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_GLOBAL_OPTIONS,[view.data], event.data, true));
		}
        private function view_meshSubmeshChangeHandler(event:PropertyEditorEvent):void
        {
			var currentSubmesh:SubMeshVO;
			if( view.data )
			{
				var vo:MeshVO = view.data as MeshVO;
				for each( var subMesh:SubMeshVO in vo.subMeshes )
				{
					if( subMesh.equals( AssetVO(event.data) ) )
					{
						currentSubmesh = subMesh;
					}
				}
				this.dispatch(new SceneEvent(SceneEvent.CHANGE_SUBMESH,[currentSubmesh], event.data));
			}
        }
        private function view_materialChangeHandler(event:PropertyEditorEvent):void
        {
			var items:Array;
			if( view.data is MaterialVO ) items = [view.data];
			if( view.data is Array ) items = view.data as Array;
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_MATERIAL, items, event.data));
        }
        private function view_materialNameChangeHandler(event:PropertyEditorEvent):void
        {
			var items:Array;
			if( view.data is MaterialVO ) items = [view.data];
			if( view.data is Array ) items = view.data as Array;
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_MATERIAL,items, event.data, true));
        }
		private function view_materialAmbientMethodHandler(event:PropertyEditorEvent):void
		{
			var newMaterial:MaterialVO = MaterialVO(view.data).clone() as MaterialVO;
			var method:ShadingMethodVO = assets.CreateShadingMethod( event.data.toString() );
			newMaterial.ambientMethod = method;
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_MATERIAL,[view.data], newMaterial));
		}
		private function view_materialDiffuseMethodHandler(event:PropertyEditorEvent):void
		{
			var newMaterial:MaterialVO = MaterialVO(view.data).clone() as MaterialVO;
			var method:ShadingMethodVO = assets.CreateShadingMethod( event.data.toString() );
			newMaterial.diffuseMethod = method;
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_MATERIAL,[view.data], newMaterial));
		}
		private function view_materialNormalMethodHandler(event:PropertyEditorEvent):void
		{
			var newMaterial:MaterialVO = MaterialVO(view.data).clone() as MaterialVO;
			var method:ShadingMethodVO = assets.CreateShadingMethod( event.data.toString() );
			newMaterial.normalMethod = method;
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_MATERIAL,[view.data], newMaterial));
		}
		private function view_materialSpecularMethodHandler(event:PropertyEditorEvent):void
		{
			var newMaterial:MaterialVO = MaterialVO(view.data).clone() as MaterialVO;
			var method:ShadingMethodVO = assets.CreateShadingMethod( event.data.toString() );
			newMaterial.specularMethod = method;
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_MATERIAL,[view.data], newMaterial));
		}
		
		private function view_textureProjectorChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_TEXTURE_PROJECTOR,[view.data], event.data));
		}
		private function view_textureProjectorAddTextureHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new ImportTextureEvent(ImportTextureEvent.IMPORT_AND_ADD,[view.data],"texture"));
		}
		private function view_textureProjectorChangeStepperHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_TEXTURE_PROJECTOR,[view.data], event.data, true));
		}
		
		private function view_cameraChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_CAMERA,[view.data], event.data));
		}
		private function view_cameraChangeStepperHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_CAMERA,[view.data], event.data, true));
		}
		private function view_cameraLensChangeHandler(event:PropertyEditorEvent):void
		{
			var newCamera:CameraVO = CameraVO(view.data).clone() as CameraVO;
			var lens:LensVO = assets.CreateLens( event.data.toString() );
			newCamera.lens = lens;
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_CAMERA,[view.data], newCamera));
		}
		
		private function view_lensChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_LENS,[view.data], event.data));
		}
		private function view_lensChangeStepperHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_LENS,[view.data], event.data, true));
		}
		
		private function view_effectmethodChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_EFFECT_METHOD,[view.data], event.data));
		}
		private function view_effectmethodAddTextureHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new ImportTextureEvent(ImportTextureEvent.IMPORT_AND_ADD,[view.data],"texture"));
		}
		private function view_effectmethodAddCubeTextureHandler(event:PropertyEditorEvent):void
		{
			var e:SceneEvent = new SceneEvent(SceneEvent.ADD_NEW_CUBE_TEXTURE,[view.data],assets.CreateCubeTexture());
			e.options = "cubeTexture";
			this.dispatch(e);
		}
		private function view_effectmethodChangeStepperHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_EFFECT_METHOD,[view.data], event.data, true));
		}
		private function view_textureChangeStepperHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_TEXTURE,[view.data], event.data, true));
		}
		private function view_cubetextureChangeStepperHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_CUBE_TEXTURE,[view.data], event.data, true));
		}
		
		private function view_shadowmapperChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_SHADOW_MAPPER,[view.data], event.data));
		}
		private function view_shadowmapperChangeStepperHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_SHADOW_MAPPER,[view.data], event.data, true));
		}
		private function view_skyboxChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_SKYBOX,[view.data], event.data));
		}
		private function view_skyboxChangeStepperHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_SKYBOX,[view.data], event.data));
		}
		private function view_skyboxAddCubeTextureHandler(event:PropertyEditorEvent):void
		{
			var e:SceneEvent = new SceneEvent(SceneEvent.ADD_NEW_CUBE_TEXTURE,[view.data],assets.CreateCubeTexture());
			e.options = "cubeMap";
			this.dispatch(e);
		}
		private function view_shadowmethodChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_SHADOW_METHOD,[view.data], event.data));
		}
		private function view_shadowmethodChangeStepperHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_SHADOW_METHOD,[view.data], event.data, true));
		}
		private function view_shadowmethodBaseMethodChangeHandler(event:PropertyEditorEvent):void
		{
			var method:ShadowMethodVO;
			var light:LightVO = ShadowMethodVO(view.data).castingLight;
			var newMethod:ShadowMethodVO = ShadowMethodVO(view.data).clone() as ShadowMethodVO;
			switch(event.data)
			{
				case "FilteredShadowMapMethod":
					method = assets.CreateFilteredShadowMapMethod( light );
					break;
				case "DitheredShadowMapMethod":
					method = assets.CreateDitheredShadowMapMethod( light );
					break;
				case "SoftShadowMapMethod":
					method = assets.CreateSoftShadowMapMethod( light );
					break;
				case "HardShadowMapMethod":
					method = assets.CreateHardShadowMapMethod( light );
					break;
					
			}
			newMethod.baseMethod = method;
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_SHADOW_METHOD,[view.data], newMethod));
		}
		
		private function view_shadingmethodChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_SHADING_METHOD,[view.data], event.data));
		}
		private function view_shadingmethodAddTextureHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new ImportTextureEvent(ImportTextureEvent.IMPORT_AND_ADD,[view.data],"texture"));
		}
		private function view_shadingmethodAddCubeTextureHandler(event:PropertyEditorEvent):void
		{
			var e:SceneEvent = new SceneEvent(SceneEvent.ADD_NEW_CUBE_TEXTURE,[view.data],assets.CreateCubeTexture());
			e.options = "envMap";
			this.dispatch(e);
		}
		private function view_shadingmethodBaseMethodChangeHandler(event:PropertyEditorEvent):void
		{
			var newMethod:ShadingMethodVO = ShadingMethodVO(view.data).clone() as ShadingMethodVO;
			var method:ShadingMethodVO = assets.CreateShadingMethod( event.data.toString() );
			newMethod.baseMethod = method;
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_SHADING_METHOD,[view.data], newMethod));
		}
		
		private function view_shadingmethodChangeStepperHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_SHADING_METHOD,[view.data], event.data, true));
		}
		
		private function view_showChildObjectPropertiesHandler(event:PropertyEditorEvent):void
		{
			view.prevSelected.addItem(view.data);
			this.dispatch(new SceneEvent(SceneEvent.SELECT,[event.data],true));
		}
		
		private function view_showParentHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.SELECT,[event.data],false,false,true));
		}
		
		private function view_materialAddLightpickerHandler(event:PropertyEditorEvent):void
		{
			var asset:LightPickerVO = assets.CreateLightPicker();
			this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_LIGHTPICKER,[view.data], asset ));
		}
		
		private function view_materialAddNewTextureHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new ImportTextureEvent(ImportTextureEvent.IMPORT_AND_ADD,[view.data],event.data));
		}
		private function view_materialAddEffectMetodHandler(event:PropertyEditorEvent):void
		{
			if( event.data == "ProjectiveTextureMethod" )
			{
				var textureProjectors:Vector.<AssetVO> = document.getAssetsByType( TextureProjectorVO );
				if( textureProjectors.length == 0 )
				{
					Alert.show( "TextureProjector is missing", "Warning" );
				}
				else
				{
					this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_EFFECT_METHOD,[view.data], assets.CreateProjectiveTextureMethod( textureProjectors[0] as TextureProjectorVO )));
				}
				return;
			}
			this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_EFFECT_METHOD,[view.data], assets.CreateEffectMethod( event.data as String )));
		}
		private function view_materialRemoveEffectMetodHandler(event:PropertyEditorEvent):void
		{
			var material:MaterialVO = MaterialVO(view.data);
			for (var i:int = 0; i < material.effectMethods.length; i++) 
			{
				if( material.effectMethods.getItemAt( i ) == event.data )
				{
					material.effectMethods.removeItemAt(i);
					i--;
				}
			}
			
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_MATERIAL,[view.data], material));
		}
		
		
		private function view_submeshAddNewMaterialHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_MATERIAL,[event.data], assets.CreateMaterial()));
		}
		private function view_replaceTextureHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new ImportTextureEvent(ImportTextureEvent.IMPORT_AND_BITMAP_REPLACE,[view.data],"bitmapData"));
		}
		private function view_replaceCubeTextureHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new ImportTextureEvent(ImportTextureEvent.IMPORT_AND_BITMAP_REPLACE,[view.data],event.data));
		}
		
		private function view_lightChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_LIGHT,[view.data], event.data));
		}
		
		private var _storedLight:LightVO;
		private function view_lightMapperChangeHandler(event:PropertyEditorEvent):void
		{
			_storedLight = LightVO(view.data).clone() as LightVO;
			var mapper:ShadowMapperVO = assets.CreateShadowMapper( event.data.toString() );
			_storedLight.shadowMapper = mapper;
			if( LightVO(view.data).shadowMethods && LightVO(view.data).shadowMethods.length ) {
				_storedLight.shadowMethods = new ArrayCollection();
				view.callLater( alertCalledLater );
			}
			else
			{
				this.dispatch(new SceneEvent(SceneEvent.CHANGE_LIGHT,[view.data], _storedLight));
			}
			
		}
		private function alertCalledLater():void
		{
			Alert.show( "Assigned ShadowMethods will be removed (this operation cannot be undone)", "Warning", Alert.OK|Alert.CANCEL, null, lightMapperAlert_closeHandler )
		}
		private function lightMapperAlert_closeHandler(event:CloseEvent):void
		{
			if (event.detail == Alert.OK) 
			{
				this.dispatch(new SceneEvent(SceneEvent.CHANGE_LIGHT,[view.data], _storedLight));
			}
		}
		private function view_lightAddFilteredShadowMapMethodHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_SHADOW_METHOD,[view.data], assets.CreateFilteredShadowMapMethod(view.data as LightVO)));
		}
		private function view_lightAddCascadeShadowMapMethodHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_SHADOW_METHOD,[view.data], assets.CreateCascadeShadowMapMethod(view.data as LightVO)));
		}
		private function view_lightAddDitheredShadowMapHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_SHADOW_METHOD,[view.data], assets.CreateDitheredShadowMapMethod(view.data as LightVO)));
		}
		private function view_lightAddHardShadowMapMethodHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_SHADOW_METHOD,[view.data], assets.CreateHardShadowMapMethod(view.data as LightVO)));
		}
		private function view_lightAddNearShadowMapMethodHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_SHADOW_METHOD,[view.data], assets.CreateNearShadowMapMethod(view.data as LightVO)));
		}
		private function view_lightAddSoftShadowMapMethodHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_SHADOW_METHOD,[view.data], assets.CreateSoftShadowMapMethod(view.data as LightVO)));
		}
		
		private function view_lightStepperChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_LIGHT, [view.data], event.data, true));
		}
		
		private function view_lightPickerChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_LIGHTPICKER,[view.data], event.data));
		}
		private function view_lightPickerStepperChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_LIGHTPICKER, [view.data], event.data, true));
		}
		
		private function view_lightPickerAddDirectionalLightHandler(event:PropertyEditorEvent):void
		{
			var asset:LightVO = assets.CreateDirectionalLight();
			this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_LIGHT,[view.data],asset));
		}
		private function view_lightPickerAddPointLightHandler(event:PropertyEditorEvent):void
		{
			var asset:LightVO = assets.CreatePointLight();
			this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_LIGHT,[view.data],asset));
		}
		
		private function view_skeletonChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_SKELETON,[view.data], event.data, true));
		}
		
		private function view_animationNodeChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_ANIMATION_NODE,[view.data], event.data));
		}
		private function view_animationNodeStepperChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_ANIMATION_NODE, [view.data], event.data, true));
		}
		
		private function view_animationSetChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_ANIMATION_SET,[view.data], event.data));
		}
		private function view_animationSetStepperChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_ANIMATION_SET, [view.data], event.data, true));
		}
		private function view_animationAddAnimatorHandler(event:PropertyEditorEvent):void
		{
			var animator:AnimatorVO;
			switch( AnimationSetVO(view.data).type )
			{
				case "VertexAnimationSet":
					animator = assets.CreateAnimator( "VertexAnimator", view.data as AnimationSetVO );
					break;
				case "SkeletonAnimationSet":
					var skeletons:Vector.<SkeletonVO> = new Vector.<SkeletonVO>();
					for each( var asset:AssetVO in document.animations )
					{
						if( asset is SkeletonVO )
						{
							skeletons.push(asset);
						}
					}
					if( !skeletons.length )
					{
						Alert.show( "Skeleton is missing", "Warning" );
						return;
					}
					animator = assets.CreateAnimator( "SkeletonAnimator", view.data as AnimationSetVO, skeletons[0] );
					break;
			}
			this.dispatch(new SceneEvent(SceneEvent.ADD_NEW_ANIMATOR,[view.data], animator));
		}
		private function view_animationRemoveAnimatorHandler(event:PropertyEditorEvent):void
		{
			var newAnimationSet:AnimationSetVO = AnimationSetVO(view.data).clone();
			var animator:AnimatorVO = event.data as AnimatorVO;
			for( var i:int = 0; i < newAnimationSet.animators.length; i++ )
			{
				if( animator.equals(newAnimationSet.animators.getItemAt(i) as AnimatorVO) )
					newAnimationSet.animators.removeItemAt( i );
			}
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_ANIMATION_SET,[view.data], newAnimationSet));
		}
		
		private function view_animatorChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_ANIMATOR,[view.data], event.data));
		}
		private function view_animatorStepperChangeHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new SceneEvent(SceneEvent.CHANGE_ANIMATOR, [view.data], event.data, true));
		}
		private function view_animatorPlayHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new AnimationEvent(AnimationEvent.PLAY, view.data as AnimatorVO, event.data as AnimationNodeVO ));
		}
		private function view_animatorPauseHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new AnimationEvent(AnimationEvent.PAUSE, view.data as AnimatorVO, event.data as AnimationNodeVO));
		}
		private function view_animatorStopHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new AnimationEvent(AnimationEvent.STOP, view.data as AnimatorVO, event.data as AnimationNodeVO));
		}
		private function view_animatorSeekHandler(event:PropertyEditorEvent):void
		{
			this.dispatch(new AnimationEvent(AnimationEvent.SEEK, view.data as AnimatorVO, event.data as AnimationNodeVO));
		}
        //----------------------------------------------------------------------
        //
        //	context handlers
        //
        //----------------------------------------------------------------------

        private function context_itemsSelectHandler(event:SceneEvent):void
        {
            if( !event.items || event.items.length == 0)
            {
				view.showEditor( "global", event.newValue, event.oldValue, document.globalOptions );
                return;
            }
			
            if( event.items.length == 1 )
            {
				view.showEditor( getStateByType(event.items[0]), event.newValue, event.oldValue, event.items[0] );
            }
            else
            {
				view.showEditor( getStateByGroup(event.items), event.newValue, event.oldValue, event.items  );
            }
			view.validateNow();
			
			//if event.oldValue is true it means that we just back from child
			//if event.newValue is true it means that we select child
			if( !(event.oldValue||event.newValue) && view.prevSelected.length ) {
				view.prevSelected = new ArrayCollection();
			}
        }
		
		private function context_deleteHandler(event:SceneEvent):void
		{
			if( (view.data is AssetVO) && !getCurrentIsPresent( view.data as AssetVO ) ) 
			{
				dispatch( new SceneEvent( SceneEvent.SELECT, [] ) );
			}
		}
		private function context_undoHandler(event:UndoRedoEvent):void
		{
			view.callLater( undoHandler ); // must be executed after SceneObject is changed
		}
		private function undoHandler():void
		{
			if( (view.data is AssetVO) && !getCurrentIsPresent( view.data as AssetVO ) ) 
			{
				if( view.prevSelected && view.prevSelected.length>0 ) 
				{
					this.dispatch(new SceneEvent(SceneEvent.SELECT,[view.prevSelected.removeItemAt(view.prevSelected.length-1)],false,false,true));
				}
				else
				{
					this.dispatch(new SceneEvent(SceneEvent.SELECT,[]));
				}
			}
			else if ( view.data is Array )
			{
				view.forceUpdate();
			}
		}
		private function getCurrentIsPresent( asset:AssetVO ):Boolean
		{
			return getAssetIsInList( asset, document.getAllAssets() );
		}
		private function getAssetIsInList( asset:AssetVO, list:Array ):Boolean
		{
			for each ( var item:AssetVO in list )
			{
				if( item.equals( asset ) ) return true;
				
				var container:ContainerVO = item as ContainerVO;
				if( container && container.children && container.children.length )
				{
					if( getAssetIsInList( asset, container.children.source ) ) return true;
				}
				
				var materialVO:MaterialVO = item as MaterialVO;
				if( materialVO )
				{
					if( materialVO.ambientMethod.equals( asset ) ) return true;
					if( materialVO.specularMethod.equals( asset ) ) return true;
					if( materialVO.diffuseMethod.equals( asset ) ) return true;
					if( materialVO.normalMethod.equals( asset ) ) return true;
				}
				
				var lightVO:LightVO = item as LightVO;
				if( lightVO && lightVO.shadowMethods && lightVO.shadowMethods.length )
				{
					if( getAssetIsInList( asset, lightVO.shadowMethods.source ) ) return true;
					if( lightVO.shadowMapper.equals( asset ) ) return true;
				}
				var cameraVO:CameraVO = item as CameraVO;
				if( cameraVO)
				{
					if( cameraVO.lens.equals( asset ) ) return true;
				}
			}
			return false;
		}
		private function context_objectsUpdatedHandler(event:DocumentModelEvent):void
		{
			view.dispatchEvent( new Event("updateGroupCollection") );
		}
		private function context_documentUpdatedHandler(event:DocumentModelEvent):void
		{
			var nullItem:AssetVO = new AssetVO();
			nullItem.name = "Null";
			nullItem.isNull = true;
			var nullTextureItem:TextureVO = new TextureVO();
			nullTextureItem.name = "Null";
			nullTextureItem.isNull = true;
			
			var asset:AssetVO;
			var lights:Array = [];
			var pickers:Array = [nullItem];
			for each( asset in document.lights )
			{
				if( asset is LightPickerVO ) pickers.push( asset );
				if( asset is LightVO ) 
				{
					if( LightVO(asset).castsShadows ) lights.push( asset );
				}
			}
			view.lightPickers = new ArrayCollection(pickers);
			
			var nullableTextures:Array = [nullTextureItem, assets.defaultTexture];
			var defaultableTextures:Array = [assets.defaultTexture];
			var cubeTextures:Array = [assets.defaultCubeTexture];
			for each( asset in document.textures )
			{
				if( asset is TextureVO ) 
				{
					nullableTextures.push( asset );
					defaultableTextures.push( asset );
				}
				if( asset is CubeTextureVO )
				{
					cubeTextures.push( asset );
				}
			}
			view.nullableTextures = new ArrayCollection(nullableTextures);
			view.defaultableTextures = new ArrayCollection(defaultableTextures);
			view.cubeTextures = new ArrayCollection(cubeTextures);
			
			var geometry:Array = [];
			for each( asset in document.geometry )
			{
				if( asset is GeometryVO ) 
				{
					geometry.push( asset );
				}
			}
			view.geometry = new ArrayCollection(geometry);
			
			var animators:Array = [null];
			var skeletons:Array = [];
			for each( asset in document.animations )
			{
				if( asset is AnimationSetVO ) 
				{
					
					for each( var animator:AnimatorVO in AnimationSetVO(asset).animators )
					{
						animators.push( animator );
					}
					
				}
				else if( asset is SkeletonVO ) 
				{
					skeletons.push( asset );
				}
			}
			view.animators = new ArrayCollection(animators);
			view.skeletons = new ArrayCollection(skeletons);
			
			var texturePojectors:Array = [];
			var texturePojectorsVector:Vector.<AssetVO> = document.getAssetsByType( TextureProjectorVO );
			for each( asset in texturePojectorsVector )
			{
				texturePojectors.push( asset );
			}
			view.texturePojectors = new ArrayCollection( texturePojectors );
			
			var materials:ArrayCollection = new ArrayCollection();
			materials.addItemAt( assets.defaultMaterial, 0 );
			
			for each( asset in document.materials )
			{
				if( asset is MaterialVO ) 
				{
					materials.addItem( asset );
				}
			}
			
			view.materials = materials;
		}
		private static function getStateByGroup( assets:Array ):String
		{
			var initType:String = getStateByType( assets[0] );
			for each( var asset:AssetVO in assets )
			{
				if( asset is LightVO )
				{
					if( LightVO(asset).type == LightVO.DIRECTIONAL ) return "global";
				}
				if( initType != getStateByType( asset ) )
				{
					if( initType == "light" )
					{
						initType = "container";
						if( initType != getStateByType( asset ) )
						{
							return "global";
						}
					}
					
				}
			}
			if( initType == "container" || initType == "material" || initType == "mesh" )
			{
				return initType+"Group";
			}
			return "global";
		}		
		private static function getStateByType( asset:Object ):String
		{
			switch(true)
			{
				case(asset is MeshVO):
					return "mesh";
				case(asset is SkyBoxVO):
					return "skyBox";
				case(asset is TextureProjectorVO):
					return "textureProjector";
				case(asset is ContainerVO):
					return "container";
				case(asset is MaterialVO):
					return "material";
				case(asset is TextureVO):
					return "texture";
				case(asset is LightVO):
					return "light";
				case(asset is LightPickerVO):
					return "lightPicker";
				case(asset is ShadowMethodVO):
					return "shadowMethod";
				case(asset is EffectVO):
					return "effectMethod";
				case(asset is CubeTextureVO):
					return "cubeTexture";
				case(asset is ShadowMapperVO):
					return "shadowMapper";
				case(asset is ShadingMethodVO):
					return "shadingMethod";
				case(asset is GeometryVO):
					return "geometry";
				case(asset is SubGeometryVO):
					return "subGeometry";
				case(asset is AnimationSetVO):
					return "animationSet";
				case(asset is AnimationNodeVO):
					return "animationNode";
				case(asset is AnimatorVO):
					return "animator";
				case(asset is SkeletonVO):
					return "skeleton";
				case(asset is CameraVO):
					return "camera";
				case(asset is LensVO):
					return "lens";
					
			}
			return "global";
		}
	}
}