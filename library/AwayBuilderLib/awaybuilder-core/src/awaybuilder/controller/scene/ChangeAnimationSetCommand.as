package awaybuilder.controller.scene
{
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.vo.scene.AnimationSetVO;

	public class ChangeAnimationSetCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		override public function execute():void
		{
			var asset:AnimationSetVO = event.newValue as AnimationSetVO;
			var vo:AnimationSetVO = event.items[0] as AnimationSetVO;
			
			saveOldValue( event, vo.clone() );
			
			vo.fillFromAnimationSet( asset );
			
			commitHistoryEvent( event );
		}
	}
}