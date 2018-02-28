package awaybuilder.view.scene.controls
{
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.lights.DirectionalLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	
	import awaybuilder.utils.scene.Scene3DManager;
	
	public class Gizmo3DBase extends ObjectContainer3D
	{
		protected const BASE_GIZMO:String = "baseGizmo";
		protected const TRANSLATE_GIZMO:String = "translationGizmo";
		protected const ROTATE_GIZMO:String = "rotationGizmo";
		protected const SCALE_GIZMO:String = "scaleGizmo";
		
		public var active:Boolean = false;
		public var hasMoved:Boolean = false;
		public var isMoving : Boolean = false;
		
		public var currentMesh:ObjectContainer3D;	
		public var currentAxis:String = "";
		
		protected var content:ObjectContainer3D;
		protected var click:Point = new Point();
		protected var click2:Point = new Point();
		protected var xAxisMaterial:ColorMaterial = new ColorMaterial(0xff0000, 1);
		protected var yAxisMaterial:ColorMaterial = new ColorMaterial(0x00cc00, 1);
		protected var zAxisMaterial:ColorMaterial = new ColorMaterial(0x0033ff, 1);
		protected var highlightOverMaterial:ColorMaterial = new ColorMaterial(0xffcc00);
		protected var highlightDownMaterial:ColorMaterial = new ColorMaterial(0xfff000);
		protected var sphereMaterial:ColorMaterial = new ColorMaterial(0xFFFFFF, 0.3);
		protected var sphereHighlightMaterial:ColorMaterial = new ColorMaterial(0xFFFFFF, 0.6);
		protected var cubeMaterial:ColorMaterial = new ColorMaterial();
		protected var isLightGizmo:LightGizmo3D;
		protected var isContainerGizmo:ContainerGizmo3D;
		protected var isTextureProjectorGizmo:TextureProjectorGizmo3D;
		protected var type : String = BASE_GIZMO;
		
		private var ambientLight : DirectionalLight;
		
		public function Gizmo3DBase()
		{
			content = new ObjectContainer3D();
			this.addChild(content);
			
			ambientLight = new DirectionalLight(1, 1, 1);
			ambientLight.name = "AmbientLight";
			ambientLight.color = 0xFFFFFF;
			ambientLight.ambient = 0.75;
			ambientLight.diffuse = 0.5;
			ambientLight.specular = 0.5;			
			
			var picker:StaticLightPicker = new StaticLightPicker([ambientLight]);
			
			xAxisMaterial.lightPicker = picker;
			yAxisMaterial.lightPicker = picker;
			zAxisMaterial.lightPicker = picker;
			highlightOverMaterial.lightPicker = picker;
			highlightDownMaterial.lightPicker = picker;
			sphereMaterial.lightPicker = picker;
			sphereHighlightMaterial.lightPicker = picker;			
			
			this.visible = false;
		}
		
		public function update():void
		{
			this.scaleX = this.scaleY = this.scaleZ = content.scaleX = content.scaleY = content.scaleZ = 1;
				
			var dist:Vector3D = Scene3DManager.camera.scenePosition.subtract(content.scenePosition);
			var scale:Number = dist.length/1000;
			content.scaleX = scale;
			content.scaleY = scale;
			content.scaleZ = scale;
				
			content.transform = content.transform.clone(); // Force the transform invalidation
			
			ambientLight.direction = Scene3DManager.camera.forwardVector;
							
			if (currentMesh && !active) updatePositionAndRotation();
		}			
		
		public function show(sceneObject:ObjectContainer3D):void
		{
			currentMesh = sceneObject;
			
			isLightGizmo = currentMesh.parent as LightGizmo3D;
			isContainerGizmo = currentMesh.parent as ContainerGizmo3D;
			isTextureProjectorGizmo = currentMesh.parent as TextureProjectorGizmo3D;

			content.transform.identity();
			this.transform = currentMesh.parent.sceneTransform.clone();
			
			this.visible = true;
			
			update();
		}
		
		protected function updatePositionAndRotation() : void {
			if (type == TRANSLATE_GIZMO) {
				if (!currentMesh.parent) return;
			
				this.rotationX = this.rotationY = this.rotationZ = 0;
				var vecs:Vector.<Vector3D> = currentMesh.parent.sceneTransform.decompose();
				vecs[0] = new Vector3D();
				vecs[2] = new Vector3D(1, 1, 1);
				var mat:Matrix3D = new Matrix3D();
				mat.recompose(vecs);
				var pos:Vector3D = new Vector3D(currentMesh.x, currentMesh.y, currentMesh.z);
				pos = mat.transformVector(pos);
				content.position = pos;
				
				this.position = currentMesh.parent.scenePosition.clone();
				return;
			}
			
			if (isTextureProjectorGizmo) {
				content.rotationX = isTextureProjectorGizmo.sceneObject.rotationX;
				content.rotationY = isTextureProjectorGizmo.sceneObject.rotationY;
				content.rotationZ = isTextureProjectorGizmo.sceneObject.rotationZ;
			} else if (!isLightGizmo) {
				content.rotationX = (isContainerGizmo) ? isContainerGizmo.parent.rotationX : currentMesh.rotationX;
				content.rotationY = (isContainerGizmo) ? isContainerGizmo.parent.rotationY : currentMesh.rotationY;
				content.rotationZ = (isContainerGizmo) ? isContainerGizmo.parent.rotationZ : currentMesh.rotationZ;
			}

			var pivot:Vector3D = currentMesh.sceneTransform.deltaTransformVector(currentMesh.pivotPoint);		
			this.position = currentMesh.scenePosition.add(pivot);
		}
		
		public function hide():void
		{
			isLightGizmo = null;
			isContainerGizmo = null;
			isTextureProjectorGizmo = null;
			
			this.visible = false;
			hasMoved = false;
		}		
	}
}