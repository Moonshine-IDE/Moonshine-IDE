package actionScripts.valueObjects
{
	/**
	 * Implementation of WorkspaceEdit interface from Language Server Protocol
	 * 
	 * <p><strong>DO NOT</strong> add new properties or methods to this class
	 * that are specific to Moonshine IDE or to a particular language. Create a
	 * subclass for new properties or create a utility function for methods.</p>
	 * 
	 * @see https://microsoft.github.io/language-server-protocol/specification#workspaceedit
	 */
	public class WorkspaceEdit
	{
		/**
		 * Holds changes to existing resources.
		 * 
		 * <p>The object key is the URI, and the value is an Array of TextEdit
		 * instnaces.</p>
		 */
		public var changes:Object;

		public function WorkspaceEdit()
		{
			
		}
	}
}