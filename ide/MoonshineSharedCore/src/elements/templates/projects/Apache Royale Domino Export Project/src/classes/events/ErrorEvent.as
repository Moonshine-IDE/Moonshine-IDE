package classes.events
{
    import org.apache.royale.events.Event;

	public class ErrorEvent extends Event 
	{
		public static const SERVER_ERROR:String = "serverError";
		
		public var errorMessage:String;
		
		public function ErrorEvent(type:String, errorMessage:String, item:Object=null)
		{
			super(type, false, false);
			
			this.errorMessage = errorMessage;
			this.errors = item;
		}
		
		private var _errors:Object;

		public function get errors():Object
		{
			return _errors;
		}

		public function set errors(value:Object):void
		{
			_errors = value;
		}
	}
}