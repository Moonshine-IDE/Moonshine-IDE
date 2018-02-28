package awaybuilder.controller.clipboard
{
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.core.base.Object3D;
	import away3d.entities.Mesh;
	
	import awaybuilder.controller.clipboard.events.PasteEvent;
	import awaybuilder.controller.events.DocumentModelEvent;
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.AssetsModel;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.DocumentVO;
	import awaybuilder.model.vo.scene.AssetVO;
	import awaybuilder.model.vo.scene.CameraVO;
	import awaybuilder.model.vo.scene.ContainerVO;
	import awaybuilder.model.vo.scene.ExtraItemVO;
	import awaybuilder.model.vo.scene.GeometryVO;
	import awaybuilder.model.vo.scene.LightVO;
	import awaybuilder.model.vo.scene.MeshVO;
	import awaybuilder.model.vo.scene.ObjectVO;
	import awaybuilder.model.vo.scene.SkyBoxVO;
	import awaybuilder.model.vo.scene.TextureVO;
	import awaybuilder.utils.AssetUtil;
	import awaybuilder.utils.scene.Scene3DManager;
	
	import mx.collections.ArrayCollection;
	
	import org.robotlegs.mvcs.Command;
	
	public class PasteCommand extends Command
	{
		[Inject]
		public var event:PasteEvent;
		
		[Inject]
		public var document:DocumentModel;
		
		[Inject]
		public var assets:AssetsModel;
		
		override public function execute():void
		{
			for each( var copy:AssetVO in document.copiedAssets ) 
			{
				var newAsset:AssetVO;
				var newId:String;
				switch( true )
				{
					case( copy is SkyBoxVO ):
						break;
					case( copy is CameraVO ):
						break;
					case( copy is SkyBoxVO ):
						break;
					case( copy is LightVO ):
						break;
					case( copy is MeshVO ):
						newAsset = createMesh( copy as MeshVO );
						dispatch( new SceneEvent( SceneEvent.ADD_NEW_MESH, [], newAsset ) );
						break;
					case( copy is ContainerVO ):
						newAsset = createContainer( copy as ContainerVO );
						dispatch( new SceneEvent( SceneEvent.ADD_NEW_CONTAINER, [], newAsset ) );
						break;
				}
			}
		}
		private function createMesh( copy:MeshVO, parent:ContainerVO=null ):MeshVO
		{
			var geometry:Geometry = assets.GetObject( MeshVO(copy).geometry ) as Geometry;
			var newAsset:MeshVO = assets.CreateMesh( MeshVO(copy).geometry );
			var newObject:Object3D = assets.GetObject( newAsset ) as Object3D;
			if( parent )
			{
				var newParentObject:ObjectContainer3D = assets.GetObject( parent ) as ObjectContainer3D;
				newParentObject.addChild( newObject as ObjectContainer3D );
			}
			newAsset.fillFromMesh( MeshVO(copy) );
			newAsset.children = createChildren( copy, newAsset );
			newAsset.name += " copy";
			return newAsset;
		}
		private function createContainer( copy:ContainerVO, parent:ContainerVO=null ):ContainerVO
		{
			var newAsset:ContainerVO = assets.CreateContainer();
			var newObject:Object3D = assets.GetObject( newAsset ) as Object3D;
			if( parent )
			{
				var newParentObject:ObjectContainer3D = assets.GetObject( parent ) as ObjectContainer3D;
				newParentObject.addChild( newObject as ObjectContainer3D );
			}
			newAsset.fillFromContainer( ContainerVO(copy) );
			newAsset.children = createChildren( copy, newAsset );
			newAsset.name += " copy";
			return newAsset;
		}
		private function createChildren( copy:ObjectVO, newParent:ContainerVO ):ArrayCollection
		{
			if( copy is ContainerVO )
			{
				var children:Array = [];
				var newAsset:AssetVO;
				for each( var asset:ObjectVO in ContainerVO(copy).children )
				{
					switch( true )
					{
						case( asset is SkyBoxVO ):
							break;
						case( asset is CameraVO ):
							break;
						case( asset is SkyBoxVO ):
							break;
						case( asset is LightVO ):
							break;
						case( asset is MeshVO ):
							newAsset = createMesh( asset as MeshVO, newParent );
							break;
						case( asset is ContainerVO ):
							newAsset = createContainer( asset as ContainerVO, newParent );
							break;
					}
					if( newAsset )
					{
						children.push( newAsset );
					}
				}
				return new ArrayCollection( children );
			}
			
			return null;
		}
		
		
	}
}