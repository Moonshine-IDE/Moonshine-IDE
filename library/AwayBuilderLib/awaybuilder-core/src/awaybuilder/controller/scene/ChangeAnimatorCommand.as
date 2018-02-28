package awaybuilder.controller.scene
{
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.scene.AnimatorVO;

	public class ChangeAnimatorCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		override public function execute():void
		{
			var asset:AnimatorVO = event.newValue as AnimatorVO;
			var vo:AnimatorVO = event.items[0] as AnimatorVO;
			
			saveOldValue( event, vo.clone() );
			
			vo.fillFromAnimator( asset );
			
			commitHistoryEvent( event );
		}
	}
}