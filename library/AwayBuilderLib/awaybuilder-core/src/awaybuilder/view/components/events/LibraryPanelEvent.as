package awaybuilder.view.components.events
{
	import flash.events.Event;

	public class LibraryPanelEvent extends Event
	{
		public static const TREE_CHANGE:String = "treeChange";
		
		public static const ADD_CAMERA:String = "addCamera";
		public static const ADD_TEXTURE_PROJECTOR:String = "addTextureProjector";
		public static const ADD_TEXTURE:String = "addTexture";
		public static const ADD_CUBE_TEXTURE:String = "addCubeTexture";
		public static const ADD_MATERIAL:String = "addMaterial";
		public static const ADD_SKYBOX:String = "addSkyBox";
		public static const ADD_ANIMATOR:String = "addAnimator";
		public static const ADD_MESH:String = "addMesh";
		public static const ADD_CONTAINER:String = "addContainer";
		public static const ADD_GEOMETRY:String = "addGeometry";
		public static const ADD_EFFECTMETHOD:String = "addEffectMethod";
		
		public static const ADD_DIRECTIONAL_LIGHT:String = "addDirectionalLight";
		public static const ADD_POINT_LIGHT:String = "addPointLight";
		public static const ADD_LIGHTPICKER:String = "addLightPicker";
		
		public static const LIGHT_DROPPED:String = "lightDropped";
		public static const SCENEOBJECT_DROPPED:String = "sceneObjectDropped";
		public static const MATERIALS_DROPPED:String = "materialsDropped";
		public static const ANIMATIONS_DROPPED:String = "animationsDropped";
		
		public function LibraryPanelEvent(type:String, data:Object=null )
		{
			super(type, false, false);
			this.data = data;
		}
		
		public var data:Object;
		
	}
}