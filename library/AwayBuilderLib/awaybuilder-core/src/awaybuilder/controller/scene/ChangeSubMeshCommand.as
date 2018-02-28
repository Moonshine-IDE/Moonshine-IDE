package awaybuilder.controller.scene
{
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.vo.scene.SubMeshVO;

	public class ChangeSubMeshCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		override public function execute():void
		{
			var newValues:Vector.<SubMeshVO> = getNewValues();
			var oldValues:Vector.<SubMeshVO> = new Vector.<SubMeshVO>();
			
			for( var i:int = 0; i < event.items.length; i++ )
			{
				var asset:SubMeshVO = event.items[i] as SubMeshVO;
				oldValues.push( asset.clone() );
				asset.material = SubMeshVO( newValues[i] ).material;
			}
			saveOldValue( event, oldValues );
			commitHistoryEvent( event );
		}
		
		private function getNewValues():Vector.<SubMeshVO>
		{
			var newValues:Vector.<SubMeshVO> = new Vector.<SubMeshVO>();
			
			if( event.newValue is Vector.<SubMeshVO> )
			{
				for each( var asset:SubMeshVO in event.newValue )
				{
					newValues.push( asset.clone() );
				}
			}
			else
			{
				for( var i:int = 0; i < event.items.length; i++ )
				{
					newValues.push( SubMeshVO(event.newValue).clone() );
				}
			}
			event.newValue = newValues;
			return newValues;
		}
	}
}