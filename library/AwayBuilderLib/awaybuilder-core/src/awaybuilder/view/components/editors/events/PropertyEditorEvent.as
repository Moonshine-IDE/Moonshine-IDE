package awaybuilder.view.components.editors.events
{
    import flash.events.Event;

    public class PropertyEditorEvent extends Event
    {

        public static const TRANSLATE:String = "objectTranslate";
		public static const TRANSLATE_PIVOT:String = "objectTranslatePivot";
        public static const SCALE:String = "objectScale";
        public static const ROTATE:String = "objectRotate";

        public static const MESH_CHANGE:String = "meshChange";
        public static const MESH_STEPPER_CHANGE:String = "meshStepperChange";
		public static const MESH_SUBMESH_ADD_NEW_MATERIAL:String = "submeshAddNewMaterial";
		
		public static const MATERIAL_CHANGE:String = "materialChange";
//		public static const MATERIAL_ADD_SHADOWMETHOD:String = "materialAddShadowMethod";
		public static const MATERIAL_AMBIENT_METHOD_CHANGE:String = "materialAmbientMethodChange";
		public static const MATERIAL_DIFFUSE_METHOD_CHANGE:String = "materialDiffuseMethodChange";
		public static const MATERIAL_NORMAL_METHOD_CHANGE:String = "materialNormalMethodChange";
		public static const MATERIAL_SPECULAR_METHOD_CHANGE:String = "materialSpecularMethodChange";
		public static const MATERIAL_ADD_TEXTURE:String = "materialAddTexture";
		public static const MATERIAL_ADD_LIGHTPICKER:String = "materialAddLightPicker";
		public static const MATERIAL_ADD_EFFECT_METHOD:String = "materialAddEffectMethod";
		public static const MATERIAL_REMOVE_EFFECT_METHOD:String = "materialRemoveEffectMethod";
		public static const MATERIAL_STEPPER_CHANGE:String = "materialStepperChange";
		
		public static const GEOMETRY_CHANGE:String = "geometryChange";
		public static const GEOMETRY_STEPPER_CHANGE:String = "geometryStepperChange";
		
		public static const TEXTURE_CHANGE:String = "textureChange";
		public static const TEXTURE_STEPPER_CHANGE:String = "textureStepperChange";
		
		public static const ANIMATION_NODE_CHANGE:String = "animationNodeChange";
		public static const ANIMATION_NODE_STEPPER_CHANGE:String = "animationNodeStepperChange";
		
		public static const ANIMATION_SET_CHANGE:String = "animationSetChange";
		public static const ANIMATION_SET_STEPPER_CHANGE:String = "animationSetStepperChange";
		public static const ANIMATION_SET_ADD_ANIMATOR:String = "animationSetAddAnimator";
		public static const ANIMATION_SET_REMOVE_ANIMATOR:String = "animationSetRemoveAnimator";
		public static const ANIMATION_SET_REMOVE_ANIMATION:String = "animationSetRemoveAnimation";
		
		public static const ANIMATOR_CHANGE:String = "animatorChange";
		public static const ANIMATOR_STEPPER_CHANGE:String = "animatorStepperChange";
		public static const ANIMATOR_PLAY:String = "animatorPlay";
		public static const ANIMATOR_STOP:String = "animatorStop";
		public static const ANIMATOR_PAUSE:String = "animatorPause";
		public static const ANIMATOR_SEEK:String = "animatorSeek";
		
		public static const SKELETON_CHANGE:String = "skeletonChange";
		public static const SKELETON_STEPPER_CHANGE:String = "skeletonStepperChange";
		
		public static const TEXTURE_PROJECTOR_CHANGE:String = "textureProjectorChange";
		public static const TEXTURE_PROJECTOR_ADD_TEXTURE:String = "textureProjectorAddTexture";
		public static const TEXTURE_PROJECTOR_STEPPER_CHANGE:String = "textureProjectorStepperChange";
		
		public static const CUBETEXTURE_CHANGE:String = "cubetextureChange";
		public static const CUBETEXTURE_STEPPER_CHANGE:String = "cubetextureStepperChange";
		
		public static const REPLACE_TEXTURE:String = "replaceTexture";
		public static const REPLACE_CUBE_TEXTURE:String = "replaceCubeTexture";

        public static const MESH_SUBMESH_CHANGE:String = "meshSubmeshChange";

		public static const CONTAINER_CHANGE:String = "containerChange";
		public static const CONTAINER_STEPPER_CHANGE:String = "containerStepperChange";
		
		public static const CAMERA_CHANGE:String = "cameraChange";
		public static const CAMERA_STEPPER_CHANGE:String = "cameraStepperChange";
		public static const CAMERA_LENS_CHANGE:String = "cameraLensChange";
		
		public static const LENS_CHANGE:String = "lensChange";
		public static const LENS_STEPPER_CHANGE:String = "lensStepperChange";
		
		public static const LIGHT_CHANGE:String = "lightChange";
		public static const LIGHT_MAPPER_CHANGE:String = "lightMapperChange";
		public static const LIGHT_STEPPER_CHANGE:String = "lightStepperChange";
		
		public static const LIGHT_ADD_FilteredShadowMapMethod:String = "lightAddFilteredShadowMapMethod";
		public static const LIGHT_ADD_DitheredShadowMapMethod:String = "lightAddDitheredShadowMapMethod";
		public static const LIGHT_ADD_SoftShadowMapMethod:String = "lightAddSoftShadowMapMethod";
		public static const LIGHT_ADD_HardShadowMapMethod:String = "lightAddHardShadowMapMethod";
		public static const LIGHT_ADD_NearShadowMapMethod:String = "lightAddNearShadowMapMethod";
		public static const LIGHT_ADD_CascadeShadowMapMethod:String = "lightAddCascadeShadowMapMethod";
		
		public static const SHADINGMETHOD_CHANGE:String = "shadingmethodChange";
		public static const SHADINGMETHOD_BASE_METHOD_CHANGE:String = "shadingmethodBaseMethodChange";
		public static const SHADINGMETHOD_ADD_TEXTURE:String = "shadingmethodAddTexture";
		public static const SHADINGMETHOD_ADD_CUBE_TEXTURE:String = "shadingmethodAddCubeTexture";
		public static const SHADINGMETHOD_STEPPER_CHANGE:String = "shadingmethodStepperChange";
		
		public static const SHADOWMETHOD_CHANGE:String = "shadowmethodChange";
		public static const SHADOWMETHOD_STEPPER_CHANGE:String = "shadowmethodStepperChange";
		public static const SHADOWMETHOD_BASE_METHOD_CHANGE:String = "shadowmethodBaseMethodChange";
		
		public static const SHADOWMAPPER_CHANGE:String = "shadowMapperChange";
		public static const SHADOWMAPPER_STEPPER_CHANGE:String = "shadowMapperStepperChange";
		
		public static const EFFECTMETHOD_CHANGE:String = "effectmethodChange";
		public static const EFFECTMETHOD_ADD_TEXTURE:String = "effectmethodAddTexture";
		public static const EFFECTMETHOD_ADD_CUBE_TEXTURE:String = "effectmethodAddCubeTexture";
		public static const EFFECTMETHOD_STEPPER_CHANGE:String = "effectmethodStepperChange";
		
		public static const SKYBOX_CHANGE:String = "skyboxChange";
		public static const SKYBOX_ADD_CUBE_TEXTURE:String = "skyboxAddCubeTexture";
		public static const SKYBOX_STEPPER_CHANGE:String = "skyboxStepperChange";
		
		public static const LIGHTPICKER_CHANGE:String = "lightPickerChange";
		public static const LIGHTPICKER_STEPPER_CHANGE:String = "lightPickerStepperChange";
		public static const LIGHTPICKER_ADD_DIRECTIONAL_LIGHT:String = "lightPickerAddDirectionalLight";
		public static const LIGHTPICKER_ADD_POINT_LIGHT:String = "lightPickerAddPointLight";
		
		public static const SHOW_CHILD_PROPERTIES:String = "showChildProperties";
		
		public static const SHOW_PARENT_PROPERTIES:String = "showParentProperties";

		public static const GLOBAL_OPTIONS_CHANGE:String = "globalOptionsChange";
		public static const GLOBAL_OPTIONS_STEPPER_CHANGE:String = "globalOptionsStepperChange";
		
        public function PropertyEditorEvent( type:String, data:Object=null, bubbles:Boolean=true ) 
		{
            super( type, bubbles, false );
            this.data = data;
        }

        public var data:Object;
    }
}
