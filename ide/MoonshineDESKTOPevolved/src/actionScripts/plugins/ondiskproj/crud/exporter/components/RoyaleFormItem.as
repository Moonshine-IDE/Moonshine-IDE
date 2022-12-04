////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
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
			var formItem:String = readTemplate("elements/templates/royaleTabularCRUD/elements/FormItem.template");
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
			
			var textInput:String = readTemplate("elements/templates/royaleTabularCRUD/elements/TextInput.template");
			textInput = textInput.replace(/%localId%/ig, field.name +"_id");
			textInput = textInput.replace(/%Beads%/ig, beads);
			
			if (field.description) return formItemWithDescription(textInput, field);
			return textInput;
		}
		
		private static function toNumberTextInputCode(field:DominoFormFieldVO):String
		{
			var beads:String = updateBeads(field);
			
			var textInput:String = readTemplate("elements/templates/royaleTabularCRUD/elements/TextInput.template");
			textInput = textInput.replace(/%localId%/ig, field.name +"_id");
			textInput = textInput.replace(/%Beads%/ig, beads);
			
			if (field.description) return formItemWithDescription(textInput, field);
			return textInput;
		}
		
		private static function toMultiValueListCode(field:DominoFormFieldVO):String
		{			
			var multiValueField:String = readTemplate("elements/templates/royaleTabularCRUD/elements/MultiValueList.template");
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
			
			var dateField:String = readTemplate("elements/templates/royaleTabularCRUD/elements/DateField.template");
			dateField = dateField.replace(/%localId%/ig, field.name +"_id");
			dateField = dateField.replace(/%Beads%/ig, beads);
			
			if (field.description) return formItemWithDescription(dateField, field);
			return dateField;
		}
		
		private static function toRichTextFieldCode(field:DominoFormFieldVO):String
		{
			var richText:String = readTemplate("elements/templates/royaleTabularCRUD/elements/JoditEditor.template");
			richText = richText.replace(/%localId%/ig, field.name +"_id");
			
			if (field.description) return formItemWithDescription(richText, field);
			return richText;
		}
		
		private static function updateBeads(field:DominoFormFieldVO):String
		{
			var beads:String = readTemplate("elements/templates/royaleTabularCRUD/elements/Beads.template");
			var beadElements:String = "";
			
			if (field.editable != FormBuilderEditableType.EDITABLE)
			{
				beadElements = readTemplate("elements/templates/royaleTabularCRUD/elements/BeadDisabled.template") +"\n";
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
					var beadRestrict:String = readTemplate("elements/templates/royaleTabularCRUD/elements/BeadRestrict.template");
					beadElements += beadRestrict.replace(/%pattern%/gi, "[^0-9]") +"\n";
					break;
			}
			
			beads = beads.replace(/%BeadsContent%/ig, beadElements);
			return beads;
		}
		
		private static function formItemWithDescription(formItem:String, field:DominoFormFieldVO):String
		{
			var container:String = "<j:VGroup percentWidth=\"100\">\n"+ formItem;
			
			var label:String = readTemplate("elements/templates/royaleTabularCRUD/elements/Label.template");
			label = label.replace(/%Multiline%/ig, "true");
			label = label.replace(/%ClassName%/ig, "formFieldDescription");
			label = label.replace(/%PercentWidth%/ig, "100");
			label = label.replace(/%Text%/ig, field.description);
			
			container += "\n"+ label +"\n</j:VGroup>";
			return container;
		}
	}
}