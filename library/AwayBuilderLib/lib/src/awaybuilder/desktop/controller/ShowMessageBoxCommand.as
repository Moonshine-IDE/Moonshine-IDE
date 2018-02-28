package awaybuilder.desktop.controller
{
	import awaybuilder.controller.events.MessageBoxEvent;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.desktop.view.components.MessageBox;
	
	import mx.core.FlexGlobals;
	
	import org.robotlegs.mvcs.Command;
	
	public class ShowMessageBoxCommand extends Command
	{
		
		[Inject]
		public var event:MessageBoxEvent;
		
		override public function execute():void
		{
			//deselect so that the editor window doesn't interfere.
			this.dispatch(new SceneEvent(SceneEvent.SELECT_NONE));
			
			var messageBox:MessageBox = new MessageBox();
			messageBox.title = event.title;
			messageBox.open();
			messageBox.validateNow();
			messageBox.content.message = event.message;
			messageBox.content.okLabel = event.okLabel;
			messageBox.content.okCallback = event.okCallback;
			messageBox.content.cancelLabel = event.cancelLabel;
			messageBox.content.cancelCallback = event.cancelCallback;
			messageBox.validateNow();
			this.mediatorMap.createMediator(messageBox);
			messageBox.width = messageBox.measuredWidth;
			messageBox.height = messageBox.measuredHeight;
			
			var app:AwayBuilderApplication = FlexGlobals.topLevelApplication as AwayBuilderApplication;
			
			/*messageBox.nativeWindow.x = app.nativeWindow.x + (app.nativeWindow.width - messageBox.nativeWindow.width) / 2;
			messageBox.nativeWindow.y = app.nativeWindow.y + (app.nativeWindow.height - messageBox.nativeWindow.height) / 2;*/
		}
	}
}