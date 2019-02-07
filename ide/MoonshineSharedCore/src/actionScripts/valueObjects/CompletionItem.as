package actionScripts.valueObjects
{
	import flash.events.EventDispatcher;

	/**
	 * Implementation of CompletionItem interface from Language Server Protocol
	 * 
	 * <p><strong>DO NOT</strong> add new properties or methods to this class
	 * that are specific to Moonshine IDE or to a particular language. Create a
	 * subclass for new properties or create a utility function for methods.</p>
	 * 
	 * @see https://microsoft.github.io/language-server-protocol/specification#textDocument_completion
	 */
	public class CompletionItem extends EventDispatcher
	{
		private var _label:String;

		[Bindable("labelChange")]
		public function get label():String
		{
			return this._label;
		}
		
		private var _sortLabel:String;
		
		//TODO: remove sortLabel because it does not exist in language server protocol
		public function get sortLabel():String
		{
			return this._sortLabel;
		}
		
		private var _kind:int;
		
		[Bindable("kindChange")]
		public function get kind():int
		{
			return this._kind;
		}

		private var _detail:String;

		[Bindable("detailChange")]
		public function get detail():String
		{
			return this._detail;
		}

		private var _documentation:String;

		[Bindable("documentationChange")]
		public function get documentation():String
		{
			return this._documentation;
		}

		private var _insertText:String = null;

		[Bindable("insertTextChange")]
		public function get insertText():String
		{
			return this._insertText;
		}

		private var _command: Command;

		/**
		 * An optional command that is executed *after* inserting this completion. *Note* that
		 * additional modifications to the current document should be described with the
		 * additionalTextEdits-property.
		 */
		[Bindable("commandChange")]
		public function get command():Command
		{
			return this._command;
		}

		private var _data: *;

		private var _deprecated:Boolean;

		[Bindable("deprecatedChange")]
		public function get deprecated():Boolean
		{
			return this._deprecated;
		}

		private var _additionalTextEdits:Vector.<TextEdit>;

		public function get additionalTextEdits():Vector.<TextEdit>
		{
			return this._additionalTextEdits;
		}

		/**
		 * An data entry field that is preserved on a completion item between
		 * a completion and a completion resolve request.
		 */
		[Bindable("dataChange")]
		public function get data():String
		{
			return this._data;
		}

        public function CompletionItem(label:String = "", insertText:String = "",
									   kind:int = -1, detail:String = "",
									   documentation:String = "", command:Command = null, data:* = undefined,
									   deprecated:Boolean = false, additionalTextEdits:Vector.<TextEdit> = null):void
		{
			this._label = label;
			this._sortLabel = label.toLowerCase();
			this._insertText = insertText;
			this._kind = kind;
			this._detail = detail;
			this._documentation = documentation;
			this._command = command;
			this._data = data;
			this._deprecated = deprecated;
			this._additionalTextEdits = additionalTextEdits;
		}
    }
}