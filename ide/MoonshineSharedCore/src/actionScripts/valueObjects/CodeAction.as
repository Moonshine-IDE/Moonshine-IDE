package actionScripts.valueObjects
{
	/**
	 * Implementation of CodeAction interface from Language Server Protocol
	 * 
	 * <p><strong>DO NOT</strong> add new properties or methods to this class
	 * that are specific to Moonshine IDE or to a particular language. Create a
	 * subclass for new properties or create a utility function for methods.</p>
	 * 
	 * @see https://microsoft.github.io/language-server-protocol/specification#textDocument_codeAction
	 */
	public class CodeAction
	{
		public static const KIND_QUICK_FIX:String = "quickfix";
		public static const KIND_REFACTOR:String = "refactor";
		public static const KIND_REFACTOR_EXTRACT:String = "refactor.extract";
		public static const KIND_REFACTOR_INLINE:String = "refactor.inline";
		public static const KIND_REFACTOR_REWRITE:String = "refactor.rewrite";
		public static const KIND_SOURCE:String = "source";
		public static const KIND_SOURCE_ORGANIZE_IMPORTS:String = "source.organizeImports";

		/**
		 * A short, human-readable, title for this code action.
		 */
		public var title:String;

		/**
		 * The kind of the code action. Used to filter code actions.
		 */
		public var kind:String;

		/**
		 * The diagnostics that this code action resolves.
		 */
		public var diagnostics:Vector.<Diagnostic>;

		/**
		 * The workspace edit this code action performs.
		 */
		public var edit:WorkspaceEdit;

		/**
		 * A command this code action executes. If a code action provides an
		 * edit and a command, first the edit is executed and then the command.
		 */
		public var command:Command;

		public function CodeAction()
		{
			
		}
	}
}