package awaybuilder.controller.scene
{
	import awaybuilder.controller.events.DocumentModelEvent;
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.scene.MaterialVO;
	import awaybuilder.model.vo.scene.SubMeshVO;
	
	public class AddNewMaterialCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		override public function execute():void
		{
			var subMesh:SubMeshVO = event.items[0] as SubMeshVO;
			
			var newMaterial:MaterialVO = event.newValue as MaterialVO;
			if( subMesh ) 
			{
				saveOldValue( event, subMesh.material.clone() );
				subMesh.material = newMaterial;
			}
			
			if( event.isUndoAction )
			{
				var oldMaterial:MaterialVO = event.oldValue as MaterialVO;
				for (var j:int = 0; j < document.materials.length; j++) 
				{
					if( document.materials[j].id == oldMaterial.id )
					{
						document.materials.removeItemAt( j );
						break;
					}
				}
			}
			else 
			{
				document.materials.addItemAt( newMaterial, 0 );
			}
			
			commitHistoryEvent( event );
		}
		
	}
}