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
		private static const FIELD_COMMAND:String = "command";
		private static const FIELD_IS_INCOMPLETE:String = "isIncomplete";
		private static const FIELD_TEXT_EDIT:String = "textEdit";
		private static const FIELD_ADDITIONAL_TEXT_EDITS:String = "additionalTextEdits";
		private static const FIELD_LABEL:String = "label";
		private static const FIELD_INSERT_TEXT:String = "insertText";
		private static const FIELD_SORT_TEXT:String = "sortText";
		private static const FIELD_DOCUMENTATION:String = "documentation";
		private static const FIELD_DETAIL:String = "detail";
		private static const FIELD_DEPRECATED:String = "deprecated";
		private static const FIELD_DATA:String = "data";
		private static const FIELD_KIND:String = "kind";

		private var _label:String;

		[Bindable("labelChange")]
		public function get label():String
		{
			return this._label;
		}
		
		private var _sortText:String;
		
		public function get sortText():String
		{
			return this._sortText;
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

		private var _textEdit:TextEdit = null;

		[Bindable("textEditChange")]
		public function get textEdit():TextEdit
		{
			return this._textEdit;
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
		public function get data():*
		{
			return this._data;
		}

		public function CompletionItem(label:String = "", insertText:String = "",
			kind:int = -1, detail:String = "",
			documentation:String = "", command:Command = null, data:* = undefined,
			deprecated:Boolean = false, additionalTextEdits:Vector.<TextEdit> = null):void
		{
			this._label = label;
			this._sortText = label.toLowerCase();
			this._insertText = insertText;
			this._kind = kind;
			this._detail = detail;
			this._documentation = documentation;
			this._command = command;
			this._data = data;
			this._deprecated = deprecated;
			this._additionalTextEdits = additionalTextEdits;
		}

		public static function resolve(item:CompletionItem, resolvedFields:Object):CompletionItem
		{
			if(FIELD_LABEL in resolvedFields)
			{
				item._label = resolvedFields[FIELD_LABEL];
			}
			if(FIELD_SORT_TEXT in resolvedFields)
			{
				item._sortText = resolvedFields[FIELD_SORT_TEXT].toLowerCase();
			}
			else
			{
				item._sortText = item.label.toLowerCase();
			}
			if(FIELD_INSERT_TEXT in resolvedFields)
			{
				item._insertText = resolvedFields[FIELD_INSERT_TEXT];
			}
			if(FIELD_KIND in resolvedFields)
			{
				item._kind = resolvedFields[FIELD_KIND];
			}
			if(FIELD_DETAIL in resolvedFields)
			{
				item._detail = resolvedFields[FIELD_DETAIL];
			}
			if(FIELD_DOCUMENTATION in resolvedFields)
			{
				item._documentation = resolvedFields[FIELD_DOCUMENTATION];
			}
			if(FIELD_DEPRECATED in resolvedFields)
			{
				item._deprecated = resolvedFields[FIELD_DEPRECATED];
			}
			if(FIELD_COMMAND in resolvedFields)
			{
				item._command = Command.parse(resolvedFields[FIELD_COMMAND]);
			}
			if(FIELD_IS_INCOMPLETE in resolvedFields && resolvedFields[FIELD_IS_INCOMPLETE])
			{
				trace("WARNING: Completion item is incomplete. Resolving a completion item is not supported yet. Item: " + item.label);
			}
			if(FIELD_TEXT_EDIT in resolvedFields)
			{
				var jsonTextEdit:Object = resolvedFields[FIELD_TEXT_EDIT];
				item._textEdit = TextEdit.parse(jsonTextEdit);
			}
			if(FIELD_ADDITIONAL_TEXT_EDITS in resolvedFields)
			{
				var additionalTextEdits:Vector.<TextEdit> = new <TextEdit>[];
				var jsonTextEdits:Array = resolvedFields[FIELD_ADDITIONAL_TEXT_EDITS] as Array;
				var textEditCount:int = jsonTextEdits.length;
				for(var i:int = 0; i < textEditCount; i++)
				{
					jsonTextEdit = jsonTextEdits[i];
					additionalTextEdits[i] = TextEdit.parse(jsonTextEdit);
				}
				item._additionalTextEdits = additionalTextEdits;
			}

			if(FIELD_DATA in resolvedFields)
			{
				item._data = resolvedFields[FIELD_DATA];
			}
			return item;
		}

		public static function parse(original:Object):CompletionItem
		{
			var item:CompletionItem = new CompletionItem();
			return resolve(item, original);
		}

		public function toJSON(key:String):*
		{
			var result:Object = {};
			result.label = this._label;
			result.kind = this._kind;
			result.deprecated = this._deprecated;
			if(this._detail)
			{
				result.detail = this._detail;
			}
			if(this._documentation)
			{
				result.documentation = this._documentation;
			}
			if(this._command)
			{
				result.command = this._command;
			}
			if(this._data)
			{
				result.data = this._data;
			}
			if(this._additionalTextEdits)
			{
				var additionalTextEdits:Array = [];
				var length:int = this._additionalTextEdits.length;
				for(var i:int = 0; i < length; i++)
				{
					var textEdit:TextEdit = this._additionalTextEdits[i];
					additionalTextEdits[i] = textEdit;
				}
				result.additionalTextEdits = additionalTextEdits;
			}
			return result;
		}
	}
}