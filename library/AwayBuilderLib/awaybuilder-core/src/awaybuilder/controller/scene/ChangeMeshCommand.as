package awaybuilder.controller.scene
{
    import away3d.core.base.SubMesh;
    import away3d.entities.Mesh;
    import away3d.library.AssetLibrary;
    import away3d.materials.MaterialBase;
    
    import awaybuilder.controller.history.HistoryCommandBase;
    import awaybuilder.controller.scene.events.SceneEvent;
    import awaybuilder.model.DocumentModel;
    import awaybuilder.model.vo.scene.ExtraItemVO;
    import awaybuilder.model.vo.scene.MaterialVO;
    import awaybuilder.model.vo.scene.MeshVO;
    import awaybuilder.model.vo.scene.SubMeshVO;
    import awaybuilder.utils.AssetUtil;
    
    import mx.collections.ArrayCollection;

    public class ChangeMeshCommand extends HistoryCommandBase
    {
        [Inject]
        public var event:SceneEvent;

        override public function execute():void
        {
			var newValues:Vector.<MeshVO> = getNewValues();
			var oldValues:Vector.<MeshVO> = new Vector.<MeshVO>();
			
			for( var i:int = 0; i < event.items.length; i++ )
			{
				var asset:MeshVO = event.items[i] as MeshVO;
				oldValues.push( asset.clone() );
				asset.fillFromMesh( newValues[i] as MeshVO );
				
				var e:Array = new Array();
				for each( var extra:ExtraItemVO in MeshVO(newValues[i]).extras )
				{
					e.push( extra.clone() );
				}
				asset.extras = new ArrayCollection( e );
			}
			
			saveOldValue( event, oldValues );
			commitHistoryEvent( event );
        }
		
		private function getNewValues():Vector.<MeshVO>
		{
			var newValues:Vector.<MeshVO> = new Vector.<MeshVO>();
			
			if( event.newValue is Vector.<MeshVO> )
			{
				for each( var asset:MeshVO in event.newValue )
				{
					newValues.push( asset.clone() );
				}
			}
			else
			{
				for( var i:int = 0; i < event.items.length; i++ )
				{
					newValues.push( MeshVO(event.newValue).clone() );
				}
			}
			event.newValue = newValues;
			return newValues;
		}
    }
}