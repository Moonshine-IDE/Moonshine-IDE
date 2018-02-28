package awaybuilder.desktop.controller
{
	import awaybuilder.controller.events.ConcatenateDataOperationEvent;
	import awaybuilder.controller.events.DocumentEvent;
	import awaybuilder.controller.events.ReplaceDocumentDataEvent;
	import awaybuilder.desktop.controller.events.OpenFromInvokeEvent;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.model.IDocumentService;
	import awaybuilder.view.components.popup.ImportWarningPopup;
	
	import flash.events.Event;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import org.robotlegs.mvcs.Command;
	
	public class OpenFromInvokeCommand extends Command
	{
		[Inject]
		public var document:DocumentModel;
		
		[Inject]
		public var documentService:IDocumentService;
		
		[Inject]
		public var event:OpenFromInvokeEvent;
		
		override public function execute():void
		{
			if( document.empty ) 
			{
				//var nextEvent:ConcatenateDataOperationEvent = new ConcatenateDataOperationEvent(ConcatenateDataOperationEvent.CONCAT_DOCUMENT_DATA );
				var nextEvent:ReplaceDocumentDataEvent = new ReplaceDocumentDataEvent(ReplaceDocumentDataEvent.REPLACE_DOCUMENT_DATA );
				documentService.load( event.file.url, event.file.name, nextEvent);
				return;
			}
				
			var popup:ImportWarningPopup = ImportWarningPopup.show( popup_closeHandler );
		}
		
		private function popup_closeHandler( e:CloseEvent ):void 
		{
			var nextEvent:Event;
			
			switch( e.detail )
			{
				case Alert.YES:
					nextEvent = new ConcatenateDataOperationEvent(ConcatenateDataOperationEvent.CONCAT_DOCUMENT_DATA );
					documentService.load( event.file.url, event.file.name, nextEvent);
					break;
				case Alert.NO:
					this.dispatch(new DocumentEvent(DocumentEvent.NEW_DOCUMENT));
					nextEvent = new ReplaceDocumentDataEvent(ReplaceDocumentDataEvent.REPLACE_DOCUMENT_DATA );
					documentService.load( event.file.url, event.file.name, nextEvent);
					break;
			}
		}
	}
}