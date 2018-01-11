package actionScripts.valueObjects
{
	public class CompletionItem
	{
		public var label:String;

		[Bindable]
		public var kind:String;

		public var detail:String;
		[Bindable]
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

        private var _displayLabel:String;
        private var _displayType:String;
		private var _displayKind:String;

        public function CompletionItem(label:String = "", insertText:String = "",
									   kind:String = "", detail:String = "",
									   documentation:String = "", command:Command = null):void
		{
			this.label = label;
			this.insertText = insertText;
			this.kind = kind;
			this.detail = detail;
			this.documentation = documentation;
			this.command = command;
			this.data = data;

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
                _displayType = this.kind;
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
            if (command && command.command == "nextgenas.addMXMLNamespace")
            {
                if (command.arguments)
                {
                    var namespace:String = command.arguments[1];
                    if (namespace.indexOf("http://") > -1 || namespace.indexOf("library://") > -1)
                    {
                        value = command.arguments[0] + ":" + label;
                    }
                }
            }
			else if (isMethod)
			{
				var detailFunctionIndex:int = detail.lastIndexOf(label);
                var lastColonIndex:int = detail.lastIndexOf(":");
				value = detail.substring(detailFunctionIndex, lastColonIndex);
			}

            _displayLabel = value;
		}

        private function get isEvent():Boolean
        {
            if (detail)
            {
                return kind == "Field" && detail.indexOf("(event)") > -1;
            }

            return false;
        }

        private function get isProperty():Boolean
        {
            if (detail)
            {
                return kind == "Function" && detail.indexOf("(property)") > -1;
            }

            return false;
        }

        private function get isMethod():Boolean
        {
            return kind == "Function" && detail.indexOf("(method)") > -1;
        }

        private function get isVariable():Boolean
        {
            return kind == "Variable" && detail.indexOf("(variable)") > -1;
        }

		private function get isClass():Boolean
		{
			return kind == "Class" && detail.indexOf("(Class)") > -1;
		}
    }
}