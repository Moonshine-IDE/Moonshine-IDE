package awaybuilder.view.scene.controls
{
	import awaybuilder.view.scene.representations.ISceneRepresentation;
	import awaybuilder.utils.scene.Scene3DManager;
	import awaybuilder.utils.scene.CameraManager;
	import flash.display3D.Context3DCompareMode;
	import away3d.primitives.WireframeCylinder;
	import away3d.lights.DirectionalLight;
	import flash.geom.Vector3D;
	import away3d.primitives.PlaneGeometry;
	import away3d.materials.TextureMaterial;
	import away3d.utils.Cast;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.pick.PickingColliderType;
	import away3d.entities.Mesh;
	import away3d.lights.LightBase;
	
	public class LightGizmo3D extends ObjectContainer3D implements ISceneRepresentation
	{
		private var _representation : Mesh;
		public function get representation() : Mesh { return _representation; }

		private var _sceneObject : ObjectContainer3D;
		public function get sceneObject() : ObjectContainer3D { return _sceneObject; }

		public static const DIRECTIONAL_LIGHT : String = "directionalLight";
		public static const POINT_LIGHT : String = "pointLight";
		
		[Embed(source="/assets/spritetextures/light_source.png")]
		private var LightSourceImage:Class;
		
		public var type : String;
		
		public function LightGizmo3D(light:LightBase)
		{
			_sceneObject = light as ObjectContainer3D;
			
			type = (light is DirectionalLight) ? DIRECTIONAL_LIGHT : POINT_LIGHT;
				
			var lightTexture:TextureMaterial = new TextureMaterial(Cast.bitmapTexture(new LightSourceImage()));
			lightTexture.alphaBlending = true;
			lightTexture.bothSides = true;
			if (type == DIRECTIONAL_LIGHT) {
				_representation = new Mesh(new PlaneGeometry(50, 50, 1, 1), lightTexture);
				_representation.y = 150;
				var wC:WireframeCylinder = new WireframeCylinder(100, 100, 300, 8, 1, 0xffff00, 0.25);
				wC.y = -150;
				_representation.addChild(wC);
				_representation.rotationX = -90;
				_representation.pivotPoint = new Vector3D(0, -150, 0);
				_representation.material.depthCompareMode = wC.material.depthCompareMode = Context3DCompareMode.ALWAYS;
			} else {
				_representation = new Mesh(new PlaneGeometry(100, 100, 1, 1), lightTexture);
			}
			_representation.castsShadows=false;
			_representation.name = light.name + "_representation";
			_representation.mouseEnabled = true;
			_representation.pickingCollider = PickingColliderType.AS3_BEST_HIT;
			this.addChild(_representation);
		}

		public function updateRepresentation() : void {
			_representation.transform.identity();
			if (type == DIRECTIONAL_LIGHT) {
				_representation.eulers = sceneObject.eulers.clone();
				_representation.rotationX -= 90;
				_representation.scaleX = _representation.scaleY = _representation.scaleZ = Scene3DManager.stage.stageHeight/720;
			} else {
				_representation.transform = sceneObject.sceneTransform.clone();
				_representation.eulers = CameraManager.camera.eulers.clone();
				_representation.rotationX -= 90;
				_representation.rotationY -= 1; // Temporary fix for bounds visiblity
				var dist:Vector3D = Scene3DManager.camera.scenePosition.subtract(_representation.scenePosition);
				_representation.scaleX = _representation.scaleZ = dist.length/1500;
			}
		}
	}
}