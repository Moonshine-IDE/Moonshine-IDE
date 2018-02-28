package awaybuilder.view.scene.controls
{
	import awaybuilder.view.scene.representations.ISceneRepresentation;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.pick.PickingColliderType;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.CylinderGeometry;
	
	import awaybuilder.utils.scene.CameraManager;
	import awaybuilder.utils.scene.Scene3DManager;
	import awaybuilder.utils.scene.modes.GizmoMode;
	import awaybuilder.view.scene.controls.Gizmo3DBase;
	import awaybuilder.view.scene.events.Gizmo3DEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	public class ScaleGizmo3D extends Gizmo3DBase
	{		
		private var xCylinder:Mesh;
		private var yCylinder:Mesh;
		private var zCylinder:Mesh;
		
		private var xCube:Mesh;
		private var yCube:Mesh;
		private var zCube:Mesh;
		
		private var mCube:Mesh;
		
		private var scaleRatio:Vector3D = new Vector3D(1, 1, 1);
		private var maxBounds:Number;
		private var actualMesh:ObjectContainer3D;
		
		private var startValue:Vector3D;
		
		public function ScaleGizmo3D()
		{
			type = SCALE_GIZMO;

			var cubeGeom:CubeGeometry = new CubeGeometry(20, 20, 20, 1, 1, 1, true);
			var cylGeom:CylinderGeometry = new CylinderGeometry(5, 5, 100, 16, 1, true, true, true, false);
			
			mCube = new Mesh(cubeGeom, cubeMaterial);
			mCube.name = "allAxis";
			mCube.pickingCollider = PickingColliderType.AS3_BEST_HIT;
			mCube.mouseEnabled = true;
			mCube.addEventListener(MouseEvent3D.MOUSE_OVER, handleMouseOver);
			mCube.addEventListener(MouseEvent3D.MOUSE_OUT, handleMouseOut);				
			mCube.addEventListener(MouseEvent3D.MOUSE_DOWN, handleMouseDown);
			mCube.addEventListener(MouseEvent3D.MOUSE_UP, handleMouseUp);			
			content.addChild(mCube);							
			
			xCylinder = new Mesh(cylGeom, xAxisMaterial);
			xCylinder.name = "xAxis";
			xCylinder.pickingCollider = PickingColliderType.AS3_BEST_HIT;
			xCylinder.mouseEnabled = true;
			xCylinder.addEventListener(MouseEvent3D.MOUSE_OVER, handleMouseOver);
			xCylinder.addEventListener(MouseEvent3D.MOUSE_OUT, handleMouseOut);				
			xCylinder.addEventListener(MouseEvent3D.MOUSE_DOWN, handleMouseDown);
			xCylinder.addEventListener(MouseEvent3D.MOUSE_UP, handleMouseUp);
			xCylinder.x = 50;
			xCylinder.rotationY = -90;
			content.addChild(xCylinder);		
			
			xCube = new Mesh(cubeGeom, xAxisMaterial);
			xCube.name = "xAxis";
			xCube.pickingCollider = PickingColliderType.AS3_BEST_HIT;
			xCube.mouseEnabled = true;
			xCube.addEventListener(MouseEvent3D.MOUSE_OVER, handleMouseOver);
			xCube.addEventListener(MouseEvent3D.MOUSE_OUT, handleMouseOut);				
			xCube.addEventListener(MouseEvent3D.MOUSE_DOWN, handleMouseDown);
			xCube.addEventListener(MouseEvent3D.MOUSE_UP, handleMouseUp);			
			xCube.rotationY = -90;
			xCube.x = 100 + (cubeGeom.height/2);
			content.addChild(xCube);					
			
			yCylinder = new Mesh(cylGeom, yAxisMaterial);
			yCylinder.name = "yAxis";
			yCylinder.pickingCollider = PickingColliderType.AS3_BEST_HIT;
			yCylinder.mouseEnabled = true;
			yCylinder.addEventListener(MouseEvent3D.MOUSE_OVER, handleMouseOver);
			yCylinder.addEventListener(MouseEvent3D.MOUSE_OUT, handleMouseOut);				
			yCylinder.addEventListener(MouseEvent3D.MOUSE_DOWN, handleMouseDown);
			yCylinder.addEventListener(MouseEvent3D.MOUSE_UP, handleMouseUp);
			yCylinder.y = 50;
			yCylinder.rotationX = -90;
			content.addChild(yCylinder);			
			
			yCube = new Mesh(cubeGeom, yAxisMaterial);
			yCube.name = "yAxis";
			yCube.pickingCollider = PickingColliderType.AS3_BEST_HIT;
			yCube.mouseEnabled = true;
			yCube.addEventListener(MouseEvent3D.MOUSE_OVER, handleMouseOver);
			yCube.addEventListener(MouseEvent3D.MOUSE_OUT, handleMouseOut);				
			yCube.addEventListener(MouseEvent3D.MOUSE_DOWN, handleMouseDown);
			yCube.addEventListener(MouseEvent3D.MOUSE_UP, handleMouseUp);			
			yCube.rotationX = 90;
			yCube.y = 100 + (cubeGeom.height/2);
			content.addChild(yCube);			
			
			zCylinder = new Mesh(cylGeom, zAxisMaterial);
			zCylinder.name = "zAxis";
			zCylinder.pickingCollider = PickingColliderType.AS3_BEST_HIT;
			zCylinder.mouseEnabled = true;
			zCylinder.addEventListener(MouseEvent3D.MOUSE_OVER, handleMouseOver);
			zCylinder.addEventListener(MouseEvent3D.MOUSE_OUT, handleMouseOut);				
			zCylinder.addEventListener(MouseEvent3D.MOUSE_DOWN, handleMouseDown);
			zCylinder.addEventListener(MouseEvent3D.MOUSE_UP, handleMouseUp);
			zCylinder.z = 50;
			content.addChild(zCylinder);			
			
			zCube = new Mesh(cubeGeom, zAxisMaterial);
			zCube.name = "zAxis";
			zCube.pickingCollider = PickingColliderType.AS3_BEST_HIT;
			zCube.mouseEnabled = true;
			zCube.addEventListener(MouseEvent3D.MOUSE_OVER, handleMouseOver);
			zCube.addEventListener(MouseEvent3D.MOUSE_OUT, handleMouseOut);				
			zCube.addEventListener(MouseEvent3D.MOUSE_DOWN, handleMouseDown);
			zCube.addEventListener(MouseEvent3D.MOUSE_UP, handleMouseUp);			
			zCube.rotationX = 180;
			zCube.z = 100 + (cubeGeom.height/2);
			content.addChild(zCube);						
		}
		
		protected function handleMouseOut(event:MouseEvent3D):void
		{
			if (!active) 
			{
				switch(event.target.name)
				{					
					case "xAxis":
						
						xCube.material = xAxisMaterial;
						xCylinder.material = xAxisMaterial;
						
						break;
					
					case "yAxis":
						
						yCube.material = yAxisMaterial;
						yCylinder.material = yAxisMaterial;
						
						break;
					
					case "zAxis":
						
						zCube.material = zAxisMaterial;
						zCylinder.material = zAxisMaterial;
						
						break;		
					
					case "allAxis":
						
						mCube.material = cubeMaterial;
						
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
						
						xCube.material = highlightOverMaterial;
						xCylinder.material = highlightOverMaterial;
						
						break;
					
					case "yAxis":
						
						yCube.material = highlightOverMaterial;
						yCylinder.material = highlightOverMaterial;
						
						break;
					
					case "zAxis":
						
						zCube.material = highlightOverMaterial;
						zCylinder.material = highlightOverMaterial;
						
						break;		
					
					case "allAxis":
						
						mCube.material = highlightOverMaterial;
						
						break;								
				}							
			}			
		}			
		
		protected function handleMouseDown(e:Event):void
		{
			currentAxis = e.target.name;
			
			if (currentMesh.parent is ISceneRepresentation) actualMesh = (currentMesh.parent as ISceneRepresentation).sceneObject;
			else actualMesh = currentMesh;
			
			var maxScale:Number = Math.max( actualMesh.scaleX,  actualMesh.scaleY,  actualMesh.scaleZ );
			scaleRatio.x = actualMesh.scaleX / maxScale;
			scaleRatio.y = actualMesh.scaleY / maxScale;
			scaleRatio.z = actualMesh.scaleZ / maxScale;				

			maxBounds = Math.max(actualMesh.maxX - actualMesh.minX, actualMesh.maxY - actualMesh.minY, actualMesh.maxZ - actualMesh.minZ)

			click.x = Scene3DManager.stage.mouseX;
			click.y = Scene3DManager.stage.mouseY;				

			switch(currentAxis)
			{
				case "xAxis":
					
					xCube.material = highlightDownMaterial;
					xCylinder.material = highlightDownMaterial;
					
					break;
				
				case "yAxis":
					
					yCube.material = highlightDownMaterial;
					yCylinder.material = highlightDownMaterial;
					
					break;
				
				case "zAxis":
					
					zCube.material = highlightDownMaterial;
					zCylinder.material = highlightDownMaterial;
					
					break;		
				
				case "allAxis":
					
					mCube.material = highlightDownMaterial;
					
					break;							
			}
			
			hasMoved = true;
			isMoving = true;
			active = true;
			CameraManager.active = false;
			
			startValue = new Vector3D();
			startValue.x = actualMesh.scaleX;
			startValue.y = actualMesh.scaleY;
			startValue.z = actualMesh.scaleZ;			
			
			Scene3DManager.stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			Scene3DManager.stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
		}
		
		protected function handleMouseMove(e:MouseEvent):void
		{	
			var dx:Number = Scene3DManager.stage.mouseX - click.x;
			var dy:Number = -(Scene3DManager.stage.mouseY - click.y);
			
			var trans:Number = (dx+dy) * 0.005 * CameraManager.radius/maxBounds;				
			
			var mScale:Vector3D = new Vector3D();
			mScale.x = actualMesh.scaleX;
			mScale.y = actualMesh.scaleY;
			mScale.z = actualMesh.scaleZ;
			
			switch(currentAxis)
			{
				case "xAxis":
					
					var xv1:Vector3D = Scene3DManager.camera.rightVector;
					var xv2:Vector3D = content.rightVector; 
					xv1.normalize();
					xv2.normalize();
					var ax:Number = xv1.dotProduct(xv2);
					if (ax < 0) trans = -trans;					
					
					mScale.x += trans;
					
					break;
				
				case "yAxis":
					
					var yv1:Vector3D = Scene3DManager.camera.upVector;
					var yv2:Vector3D = content.upVector; 			
					yv1.normalize();
					yv2.normalize();
					var ay:Number = yv1.dotProduct(yv2);
					if (ay < 0) trans = -trans;					
					
					mScale.y += trans;
					
					break;
				
				case "zAxis":
					
					var zv1:Vector3D = Scene3DManager.camera.rightVector;
					var zv2:Vector3D = content.forwardVector; 			
					zv1.normalize();
					zv2.normalize();
					var az:Number = zv1.dotProduct(zv2);
					if (az < 0) trans = -trans;					
					
					mScale.z += trans;
					
					break;				
				
				case "allAxis":
					
					mScale.x += trans * scaleRatio.x;
					mScale.y += trans * scaleRatio.y;
					mScale.z += trans * scaleRatio.z;
					
					break;				
				
				
			}							
			
			actualMesh.scaleX = mScale.x;					
			actualMesh.scaleY = mScale.y;
			actualMesh.scaleZ = mScale.z;
			
			click.x = Scene3DManager.stage.mouseX;
			click.y = Scene3DManager.stage.mouseY;			

			Scene3DManager.updateDefaultCameraFarPlane();
			
			dispatchEvent(new Gizmo3DEvent(Gizmo3DEvent.MOVE, GizmoMode.SCALE, actualMesh, mScale, startValue, mScale));
		}
		
		protected function handleMouseUp(event:Event):void
		{
			isMoving = false;
			Scene3DManager.stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			Scene3DManager.stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			
			currentAxis = "";
			active = false;
			CameraManager.active = true;
			
			mCube.material = new ColorMaterial();
			xCube.material = xAxisMaterial;
			xCylinder.material = xAxisMaterial;			
			yCube.material = yAxisMaterial;
			yCylinder.material = yAxisMaterial;			
			zCube.material = zAxisMaterial;
			zCylinder.material = zAxisMaterial;			
			
			var sc:Vector3D = new Vector3D();
			sc.x = actualMesh.scaleX;
			sc.y = actualMesh.scaleY;
			sc.z = actualMesh.scaleZ;
			
			dispatchEvent(new Gizmo3DEvent(Gizmo3DEvent.RELEASE, GizmoMode.SCALE, actualMesh, sc, startValue, sc));
		}		
		
	}
}