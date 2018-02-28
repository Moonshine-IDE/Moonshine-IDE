package awaybuilder.utils.scene
{
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import mx.core.UIComponent;
	
	import avmplus.getQualifiedClassName;
	
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.LensBase;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.core.pick.PickingColliderType;
	import away3d.core.pick.PickingType;
	import away3d.entities.Entity;
	import away3d.entities.Mesh;
	import away3d.entities.TextureProjector;
	import away3d.events.MouseEvent3D;
	import away3d.events.Stage3DEvent;
	import away3d.library.AssetLibrary;
	import away3d.lights.DirectionalLight;
	import away3d.lights.LightBase;
	import away3d.lights.PointLight;
	import away3d.primitives.SkyBox;
	import away3d.primitives.WireframePlane;
	import away3d.primitives.WireframePrimitiveBase;
	import away3d.textures.BitmapTexture;
	import away3d.tools.utils.Bounds;
	
	import awaybuilder.utils.MathUtils;
	import awaybuilder.utils.scene.modes.GizmoMode;
	import awaybuilder.view.scene.OrientationTool;
	import awaybuilder.view.scene.controls.CameraGizmo3D;
	import awaybuilder.view.scene.controls.ContainerGizmo3D;
	import awaybuilder.view.scene.controls.Gizmo3DBase;
	import awaybuilder.view.scene.controls.LightGizmo3D;
	import awaybuilder.view.scene.controls.RotateGizmo3D;
	import awaybuilder.view.scene.controls.ScaleGizmo3D;
	import awaybuilder.view.scene.controls.TextureProjectorGizmo3D;
	import awaybuilder.view.scene.controls.TranslateGizmo3D;
	import awaybuilder.view.scene.events.Gizmo3DEvent;
	import awaybuilder.view.scene.events.Scene3DManagerEvent;
	import awaybuilder.view.scene.representations.ISceneRepresentation;
	import awaybuilder.view.scene.utils.ObjectContainerBounds;
	
	public class Scene3DManager extends EventDispatcher
	{
		// Singleton instance declaration
		public static const instance : Scene3DManager = new Scene3DManager();
		
		public function Scene3DManager() { if ( instance ) throw new Error("Scene3DManager is a singleton"); }	
		
		private var sceneDoubleClickDetected : Boolean;
		private var doubleClick3DMonitor : Boolean;
		
		public static var active:Boolean = true;

		public static var scope:UIComponent;
		public static var stage:Stage;
		public static var stage3DProxy:Stage3DProxy;
		public static var mode:String;
		public static var view:View3D;
		public static var directionalLightView:View3D;
		public static var gizmoView : View3D;
		public static var backgroundView : View3D;
		public static var scene:Scene3D;
		public static var camera:Camera3D;
		public static var gizmoCamera:Camera3D;
		
		public static var selectedObjects:Vector.<ObjectContainer3D> = new Vector.<ObjectContainer3D>();
		public static var selectedObject:ObjectContainer3D;
		public static var multiSelection:Boolean = false;
		public static var mouseSelection:ObjectContainer3D;
		public static var lensSelected:LensBase;
		
		public static var grid:WireframePlane;
		public static var backgroundGrid:WireframePlane;
		public static var orientationTool:OrientationTool;
		
		public static var currentGizmo:Gizmo3DBase;
		public static var translateGizmo:TranslateGizmo3D;
		public static var rotateGizmo:RotateGizmo3D;
		public static var scaleGizmo:ScaleGizmo3D;
		
		public static var lightGizmos:Vector.<LightGizmo3D> = new Vector.<LightGizmo3D>();
		public static var textureProjectorGizmos:Vector.<TextureProjectorGizmo3D> = new Vector.<TextureProjectorGizmo3D>();
		public static var cameraGizmos:Vector.<CameraGizmo3D> = new Vector.<CameraGizmo3D>();
		public static var containerGizmos:Vector.<ContainerGizmo3D> = new Vector.<ContainerGizmo3D>();
		
		public static var currentContainer:ObjectContainer3D;
		public static var containerBreadCrumbs : Array;
		
		private static var _lastCameraPos : Vector3D;
		private static var _lastCameraRot : Vector3D;
		
		public static function init(scope:UIComponent):void
		{
			Scene3DManager.scope = scope;			
			Scene3DManager.stage = scope.stage;
			
			stage3DProxy = Stage3DManager.getInstance(stage).getFreeStage3DProxy();
			stage3DProxy.antiAlias = 4;
			stage3DProxy.color = 0x333333;
			stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, instance.onContextCreated);				
		}
		
		private function onContextCreated(e:Stage3DEvent):void 
		{
			trace( "onContextCreated" );
			backgroundView = new View3D();
			backgroundView.shareContext = true;
			backgroundView.stage3DProxy = stage3DProxy;	
			backgroundView.camera.lens.near = 1;
			backgroundView.camera.lens.far = 110000;			
			scope.addChild(backgroundView);

			//Create view3D, camera and add to stage
			view = new View3D();
			view.shareContext = true;
			view.stage3DProxy = stage3DProxy;
			view.layeredView = true;
			view.mousePicker = PickingType.RAYCAST_BEST_HIT;
			view.camera.lens.near = 1;
			view.camera.lens.far = 100000;			
			view.camera.position = new Vector3D(0, 200, -1000);
			view.camera.rotationX = 0;
			view.camera.rotationY = 0;	
			view.camera.rotationZ = 0;			
			scope.addChild(view);
			Scene3DManager.scene = view.scene;
			Scene3DManager.camera = view.camera;
			
			_lastCameraPos = new Vector3D();
			_lastCameraRot = new Vector3D();							
			
			directionalLightView = new View3D();
			directionalLightView.shareContext = true;
			directionalLightView.layeredView = true;
			directionalLightView.stage3DProxy = stage3DProxy;	
			directionalLightView.mousePicker = PickingType.RAYCAST_BEST_HIT;
			directionalLightView.camera.lens.near = 1;
			directionalLightView.camera.lens.far = 100000;			
			scope.addChild(directionalLightView);

			//Create OrientationTool			
			orientationTool = new OrientationTool();
			scope.addChild(orientationTool);
			scope.name = "scope";
			orientationTool.name = "orientationTool";
			view.name = "view";

			gizmoView = new View3D();
			gizmoView.shareContext = true;
			gizmoView.stage3DProxy = stage3DProxy;	
			gizmoView.layeredView = true;
			gizmoView.mousePicker = PickingType.RAYCAST_BEST_HIT;
			gizmoView.camera.lens.near = 1;
			gizmoView.camera.lens.far = 100000;	
			gizmoCamera = gizmoView.camera;
			scope.addChild(gizmoView);
			
			//Create Gizmos
			translateGizmo = new TranslateGizmo3D();
			translateGizmo.addEventListener(Gizmo3DEvent.MOVE, handleGizmoAction);
			translateGizmo.addEventListener(Gizmo3DEvent.RELEASE, handleGizmoActionRelease);
			gizmoView.scene.addChild(translateGizmo);
			rotateGizmo = new RotateGizmo3D();
			rotateGizmo.addEventListener(Gizmo3DEvent.MOVE, handleGizmoAction);
			rotateGizmo.addEventListener(Gizmo3DEvent.RELEASE, handleGizmoActionRelease);
			gizmoView.scene.addChild(rotateGizmo);
			scaleGizmo = new ScaleGizmo3D();
			scaleGizmo.addEventListener(Gizmo3DEvent.MOVE, handleGizmoAction);
			scaleGizmo.addEventListener(Gizmo3DEvent.RELEASE, handleGizmoActionRelease);
			gizmoView.scene.addChild(scaleGizmo);	
			
			//assing default gizmo
			currentGizmo = translateGizmo;
						
			//Create Grid
			grid = new WireframePlane(10000, 10000, 100, 100, 0x000000, 0.5, "xz");
			grid.mouseEnabled = false;
			scene.addChild(grid);	
			
			//Background grid 
			backgroundGrid = new WireframePlane(10000, 10000, 100, 100, 0x000000, 0.375, "xz");
			backgroundGrid.mouseEnabled = false;
			backgroundView.scene.addChild(backgroundGrid);	
			
			//Camera Settings
			CameraManager.init(scope, view);	
				
			//handle stage events
			scope.addEventListener(MouseEvent.MOUSE_DOWN, instance.onMouseDown);
			scope.addEventListener(MouseEvent.DOUBLE_CLICK, instance.onSceneDoubleClick);			
			
			containerBreadCrumbs = new Array();
			
			scope.addEventListener(Event.RESIZE, instance.handleScreenSize);
			instance.resize();
			
			stage3DProxy.addEventListener(Event.ENTER_FRAME, instance.loop);		
			
			dispatchEvent(new Scene3DManagerEvent(Scene3DManagerEvent.READY));
		}
		
		private function handleGizmoActionRelease(e:Gizmo3DEvent):void
		{
			dispatchEvent(new Scene3DManagerEvent(Scene3DManagerEvent.TRANSFORM_RELEASE, e.mode, e.object, e.currentValue, e.startValue, e.endValue));
		}
						
		private function handleGizmoAction(e:Gizmo3DEvent):void
		{
			dispatchEvent(new Scene3DManagerEvent(Scene3DManagerEvent.TRANSFORM, e.mode, e.object, e.currentValue, e.startValue, e.endValue));
		}
		
		private function loop(e:Event):void 
		{	
			updateBackgroundGrid();
			
			currentGizmo.update();
			updateGizmo();
			updateLights();
			updateTextureProjectorGizmos();
			updateCameraGizmos();
			updateContainerGizmos();

			Scene3DManager.checkCameraMovement();	
			
			view.render();			

			updateDirectionalLightView();
			orientationTool.update();
			gizmoView.render();
			
			// Handle double click (stage and 3D) events staggered acros frames		
			if (sceneDoubleClickDetected && doubleClick3DMonitor && currentContainer) {
				if (scene.contains(currentContainer)) currentContainer = null;
				else currentContainer = currentContainer.parent;
				if (containerBreadCrumbs.length>0) containerBreadCrumbs.pop();
				sceneDoubleClickDetected = doubleClick3DMonitor = false;
				
				instance.dispatchEvent(new Scene3DManagerEvent(Scene3DManagerEvent.UPDATE_BREADCRUMBS));
			}

			if (sceneDoubleClickDetected)
				doubleClick3DMonitor = true;	
		}

		private function updateBackgroundGrid() : void {
			backgroundView.camera.lens.near = CameraManager.camera.lens.far;
			backgroundView.camera.lens.far = CameraManager.camera.lens.far + 10000;
			backgroundView.camera.transform = CameraManager.camera.transform.clone();
			backgroundGrid.transform = Scene3DManager.grid.transform.clone();
			backgroundView.render();
		}

		private function updateDirectionalLightView() : void {
			directionalLightView.camera.eulers = Scene3DManager.camera.eulers;
			
			var camPos:Vector3D = getCameraPosition(CameraManager._xDeg, -CameraManager._yDeg);
			directionalLightView.camera.x = -camPos.x;
			directionalLightView.camera.y = -camPos.y;
			directionalLightView.camera.z = -camPos.z;
			
			directionalLightView.render();						
		}
		
		private function getCameraPosition(xDegree:Number, yDegree:Number):Vector3D
		{
			var cy:Number = Math.cos(MathUtils.convertToRadian(yDegree)) * Scene3DManager.view.height/2;			
			
			var v:Vector3D = new Vector3D();
			
			v.x = Math.sin(MathUtils.convertToRadian(xDegree)) * cy;
			v.y = Math.sin(MathUtils.convertToRadian(yDegree)) * Scene3DManager.view.height/2;
			v.z = Math.cos(MathUtils.convertToRadian(xDegree)) * cy;
			
			return v;
		}
						
		private function updateLights() : void {
			var l:LightGizmo3D;
			var lI:int;
			for (lI=0; lI<lightGizmos.length; lI++) {
				l = lightGizmos[lI];
				l.updateRepresentation();
			}
		}

		private function updateTextureProjectorGizmos() : void {
			var tP:TextureProjectorGizmo3D;
			var tPI:int;
			for (tPI=0; tPI<textureProjectorGizmos.length; tPI++) {
				tP = textureProjectorGizmos[tPI];
				tP.updateRepresentation();
			}
		}
		
		private function updateCameraGizmos() : void {
			var c:CameraGizmo3D;
			var cI:int;
			for (cI=0; cI<cameraGizmos.length; cI++) {
				c = cameraGizmos[cI];
				c.updateRepresentation();
			}
		}
		
		private function updateContainerGizmos() : void {
			var c:ContainerGizmo3D;
			var cI:int;
			for (cI=0; cI<containerGizmos.length; cI++) {
				c = containerGizmos[cI];
				c.updateRepresentation();
			}
		}	
		
		private function handleScreenSize(e:Event=null):void 
		{
//			resize();
			scope.addEventListener(Event.ENTER_FRAME, validateSizeOnNextFrame );
			updateLights();
		}	

		private function validateSizeOnNextFrame( e:Event ):void 
		{
			resize();
		}	

		private function resize():void 
		{
			scope.removeEventListener(Event.ENTER_FRAME, validateSizeOnNextFrame );
			orientationTool.x = scope.width - orientationTool.width - 10;
			orientationTool.y = 5;
			
			var position:Point = scope.localToGlobal(new Point(0, 0));
			stage3DProxy.x = position.x;
			stage3DProxy.y = position.y;
			stage3DProxy.width = scope.width;
			stage3DProxy.height = scope.height;			
			
			backgroundView.width = view.width = directionalLightView.width = gizmoView.width = scope.width;
			backgroundView.height = view.height = directionalLightView.height = gizmoView.height = scope.height;
		}
		
		// Mouse Events *************************************************************************************************************************************************
				
		private function onMouseDown(e:MouseEvent):void
		{
			scope.addEventListener(MouseEvent.MOUSE_UP, instance.onMouseUp);
		}			
		
		private function onMouseUp(e:MouseEvent):void
		{
			scope.removeEventListener(MouseEvent.MOUSE_UP, instance.onMouseUp);
			if (active)
			{
				if( currentGizmo.isMoving ) return;
				if (!CameraManager.hasMoved && !multiSelection && !currentGizmo.active && !orientationTool.orientationClicked) deselectAndDispatch();	
			}
			orientationTool.orientationClicked = false;
		}		
		
		private function onSceneDoubleClick(e:MouseEvent):void {
			if (active)
			{
				if (!CameraManager.hasMoved && !multiSelection && !currentGizmo.active && !orientationTool.orientationClicked) sceneDoubleClickDetected = true;
			}
			orientationTool.orientationClicked = false;
		}
		
		//Change gizmo mode to transform the selected mesh
		public static function setTransformMode(mode:String):void
		{
			currentGizmo.active = false;
			currentGizmo.hide();

			switch (mode) 
			{													
				case GizmoMode.TRANSLATE : 
					currentGizmo = translateGizmo;
					break;				
				
				case GizmoMode.ROTATE: 
					currentGizmo = rotateGizmo;
					break;				
				
				case GizmoMode.SCALE: 
					currentGizmo = scaleGizmo;
					break;													
			}
			
			if (selectedObject) 
			{
				var isLightGizmo:LightGizmo3D = selectedObject.parent as LightGizmo3D;
			 	if (!isLightGizmo || 
					(isLightGizmo.type==LightGizmo3D.DIRECTIONAL_LIGHT && Scene3DManager.currentGizmo==rotateGizmo) ||
					(isLightGizmo.type==LightGizmo3D.POINT_LIGHT && Scene3DManager.currentGizmo==translateGizmo))
					currentGizmo.show(selectedObject);			
			}
		}
		
		public static function updateGizmo() : void {
			gizmoCamera.transform = camera.transform.clone();
			var isLightGizmo:LightGizmo3D = (selectedObject && selectedObject.parent) as LightGizmo3D;
		 	if (isLightGizmo && isLightGizmo.type==LightGizmo3D.DIRECTIONAL_LIGHT && Scene3DManager.currentGizmo==rotateGizmo) 
			{
				var oC:ObjectContainer3D = Scene3DManager.camera.clone() as ObjectContainer3D;
				oC.moveForward(1000);
				currentGizmo.position = oC.position;
			}
		}
		
		// Lights Handling *********************************************************************************************************************************************
		
		public static function addLight(light:LightBase):void
		{
			var gizmo:LightGizmo3D = new LightGizmo3D(light); 
			gizmo.representation.addEventListener(MouseEvent3D.CLICK, instance.handleClickMouseEvent3D);
			lightGizmos.push(gizmo);
			
			if (light is DirectionalLight) Scene3DManager.directionalLightView.scene.addChild(gizmo);
			else scene.addChild(gizmo);
			if (light.parent == null) scene.addChild(light);
		}
		
		public static function removeLight(light:LightBase):void
		{
			// Remove light gizmo from scene	
			for each (var lG:LightGizmo3D in lightGizmos) {
				if (lG.sceneObject == light && lG.parent) {
					lG.parent.removeChild(lG);
					lightGizmos.splice(lightGizmos.indexOf(lG), 1);
					break;
				}
			}

			// Remove light from scene
			if (light.parent)
				light.parent.removeChild(light);
		}	
				
		// Meshes Handling *********************************************************************************************************************************************
		
		public static function clear(disposeMaterials:Boolean=false):void
		{
			currentContainer = null;
			
			if (currentGizmo) {
				currentGizmo.active = false;
				currentGizmo.hide();
			}
			
			AssetLibrary.removeAllAssets(true);
			
			for each(var lG:LightGizmo3D in lightGizmos)
			{
				if (lG.parent) 
					lG.parent.removeChild(lG);
				lG.dispose();	
			}
			lightGizmos.length = 0;	

			for each(var tPG:TextureProjectorGizmo3D in textureProjectorGizmos)
			{
				if (tPG.parent) 
					tPG.parent.removeChild(tPG);
				tPG.dispose();	
			}
			textureProjectorGizmos.length = 0;

			for each(var cMG:CameraGizmo3D in cameraGizmos)
			{
				if (cMG.parent) 
					cMG.parent.removeChild(cMG);
				cMG.dispose();	
			}
			cameraGizmos.length = 0;

			for each(var cG:ContainerGizmo3D in containerGizmos)
			{
				if (cG.parent) 
					cG.parent.removeChild(cG);
				cG.dispose();	
			}
			containerGizmos.length = 0;
		
			var oC:ObjectContainer3D;
			var keepCtr:int = 0;
			while (Scene3DManager.scene.numChildren>keepCtr)
			{
				oC = Scene3DManager.scene.getChildAt(keepCtr);
				if (oC == Scene3DManager.grid) keepCtr++;
				else if (oC) {
					var isMesh:Mesh = oC as Mesh;
					if (isMesh && isMesh.material && disposeMaterials) 
						isMesh.material.dispose();
					if (oC.parent) oC.parent.removeChild(oC);
					oC.dispose();
				}
			}
			
			keepCtr = 0;
			while (Scene3DManager.backgroundView.scene.numChildren>keepCtr)
			{
				oC = backgroundView.scene.getChildAt(keepCtr);
				if (oC == Scene3DManager.backgroundGrid) keepCtr++;
				else if (oC) {
					if (oC.parent) oC.parent.removeChild(oC);
					oC.dispose();
				}
			}

			instance.dispatchEvent(new Scene3DManagerEvent(Scene3DManagerEvent.ENABLE_TRANSFORM_MODES));
		}
		
		public static function getSceneBounds(excludeGizmos : Boolean = true) : Vector.<Number> {
			
			var min:Vector3D = new Vector3D(Infinity, Infinity, Infinity);
			var max:Vector3D = new Vector3D(-Infinity, -Infinity, -Infinity);
			
			var ctr:int = 0;
			var oCCount:int = Scene3DManager.view.scene.numChildren;
			var rep:ISceneRepresentation;
			
			// Hide representations to get clear bounds
			if (excludeGizmos) {
				for each (rep in lightGizmos) rep.visible = false;
				for each (rep in textureProjectorGizmos) rep.visible = false;
				for each (rep in cameraGizmos) rep.visible = false;
				for each (rep in containerGizmos) rep.visible = false;
			}

			// Get all scene child container bounds		
			while (ctr < oCCount) {
				var oC:ObjectContainer3D = Scene3DManager.view.scene.getChildAt(ctr++);
				if (!(oC is SkyBox || oC is PointLight || oC == Scene3DManager.grid)) {
					Bounds.getObjectContainerBounds(oC);
					if (Bounds.minX < min.x) min.x = Bounds.minX;
					if (Bounds.minY < min.y) min.y = Bounds.minY;
					if (Bounds.minZ < min.z) min.z = Bounds.minZ;
					if (Bounds.maxX > max.x) max.x = Bounds.maxX;
					if (Bounds.maxY > max.y) max.y = Bounds.maxY;
					if (Bounds.maxZ > max.z) max.z = Bounds.maxZ;
				}
			}

			// Re-show representations
			if (excludeGizmos) {
				for each (rep in lightGizmos) rep.visible = true;
				for each (rep in textureProjectorGizmos) rep.visible = true;
				for each (rep in cameraGizmos) rep.visible = true;
				for each (rep in containerGizmos) rep.visible = true;
			}

			return Vector.<Number>([min.x, min.y, min.z, max.x, max.y, max.z]);
		}
		
		public static function containerBounds(oC:ObjectContainer3D, sceneBased:Boolean = true) : Vector.<Number> {
			Bounds.getObjectContainerBounds(oC, sceneBased);
			return Vector.<Number>([Bounds.minX, Bounds.minY, Bounds.minZ, Bounds.maxX, Bounds.maxY, Bounds.maxZ]);
		}
		
		public static function abs( value:Number ):Number {
			return value < 0 ? -value : value;
		}
 
 		public static function checkCameraMovement() : void {
			var xd:Boolean = abs(_lastCameraPos.x-camera.x)<0.001;
			var yd:Boolean = abs(_lastCameraPos.y-camera.y)<0.001;
			var zd:Boolean = abs(_lastCameraPos.z-camera.z)<0.001;
			var xr:Boolean = abs(_lastCameraRot.x-camera.rotationX)<0.001;
			var yr:Boolean = abs(_lastCameraRot.y-camera.rotationY)<0.001;
			var zr:Boolean = abs(_lastCameraRot.z-camera.rotationZ)<0.001;
			if (xd && yd && zd && xr && yr && zr) return;

			_lastCameraPos = camera.position.clone();
			_lastCameraRot = new Vector3D(camera.rotationX, camera.rotationY, camera.rotationZ);
			
			updateDefaultCameraFarPlane();
		}

		public static function updateDefaultCameraFarPlane() : void {
			var bounds:Vector.<Number> = getSceneBounds(false);
			if (abs(bounds[0])==Infinity || abs(bounds[1])==Infinity || abs(bounds[2])==Infinity || abs(bounds[3])==Infinity || abs(bounds[4])==Infinity || abs(bounds[5])==Infinity)
				camera.lens.far = 100000;
			else {
				var vec:Vector3D = new Vector3D(bounds[3] - bounds[0], bounds[4] - bounds[1], bounds[5] - bounds[2]);
				var objRadius:Number = vec.length / 2;
				vec.x = (vec.x * 0.5) + bounds[0];
				vec.y = (vec.y * 0.5) + bounds[1];
				vec.z = (vec.z * 0.5) + bounds[2];

				// Far plane is distance from camera position to scene bounds center + the radius of the scene bounds
				camera.lens.far = Vector3D.distance(camera.position, vec) + objRadius;
			}
		}
		
		public static function addObject(o:ObjectContainer3D):void
		{		
			addMousePicker(o);
			
			scene.addChild(o);

			attachGizmos(o);
			
			updateDefaultCameraFarPlane();
		}

		public static function addSkybox(o:ObjectContainer3D):void
		{		
			addMousePicker(o);
			
			backgroundView.scene.addChild(o);
		}
		
		public static function addTextureProjector(tP:TextureProjector, projectorBitmap:BitmapData = null):void
		{		
			if( projectorBitmap )
			{
				projectorBitmap = BitmapTexture(tP.texture).bitmapData;
			}
			var gizmo:TextureProjectorGizmo3D = new TextureProjectorGizmo3D(tP, projectorBitmap); 
			gizmo.representation.addEventListener(MouseEvent3D.CLICK, instance.handleClickMouseEvent3D);
			textureProjectorGizmos.push(gizmo);
			
			scene.addChild(gizmo);
			if (tP.parent == null) scene.addChild(tP);

			updateDefaultCameraFarPlane();
		}

		public static function addCamera(cam:Camera3D):void
		{		
			var gizmo:CameraGizmo3D = new CameraGizmo3D(cam); 
			gizmo.representation.addEventListener(MouseEvent3D.CLICK, instance.handleClickMouseEvent3D);
			cameraGizmos.push(gizmo);
			
			scene.addChild(gizmo);
			if (cam.parent == null) scene.addChild(cam);

			updateDefaultCameraFarPlane();
		}
		
		private static function attachGizmos(container:ObjectContainer3D) : void {			
			var childCtr:int = 0;
			while (childCtr < container.numChildren) 
			{
				attachGizmos(container.getChildAt(childCtr++));
			}

			if (getQualifiedClassName(container)=="away3d.containers::ObjectContainer3D" && container.numChildren == 0) 
			{
				addEmptyContainerRepresentation(container);
			} 
			else if (container is Camera3D) {
				addCamera(container as Camera3D);
			}

			updateDefaultCameraFarPlane();
		}

		public static function addEmptyContainerRepresentation(container : ObjectContainer3D) : void {
			var cG:ContainerGizmo3D = new ContainerGizmo3D(container);
			cG.representation.addEventListener(MouseEvent3D.CLICK, instance.handleClickMouseEvent3D);
			Scene3DManager.containerGizmos.push(cG);
			container.addChild(cG);
		}

		public static function removeEmptyContainerRepresentation(container : ObjectContainer3D) : void {
			Scene3DManager.currentGizmo.hide();

			var cG:ContainerGizmo3D = container.getChildAt(0) as ContainerGizmo3D;
			if (!cG) return;
			cG.representation.removeEventListener(MouseEvent3D.CLICK, instance.handleClickMouseEvent3D);
			container.removeChild(cG);
			Scene3DManager.containerGizmos.splice(Scene3DManager.containerGizmos.indexOf(cG), 1);
		}
		
		public static function removeMesh(mesh:ObjectContainer3D):void
		{
			Scene3DManager.currentGizmo.hide();
			mesh.parent.removeChild(mesh);
			mesh.dispose();

			updateDefaultCameraFarPlane();
		}

		public static function removeContainer(container:ObjectContainer3D, removeContainer:Boolean = true):void
		{
			Scene3DManager.currentGizmo.hide();

			// Remove gizmo first
			for each (var cG:ContainerGizmo3D in containerGizmos)
			{
				if (cG.sceneObject == container)
				{
					if (cG.parent) cG.parent.removeChild(cG);
					containerGizmos.splice(containerGizmos.indexOf(cG), 1);
					break;
				}
			}
			
			// Remove container
			if (removeContainer) {
				if (container.parent) container.parent.removeChild(container);
				container.dispose();
			}

			updateDefaultCameraFarPlane();
		}

		public static function removeSkyBox(skyBox:SkyBox):void
		{
			Scene3DManager.currentGizmo.hide();

			if (skyBox.parent) skyBox.parent.removeChild(skyBox);
			skyBox.dispose();
		}

		public static function removeTextureProjector(tP:TextureProjector):void
		{					
			Scene3DManager.currentGizmo.hide();

			for each (var tPG:TextureProjectorGizmo3D in textureProjectorGizmos)
			{
				if (tPG.sceneObject == tP)
				{
					if (tPG.parent) tPG.parent.removeChild(tPG);
					textureProjectorGizmos.splice(textureProjectorGizmos.indexOf(tPG), 1);
					break;
				}
			}
			
			if (tP.parent) tP.parent.removeChild(tP);
			tP.dispose();

			updateDefaultCameraFarPlane();
		}

		public static function removeCamera(cam:Camera3D):void
		{					
			Scene3DManager.currentGizmo.hide();

			for each (var camG:CameraGizmo3D in cameraGizmos)
			{
				if (camG.sceneObject == cam)
				{
					if (camG.parent) camG.parent.removeChild(camG);
					cameraGizmos.splice(cameraGizmos.indexOf(camG), 1);
					break;
				}
			}
			
			if (cam.parent) cam.parent.removeChild(cam);
			cam.dispose();

			updateDefaultCameraFarPlane();
		}

		public static function reparentObject(item:ObjectContainer3D, newParent:ObjectContainer3D):void
		{
			var itemParent:ObjectContainer3D = item.parent;
			if (itemParent) itemParent.removeChild(item);
						
			var containerBounds:ObjectContainerBounds;
			if (itemParent.numChildren==0 || (itemParent.numChildren==1 && (containerBounds = (itemParent.getChildAt(0) as ObjectContainerBounds))!=null)) {
				if (itemParent.numChildren == 1) {
					itemParent.removeChildAt(0);
					containerBounds.dispose();
				}
				attachGizmos(itemParent);
			}
			
			// Remove container gizmo if it existed as a new child is added
			if (newParent) {
				if (newParent.numChildren == 1 && newParent.getChildAt(0) is ContainerGizmo3D)
					removeContainer(newParent, false);
				newParent.addChild(item);
			} else scene.addChild(item);

			updateDefaultCameraFarPlane();
		}		

		private static function addMousePicker(o : ObjectContainer3D) : void
		{
			o.mouseEnabled = true;
			var m:Mesh = o as Mesh;
			if (m) {
				m.pickingCollider = PickingColliderType.PB_BEST_HIT;
				o.addEventListener(MouseEvent3D.CLICK, instance.handleClickMouseEvent3D);
				o.addEventListener(MouseEvent3D.DOUBLE_CLICK, instance.handleDblClickMouseEvent3D);
			}

			var container:ObjectContainer3D;
			for (var c:int = 0; c<o.numChildren; c++) {
				container = o.getChildAt(c) as ObjectContainer3D;
				if (container) addMousePicker(container);
			}
		}
		
		private function handleClickMouseEvent3D(e:MouseEvent3D):void 
		{
			if (!CameraManager.hasMoved && !currentGizmo.hasMoved && active)
			{
				var selectedObject:ObjectContainer3D = e.target as ObjectContainer3D;
				var container : ObjectContainer3D = getContainer(selectedObject);

				if (selectedObject.parent is ContainerGizmo3D) {
					selectedObject = (selectedObject.parent as ContainerGizmo3D).sceneObject;
					mouseSelection = selectedObject;
				} else if (selectedObject.parent is LightGizmo3D){ 
					selectedObject = (selectedObject.parent as LightGizmo3D).sceneObject;
					mouseSelection = selectedObject;
				} else if (selectedObject.parent is TextureProjectorGizmo3D) { 
					selectedObject = (selectedObject.parent as TextureProjectorGizmo3D).sceneObject;
					mouseSelection = selectedObject;
				} else if (selectedObject.parent is CameraGizmo3D) { 
					selectedObject = (selectedObject.parent as CameraGizmo3D).sceneObject;
					mouseSelection = selectedObject;
				} else {
					var m:Mesh = toggleMeshBounds(selectedObject);
					if (!m) return;
					mouseSelection = container;
				}
				instance.dispatchEvent(new Scene3DManagerEvent(Scene3DManagerEvent.OBJECT_SELECTED_FROM_VIEW));			
			}
		}

		private function handleDblClickMouseEvent3D(e:MouseEvent3D):void 
		{
			sceneDoubleClickDetected = doubleClick3DMonitor = false;

			if (!CameraManager.hasMoved && !currentGizmo.hasMoved && active)
			{
				var selectedObject:ObjectContainer3D = e.target as ObjectContainer3D;

				if (selectedObject.parent is ContainerGizmo3D) {
					return;
				} else if (selectedObject.parent is LightGizmo3D){ 
					return;
				} else if (selectedObject.parent is TextureProjectorGizmo3D) { 
					return;
				} else if (selectedObject.parent is CameraGizmo3D) { 
					return;
				} else {
					var isMesh:Mesh = selectedObject as Mesh;
					if (isMesh) {
						var container:ObjectContainer3D = getCurrentContainerChild(selectedObject);
						if (container) {
							containerBreadCrumbs.push([container.name, container]);

							currentContainer = container;
							
							instance.dispatchEvent(new Scene3DManagerEvent(Scene3DManagerEvent.UPDATE_BREADCRUMBS));
						}				
					}
				}
			}
		}

		private function getContainer(o : ObjectContainer3D) : ObjectContainer3D {
			if (o)
				if ((currentContainer && currentContainer == o.parent) ||
				    (!currentContainer && scene.contains(o))) return o;
				else return getContainer(o.parent);
			return null;
		}
		
		private function getCurrentContainerChild(o : ObjectContainer3D) : ObjectContainer3D {
			if (o)
				if ((currentContainer && currentContainer.contains(o.parent)) ||
				    (!currentContainer && scene.contains(o.parent))) return o.parent;
				else return getCurrentContainerChild(o.parent);
			return null;
		}
		

		private function toggleMeshBounds(o : ObjectContainer3D) : Mesh {
			var m:Mesh = o as Mesh;	
			if (m) return m;

			var container:ObjectContainer3D;
			for (var c:int = 0; c<o.numChildren; c++) {
				container = o.getChildAt(c) as ObjectContainer3D;
				return toggleMeshBounds(container);
			}
			
			return m;
		}

		public static function resetCurrentContainer(oC:ObjectContainer3D) : void {
			if (!oC) { 
				currentContainer = null;
				containerBreadCrumbs = new Array();
			} else {
				var lastContainer:int = containerBreadCrumbs.length-1;
				while (lastContainer>0 && containerBreadCrumbs[lastContainer][1] != oC) {
					containerBreadCrumbs.pop();
					lastContainer--;
				}
				if (containerBreadCrumbs.length == 0) currentContainer = null;
				else currentContainer = containerBreadCrumbs[lastContainer][1];
			}
			
			unselectAll();
					
			instance.dispatchEvent(new Scene3DManagerEvent(Scene3DManagerEvent.UPDATE_BREADCRUMBS));
		}
		
		public static function unselectAll():Boolean
		{
			instance.dispatchEvent(new Scene3DManagerEvent(Scene3DManagerEvent.ENABLE_TRANSFORM_MODES));

			lensSelected = null;
			
			var itemsDeselected:Boolean = false;
			for(var i:int=0;i<selectedObjects.length;i++)
			{
				var oC:ObjectContainer3D = selectedObjects[i];
				var m:Entity = oC as Entity;
				var g:ISceneRepresentation = oC as ISceneRepresentation;
				if (m && !g) g = m.parent as ISceneRepresentation;
				if (g) (g.representation as Mesh).showBounds = false;
				else if (m && m.numChildren < 2 && m.getChildAt(0) is WireframePrimitiveBase) m.showBounds = false;
				else {
					var bounds:ObjectContainerBounds;
					for (var c:int = 0; c<oC.numChildren; c++)
						bounds ||= (oC.getChildAt(c) as ObjectContainerBounds);
					
					if (bounds) {
						oC.removeChild(bounds);
						bounds.dispose();
					}
				}
				itemsDeselected = true;
			}
			
			selectedObjects = new Vector.<ObjectContainer3D>();
			selectedObject = null;
			currentGizmo.hide();
			return itemsDeselected;
		}
		
		private static function deselectAndDispatch():void
		{
			if (unselectAll()) instance.dispatchEvent(new Scene3DManagerEvent(Scene3DManagerEvent.MESH_SELECTED));
		}
		
		public static function unSelectObjectByName( name:String ):void
		{
			for each( var o:ObjectContainer3D in selectedObjects )
			{
				if (o.name == name)
				{
					if (o is Mesh) Mesh(o).showBounds = false;			
					selectedObject = selectedObjects[selectedObjects.length-1];
					break;
				}
			}
			instance.dispatchEvent(new Scene3DManagerEvent(Scene3DManagerEvent.MESH_SELECTED));
		}		
		
		public static function selectObject(oC:ObjectContainer3D):void 
		{			
			if (!multiSelection) unselectAll();
			
			var lG:LightGizmo3D;
			var tPG:TextureProjectorGizmo3D;
			var cG:CameraGizmo3D;
			var oCG:ContainerGizmo3D;

			// If its a scene representation object, use the representations name
			if (oC is ISceneRepresentation) {
				lG = oC as LightGizmo3D;
				tPG = oC as TextureProjectorGizmo3D;
				cG = oC as CameraGizmo3D;

				var ev : String;
				if (lG) ev = (lG.type == LightGizmo3D.DIRECTIONAL_LIGHT ? Scene3DManagerEvent.SWITCH_TRANSFORM_ROTATE : Scene3DManagerEvent.SWITCH_TRANSFORM_TRANSLATE);
				else if (tPG || cG) ev = Scene3DManagerEvent.SWITCH_CAMERA_TRANSFORMS;
				else ev = Scene3DManagerEvent.ENABLE_TRANSFORM_MODES;

				addToSelection((oC as ISceneRepresentation).representation, ev);
			} else if (oC && oC.parent is ISceneRepresentation) {
				// If light selected from view, select it
				for each (lG in lightGizmos) {
					if (lG.representation == oC) {
						addToSelection(lG.representation, (lG.type==LightGizmo3D.DIRECTIONAL_LIGHT ? Scene3DManagerEvent.SWITCH_TRANSFORM_ROTATE : Scene3DManagerEvent.SWITCH_TRANSFORM_TRANSLATE));
						return;
					}
				}

				// If textureProjector selected from view, select it
				for each (tPG in textureProjectorGizmos) {
					if (tPG.representation == oC) {
						addToSelection(tPG.representation, Scene3DManagerEvent.SWITCH_CAMERA_TRANSFORMS);
						return;
					}
				}

				// If camera selected from view, select it
				for each (cG in cameraGizmos) {
					if (cG.representation == oC) {
						addToSelection(cG.representation, Scene3DManagerEvent.SWITCH_CAMERA_TRANSFORMS);
						return;
					}
				}

				// If empty objectcontainer3D selected from view, select it
				for each (oCG in containerGizmos) {
					if (oCG.representation == oC) {
						addToSelection(oCG.representation, Scene3DManagerEvent.ENABLE_TRANSFORM_MODES);
						return;
					}
				}
			} else {
				// If mesh selected from view, select it
				var m : Mesh = oC as Mesh;
				if (m && m.numChildren == 0) {
					if (!m.showBounds) {
						addToSelection(m, Scene3DManagerEvent.ENABLE_TRANSFORM_MODES);
						return;
					}
				} else {
					// Select the container as item is not a mesh or is a mesh with oCren
					var bounds : ObjectContainerBounds;
					for (var c : int = 0; c < oC.numChildren; c++)
						bounds ||= (oC.getChildAt(c) as ObjectContainerBounds);

					if (!bounds) bounds = new ObjectContainerBounds(oC);
					else bounds.updateContainerBounds();
					bounds.showBounds = true;

					selectedObjects.push(oC);
					selectedObject = oC;

					currentGizmo.show(selectedObject);
					instance.dispatchEvent(new Scene3DManagerEvent(Scene3DManagerEvent.ENABLE_TRANSFORM_MODES));
				}
			}
		}
		
		private static function addToSelection(m:ObjectContainer3D, eventType:String) : void {
			if (m is Entity) (m as Entity).showBounds = true;
			selectedObjects.push(m);						
			selectedObject = m;

			currentGizmo.show(selectedObject);
			instance.dispatchEvent(new Scene3DManagerEvent(eventType));
		}
		
		public static function zoomDistanceDelta(delta:Number) : void {
			instance.dispatchEvent(new Scene3DManagerEvent(Scene3DManagerEvent.ZOOM_DISTANCE_DELTA, "", null, new Vector3D(delta, 0, 0)));
		}

		public static function zoomToDistance(distance:Number) : void {
			instance.dispatchEvent(new Scene3DManagerEvent(Scene3DManagerEvent.ZOOM_TO_DISTANCE, "", null, new Vector3D(distance, 0, 0)));
		}

		public static function updateTextureProjectorBitmap(projector : TextureProjector, bitmap:BitmapData) : void {
			var tPG:TextureProjectorGizmo3D;
			for each (tPG in textureProjectorGizmos) {
				if (tPG.sceneObject == projector) {
					tPG.projectorBitmap.bitmapData = bitmap;
					tPG.projectorBitmap.invalidateContent();
				}
			}
		}
	}
}