package awaybuilder.view.scene.controls
{
	import away3d.cameras.lenses.OrthographicOffCenterLens;
	import away3d.cameras.lenses.OrthographicLens;
	import away3d.primitives.WireframePlane;
	import away3d.primitives.WireframeCylinder;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.WireframeCube;
	import away3d.primitives.CubeGeometry;
	import away3d.core.math.MathConsts;
	import away3d.cameras.lenses.PerspectiveOffCenterLens;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.primitives.LineSegment;
	import away3d.entities.SegmentSet;
	import awaybuilder.utils.scene.Scene3DManager;
	import flash.geom.Vector3D;
	import flash.geom.Matrix3D;
	import awaybuilder.view.scene.representations.ISceneRepresentation;
	import away3d.primitives.ConeGeometry;
	import away3d.cameras.Camera3D;
	import away3d.materials.ColorMaterial;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.pick.PickingColliderType;
	import away3d.entities.Mesh;
	
	public class CameraGizmo3D extends ObjectContainer3D implements ISceneRepresentation {

		private var _representation : Mesh;
		private var _perspectiveCone : ObjectContainer3D;
		private var _camera : ObjectContainer3D;
		private var _frustum : ObjectContainer3D;
		private var _tL : LineSegment;
		private var _tR : LineSegment;
		private var _bL : LineSegment;
		private var _bR : LineSegment;
		private var _far : WireframePlane;
		private var _near : WireframePlane;
		private var _overrideObjectSelection : Boolean;
		private var _orthoCube : ObjectContainer3D;
		private var _orthoPlaneNear : WireframePlane;
		private var _orthoPlaneFar : WireframePlane;
		
		public function get representation() : Mesh { return _representation; }

		private var _sceneObject : ObjectContainer3D;
		public function get sceneObject() : ObjectContainer3D { return _sceneObject; }
		
		public function CameraGizmo3D(originalCamera:Camera3D)
		{
			_sceneObject = originalCamera as ObjectContainer3D;
			
			var camMat:ColorMaterial = new ColorMaterial(0xffffff, 0.2);
			_representation = new Mesh(new CubeGeometry(0, 0, 0), camMat);
			_representation.name = originalCamera.name + "_representation";
			_representation.mouseEnabled = true;
			_representation.mouseChildren = true;
			_representation.pickingCollider = PickingColliderType.AS3_BEST_HIT;
						
			_camera = new ObjectContainer3D();			
			_representation.addChild(_camera);

			_perspectiveCone = new ObjectContainer3D();			
			_camera.addChild(_perspectiveCone);
			
			_orthoCube = new ObjectContainer3D();		
			_camera.addChild(_orthoCube);
			
			_frustum = new ObjectContainer3D();
			_representation.addChild(_frustum);

			var geom:Mesh = new Mesh(new ConeGeometry(70.5, 100, 4, 1, true), camMat);
			var mat:Matrix3D = new Matrix3D();
			mat.appendTranslation(0, -50, 0);
			mat.appendRotation(45, new Vector3D(0, 1, 0));
			mat.appendRotation(-90, new Vector3D(1, 0, 0));
			geom.geometry.applyTransformation(mat);
			_perspectiveCone.addChild(geom);
						
			var cameraLines:SegmentSet = new SegmentSet();
			var c:Vector3D = new Vector3D(0, 0, 0);
			cameraLines.addSegment(new LineSegment(new Vector3D(-50, -50, 100), c, 0xffffff, 0xffffff, 0.5));
			cameraLines.addSegment(new LineSegment(new Vector3D( 50, -50, 100), c, 0xffffff, 0xffffff, 0.5));
			cameraLines.addSegment(new LineSegment(new Vector3D(-50,  50, 100), c, 0xffffff, 0xffffff, 0.5));
			cameraLines.addSegment(new LineSegment(new Vector3D( 50,  50, 100), c, 0xffffff, 0xffffff, 0.5));
			cameraLines.addSegment(new LineSegment(new Vector3D(-50, -50, 100), new Vector3D( 50, -50, 100), 0xffffff, 0xffffff, 0.5));
			cameraLines.addSegment(new LineSegment(new Vector3D( 50, -50, 100), new Vector3D( 50,  50, 100), 0xffffff, 0xffffff, 0.5));
			cameraLines.addSegment(new LineSegment(new Vector3D( 50,  50, 100), new Vector3D(-50,  50, 100), 0xffffff, 0xffffff, 0.5));
			cameraLines.addSegment(new LineSegment(new Vector3D(-50,  50, 100), new Vector3D(-50, -50, 100), 0xffffff, 0xffffff, 0.5));
			_perspectiveCone.addChild(cameraLines);
	
			_orthoCube.addChild(new Mesh(new CubeGeometry(100, 100, 100), camMat));
			_orthoCube.addChild(new WireframeCube(100, 100, 100, 0xffffff, 0.5));
			_orthoCube.z = 50;
			
			cameraLines = new SegmentSet();
			cameraLines.addSegment(_tL = new LineSegment(c, new Vector3D(0, 0, 500), 0xff0000, 0xff0000, 0.25));
			cameraLines.addSegment(_tR = new LineSegment(c, new Vector3D(0, 0, 500), 0xff0000, 0xff0000, 0.25));
			cameraLines.addSegment(_bL = new LineSegment(c, new Vector3D(0, 0, 500), 0xff0000, 0xff0000, 0.25));
			cameraLines.addSegment(_bR = new LineSegment(c, new Vector3D(0, 0, 500), 0xff0000, 0xff0000, 0.25));
			_frustum.addChild(cameraLines);
			
			_far = new WireframePlane(500, 500, 1, 1, 0xeeeeee, 0.25, "xy");
			_near = new WireframePlane(400, 400, 1, 1, 0xeeeeee, 0.25, "xy");
			_frustum.addChild(_far);
			_frustum.addChild(_near);
			
			_orthoPlaneNear = new WireframePlane(100, 100, 1, 1, 0xeeeeee, 0.25, "xy");
			_orthoPlaneFar = new WireframePlane(100, 100, 1, 1, 0xeeeeee, 0.25, "xy");
			_representation.addChild(_orthoPlaneNear);
			_representation.addChild(_orthoPlaneFar);
			
			var body:Mesh = new Mesh(new CubeGeometry(100, 150, 300), camMat);
			body.mouseEnabled = true;
			body.z = -150;
			_camera.addChild(body);

			var bodyFrame:WireframeCube = new WireframeCube(100, 150, 300, 0xffffff, 0.5);
			bodyFrame.z = -150;
			_camera.addChild(bodyFrame);

			var cyl1:Mesh = new Mesh(new CylinderGeometry(75, 75, 50), camMat);
			cyl1.z = -75;
			_camera.addChild(cyl1);
			var cyl2:Mesh = new Mesh(new CylinderGeometry(75, 75, 50), camMat);
			cyl2.z = -225;
			_camera.addChild(cyl2);
			cyl1.mouseEnabled = cyl2.mouseEnabled = true;

			var cylFrame1:WireframeCylinder = new WireframeCylinder(75, 75, 50, 16, 1, 0xffffff, 0.5);
			cylFrame1.z = -75;
			_camera.addChild(cylFrame1);
			var cylFrame2:WireframeCylinder = new WireframeCylinder(75, 75, 50, 16, 1, 0xffffff, 0.5);
			cylFrame2.z = -225;
			_camera.addChild(cylFrame2);
			cyl1.y = cyl2.y = cylFrame1.y = cylFrame2.y = 150;
			cyl1.rotationZ = cyl2.rotationZ = cylFrame1.rotationZ = cylFrame2.rotationZ = -90;
						
			_representation.transform = originalCamera.transform.clone();
			this.addChild(_representation);
			
			_overrideObjectSelection = true;
			updateRepresentation();
		}

		public function updateRepresentation() : void {
			_representation.transform = sceneObject.sceneTransform.clone();
			var dist:Vector3D = Scene3DManager.camera.scenePosition.subtract(sceneObject.scenePosition);
			_camera.scaleX = _camera.scaleY = _camera.scaleZ = 0.4 * dist.length / 1500;
			
			var cam:Camera3D = sceneObject as Camera3D;
			var perspLens:PerspectiveLens = cam.lens as PerspectiveLens;
			var perspOCLens:PerspectiveOffCenterLens = cam.lens as PerspectiveOffCenterLens;
			var orthoLens:OrthographicLens = cam.lens as OrthographicLens;
			var orthoOCLens:OrthographicOffCenterLens = cam.lens as OrthographicOffCenterLens;
			if (perspLens) {
				_perspectiveCone.scaleX = _perspectiveCone.scaleY = Math.tan(perspLens.fieldOfView * 0.5 * MathConsts.DEGREES_TO_RADIANS) * 2;
				
				var farCorner:Number = Math.tan(perspLens.fieldOfView * 0.5 * MathConsts.DEGREES_TO_RADIANS) * perspLens.far;
				var nearCorner:Number = Math.tan(perspLens.fieldOfView * 0.5 * MathConsts.DEGREES_TO_RADIANS) * perspLens.near;
				_tL.end.x = _tL.end.y = _bL.end.x = _tR.end.y = farCorner * 1.1;
				_bR.end.x = _bR.end.y = _bL.end.y = _tR.end.x = -farCorner * 1.1;
				_tL.end.z = _tR.end.z = _bL.end.z = _bR.end.z = perspLens.far * 1.1;

				_tL.updateSegment(_tL.start, _tL.end, null, 0xcccccc, 0xcccccc, 0.25);
				_bL.updateSegment(_bL.start, _bL.end, null, 0xcccccc, 0xcccccc, 0.25);
				_tR.updateSegment(_tR.start, _tR.end, null, 0xcccccc, 0xcccccc, 0.25);
				_bR.updateSegment(_bR.start, _bR.end, null, 0xcccccc, 0xcccccc, 0.25);

				_far.z = perspLens.far;
				_near.z = perspLens.near;
				_far.width = _far.height = farCorner * 2;
				_near.width = _near.height = nearCorner * 2;
			} else if (perspOCLens) {
				_perspectiveCone.scaleX = Math.tan((perspOCLens.maxAngleX - perspOCLens.minAngleX) * 0.5 * MathConsts.DEGREES_TO_RADIANS) * 2;
				_perspectiveCone.scaleY = Math.tan((perspOCLens.maxAngleY - perspOCLens.minAngleY) * 0.5 * MathConsts.DEGREES_TO_RADIANS) * 2;
			} else if (orthoLens) {
				_orthoPlaneNear.x = _orthoPlaneFar.x = 0;
				_orthoPlaneNear.y = _orthoPlaneFar.y = 0;
				_orthoPlaneNear.z = orthoLens.near;
				_orthoPlaneFar.z = orthoLens.far;
				
				_orthoPlaneNear.width = _orthoPlaneFar.width = orthoLens.projectionHeight;
				_orthoPlaneNear.height = _orthoPlaneFar.height = orthoLens.projectionHeight;
			} else {
				_orthoPlaneNear.x = orthoOCLens.minX + ((orthoOCLens.maxX - orthoOCLens.minX) * 0.5);
				_orthoPlaneNear.y = orthoOCLens.minY + ((orthoOCLens.maxY - orthoOCLens.minY) * 0.5);

				_orthoPlaneNear.width = _orthoPlaneFar.width = (orthoOCLens.maxX - orthoOCLens.minX);
				_orthoPlaneNear.height = _orthoPlaneFar.height = (orthoOCLens.maxY - orthoOCLens.minY);
			}
			
			var oldFrustumVis:Boolean = _frustum.visible;
			_perspectiveCone.visible = (perspLens!=null || perspOCLens!=null); 
			_frustum.visible = _perspectiveCone.visible && (_overrideObjectSelection || Scene3DManager.selectedObject == _representation);

			var oldOrthoCubeVis:Boolean = _orthoPlaneNear.visible;
			_orthoCube.visible = !_perspectiveCone.visible;
			_orthoPlaneNear.visible = _orthoPlaneFar.visible = _orthoCube.visible && (_overrideObjectSelection || Scene3DManager.selectedObject == _representation);
			
			if (oldFrustumVis!=_frustum.visible || oldOrthoCubeVis!=_orthoPlaneNear.visible)
				Scene3DManager.updateDefaultCameraFarPlane();
				
			_overrideObjectSelection = false;
		}
	}
}
