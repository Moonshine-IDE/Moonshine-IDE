package awaybuilder.controller.scene
{
    import away3d.core.base.Object3D;
    
    import awaybuilder.controller.history.HistoryCommandBase;
    import awaybuilder.controller.scene.events.SceneEvent;
    import awaybuilder.model.DocumentModel;
    import awaybuilder.model.vo.scene.MeshVO;
    import awaybuilder.model.vo.scene.ObjectVO;
    
    import flash.geom.Vector3D;

    public class TranslateCommand extends HistoryCommandBase
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
				oldValues.push( new Vector3D( asset.x, asset.y, asset.z ) );
				asset.x = isNaN(newValues[i].x)?asset.x:newValues[i].x;
				asset.y = isNaN(newValues[i].y)?asset.y:newValues[i].y;
				asset.z = isNaN(newValues[i].z)?asset.z:newValues[i].z;
			}
			
			saveOldValue( event, oldValues );
			commitHistoryEvent( event );
        }
    }
}