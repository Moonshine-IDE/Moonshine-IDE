package awaybuilder.view.scene.controls
{
	import awaybuilder.utils.scene.Scene3DManager;
	import away3d.core.base.Geometry;
	import away3d.bounds.NullBounds;
	import away3d.bounds.BoundingVolumeBase;
	import awaybuilder.view.scene.representations.ISceneRepresentation;
	import away3d.primitives.CubeGeometry;
	import away3d.materials.ColorMaterial;
	import flash.geom.Vector3D;
	import away3d.primitives.LineSegment;
	import away3d.entities.SegmentSet;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.pick.PickingColliderType;
	import away3d.entities.Mesh;
	
	public class ContainerGizmo3D extends Mesh implements ISceneRepresentation
	{	
		private var _representation : Mesh;
		public function get representation() : Mesh { return _representation; }

		private var _sceneObject : ObjectContainer3D;
		public function get sceneObject() : ObjectContainer3D { return _sceneObject; }
		
		public function ContainerGizmo3D(originalContainer:ObjectContainer3D)
		{
			super(new Geometry());
			
			_bounds = getDefaultBoundingVolume();
			
			_sceneObject = originalContainer as ObjectContainer3D;
			
			_representation = new Mesh(new CubeGeometry(10, 10, 10), new ColorMaterial(0x0000ff));
			var axisLines:SegmentSet = new SegmentSet();
			axisLines.addSegment(new LineSegment(new Vector3D(-35, 0, 0), new Vector3D(35, 0, 0), 0xddddff, 0xddddff, 0.5));
			axisLines.addSegment(new LineSegment(new Vector3D(0, -35, 0), new Vector3D(0, 35, 0), 0xddddff, 0xddddff, 0.5));
			axisLines.addSegment(new LineSegment(new Vector3D(0, 0, -35), new Vector3D(0, 0, 35), 0xddddff, 0xddddff, 0.5));
			_representation.name = sceneObject.name + "_representation";
			_representation.mouseEnabled = true;
			_representation.pickingCollider = PickingColliderType.AS3_BEST_HIT;
			_representation.addChild(axisLines);
			this.addChild(_representation);
		}

		public function updateRepresentation() : void {
			var dist:Vector3D = Scene3DManager.camera.scenePosition.subtract(_representation.scenePosition);
			_representation.scaleX = _representation.scaleY = _representation.scaleZ = dist.length / 500;
		}
		
		protected override function getDefaultBoundingVolume():BoundingVolumeBase {
			return new NullBounds();
		}
		
	}
}