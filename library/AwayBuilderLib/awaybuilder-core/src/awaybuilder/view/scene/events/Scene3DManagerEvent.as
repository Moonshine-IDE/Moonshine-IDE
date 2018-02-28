package awaybuilder.view.scene.events
{
	import away3d.containers.ObjectContainer3D;
	
	import awaybuilder.utils.scene.modes.GizmoMode;
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	public class Scene3DManagerEvent extends Event
	{
		public static const READY:String = "Scene3DManagerEventReady";
		public static const MESH_SELECTED:String = "Scene3DManagerEventMeshSelected";
		public static const OBJECT_SELECTED_FROM_VIEW:String = "Scene3DManagerEventMeshSelectedFromView";
		public static const TRANSFORM:String = "Scene3DManagerEventMeshTransform";
		public static const TRANSFORM_RELEASE:String = "Scene3DManagerEventMeshTransformRelease";
		public static const ZOOM_DISTANCE_DELTA : String = "Scene3DManagerEventZoomDistanceDelta";
		public static const ZOOM_TO_DISTANCE : String = "Scene3DManagerEventZoomToDistance";
		public static const SWITCH_TRANSFORM_ROTATE : String = "Scene3DManagerEventSwitchTransformRotate";
		public static const SWITCH_TRANSFORM_TRANSLATE : String = "Scene3DManagerEventSwitchTransformTranslate";
		public static const SWITCH_CAMERA_TRANSFORMS : String = "Scene3DManagerEventSwitchCameraTransforms";
		public static const ENABLE_TRANSFORM_MODES : String = "Scene3DManagerEventEnableTransformModes";
		public static const UPDATE_BREADCRUMBS : String = "Scene3DManagerEventUpdateBreadcrumbs";
		
		public var object:ObjectContainer3D;
		public var gizmoMode:String;
		public var startValue:Vector3D;
		public var endValue:Vector3D;
		public var currentValue:Vector3D;
		
		public function Scene3DManagerEvent(type:String, gizmoMode:String="", object:ObjectContainer3D=null, currentValue:Vector3D=null, startValue:Vector3D=null, endValue:Vector3D=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.object = object;
			this.startValue = startValue;
			this.endValue = endValue;
			this.currentValue = currentValue;
			this.gizmoMode = gizmoMode;
		}
	}
}