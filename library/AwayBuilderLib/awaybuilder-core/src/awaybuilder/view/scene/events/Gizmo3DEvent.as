package awaybuilder.view.scene.events
{
	import away3d.containers.ObjectContainer3D;
	
	import awaybuilder.utils.scene.modes.GizmoMode;
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	public class Gizmo3DEvent extends Event
	{
		public static const MOVE:String = "Gizmo3DEventMove";
		public static const RELEASE:String = "Gizmo3DEventRelease";
		
		public var mode:String;
		public var startValue:Vector3D;
		public var endValue:Vector3D;
		public var currentValue:Vector3D;
		
		public var object:ObjectContainer3D;
		
		public function Gizmo3DEvent(type:String, mode:String, object:ObjectContainer3D, currentValue:Vector3D, startValue:Vector3D, endValue:Vector3D, bubbles:Boolean=false, cancelable:Boolean=false)
		{			
			super(type, bubbles, cancelable);
			this.object = object;
			this.mode = mode;
			this.startValue = startValue;
			this.endValue = endValue;
			this.currentValue = currentValue;
		}
	}
}