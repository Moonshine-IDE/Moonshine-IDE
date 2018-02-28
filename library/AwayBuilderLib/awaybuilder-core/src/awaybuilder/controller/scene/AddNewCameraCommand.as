package awaybuilder.controller.scene
{
	import awaybuilder.model.AssetsModel;
	import away3d.cameras.Camera3D;
	import awaybuilder.utils.scene.Scene3DManager;
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.vo.scene.CameraVO;

	public class AddNewCameraCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		[Inject]
		public var assets:AssetsModel;

		override public function execute():void
		{
			var oldValue:CameraVO = event.oldValue as CameraVO;
			var newValue:CameraVO = event.newValue as CameraVO;
			
			if( event.isUndoAction )
			{
				document.removeAsset( document.scene, oldValue );
				Scene3DManager.removeCamera( assets.GetObject(oldValue) as Camera3D );
			}
			else 
			{
				document.scene.addItemAt( newValue, 0 );
				Scene3DManager.addCamera( assets.GetObject(newValue) as Camera3D );
			}
			
			commitHistoryEvent( event );
		}
		
	}
}