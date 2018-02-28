package awaybuilder.view.scene.controls
{
	import awaybuilder.view.scene.representations.ISceneRepresentation;
	import away3d.primitives.CylinderGeometry;
	import away3d.lights.DirectionalLight;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.pick.PickingColliderType;
	import away3d.entities.Mesh;
	import away3d.entities.SegmentSet;
	import away3d.events.MouseEvent3D;
	import away3d.primitives.LineSegment;
	import away3d.primitives.SphereGeometry;
	import away3d.primitives.TorusGeometry;
	
	import awaybuilder.utils.scene.CameraManager;
	import awaybuilder.utils.scene.Scene3DManager;
	import awaybuilder.utils.scene.modes.GizmoMode;
	import awaybuilder.view.scene.events.Gizmo3DEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	public class RotateGizmo3D extends Gizmo3DBase
	{	
		private var xTorus:Mesh;
		private var xDirection:Mesh;
		private var yTorus:Mesh;
		private var zTorus:Mesh;
		
		private var sphere:Mesh;
		
		private var freeXAxis:Vector3D = new Vector3D();
		private var freeYAxis:Vector3D = new Vector3D();
		private var freeZAxis:Vector3D = new Vector3D();
		private var lines:SegmentSet;
		private var xLine:LineSegment;
		private var yLine:LineSegment;
		private var zLine:LineSegment;
				
		private var actualMesh:ObjectContainer3D;
		
		private var startValue:Vector3D;
		//private var startSceneRotation:Vector3D;
		private var behindGizmoPlane : Boolean;
		
		public function RotateGizmo3D()
		{
			type = ROTATE_GIZMO;

			this.visible = false;
			
			var sphereGeom:SphereGeometry = new SphereGeometry(95, 16, 12, true);
			
			sphere = new Mesh(sphereGeom, sphereMaterial);
			sphere.name = "allAxis";
			sphere.pickingCollider = PickingColliderType.AS3_BEST_HIT;
			sphere.mouseEnabled = true;
			sphere.addEventListener(MouseEvent3D.MOUSE_DOWN, handleMouseDown);
			this.addChild(sphere);
			
			var torusGeometry:TorusGeometry = new TorusGeometry(100, 5, 30, 8, false);
			var cylGeom:CylinderGeometry = new CylinderGeometry(5, 5, 100, 16, 1, true, true, true, false);		
			
			xTorus = new Mesh(torusGeometry, xAxisMaterial);
			xTorus.name = "xAxis"; 
			xTorus.pickingCollider = PickingColliderType.AS3_BEST_HIT;
			xTorus.mouseEnabled = true;
			xTorus.addEventListener(MouseEvent3D.MOUSE_OVER, handleMouseOver);
			xTorus.addEventListener(MouseEvent3D.MOUSE_OUT, handleMouseOut);
			xTorus.addEventListener(MouseEvent3D.MOUSE_DOWN, handleMouseDown);
			xTorus.rotationY = 90;
			content.addChild(xTorus);
			
			xDirection = new Mesh(cylGeom, xAxisMaterial);
			xDirection.y = 50;
			xDirection.rotationX = -90;
			xTorus.addChild(xDirection);			
			
			yTorus = new Mesh(torusGeometry, yAxisMaterial);
			yTorus.name = "yAxis";
			yTorus.pickingCollider = PickingColliderType.AS3_BEST_HIT;
			yTorus.mouseEnabled = true;
			yTorus.addEventListener(MouseEvent3D.MOUSE_OVER, handleMouseOver);
			yTorus.addEventListener(MouseEvent3D.MOUSE_OUT, handleMouseOut);			
			yTorus.addEventListener(MouseEvent3D.MOUSE_DOWN, handleMouseDown);
			yTorus.rotationX = -90;
			content.addChild(yTorus);				
			
			zTorus = new Mesh(torusGeometry, zAxisMaterial);
			zTorus.name = "zAxis";
			zTorus.pickingCollider = PickingColliderType.AS3_BEST_HIT;
			zTorus.mouseEnabled = true;
			zTorus.addEventListener(MouseEvent3D.MOUSE_OVER, handleMouseOver);
			zTorus.addEventListener(MouseEvent3D.MOUSE_OUT, handleMouseOut);			
			zTorus.addEventListener(MouseEvent3D.MOUSE_DOWN, handleMouseDown);
			content.addChild(zTorus);			
			
			lines = new SegmentSet();	
			
			zLine = new LineSegment(new Vector3D(), new Vector3D(), 0xFFCC00, 0xFFCC00, 3);
			lines.addSegment(zLine);			
			
			xLine = new LineSegment(new Vector3D(), new Vector3D(), 0xFF0000, 0xFF0000, 3);
			lines.addSegment(xLine);
			
			yLine = new LineSegment(new Vector3D(), new Vector3D(), 0xCC99CC, 0xCC99CC, 3);
			lines.addSegment(yLine);			
			
			this.addChild(lines);
		}
		
		protected function handleMouseOut(event:MouseEvent3D):void
		{
			if (!active) 
			{
				switch(event.target.name)
				{
					case "xAxis":
												
						xTorus.material = xAxisMaterial;
						
						break;
					
					case "yAxis":
						
						yTorus.material = yAxisMaterial;
						
						break;
					
					case "zAxis":
						
						zTorus.material = zAxisMaterial;
						
						break;								
				}							
			}			
		}
		
		protected function handleMouseOver(event:MouseEvent3D):void
		{
			if (!active) 
			{
				switch(event.target.name)
				{
					case "xAxis":
						
						xTorus.material = highlightOverMaterial;
						
						break;
					
					case "yAxis":
						
						yTorus.material = highlightOverMaterial;
						
						break;
					
					case "zAxis":
						
						zTorus.material = highlightOverMaterial;
						
						break;								
				}							
			}			
		}
		
		override public function update():void
		{			
			super.update();									
			
			sphere.scaleX = content.scaleX;
			sphere.scaleY = content.scaleY;
			sphere.scaleZ = content.scaleZ;
			
			xLine.end = freeXAxis;
			yLine.end = freeYAxis;			
			zLine.end = freeZAxis;
		}
	
		protected function handleMouseDown(e:MouseEvent3D):void
		{
			currentAxis = e.target.name;	
			
			behindGizmoPlane = this.scenePosition.subtract(e.scenePosition).z > 0; //e.scenePosition.z > 0;
			//trace("CLICKPOS:l:"+e.localPosition+" s:"+e.scenePosition+" - sD:"+this.scenePosition.subtract(e.scenePosition));
			//freeZAxis = Scene3DManager.camera.backVector;
			//freeYAxis = sphere.rightVector.crossProduct(Scene3DManager.camera.rightVector);
			//freeYAxis = freeZAxis.crossProduct(freeXAxis);
			
			/*
			freeXAxis = sphere.rightVector.clone();
			freeYAxis = sphere.downVector.clone();
			freeZAxis = sphere.forwardVector.clone();
			
			freeXAxis.scaleBy(50);
			freeYAxis.scaleBy(50);
			freeZAxis.scaleBy(50);
			*/
			
			click.x = Scene3DManager.stage.mouseX;
			click.y = Scene3DManager.stage.mouseY;
			
			click2.x = Scene3DManager.stage.mouseX;
			click2.y = Scene3DManager.stage.mouseY;			
			
			if (currentMesh.parent is ISceneRepresentation) actualMesh = (currentMesh.parent as ISceneRepresentation).sceneObject;
			else actualMesh = currentMesh;
			
			switch(currentAxis)
			{
				case "xAxis":
					
					xTorus.material = highlightDownMaterial;
					
					break;
				
				case "yAxis":
					
					yTorus.material = highlightDownMaterial;
					
					break;
				
				case "zAxis":
					
					zTorus.material = highlightDownMaterial;
					
					break;				
				
				case "allAxis":				
					
					sphere.material = sphereHighlightMaterial;
					
					break;					
			}
			
			hasMoved = true;
			isMoving = true;
			active = true;
			CameraManager.active = false;			
			
			startValue = actualMesh.eulers.clone();

			Scene3DManager.stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			Scene3DManager.stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
		}
		
		protected function handleMouseMove(e:MouseEvent):void
		{
			var dx:Number = (Scene3DManager.stage.mouseX - click.x);
			var dy:Number = -(Scene3DManager.stage.mouseY - click.y);
			
			var rx:Number = (Scene3DManager.stage.mouseX - click2.x);
			var ry:Number = -(Scene3DManager.stage.mouseY - click2.y);			
			
			var trans:Number = (dx+dy)/2 * (behindGizmoPlane ? 1 : -1);
			
			switch(currentAxis)
			{
				case "xAxis":
					
					var xv1:Vector3D = Scene3DManager.camera.rightVector;
					var xv2:Vector3D = content.rightVector; 
					xv1.normalize();
					xv2.normalize();
					var ax:Number = xv1.dotProduct(xv2);
					if (ax < 0) trans = -trans;							
					
					if (isLightGizmo && isLightGizmo.type == LightGizmo3D.DIRECTIONAL_LIGHT) {
						xTorus.rotate(new Vector3D(0, 0, 1), trans);
						if (xTorus.rotationX>80 && xTorus.rotationY>0) xTorus.rotationY = 90;
						if (xTorus.rotationX>80 && xTorus.rotationY<0) xTorus.rotationY = -90;
					}
					else content.rotate(new Vector3D(1, 0, 0), trans);
					
					break;
				
				case "yAxis":
					
					var yv1:Vector3D = Scene3DManager.camera.downVector;
					var yv2:Vector3D = content.upVector; 			
					yv1.normalize();
					yv2.normalize();
					var ay:Number = yv1.dotProduct(yv2);
					if (ay < 0) trans = -trans;									
					
					content.rotate(new Vector3D(0, 1, 0), trans);				
					
					break;
				
				case "zAxis":
					
					var zv1:Vector3D = Scene3DManager.camera.rightVector;
					var zv2:Vector3D = content.forwardVector; 			
					zv1.normalize();
					zv2.normalize();
					var az:Number = zv1.dotProduct(zv2);
					if (az < 0) trans = -trans;				
					
					content.rotate(new Vector3D(0, 0, 1), trans);					
					
					break;				
				
				case "allAxis":														

					//sphere.rotate(freeXAxis, dy);
					//sphere.rotate(freeYAxis, dx);			
					
					//content.eulers = startValue.add(sphere.eulers); 
					
					
					break;					
			}					
		
			if (isLightGizmo && isLightGizmo.type == LightGizmo3D.DIRECTIONAL_LIGHT) updateDirectionalLight();
			else actualMesh.eulers = content.eulers.clone();

			click.x = Scene3DManager.stage.mouseX;
			click.y = Scene3DManager.stage.mouseY;			

			Scene3DManager.updateDefaultCameraFarPlane();
			
			dispatchEvent(new Gizmo3DEvent(Gizmo3DEvent.MOVE, GizmoMode.ROTATE, actualMesh, actualMesh.eulers, startValue, actualMesh.eulers));
		}		
		
		protected function handleMouseUp(event:Event):void
		{
			isMoving = false;
			Scene3DManager.stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			Scene3DManager.stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			
			currentAxis = "";
			active = false;
			CameraManager.active = true;
			
			xTorus.material = xAxisMaterial;		
			yTorus.material = yAxisMaterial;
			zTorus.material = zAxisMaterial;
			sphere.material = sphereMaterial;
			
			sphere.eulers = new Vector3D();
			
			xTorus.material = xAxisMaterial;
			yTorus.material = yAxisMaterial;
			zTorus.material = zAxisMaterial;

			if (isLightGizmo && isLightGizmo.type == LightGizmo3D.DIRECTIONAL_LIGHT) 
				updateDirectionalLight();
			
			dispatchEvent(new Gizmo3DEvent(Gizmo3DEvent.RELEASE, GizmoMode.ROTATE, actualMesh, actualMesh.eulers, startValue, actualMesh.eulers.clone()));
		}

		private function updateDirectionalLight() : void {
			var elevationAngle : Number = xTorus.rotationY;
			var cTRotX : int = Math.round(content.rotationX < 0 ? content.rotationX+360 : content.rotationX) % 360;		
			var azimuthAngle : Number = content.rotationY % 360;
			if (azimuthAngle<0) azimuthAngle+=360;
			azimuthAngle = (cTRotX != 0 ? 270 + (270 - azimuthAngle) : azimuthAngle);

			var dL : DirectionalLight = actualMesh as DirectionalLight;
			var aY : Number = -Math.sin(elevationAngle * Math.PI / 180);
			var aX : Number = Math.sin(Math.PI / 2 - elevationAngle * Math.PI / 180) * Math.sin(azimuthAngle * Math.PI / 180);
			var aZ : Number = Math.sin(Math.PI / 2 - elevationAngle * Math.PI / 180) * Math.cos(azimuthAngle * Math.PI / 180);
			dL.direction = new Vector3D(aX, aY, aZ);
		}

		override public function show(mesh:ObjectContainer3D):void
		{
			super.show(mesh);
			
			xTorus.rotationX = xTorus.rotationZ = 0;
			xTorus.rotationY = 90;
			isLightGizmo = currentMesh.parent as LightGizmo3D;
			zTorus.visible = !(isLightGizmo && isLightGizmo.type == LightGizmo3D.DIRECTIONAL_LIGHT);
			xDirection.visible = !zTorus.visible;

			if (isLightGizmo && isLightGizmo.type == LightGizmo3D.DIRECTIONAL_LIGHT) {
				var dirLight:DirectionalLight = isLightGizmo.sceneObject as DirectionalLight;
				xTorus.rotate(new Vector3D(0, 0, 1), Math.round(-Math.asin( dirLight.direction.y )*180/Math.PI) - 90);
				var a:Number = Math.atan2(dirLight.direction.x, dirLight.direction.z )*180/Math.PI;
				content.rotationY = Math.round(a<0?a+360:a);
			}
		}
	}
}