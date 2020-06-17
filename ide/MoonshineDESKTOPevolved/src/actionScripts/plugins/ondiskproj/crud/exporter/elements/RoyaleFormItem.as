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
package actionScripts.plugins.ondiskproj.crud.exporter.elements
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
			
			switch (value.type)
			{
				case FormBuilderFieldType.TEXT:
					formContent = toTextInputCode(value);
					break;
				case FormBuilderFieldType.DATETIME:
					formContent = toDateFieldCode(value);
					break;
				case FormBuilderFieldType.RICH_TEXT:
					break;
				case FormBuilderFieldType.NUMBER:
					formContent = toNumberTextInputCode(value);
					break;
			}
			
			formItem = formItem.replace(/%label%/ig, value.label);
			formItem = formItem.replace(/%required%/ig, 'false');
			formItem = formItem.replace(/%FormItemContent%/ig, formContent);
			
			return formItem;
		}
		
		private static function toTextInputCode(field:DominoFormFieldVO):String
		{
			var beads:String = readTemplate("Beads.template");
			var beadElements:String = "";
			
			if (field.editable != FormBuilderEditableType.EDITABLE)
			{
				beadElements += "\n"+ readTemplate("Bead_Disabled.template");
			}
			
			beads = beads.replace(/%BeadsContent%/ig, beadElements);
			
			var textInput:String = readTemplate("TextInput.template");;
			textInput = textInput.replace(/%localId%/ig, field.name +"_id");
			textInput = textInput.replace(/%Beads%/ig, beads);
			
			return textInput;
		}
		
		private static function toNumberTextInputCode(field:DominoFormFieldVO):String
		{
			var beads:String = readTemplate("Beads.template");
			var beadRestrict:String = readTemplate("Bead_Restrict.template");
			var beadElements:String = "";
			
			beadElements = beadRestrict.replace(/%pattern%/gi, "[^0-9]");
			if (field.editable != FormBuilderEditableType.EDITABLE)
			{
				beadElements += "\n"+ readTemplate("Bead_Disabled.template");
			}
			
			beads = beads.replace(/%BeadsContent%/ig, beadElements);
			
			var textInput:String = readTemplate("TextInput.template");;
			textInput = textInput.replace(/%localId%/ig, field.name +"_id");
			textInput = textInput.replace(/%Beads%/ig, beads);
			
			return textInput;
		}
		
		private static function toDateFieldCode(field:DominoFormFieldVO):String
		{
			var dateField:String = readTemplate("DateField.template");;
			dateField = dateField.replace(/%localId%/ig, field.name +"_id");
			
			return dateField;
		}
	}
}