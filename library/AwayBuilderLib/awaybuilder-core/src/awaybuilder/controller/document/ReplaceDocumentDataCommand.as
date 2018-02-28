package awaybuilder.controller.document
{
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.TextureProjector;
	import away3d.lights.LightBase;
	import away3d.primitives.SkyBox;
	
	import awaybuilder.controller.events.ConcatenateDataOperationEvent;
	import awaybuilder.controller.events.DocumentModelEvent;
	import awaybuilder.controller.events.ReplaceDocumentDataEvent;
	import awaybuilder.model.AssetsModel;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.DocumentVO;
	import awaybuilder.model.vo.scene.AssetVO;
	import awaybuilder.model.vo.scene.CameraVO;
	import awaybuilder.model.vo.scene.ContainerVO;
	import awaybuilder.model.vo.scene.LightVO;
	import awaybuilder.model.vo.scene.SkyBoxVO;
	import awaybuilder.model.vo.scene.TextureProjectorVO;
	import awaybuilder.utils.scene.CameraManager;
	import awaybuilder.utils.scene.Scene3DManager;
	
	import flash.display.DisplayObject;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.managers.CursorManager;
	
	import org.robotlegs.mvcs.Command;
	
	import spark.components.Application;

	public class ReplaceDocumentDataCommand extends Command
	{
		
		[Inject]
		public var document:DocumentModel;
		
		[Inject]
		public var assets:AssetsModel;
		
		[Inject]
		public var event:ReplaceDocumentDataEvent;
		
		private var _sceneObjects:Array;
		
		override public function execute():void
		{
			var data:DocumentVO = event.value;
			
			addObjects( data.scene.source.concat() );
			addLights( data.lights.source.concat() );
			
			document.fill( data );
			
			document.globalOptions.fill( event.globalOptions );
			
			document.empty = false;
			document.name = event.fileName;
			document.path = event.path;
			
			CursorManager.setBusyCursor();
			Application(FlexGlobals.topLevelApplication).mouseEnabled = false;
			
			this.dispatch(new DocumentModelEvent(DocumentModelEvent.OBJECTS_UPDATED));
			this.dispatch(new DocumentModelEvent(DocumentModelEvent.OBJECTS_FILLED));
		}
		
		private function addLights( objects:Array ):void 
		{
			for (var i:int = 0; i < objects.length; i++) 
			{
				addLight( objects.shift() );
				i--;
			}
		}
		private function addObjects( objects:Array ):void 
		{
			_sceneObjects = objects.concat();
			DisplayObject(FlexGlobals.topLevelApplication).addEventListener( Event.ENTER_FRAME, addNextObject_enterFrameHandler );
		}
		private function addNextObject_enterFrameHandler( event:Event ):void 
		{
			if( _sceneObjects.length == 0 )
			{
				CursorManager.removeBusyCursor();			
				DisplayObject(FlexGlobals.topLevelApplication).removeEventListener( Event.ENTER_FRAME, addNextObject_enterFrameHandler );
				
				Application(FlexGlobals.topLevelApplication).mouseEnabled = true;
				CameraManager.focusTarget();
				
				return;
			}
			for (var i:int = 0; i < 10; i++) 
			{
				addObject( _sceneObjects.shift() );
			}
			
		}
		private function addObject( value:Object ):void
		{
			var o:ContainerVO = value as ContainerVO;
			if( o ) 
			{
				Scene3DManager.addObject( assets.GetObject(o) as ObjectContainer3D );
			}
			var skyBox:SkyBoxVO = value as SkyBoxVO;
			if( skyBox ) 
			{
				Scene3DManager.addSkybox( assets.GetObject(skyBox) as SkyBox );
			}
			var cameraVO:CameraVO = value as CameraVO;
			if( cameraVO ) 
			{
				Scene3DManager.addCamera( assets.GetObject(cameraVO) as Camera3D );
			}
			var textureProjectorVO:TextureProjectorVO = value as TextureProjectorVO;
			if( textureProjectorVO ) 
			{
				Scene3DManager.addTextureProjector( assets.GetObject(textureProjectorVO) as TextureProjector, textureProjectorVO.texture.bitmapData );
			}
		}
		private function addLight( value:Object ):void
		{
			var light:LightVO = value as LightVO;
			if( light ) 
			{
				Scene3DManager.addLight( assets.GetObject(light) as LightBase );
			}
		}
	}
}