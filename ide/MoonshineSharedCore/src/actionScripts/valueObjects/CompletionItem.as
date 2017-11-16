package actionScripts.valueObjects
{
	public class CompletionItem
	{
		public var label:String;
		public var kind:String;
		public var detail:String;
		public var documentation:String;
		public var insertText:String = null;

		/**
		 * An optional command that is executed *after* inserting this completion. *Note* that
		 * additional modifications to the current document should be described with the
		 * additionalTextEdits-property.
		 */
		public var command: Command;
		/**
		 * An data entry field that is preserved on a completion item between
		 * a completion and a completion resolve request.
		 */
		public var data: *;

		public function isProperty():Boolean
		{
			if (detail)
			{
				return kind == "Function" && detail.indexOf("property") > -1;
			}

			return false;
		}

		public function get labelWithPrefix():String
		{
			if (command && command.command == "nextgenas.addMXMLNamespace")
			{
			   if (command.arguments)
			   {
				   var namespace:String = command.arguments[1];
				   if (namespace.indexOf("http://") > -1 || namespace.indexOf("library://") > -1)
                   {
                       return command.arguments[0] + ":" + label;
                   }
			   }
			}

			return label;
		}
	}
}