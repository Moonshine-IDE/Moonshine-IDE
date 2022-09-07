package actionScripts.utils
{
	import actionScripts.events.StatusBarEvent;
	import actionScripts.plugins.build.ConsoleBuildPluginBase;
	import actionScripts.valueObjects.ConstantsCoreVO;

	import flash.events.Event;

	import flash.events.IOErrorEvent;

	import flash.events.NativeProcessExitEvent;

	import flash.filesystem.File;

	import spark.components.Alert;

	public class ZipUsingNP extends ConsoleBuildPluginBase
	{
		public static const EVENT_ZIP_COMPLETES:String = "eventZipProcessCompletes";
		public static const EVENT_ZIP_FAILED:String = "eventZipProcessFailed";

		private var _errorText:String;
		public function get errorText():String
		{
			return _errorText;
		}

		public function ZipUsingNP()
		{
			super();
			activate();
		}

		public function zip(source:File, destination:File):void
		{
			if (running)
			{
				Alert.show("A zip process is already running.", "Error!");
				return;
			}

			_errorText = null;
			var command:String;
			if (ConstantsCoreVO.IS_MACOS)
			{
				if (source.isDirectory)
				{
					command = 'cd "'+ source.nativePath +'";zip -r "'+ destination.nativePath +'" *';
				}
				else
				{
					command = 'zip "'+ destination.nativePath +'" "'+ source.nativePath +'"';
				}
			}
			else
			{
				var powerShellPath:String = UtilsCore.getPowerShellExecutablePath();
				if (powerShellPath)
				{
					if (source.isDirectory)
					{
						command = '"'+ powerShellPath +'" Compress-Archive "'+ source.nativePath +'/* "'+ destination.nativePath +'"';
					}
					else
					{
						command = '"'+ powerShellPath +'" Compress-Archive "'+ source.nativePath +' "'+ destination.nativePath +'"';
					}
				}
				else
				{
					error("Failed to locate PowerShell during execution.");
					return;
				}
			}

			//warning("%s", command);
			this.start(
					new <String>[command]
			);
		}

		override protected function onNativeProcessIOError(event:IOErrorEvent):void
		{
			_errorText = event.text;
			dispatchEvent(new Event(EVENT_ZIP_FAILED));
		}

		override protected function onNativeProcessExit(event:NativeProcessExitEvent):void
		{
			super.onNativeProcessExit(event);
			if (!_errorText)
			{
				dispatchEvent(new Event(EVENT_ZIP_COMPLETES));
			}
		}
	}
}
