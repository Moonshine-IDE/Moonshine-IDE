////////////////////////////////////////////////////////////////////////////////
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
// 
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.ondiskproj.crud.exporter.components
{
	import view.dominoFormBuilder.vo.DominoFormFieldVO;
	import view.dominoFormBuilder.vo.FormBuilderEditableType;
	import view.dominoFormBuilder.vo.FormBuilderFieldType;

	public class RoyaleFormItem extends RoyaleElemenetBase
	{
		public static function toCode(value:DominoFormFieldVO):String
		{
			var formItem:String = readTemplate("FormItem.template");
			var formContent:String;
			
			if (value.isMultiValue)
			{
				formContent = toMultiValueListCode(value);
			}
			else
			{
				switch (value.type)
				{
					case FormBuilderFieldType.TEXT:
						formContent = toTextInputCode(value);
						break;
					case FormBuilderFieldType.DATETIME:
						formContent = toDateFieldCode(value);
						break;
					case FormBuilderFieldType.RICH_TEXT:
						formContent = toRichTextFieldCode(value);
						break;
					case FormBuilderFieldType.NUMBER:
						formContent = toNumberTextInputCode(value);
						break;
				}
			}
			
			formItem = formItem.replace(/%label%/ig, value.label);
			formItem = formItem.replace(/%required%/ig, 'false');
			formItem = formItem.replace(/%visible%/ig, 'true');
			formItem = formItem.replace(/%FormItemContent%/ig, formContent);
			
			return formItem;
		}

		public static function assignValuesToComponentCode(value:DominoFormFieldVO):String
		{
			if (value.isMultiValue)
			{
				return value.name +"_id.dataProvider = ";
			}
			else
			{
				switch (value.type)
				{
					case FormBuilderFieldType.TEXT:
					case FormBuilderFieldType.NUMBER:
						return value.name +"_id.text = ";
					case FormBuilderFieldType.RICH_TEXT:
						return value.name +"_id.data = ";
					case FormBuilderFieldType.DATETIME:
						return value.name +"_id.selectedDate = ";
				}
			}

			return "";
		}

		public static function retrieveComponentValuesToCode(value:DominoFormFieldVO):String
		{
			if (value.isMultiValue)
			{
				return " = "+ value.name +"_id.dataProvider";
			}
			else
			{
				switch (value.type)
				{
					case FormBuilderFieldType.TEXT:
						return " = "+ value.name +"_id.text";
					case FormBuilderFieldType.RICH_TEXT:
						return " = "+ value.name +"_id.data";
					case FormBuilderFieldType.NUMBER:
						return " = Number("+ value.name +"_id.text)";
					case FormBuilderFieldType.DATETIME:
						return " = "+ value.name +"_id.selectedDate";
				}
			}

			return "";
		}
		
		private static function toTextInputCode(field:DominoFormFieldVO):String
		{
			var beads:String = updateBeads(field);
			
			var textInput:String = readTemplate("TextInput.template");;
			textInput = textInput.replace(/%localId%/ig, field.name +"_id");
			textInput = textInput.replace(/%Beads%/ig, beads);
			
			if (field.description) return formItemWithDescription(textInput, field);
			return textInput;
		}
		
		private static function toNumberTextInputCode(field:DominoFormFieldVO):String
		{
			var beads:String = updateBeads(field);
			
			var textInput:String = readTemplate("TextInput.template");;
			textInput = textInput.replace(/%localId%/ig, field.name +"_id");
			textInput = textInput.replace(/%Beads%/ig, beads);
			
			if (field.description) return formItemWithDescription(textInput, field);
			return textInput;
		}
		
		private static function toMultiValueListCode(field:DominoFormFieldVO):String
		{			
			var multiValueField:String = readTemplate("MultiValueList.template");;
			multiValueField = multiValueField.replace(/%localId%/ig, field.name +"_id");
			multiValueField = multiValueField.replace(/%InputType%/ig, field.type);
			multiValueField = multiValueField.replace(/%Restrict%/ig, 
				field.type == FormBuilderFieldType.NUMBER ? "[^0-9]" : '');
			
			if (field.description) return formItemWithDescription(multiValueField, field);
			return multiValueField;
		}
		
		private static function toDateFieldCode(field:DominoFormFieldVO):String
		{
			var beads:String = updateBeads(field);
			
			var dateField:String = readTemplate("DateField.template");;
			dateField = dateField.replace(/%localId%/ig, field.name +"_id");
			dateField = dateField.replace(/%Beads%/ig, beads);
			
			if (field.description) return formItemWithDescription(dateField, field);
			return dateField;
		}
		
		private static function toRichTextFieldCode(field:DominoFormFieldVO):String
		{
			var richText:String = readTemplate("JoditEditor.template");
			richText = richText.replace(/%localId%/ig, field.name +"_id");
			
			if (field.description) return formItemWithDescription(richText, field);
			return richText;
		}
		
		private static function updateBeads(field:DominoFormFieldVO):String
		{
			var beads:String = readTemplate("Beads.template");
			var beadElements:String = "";
			
			if (field.editable != FormBuilderEditableType.EDITABLE)
			{
				beadElements = readTemplate("BeadDisabled.template") +"\n";
			}
			
			switch (field.type)
			{
				case FormBuilderFieldType.TEXT:
					break;
				case FormBuilderFieldType.DATETIME:
					break;
				case FormBuilderFieldType.RICH_TEXT:
					break;
				case FormBuilderFieldType.NUMBER:
					var beadRestrict:String = readTemplate("BeadRestrict.template");
					beadElements += beadRestrict.replace(/%pattern%/gi, "[^0-9]") +"\n";
					break;
			}
			
			beads = beads.replace(/%BeadsContent%/ig, beadElements);
			return beads;
		}
		
		private static function formItemWithDescription(formItem:String, field:DominoFormFieldVO):String
		{
			var container:String = "<j:VGroup percentWidth=\"100\">\n"+ formItem;
			
			var label:String = readTemplate("Label.template");
			label = label.replace(/%Multiline%/ig, "true");
			label = label.replace(/%ClassName%/ig, "formFieldDescription");
			label = label.replace(/%PercentWidth%/ig, "100");
			label = label.replace(/%Text%/ig, field.description);
			
			container += "\n"+ label +"\n</j:VGroup>";
			return container;
		}
	}
}