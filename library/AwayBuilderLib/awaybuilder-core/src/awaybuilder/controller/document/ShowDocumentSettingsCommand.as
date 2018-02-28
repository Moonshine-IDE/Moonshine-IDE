package awaybuilder.controller.document
{
	import awaybuilder.controller.events.SettingsEvent;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.DocumentModel;
	
	import org.robotlegs.mvcs.Command;

	public class ShowDocumentSettingsCommand extends Command
	{
		[Inject]
		public var event:SettingsEvent;
		
		[Inject]
		public var document:DocumentModel;
		
		
		override public function execute():void
		{
			dispatch( new SceneEvent( SceneEvent.SELECT, [] ) );
		}
	}
}