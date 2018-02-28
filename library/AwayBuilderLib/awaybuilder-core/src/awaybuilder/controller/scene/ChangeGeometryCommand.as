package awaybuilder.controller.scene
{
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.scene.GeometryVO;

	public class ChangeGeometryCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		override public function execute():void
		{
			var newValue:GeometryVO = event.newValue as GeometryVO;
			var vo:GeometryVO = event.items[0] as GeometryVO;
			
			saveOldValue( event, vo.clone() );
			
			vo.fillFromGeometry( newValue );
			
			commitHistoryEvent( event );
		}
	}
}