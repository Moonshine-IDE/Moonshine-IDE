package awaybuilder.view.scene.controls
{
	import awaybuilder.view.scene.representations.ISceneRepresentation;
	import flash.geom.Matrix3D;
	import away3d.textures.BitmapTexture;
	import away3d.primitives.PlaneGeometry;
	import away3d.utils.Cast;
	import flash.display.BitmapData;
	import away3d.materials.TextureMaterial;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.ConeGeometry;
	import away3d.entities.TextureProjector;
	import awaybuilder.utils.scene.Scene3DManager;
	import away3d.primitives.WireframeCylinder;
	import flash.geom.Vector3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.pick.PickingColliderType;
	import away3d.entities.Mesh;
	
	public class TextureProjectorGizmo3D extends ObjectContainer3D implements ISceneRepresentation
	{
		private var _representation : Mesh;
		public function get representation() : Mesh { return _representation; }

		private var _sceneObject : ObjectContainer3D;
		public function get sceneObject() : ObjectContainer3D { return _sceneObject; }
		
		public var projectorBitmap:BitmapTexture;
		
		public function TextureProjectorGizmo3D(projector:TextureProjector, projectorBitmapData:BitmapData)
		{
			_sceneObject = projector as ObjectContainer3D;
			this.projectorBitmap = Cast.bitmapTexture(projectorBitmapData);
						
			var projectorTexture:TextureMaterial = new TextureMaterial(projectorBitmap);
			projectorTexture.alphaBlending = true;
			projectorTexture.bothSides = true;
			
			var geom:ConeGeometry = new ConeGeometry(100, 200, 4, 1, false);
			var mat:Matrix3D = new Matrix3D();
			mat.appendRotation(45, new Vector3D(0, 1, 0));
			mat.appendRotation(90, new Vector3D(1, 0, 0));
			geom.applyTransformation(mat);
			_representation = new Mesh(geom, new ColorMaterial(0xffffff, 0.2));
			_representation.name = projector.name + "_representation";
			_representation.mouseEnabled = true;
			_representation.pickingCollider = PickingColliderType.AS3_BEST_HIT;
			
			var cameraLines:WireframeCylinder = new WireframeCylinder(0, 100, 200, 4, 1, 0xffffff, 0.5);
			cameraLines.rotationX = 90;
			cameraLines.rotationZ = 45;
			_representation.addChild(cameraLines);
			
			var projectorTexturePlane:Mesh = new Mesh(new PlaneGeometry(141, 141, 1, 1), projectorTexture);
			projectorTexturePlane.rotationX = -90;
			projectorTexturePlane.rotationZ = 180;
			projectorTexturePlane.z = -100;
			_representation.addChild(projectorTexturePlane);
			this.addChild(_representation);
		}

		public function updateRepresentation() : void {
			_representation.transform = sceneObject.sceneTransform.clone();
			var dist:Vector3D = Scene3DManager.camera.scenePosition.subtract(sceneObject.scenePosition);
			_representation.scaleX = _representation.scaleY = _representation.scaleZ = dist.length / 1500;
			
			projectorBitmap.bitmapData = ((_sceneObject as TextureProjector).texture as BitmapTexture).bitmapData;
		}
	}
}