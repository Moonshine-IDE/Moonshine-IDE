package actionScripts.valueObjects
{
	public class CompletionItem
	{
		private var _label:String;

		[Bindable("labelChange")]
		public function get label():String
		{
			return this._label;
		}
		
		private var _kind:String;
		
		[Bindable("kindChange")]
		public function get kind():String
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

        private var _displayLabel:String;
        private var _displayType:String;
		private var _displayKind:String;

        public function CompletionItem(label:String = "", insertText:String = "",
									   kind:String = "", detail:String = "",
									   documentation:String = "", command:Command = null, data:* = undefined):void
		{
			this._label = label;
			this._insertText = insertText;
			this._kind = kind;
			this._detail = detail;
			this._documentation = documentation;
			this._command = command;
			this._data = data;

			this.displayLabel = label;
			this.displayType = detail;
			this.displayKind = kind;
		}

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
                _displayType = this._kind;
			}
		}

        [Bindable]
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

        public function get displayLabel():String
        {
            return _displayLabel;
        }

        public function set displayLabel(value:String):void
		{
            if (_command && _command.command == "nextgenas.addMXMLNamespace")
            {
				var args:Array = _command.arguments;
                if (args)
                {
                    var ns:String = args[1] as String;
                    if (ns.indexOf("http://") > -1 || ns.indexOf("library://") > -1)
                    {
						var prefix:String = args[0] as String;
                        value = prefix + ":" + _label;
                    }
                }
            }
			else if (isMethod)
			{
				var detailFunctionIndex:int = _detail.lastIndexOf(_label);
                var lastColonIndex:int = _detail.lastIndexOf(":");
				value = _detail.substring(detailFunctionIndex, lastColonIndex);
			}

            _displayLabel = value;
		}

        public function get isMethod():Boolean
        {
            return _kind == "Function" && _detail.indexOf("(method)") > -1;
        }

        private function get isEvent():Boolean
        {
            if (_detail)
            {
                return _kind == "Field" && _detail.indexOf("(event)") > -1;
            }

            return false;
        }

        private function get isProperty():Boolean
        {
            if (_detail)
            {
                return _kind == "Function" && _detail.indexOf("(property)") > -1;
            }

            return false;
        }

        private function get isVariable():Boolean
        {
            return _kind == "Variable" && _detail.indexOf("(variable)") > -1;
        }

		private function get isClass():Boolean
		{
			return _kind == "Class" && _detail.indexOf("(Class)") > -1;
		}
    }
}