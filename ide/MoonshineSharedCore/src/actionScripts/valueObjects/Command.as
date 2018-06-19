package actionScripts.valueObjects
{
	/**
	 * Implementation of Command interface from Language Server Protocol
	 * 
	 * <p><strong>DO NOT</strong> add new properties or methods to this class
	 * that are specific to Moonshine IDE or to a particular language. Create a
	 * subclass for new properties or create a utility function for methods.</p>
	 * 
	 * @see https://microsoft.github.io/language-server-protocol/specification#command
	 */
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
		public var arguments: Array;
		
		public function Command()
		{
		}
	}
}