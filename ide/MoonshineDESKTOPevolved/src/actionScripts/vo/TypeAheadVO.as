package actionScripts.vo
{
	public class TypeAheadVO
	{
		public var label:String = "";
		public var kind:Number = 0;
		public var detail:String = "";
		public var documentation:String = "";
		public var sortText:String = "";
		public var filterText:String = "";
		public var insertText:String = "";
		public var textEdit: TextEdit;
		/**
		 * An optional array of additional text edits that are applied when
		 * selecting this completion. Edits must not overlap with the main edit
		 * nor with themselves.
		 */
		public var additionalTextEdits:  Array;
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
		
		public function TypeAheadVO()
		{
			
		}
	}
}