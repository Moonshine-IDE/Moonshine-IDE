package awaybuilder.controller.scene.events
{
import awaybuilder.controller.history.HistoryEvent;

import flash.events.Event;

	public class SceneEvent extends HistoryEvent
	{
		public static const FOCUS_SELECTION:String = "focusOnSelection";
		
		public static const SELECT:String = "sceneItemSelect";
        public static const CHANGING:String = "sceneItemChanging";
        public static const TRANSLATE:String = "translateObject";
		public static const TRANSLATE_PIVOT:String = "translateObjectPivot";
        public static const ROTATE:String = "rotateObject";
        public static const SCALE:String = "scaleObject";

		public static const CHANGE_GLOBAL_OPTIONS:String = "changeGlobalOptions";
		
		public static const REPARENT_MATERIAL_EFFECT:String = "reparentMaterialEffect";
		public static const REPARENT_ANIMATIONS:String = "reparentAnimations";
		public static const REPARENT_OBJECTS:String = "reparentObjects";
		public static const REPARENT_LIGHTS:String = "reparentLights";
		
		public static const CHANGE_LENS:String = "changeLens";
		public static const CHANGE_CAMERA:String = "changeCamera";
		public static const CHANGE_CONTAINER:String = "changeContainer";
		public static const CHANGE_GEOMETRY:String = "changeGeometry";
        public static const CHANGE_MESH:String = "changeMesh";
		public static const CHANGE_SUBMESH:String = "changeSubMesh";
		public static const CHANGE_TEXTURE_PROJECTOR:String = "changeTextureProjector";
        public static const CHANGE_MATERIAL:String = "changeMaterial";
		public static const CHANGE_LIGHT:String = "changeLight";
		public static const CHANGE_LIGHTPICKER:String = "changeLightPicker";
		public static const CHANGE_CUBE_TEXTURE:String = "changeCubeTexture";
		public static const CHANGE_TEXTURE:String = "changeTexture";
		
		public static const CHANGE_SHADING_METHOD:String = "changeShadingMethod";
		
		public static const CHANGE_SKYBOX:String = "changeSkyBox";
		
		public static const CHANGE_SHADOW_METHOD:String = "changeShadowMethod";
		public static const CHANGE_SHADOW_MAPPER:String = "changeShadowMapper";
		public static const CHANGE_EFFECT_METHOD:String = "changeEffectMethod";
		
		public static const CHANGE_ANIMATION_SET:String = "changeAnimationSet";
		
		public static const CHANGE_ANIMATION_NODE:String = "changeAnimationNode";
		
		public static const CHANGE_ANIMATOR:String = "changeAnimator";
		
		public static const CHANGE_SKELETON:String = "changeSkeleton";
		
		public static const ADD_NEW_LIGHT:String = "addNewLight";
		public static const ADD_NEW_MATERIAL:String = "addNewMaterial";
		public static const ADD_NEW_CAMERA:String = "addNewCamera";
		public static const ADD_NEW_MESH:String = "addNewMesh";
		public static const ADD_NEW_CONTAINER:String = "addNewContainer";
		public static const ADD_NEW_TEXTURE_PROJECTOR:String = "addNewTextureProjector";
		public static const ADD_NEW_SKYBOX:String = "addNewSkyBox";
		public static const ADD_NEW_SHADOW_METHOD:String = "addNewShadowMethod";
		public static const ADD_NEW_EFFECT_METHOD:String = "addNewEffectMethod";
		public static const ADD_NEW_LIGHTPICKER:String = "addNewLightPicker";
		public static const ADD_NEW_TEXTURE:String = "addNewTexture";
		public static const ADD_NEW_CUBE:String = "addNewCubeTexture";
		public static const ADD_NEW_CUBE_TEXTURE:String = "addNewCubeTexture";
		public static const ADD_NEW_GEOMETRY:String = "addNewGeometry";
		public static const ADD_NEW_ANIMATOR:String = "addNewAnimator";
		public static const ADD_NEW_ANIMATION_SET:String = "addNewAnimationSet";
		
		public static const SWITCH_CAMERA_TO_FREE:String = "switchCameraToFree";
		public static const SWITCH_CAMERA_TO_TARGET:String = "switchCameraToTarget";
		
		public static const SWITCH_TRANSFORM_TRANSLATE:String = "switchTransformToTranslate";
		public static const SWITCH_TRANSFORM_ROTATE:String = "switchTransformToRotate";
		public static const SWITCH_TRANSFORM_SCALE:String = "switchTransformToScale";
		public static const ENABLE_TRANSFORM_MODES:String = "enableAllTransformModes";
		
		public static const SELECT_ALL:String = "selectAll";
		public static const SELECT_NONE:String = "selectNone";
		
		public static const PERFORM_DELETION:String = "performDeletion";
		public static const DELETE:String = "delete";
		
		public static const ENABLE_ROTATE_MODE_ONLY:String = "enableRotateModeOnly";
		public static const ENABLE_TRANSLATE_MODE_ONLY:String = "enableTranslateModeOnly";
		public static const DISABLE_SCALE_MODE:String = "disableScaleMode";
		
		public static const UPDATE_BREADCRUMBS:String = "updateBreadcrumbs";
		public static const CONTAINER_CLICKED : String = "containerClicked";
//		public static const UPDATE_MESH_MATERIAL : String = "updateMeshMaterial";
		
		public function SceneEvent( type:String, items:Array=null, newValue:Object=null, canBeCombined:Boolean=false, oldValue:Object=null )
		{
			super( type,newValue,oldValue );
			this.items = items;
            this.canBeCombined = canBeCombined;
		}
		
		public var items:Array;
		
		public var options:Object;

		override public function clone():Event
		{
			var event:SceneEvent = new SceneEvent( this.type, this.items, this.newValue, this.canBeCombined, oldValue );
			event.options = options;
			return event;
		}
	}
}