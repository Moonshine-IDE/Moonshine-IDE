package awaybuilder.controller.scene
{
	import away3d.entities.Mesh;
	import away3d.primitives.SkyBox;
	
	import awaybuilder.controller.events.DocumentModelEvent;
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.AssetsModel;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.scene.SkyBoxVO;
	import awaybuilder.utils.scene.Scene3DManager;

	public class AddNewSkyBoxCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		[Inject]
		public var assets:AssetsModel;
		
		override public function execute():void
		{
			var oldValue:SkyBoxVO = event.oldValue as SkyBoxVO;
			var newValue:SkyBoxVO = event.newValue as SkyBoxVO;
			
			if( event.isUndoAction )
			{
				document.removeAsset( document.scene, oldValue );
				Scene3DManager.removeSkyBox( assets.GetObject(oldValue) as SkyBox );
			}
			else
			{
				document.scene.addItemAt( newValue, 0 );
				Scene3DManager.addSkybox( assets.GetObject(newValue) as SkyBox );
			}
			
			commitHistoryEvent( event );
		}
		
	}
}