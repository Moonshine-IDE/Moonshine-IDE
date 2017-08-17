package actionScripts.valueObjects
{
	public class Command
	{
		public var title: String = "";
		/**
		 * The identifier of the actual command handler.
		 */
		public var command: String = "";
		/**
		 * Arguments that the command handler should be
		 * invoked with.
		 */
		public var arguments: *;
		
		public function Command()
		{
		}
	}
}