package awaybuilder.controller.scene
{
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.vo.scene.EffectVO;

	public class ChangeEffectMethodCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		override public function execute():void
		{
			var newAsset:EffectVO = event.newValue as EffectVO;
			
			var vo:EffectVO = event.items[0] as EffectVO;
			
			saveOldValue( event, vo.clone() );
			
			vo.fillFromEffectMethod( newAsset );
			
			commitHistoryEvent( event );
		}
	}
}