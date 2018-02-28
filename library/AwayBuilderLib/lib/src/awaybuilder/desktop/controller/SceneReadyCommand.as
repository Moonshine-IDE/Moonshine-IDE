package awaybuilder.desktop.controller
{
	import awaybuilder.controller.events.SceneReadyEvent;
	
	import flash.events.Event;
	import flash.system.Capabilities;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.ResizeEvent;
	
	import org.robotlegs.mvcs.Command;

	public class SceneReadyCommand extends Command
	{
		[Inject]
		public var event:SceneReadyEvent;
		
		private var _app:AwayBuilderApplication;
		
		private var _alpha:Number = 1;
		
		override public function execute():void
		{
			/*_app = FlexGlobals.topLevelApplication as AwayBuilderApplication;
			_app.addEventListener(Event.ENTER_FRAME, enterFrameHandler );
			_app.splashScreen.alwaysInFront = true;*/
		}
		private function enterFrameHandler( event:Event ):void
		{
			if( _alpha <=0 )
			{
				_app.removeEventListener(Event.ENTER_FRAME, enterFrameHandler );
				_app.splashScreen.close();
				return;
			}
			_alpha -= 0.095;
			
			_app.splashScreen.setAlpha(_alpha);
		}
		
	}
}