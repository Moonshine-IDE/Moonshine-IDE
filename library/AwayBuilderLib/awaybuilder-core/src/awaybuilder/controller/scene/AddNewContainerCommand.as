package awaybuilder.controller.scene
{
	import away3d.containers.ObjectContainer3D;
	
	import awaybuilder.controller.events.DocumentModelEvent;
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.AssetsModel;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.scene.AssetVO;
	import awaybuilder.model.vo.scene.ContainerVO;
	import awaybuilder.model.vo.scene.MeshVO;
	import awaybuilder.utils.scene.Scene3DManager;
	
	import mx.collections.ArrayCollection;

	public class AddNewContainerCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		[Inject]
		public var assets:AssetsModel;
		
		override public function execute():void
		{
			var oldValue:ContainerVO = event.oldValue as ContainerVO;
			var newValue:ContainerVO = event.newValue as ContainerVO;
			
			if( event.isUndoAction )
			{
				document.removeAsset( document.scene, oldValue );
				Scene3DManager.removeContainer( assets.GetObject(oldValue) as ObjectContainer3D );
			}
			else 
			{
				document.scene.addItemAt( newValue, 0 );
				Scene3DManager.addObject( assets.GetObject(newValue) as ObjectContainer3D );
			}
			
			commitHistoryEvent( event );
		}
		
	}
}