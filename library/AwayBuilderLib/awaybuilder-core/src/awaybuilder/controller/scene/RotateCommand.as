package awaybuilder.controller.scene
{
    import awaybuilder.model.vo.scene.LightVO;
    import awaybuilder.controller.history.HistoryCommandBase;
    import awaybuilder.controller.scene.events.SceneEvent;
    import awaybuilder.model.DocumentModel;
    import awaybuilder.model.vo.scene.MeshVO;
    import awaybuilder.model.vo.scene.ObjectVO;
    
    import flash.geom.Vector3D;

    public class RotateCommand extends HistoryCommandBase
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
				oldValues.push( new Vector3D( asset.rotationX, asset.rotationY, asset.rotationZ ) );
				asset.rotationX = isNaN(newValues[i].x)?asset.rotationX:newValues[i].x;
				asset.rotationY = isNaN(newValues[i].y)?asset.rotationY:newValues[i].y;
				asset.rotationZ = isNaN(newValues[i].z)?asset.rotationZ:newValues[i].z;
				
				var lightVO:LightVO = asset as LightVO;
				if (lightVO && lightVO.type == LightVO.DIRECTIONAL) 
				{
					lightVO.elevationAngle = ((asset.rotationX + 360 + 90) % 360) - 90;
					lightVO.azimuthAngle = (asset.rotationY + 360) % 360;
				} 
			}
			
			saveOldValue( event, oldValues );
			commitHistoryEvent( event );
        }
    }
}