    package awaybuilder.controller.scene {
    import awaybuilder.controller.history.HistoryCommandBase;
    import awaybuilder.controller.scene.events.SceneEvent;
    import awaybuilder.model.DocumentModel;
    import awaybuilder.model.vo.scene.MeshVO;
    import awaybuilder.model.vo.scene.ObjectVO;
    
    import flash.geom.Vector3D;

    public class ScaleCommand extends HistoryCommandBase
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
				oldValues.push( new Vector3D( asset.scaleX, asset.scaleY, asset.scaleZ ) );
				asset.scaleX = isNaN(newValues[i].x)?asset.scaleX:newValues[i].x;
				asset.scaleY = isNaN(newValues[i].y)?asset.scaleY:newValues[i].y;
				asset.scaleZ = isNaN(newValues[i].z)?asset.scaleZ:newValues[i].z;
			}
			
			saveOldValue( event, oldValues );
			commitHistoryEvent( event );
        }
    }
}