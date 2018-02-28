package awaybuilder.controller.scene
{
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.vo.scene.SkeletonVO;

	public class ChangeSkeletonCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		override public function execute():void
		{
			var asset:SkeletonVO = event.newValue as SkeletonVO;
			var vo:SkeletonVO = event.items[0] as SkeletonVO;
			
			saveOldValue( event, vo.clone() );
			
			vo.fillFromSkeleton( asset );
			
			commitHistoryEvent( event );
		}
	}
}