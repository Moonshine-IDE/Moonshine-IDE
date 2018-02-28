package awaybuilder.utils.logging.targets {
	import flash.utils.Dictionary;
	import mx.logging.targets.LineFormattedTarget;
	import mx.core.mx_internal;

	use namespace mx_internal;

	public class ErrorLogTarget extends LineFormattedTarget {
		private var _logLines:Vector.<String>;
		private var _data : Dictionary;
		private var _dataItem : *;
		
		public function get log() : Vector.<String> { return _logLines; }

		public function get dataItem() : * { return _dataItem; }
		public function set dataItem(dataItem : *) : void { _dataItem = dataItem; }

		public function ErrorLogTarget() {
			super();

			clearLog();
		}

		public function clearLog() : void {
			_logLines = new Vector.<String>();
			_data = new Dictionary();
		}

		public function getData(msg:String) : * {
			return _data[msg];
		}

		override mx_internal function internalLog(message:String):void {
			_logLines.push(message);
			_data[message] = _dataItem;
			_dataItem = null;
		}		
	}
}
