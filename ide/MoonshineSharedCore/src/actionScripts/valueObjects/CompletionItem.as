package actionScripts.valueObjects
{
	import flash.events.EventDispatcher;

	public class CompletionItem extends EventDispatcher
	{
		private var _label:String;

		[Bindable("labelChange")]
		public function get label():String
		{
			return this._label;
		}
		
		private var _sortLabel:String;
		
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

		/**
		 * An data entry field that is preserved on a completion item between
		 * a completion and a completion resolve request.
		 */
		[Bindable("dataChange")]
		public function get data():String
		{
			return this._data;
		}

        private var _displayType:String;
		private var _displayKind:String;

        public function CompletionItem(label:String = "", insertText:String = "",
									   kind:int = -1, detail:String = "",
									   documentation:String = "", command:Command = null, data:* = undefined):void
		{
			this._label = label;
			this._sortLabel = label.toLowerCase();
			this._insertText = insertText;
			this._kind = kind;
			this._detail = detail;
			this._documentation = documentation;
			this._command = command;
			this._data = data;

			this.displayType = detail;
			this.displayKind = getDisplayKind(kind);
		}

		[Bindable("displayTypeChange")]
		public function get displayType():String
		{
			return _displayType;
		}

		public function set displayType(value:String):void
		{
            if (isMethod || isProperty || isVariable)
            {
                var lastColonIndex:int = value.lastIndexOf(":");
                _displayType = value.substring(lastColonIndex + 1);
            }
			else
			{
                _displayType = getDisplayKind(this._kind);
			}
		}

		[Bindable("displayKindChange")]
        public function get displayKind():String
        {
            return _displayKind;
        }

        public function set displayKind(value:String):void
		{
			if (isProperty)
			{
				value = "Property";
			}

			_displayKind = value;
		}

        public function get isMethod():Boolean
        {
            return kind == CompletionItemKind.METHOD && _detail.indexOf("(method)") > -1;
        }

        private function get isEvent():Boolean
        {
            if (_detail)
            {
                return kind == CompletionItemKind.FIELD && _detail.indexOf("(event)") > -1;
            }

            return false;
        }

        private function get isProperty():Boolean
        {
            if (_detail)
            {
                return kind == CompletionItemKind.FIELD && _detail.indexOf("(property)") > -1;
            }

            return false;
        }

        private function get isVariable():Boolean
        {
            return kind == CompletionItemKind.FIELD && _detail.indexOf("(variable)") > -1;
        }

		private function get isClass():Boolean
		{
			return kind == CompletionItemKind.CLASS && _detail.indexOf("(Class)") > -1;
		}

		private function getDisplayKind(kind:int):String
		{
			switch(kind)
			{
				case CompletionItemKind.CLASS:
				{
					return "Class";
				}
				case CompletionItemKind.COLOR:
				{
					return "Color";
				}
				case CompletionItemKind.CONSTANT:
				{
					return "Constant";
				}
				case CompletionItemKind.CONSTRUCTOR:
				{
					return "Constructor";
				}
				case CompletionItemKind.ENUM:
				{
					return "Enum";
				}
				case CompletionItemKind.ENUM_MEMBER:
				{
					return "EnumMember";
				}
				case CompletionItemKind.EVENT:
				{
					return "Event";
				}
				case CompletionItemKind.FIELD:
				{
					return "Field";
				}
				case CompletionItemKind.FILE:
				{
					return "File";
				}
				case CompletionItemKind.FOLDER:
				{
					return "Folder";
				}
				case CompletionItemKind.FUNCTION:
				{
					return "Function";
				}
				case CompletionItemKind.INTERFACE:
				{
					return "Interface";
				}
				case CompletionItemKind.KEYWORD:
				{
					return "Keyword";
				}
				case CompletionItemKind.METHOD:
				{
					return "Method";
				}
				case CompletionItemKind.MODULE:
				{
					return "Module";
				}
				case CompletionItemKind.OPERATOR:
				{
					return "Operator";
				}
				case CompletionItemKind.PROPERTY:
				{
					return "Property";
				}
				case CompletionItemKind.REFERENCE:
				{
					return "Reference";
				}
				case CompletionItemKind.SNIPPET:
				{
					return "Snippet";
				}
				case CompletionItemKind.STRUCT:
				{
					return "Struct";
				}
				case CompletionItemKind.TEXT:
				{
					return "Text";
				}
				case CompletionItemKind.TYPE_PARAMETER:
				{
					return "TypeParameter";
				}
				case CompletionItemKind.UNIT:
				{
					return "Unit";
				}
				case CompletionItemKind.VALUE:
				{
					return "Value";
				}
				case CompletionItemKind.VARIABLE:
				{
					return "Variable";
				}
			}
			return null;
		}
    }
}