package awaybuilder.controller.scene
{
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.utils.scene.CameraManager;
	import awaybuilder.utils.scene.modes.CameraMode;
	
	import org.robotlegs.mvcs.Command;

	public class SwitchFreeCameraModeCommand extends Command
	{
		
		[Inject]
		public var event:SceneEvent;
		
		override public function execute():void
		{
			CameraManager.mode = CameraMode.FREE;
		}
	}
}