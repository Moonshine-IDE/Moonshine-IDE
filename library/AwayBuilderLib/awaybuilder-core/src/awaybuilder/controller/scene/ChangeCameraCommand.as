package awaybuilder.controller.scene
{
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.AssetsModel;
	import awaybuilder.model.vo.scene.CameraVO;

	public class ChangeCameraCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		[Inject]
		public var assets:AssetsModel;
		
		override public function execute():void
		{
			var newAsset:CameraVO = event.newValue as CameraVO;
			var vo:CameraVO = event.items[0] as CameraVO;
			
			saveOldValue( event, vo.clone() );
			vo.fillFromCamera(newAsset);
			
			commitHistoryEvent( event );
		}
	}
}