package awaybuilder.utils.scene
{
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.math.Quaternion;
	
	import awaybuilder.utils.MathUtils;
	import awaybuilder.utils.scene.modes.CameraMode;
	
	import com.greensock.TweenMax;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.system.Capabilities;
	
	import mx.core.UIComponent;

	/**
	 * ...
	 * @author Cornflex
	 */
	public class CameraManager
	{
		
		public static const ZOOM_DELTA_VALUE:Number = .05;
		public static const ZOOM_MULTIPLIER:Number = 8;
		
		// Singleton instance declaration
		private static const self : CameraManager = new CameraManager();
		public static function get instance():CameraManager { return self; }			
		public function CameraManager() { if ( instance ) throw new Error("CameraManager is a singleton"); }			
		
		public static var camera:Camera3D;
		
		// common variables	
		public static var dragging:Boolean = false;
		public static var hasMoved:Boolean = false;
		public static var panning:Boolean = false;
		public static var running:Boolean = false;
		public static var runMultiplier:Number = 3;
		
		private static var _mode:String = CameraMode.TARGET;
		private static var _active:Boolean = false;			
		
		public static var _xDeg:Number = 0;
		public static var _yDeg:Number = 0;				
		
		private var offset:Vector3D = new Vector3D();
		private var click:Point = new Point();						
		private var pan:Point = new Point();		
		
		// target mode variables
		public static var wheelSpeed:Number = 10;
		public static var mouseSpeed:Number = 1;		
		
		private static var _radius:Number = 0;
		private var _minRadius:Number = 10;								
		private var stage:Stage;
		
		private var scope:UIComponent;
		
		// free mode variables
        private var _speed:Number = 5;				
		private var _xSpeed:Number = 0;
        private var _zSpeed:Number = 0;
		private var _runMultiplier:Number = 3;
		private var _pause:Boolean = false;
		private var ispanning:Boolean = false;
		private var _mouseOutDetected:Boolean = false;
		
		private var poi:ObjectContainer3D;
		
		private var quat:Quaternion;

		public static function get radius() : Number { return _radius; }
		public static function set radius(radius : Number) : void { 
			if (_radius == radius) return;
			
			_radius = radius;
			Scene3DManager.updateDefaultCameraFarPlane();
		}
		
		public static function init(scope:UIComponent, view:View3D, mode:String=CameraMode.TARGET, speed:Number=10):void
		{			
			instance.scope = scope;
			instance.stage = scope.stage;
			
			camera = view.camera;
			CameraManager.speed = speed;
			_mode = mode;
			
			instance.poi = new ObjectContainer3D();
			view.scene.addChild(instance.poi);
			
			instance.quat = new Quaternion();
			instance.quat.fromMatrix(camera.transform);						
			
			switch(_mode)
			{
				case CameraMode.FREE: instance.initFreeMode();
					break;
				case CameraMode.TARGET: instance.initTargetMode(5, 1000, 0, 15);
					break;
			}			
			
			instance.stage.addEventListener(MouseEvent.MOUSE_DOWN, instance.onMouseDown);			
			instance.stage.addEventListener(MouseEvent.MOUSE_UP, instance.onMouseUp);	
			instance.scope.addEventListener(MouseEvent.MOUSE_OVER, instance.onMouseOver);	
			instance.scope.addEventListener(MouseEvent.MOUSE_OUT, instance.onMouseOut);	
			instance.stage.addEventListener(Event.MOUSE_LEAVE, instance.onMouseLeave);	
			instance.stage.addEventListener(MouseEvent.MOUSE_WHEEL, instance.onMouseWheel);
			
			if(Capabilities.playerType == "Desktop")
			{
				instance.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, instance.onMouseMiddleDown);
				instance.stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, instance.onMouseMiddleUp);
			}
			
			focusTarget();
			
			scope.addEventListener(Event.ENTER_FRAME, instance.loop);
		}
		
		public static function kill():void
		{
			instance.scope.removeEventListener(Event.ENTER_FRAME, instance.loop);
			instance.stage.removeEventListener(MouseEvent.MOUSE_DOWN, instance.onMouseDown);			
			instance.stage.removeEventListener(MouseEvent.MOUSE_UP, instance.onMouseUp);	
			instance.scope.removeEventListener(MouseEvent.MOUSE_OVER, instance.onMouseOver);	
			instance.scope.removeEventListener(MouseEvent.MOUSE_OUT, instance.onMouseOut);	
			instance.stage.removeEventListener(Event.MOUSE_LEAVE, instance.onMouseLeave);	
			instance.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, instance.onMouseWheel);
			instance.stage.removeEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, instance.onMouseMiddleDown);
			instance.stage.removeEventListener(MouseEvent.MIDDLE_MOUSE_UP, instance.onMouseMiddleUp);
		}			
		
		public static function get active():Boolean { return _active; }		
		public static function set active(value:Boolean):void { 
			_active = value;
			
			if (!_active) {
				dragging = false;
			}
		}			
		
		public static function get speed():Number { return instance._speed; }		
		public static function set speed(value:Number):void { instance._speed = value; }				
		
		public static function get minRadius():Number { return instance._minRadius; }		
		public static function set minRadius(value:Number):void 
		{ 
			instance._minRadius = value; 
		}				
		
		static public function get mode():String { return _mode; }		
		static public function set mode(value:String):void 
		{
			_mode = value;
			
			switch(value)
			{
				case CameraMode.FREE: instance.initFreeMode();
				break;
				case CameraMode.TARGET: 
										
					var poiPos:Vector3D = Vector3D(camera.scenePosition);
					instance.poi.position = poiPos;
					instance.poi.eulers = camera.eulers;
					instance.poi.moveForward(300);
					instance.initTargetMode(5, 300, _xDeg, _yDeg);
					
					radius = Vector3D.distance(camera.position, instance.poi.scenePosition);
					Scene3DManager.updateDefaultCameraFarPlane();
					Scene3DManager.zoomToDistance(radius);
					
				break;
			}			
		}
				
		private function loop(e:Event) : void
		{
			if (!_pause)
			{
				if (_mouseOutDetected) {
					CameraManager.active = false;
					Scene3DManager.active = false;
				}
				_mouseOutDetected = false;
				
				switch(mode)
				{
					case CameraMode.FREE: processFreeMode();
						break;
					case CameraMode.TARGET: processTargetMode();
						break;				
				}
			}				
		}					
		
		
		
		// FreeMode ***************************************************************
		
		private function initFreeMode():void
		{
			TweenMax.killTweensOf(camera);
			active = true;
		}
				
		private function processFreeMode():void
		{			
			if (dragging) updateMouseRotation();
			
			if (running) _runMultiplier = runMultiplier;
			else _runMultiplier = 1;			
			
			camera.moveForward(_zSpeed * _runMultiplier);
			camera.moveRight(_xSpeed * _runMultiplier);
						
			camera.eulers = quat.rotatePoint(new Vector3D(_yDeg, _xDeg, camera.rotationZ));	
			
			if (active && dragging || (_zSpeed!=0 || _xSpeed!=0)) Scene3DManager.updateDefaultCameraFarPlane();
		}
		
		
		
		// TargetMode **********************************************
		
		private function initTargetMode(minRadius:Number=5, radius:Number=NaN, xDegree:Number=NaN, yDegree:Number=NaN):void
		{				
			CameraManager.minRadius = minRadius;
			
			if (!isNaN(xDegree)) _xDeg = xDegree;
			if (!isNaN(yDegree)) _yDeg = yDegree;								
			
			if (!isNaN(radius)) CameraManager.radius = radius;
			else
			{
				radius = Vector3D.distance(camera.position, instance.poi.scenePosition);
			}							
			
			camera.position = getCameraPosition(_xDeg, -_yDeg);							
			camera.eulers = quat.rotatePoint(new Vector3D(_yDeg, _xDeg, camera.rotationZ));		
			
			if (mode != CameraMode.TARGET) mode = CameraMode.TARGET;				
			
			active = true;
		}			
		
		private function processTargetMode():void
		{			
			if (ispanning) updatePOIPosition();
			if (dragging) updateMouseRotation();
			
			camera.position = getCameraPosition(_xDeg, -_yDeg);							
			camera.eulers = quat.rotatePoint(new Vector3D(_yDeg, _xDeg, camera.rotationZ));
			Scene3DManager.updateGizmo();

			if (hasMoved) {
				radius = Vector3D.distance(camera.position, instance.poi.scenePosition);
 			}
		}			
		
		
		
		
		public static function focusTarget(t:ObjectContainer3D = null):void
		{	
			var tr:Number;
			var bmin:Vector3D;
			var bmax:Vector3D;
			
			var bounds:Vector.<Number> = (t ? Scene3DManager.containerBounds(t) : Scene3DManager.getSceneBounds());
				
			if (bounds[0]==Infinity || bounds[1]==Infinity || bounds[2]==Infinity || bounds[3]==-Infinity || bounds[4]==-Infinity || bounds[5]==-Infinity) { 
				bmin = new Vector3D(-500, 0, 0);
				bmax = new Vector3D(500, 0, 0);
			} else {
				bmin = new Vector3D(bounds[0], bounds[1], bounds[2]);
				bmax = new Vector3D(bounds[3], bounds[4], bounds[5]);
			}
			
			var center:Vector3D = bmax.subtract(bmin);
			tr = center.length;	
			center.x /= 2;
			center.y /= 2;
			center.z /= 2;
			center = center.add(bmin);		

			TweenMax.to(CameraManager, 0.5, {radius:tr, onComplete:instance.calculateWheelSpeed, onCompleteParams:[tr, center]});
			TweenMax.to(instance.poi, 0.5, {x:center.x, y:center.y, z:center.z});
		}
		
		private function calculateWheelSpeed(radius:Number, pos:Vector3D):void
		{
			//adjust mouseWheel speed according size and scale of the mesh;
			var dist:Vector3D = camera.scenePosition.subtract(pos);
			wheelSpeed = dist.length/60; 
			Scene3DManager.zoomToDistance(radius);
			Scene3DManager.updateDefaultCameraFarPlane();
		}
		
		
		
		
		
		private function updatePOIPosition():void
		{
			poi.rotationX = camera.rotationX;
			poi.rotationY = camera.rotationY;
			poi.rotationZ = camera.rotationZ;			
			
			var dx:Number = (stage.mouseX - pan.x) * (radius/500);
			var dy:Number = (stage.mouseY - pan.y) * (radius/500);
			
			if (dx != 0 || dy != 0) hasMoved = true;
			
			pan.x = stage.mouseX;
			pan.y = stage.mouseY;			
			
			poi.moveUp(dy);
			poi.moveLeft(dx);
		}		
		
		private function updateMouseRotation() : void
		{			
			var dx:Number = stage.mouseX - click.x;
			var dy:Number = stage.mouseY - click.y;
			
			if (dx != 0 || dy != 0) hasMoved = true;
			
			click.x = stage.mouseX;
			click.y = stage.mouseY;
			
			_yDeg += (dy * mouseSpeed);
			_xDeg += (dx * mouseSpeed);
		}		
		
		private function getCameraPosition(xDegree:Number, yDegree:Number):Vector3D
		{
			var cy:Number = Math.cos(MathUtils.convertToRadian(yDegree)) * radius;			
			
			var v:Vector3D = new Vector3D();
			
			v.x = (poi.scenePosition.x + offset.x) - Math.sin(MathUtils.convertToRadian(xDegree)) * cy;
			v.y = (poi.scenePosition.y + offset.y) - Math.sin(MathUtils.convertToRadian(yDegree)) * radius;
			v.z = (poi.scenePosition.z + offset.z) - Math.cos(MathUtils.convertToRadian(xDegree)) * cy;
			
//			if (camera.x != v.x || camera.y != v.y || camera.z != v.z) {
//trace("Updating c:"+camera.position+" v:"+v);
//				Scene3DManager.updateDefaultCameraFarPlane();
//			}
				
			return v;
		}				
		
		
		// Mouse Events **********************************************************************************************************************
		
		private function onMouseMiddleDown(e:MouseEvent):void
		{
			pan.x = stage.mouseX;
			pan.y = stage.mouseY;			
			ispanning = true;
		}
		
		private function onMouseMiddleUp(e:MouseEvent):void
		{
			ispanning = false;
		}		
		
		private function onMouseDown(event : MouseEvent) : void
		{			
			if (active)
			{
				click.x = stage.mouseX;
				click.y = stage.mouseY;				
				
				if (panning)
				{
					pan.x = stage.mouseX;
					pan.y = stage.mouseY;
					ispanning = true;
				}
				else dragging = true;				
				hasMoved = false;
			}
		}
		
		private function onMouseOver(event : MouseEvent) : void
		{
			CameraManager.active = true;
			Scene3DManager.active = true;
			_mouseOutDetected = false;
		}
		
		private function onMouseOut(event : MouseEvent) : void
		{
			_mouseOutDetected = true;
		}

		private function onMouseUp(event : MouseEvent) : void
		{
			dragging = false;
			ispanning = false;
		}
		
		private function onMouseWheel(event:MouseEvent) : void
		{
			if (active)
			{
				switch(mode)
				{
					case CameraMode.TARGET: {
						Scene3DManager.zoomDistanceDelta(event.delta / 500);
						break;
					}
					case CameraMode.FREE: {
						camera.moveForward(speed * event.delta);
						Scene3DManager.updateDefaultCameraFarPlane();
						break;						
					}
				}
			}			
		}						
		
		private function onMouseLeave(event:Event) : void
		{
			dragging = false;
			ispanning = false;			
		}					
		
		
		
		// Free Camera Moves ********************************************************************************************************************************************
		
		public static function moveForward(moveSpeed:Number):void
		{
			if (active && mode == CameraMode.FREE)
			{
				instance._zSpeed = moveSpeed;
			}
		}
		
		public static function moveBackward(moveSpeed:Number):void
		{
			if (active && mode == CameraMode.FREE)
			{
				instance._zSpeed = -moveSpeed;
			}			
		}		
		
		public static function moveLeft(moveSpeed:Number):void
		{
			if (active && mode == CameraMode.FREE)
			{
				instance._xSpeed = -moveSpeed;
			}			
		}
		
		public static function moveRight(moveSpeed:Number):void
		{
			if (active && mode == CameraMode.FREE)
			{
				instance._xSpeed = moveSpeed;
			}			
		}		

		// Camera zoom math function ********************************************************************************************************************************************

		public static function zoomFunction(x:Number):Number
		{
			return Math.pow(2, 8-x);
			//return 16-Math.log(x)/(Math.LN2);
		}

		public static function distanceFunction(x:Number):Number
		{
			return 8 - Math.log(x) / Math.log(2);
		}
	}
}