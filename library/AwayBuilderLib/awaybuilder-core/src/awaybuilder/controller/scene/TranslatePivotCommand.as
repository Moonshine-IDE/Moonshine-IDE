package awaybuilder.controller.scene
{
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.vo.scene.ObjectVO;
	
	import flash.geom.Vector3D;

	public class TranslatePivotCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		override public function execute():void
		{
			var newValues:Vector.<Vector3D> = event.newValue as Vector.<Vector3D>;
			var oldValues:Vector.<Vector3D> = new Vector.<Vector3D>();
			
			for( var i:int = 0; i < event.items.length; i++ )
			{
				var asset:ObjectVO = event.items[i] as ObjectVO;
				oldValues.push( new Vector3D( asset.pivotX, asset.pivotY, asset.pivotZ ) );
				asset.pivotX = isNaN(newValues[i].x)?asset.pivotX:newValues[i].x;
				asset.pivotY = isNaN(newValues[i].y)?asset.pivotY:newValues[i].y;
				asset.pivotZ = isNaN(newValues[i].z)?asset.pivotZ:newValues[i].z;
			}
			
			saveOldValue( event, oldValues );
			commitHistoryEvent( event );
		}
	}
}