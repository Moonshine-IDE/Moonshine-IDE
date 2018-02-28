package awaybuilder.utils.logging
{
	import mx.logging.ILogger;
	import mx.logging.Log;

	public class AwayBuilderLoadErrorLogger {
		private static var _logger:ILogger = Log.getLogger("awaybuildererrorlogger");
		
		public static function clearLog() : void {
			initLogger();
		}

		public static function logError(message:String, data:* = null):void {
			target.dataItem = data;
			_logger.warn(message);
		}

		public static function get log() : Vector.<String> {
			return target.log;
		}

		public static function getData(message:String):* {
			return target.getData(message);
		}
		
		private static function initLogger() : void {
			target.clearLog();
		}
	}
}

import awaybuilder.utils.logging.targets.ErrorLogTarget;
import mx.logging.Log;
import mx.logging.LogEventLevel;

var target:ErrorLogTarget = new ErrorLogTarget();
target.level = LogEventLevel.ALL;
Log.addTarget(target);