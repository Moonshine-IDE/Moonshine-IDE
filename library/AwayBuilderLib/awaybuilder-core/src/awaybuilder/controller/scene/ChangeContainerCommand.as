package awaybuilder.controller.scene
{
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.scene.ContainerVO;
	import awaybuilder.model.vo.scene.ExtraItemVO;
	
	import mx.collections.ArrayCollection;

	public class ChangeContainerCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		override public function execute():void
		{
			var asset:ContainerVO = event.newValue as ContainerVO;
			var vo:ContainerVO = event.items[0] as ContainerVO;
			
			saveOldValue( event, vo.clone() );
			
			vo.fillFromContainer( asset );
			
			var e:Array = new Array();
			for each( var extra:ExtraItemVO in asset.extras )
			{
				e.push(extra.clone());
			}
			vo.extras = new ArrayCollection( e );
			
			commitHistoryEvent( event );
		}
	}
}