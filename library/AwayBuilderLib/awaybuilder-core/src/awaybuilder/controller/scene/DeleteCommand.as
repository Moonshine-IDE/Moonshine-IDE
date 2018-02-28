package awaybuilder.controller.scene
{
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.entities.Mesh;
	import away3d.entities.TextureProjector;
	import away3d.lights.LightBase;
	import away3d.materials.MaterialBase;
	import away3d.primitives.SkyBox;
	
	import awaybuilder.controller.events.DocumentModelEvent;
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.AssetsModel;
	import awaybuilder.model.vo.DeleteStateVO;
	import awaybuilder.model.vo.scene.AssetVO;
	import awaybuilder.model.vo.scene.CameraVO;
	import awaybuilder.model.vo.scene.ContainerVO;
	import awaybuilder.model.vo.scene.EffectVO;
	import awaybuilder.model.vo.scene.LightPickerVO;
	import awaybuilder.model.vo.scene.LightVO;
	import awaybuilder.model.vo.scene.MaterialVO;
	import awaybuilder.model.vo.scene.MeshVO;
	import awaybuilder.model.vo.scene.ObjectVO;
	import awaybuilder.model.vo.scene.ShadowMethodVO;
	import awaybuilder.model.vo.scene.SharedEffectVO;
	import awaybuilder.model.vo.scene.SkyBoxVO;
	import awaybuilder.model.vo.scene.SubMeshVO;
	import awaybuilder.model.vo.scene.TextureProjectorVO;
	import awaybuilder.utils.scene.Scene3DManager;
	
	import mx.collections.ArrayCollection;

	public class DeleteCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		[Inject]
		public var assets:AssetsModel;
		
		override public function execute():void
		{
			if( event.isUndoAction )
			{
				undo( event.oldValue as Vector.<DeleteStateVO> ); 
				return;
			}
			
			for each( var state:DeleteStateVO in event.newValue as Vector.<DeleteStateVO> ) {
				if( state.owner )
				{
					removeItemFromHolder( state.owner, state.asset );
				}
				else
				{
					var obj:ObjectVO = state.asset as ObjectVO;
					if( obj )
					{
						removeObjectFromScene( obj );
					}
					var library:ArrayCollection = document.getLibraryByAsset(state.asset);
					removeAsset( library, state.asset );
					
					var light:LightVO = state.asset as LightVO;
					if( light ) 
					{
						removeAsset( document.lights, state.asset );
					}
					
				}
			}
			
			commitHistoryEvent( event );
		}
		
		private function undo( states:Vector.<DeleteStateVO> ):void
		{
			for each( var state:DeleteStateVO in states ) {
				if( state.owner )
				{
					addItemToHolder( state.owner, state.asset );
				}
				else
				{
					
					var obj:ObjectVO = state.asset as ObjectVO;
					if( obj )
					{
						addObjectToScene( obj );
					}
					var library:ArrayCollection = document.getLibraryByAsset(state.asset);
					library.addItemAt( state.asset, state.index );
					
					var light:LightVO = state.asset as LightVO;
					if( light ) 
					{
						document.lights.addItemAt( state.asset, state.index );
					}
				}
			}
			
			commitHistoryEvent( event );
		}
		
		private function removeItemFromHolder( holder:AssetVO, asset:AssetVO ):void
		{
			var container:ContainerVO = holder as ContainerVO;
			if( container )
			{
				removeAsset( container.children, asset );
				var obj:ObjectContainer3D = assets.GetObject( container ) as ObjectContainer3D;
				obj.removeChild( assets.GetObject( asset ) as ObjectContainer3D );
			}
			var lightVO:LightVO = holder as LightVO;
			if( lightVO )
			{
				removeAsset( lightVO.shadowMethods, asset );
				
			}
			var lightPickerVO:LightPickerVO = holder as LightPickerVO;
			if( lightPickerVO )
			{
				removeAsset( lightPickerVO.lights, asset );
			}
			var materialVO:MaterialVO = holder as MaterialVO;
			if( materialVO )
			{
				if( asset is LightPickerVO )
				{
					materialVO.lightPicker = null;
				}
				else if( asset is LightVO )
				{
					materialVO.light = null;
				}
				else if( asset is ShadowMethodVO )
				{
					materialVO.shadowMethod = null;
				}
				else if( asset is EffectVO )
				{
					removeAsset( materialVO.effectMethods, asset );
				}
			}
		}
		
		private function addItemToHolder( holder:AssetVO, asset:AssetVO, index:uint = 0 ):void
		{
			var container:ContainerVO = holder as ContainerVO;
			if( container )
			{
				container.children.addItemAt( asset, index );
				var obj:ObjectContainer3D = assets.GetObject( container ) as ObjectContainer3D;
				obj.addChild( assets.GetObject( asset ) as ObjectContainer3D );
			}
			var lightVO:LightVO = holder as LightVO;
			if( lightVO )
			{
				lightVO.shadowMethods.addItemAt( asset, index );
			}
			var lightPickerVO:LightPickerVO = holder as LightPickerVO;
			if( lightPickerVO )
			{
				lightPickerVO.lights.addItemAt( asset, index );
			}
			var materialVO:MaterialVO = holder as MaterialVO;
			if( materialVO )
			{
				if( asset is LightPickerVO )
				{
					materialVO.lightPicker = asset as LightPickerVO;
				}
				if( asset is LightVO )
				{
					materialVO.light = asset as LightVO;
				}
				else if( asset is ShadowMethodVO )
				{
					materialVO.shadowMethod = asset as ShadowMethodVO;
				}
				else if( asset is EffectVO )
				{
					materialVO.effectMethods.addItemAt( new SharedEffectVO(asset as EffectVO), index );
				}
			}
		}
		
		public function removeAsset( source:ArrayCollection, oddItem:AssetVO ):void
		{
			for (var i:int = 0; i < source.length; i++) 
			{
				if( source[i].id == oddItem.id )
				{
					source.removeItemAt( i );
					i--;
				}
			}
		}
		
		private function addObjectToScene( asset:ObjectVO ):void
		{
			if( asset is MeshVO ) 
			{
				
				this.dispatch(new DocumentModelEvent(DocumentModelEvent.VALIDATE_OBJECT, asset));
				var mesh:Mesh =  assets.GetObject(asset) as Mesh;
				Scene3DManager.addObject( mesh );
			}
			else if( asset is TextureProjectorVO ) 
			{
				Scene3DManager.addTextureProjector( assets.GetObject(asset) as TextureProjector );
			}
			else if( asset is ContainerVO ) 
			{
				Scene3DManager.addObject( assets.GetObject(asset) as ObjectContainer3D );
			}
			else if( asset is LightVO ) 
			{
				Scene3DManager.addLight( assets.GetObject(asset) as LightBase );
			}
			else if( asset is SkyBoxVO ) 
			{
				Scene3DManager.addSkybox( assets.GetObject(asset) as SkyBox );
			}
			else if( asset is CameraVO ) 
			{
				Scene3DManager.addCamera( assets.GetObject(asset) as Camera3D );
			}
		}
		
		private function removeObjectFromScene( asset:ObjectVO ):void
		{
			if( asset is MeshVO ) 
			{
				Scene3DManager.removeMesh( assets.GetObject(asset) as Mesh );
			}
			else if( asset is TextureProjectorVO ) 
			{
				Scene3DManager.removeTextureProjector( assets.GetObject(asset) as TextureProjector );
			}
			else if( asset is ContainerVO ) 
			{
				Scene3DManager.removeContainer( assets.GetObject(asset) as ObjectContainer3D );
			}
			else if( asset is LightVO ) 
			{
				try 
				{
					Scene3DManager.removeLight( assets.GetObject(asset) as LightBase );
				}
				catch ( e:Error )
				{
					trace( e.message );
				}
			}
			else if( asset is SkyBoxVO ) 
			{
				Scene3DManager.removeSkyBox( assets.GetObject(asset) as SkyBox );
			}
			else if( asset is CameraVO ) 
			{
				Scene3DManager.removeCamera( assets.GetObject(asset) as Camera3D );
			}

		}
		
	}
}