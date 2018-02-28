package awaybuilder.utils.logging
{
	import mx.logging.ILogger;
	import mx.logging.Log;

	public const AwayBuilderLogger:ILogger = Log.getLogger("awaybuilder");
}
import mx.logging.Log;
import mx.logging.LogEventLevel;
import mx.logging.targets.TraceTarget;

var target:TraceTarget = new TraceTarget();
target.level = LogEventLevel.ALL;
Log.addTarget(target);