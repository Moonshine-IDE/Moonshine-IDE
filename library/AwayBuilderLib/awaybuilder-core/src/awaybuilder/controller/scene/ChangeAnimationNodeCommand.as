package awaybuilder.controller.scene
{
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.vo.scene.AnimationNodeVO;

	public class ChangeAnimationNodeCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		override public function execute():void
		{
			var asset:AnimationNodeVO = event.newValue as AnimationNodeVO;
			var vo:AnimationNodeVO = event.items[0] as AnimationNodeVO;
			
			saveOldValue( event, vo.clone() );
			
			vo.fillFromAnimationNode( asset );
			
			commitHistoryEvent( event );
		}
	}
}