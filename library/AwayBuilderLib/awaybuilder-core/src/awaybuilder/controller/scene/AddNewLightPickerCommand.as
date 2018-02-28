package awaybuilder.controller.scene
{
	import awaybuilder.controller.events.DocumentModelEvent;
	import awaybuilder.controller.history.HistoryCommandBase;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.vo.scene.LightPickerVO;
	import awaybuilder.model.vo.scene.MaterialVO;

	public class AddNewLightPickerCommand extends HistoryCommandBase
	{
		[Inject]
		public var event:SceneEvent;
		
		override public function execute():void
		{
			var material:MaterialVO;
			if( event.items && event.items.length )
			{
				material = event.items[0] as MaterialVO;
			}
			var oldValue:LightPickerVO = event.oldValue as LightPickerVO;
			var newValue:LightPickerVO = event.newValue as LightPickerVO;
			
			if( material && material.lightPicker )
			{
				saveOldValue( event, material.lightPicker.clone() );
			}
			
			
			if( event.isUndoAction )
			{
				document.removeAsset( document.lights, oldValue );
			}
			else 
			{
				document.lights.addItemAt( newValue, 0 );
			}
			
			if( material )
			{
				material.lightPicker = newValue;
			}
			
			commitHistoryEvent( event );
		}
		
		
	}
}