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
	import view.dominoFormBuilder.vo.FormBuilderFieldType;

	public class RoyaleDataGridColumn extends RoyaleElemenetBase
	{
		public static function toCode(value:DominoFormFieldVO):String
		{
			var column:String = readTemplate("DataGridColumn.template");
			column = column.replace(/%label%/ig, value.label);
			column = column.replace(/%dataField%/ig, value.name);
			column = column.replace(/%itemRenderer%/ig, getRenderer(value));
			
			return column;
		}

		private static function getRenderer(value:DominoFormFieldVO):String
		{
			if (value.isMultiValue)
			{
				switch (value.type)
				{
					case FormBuilderFieldType.DATETIME:
						return "itemRenderer=\"views.renderers.MultivalueDateGridItemRenderer\"";
						break;
					default:
						return "itemRenderer=\"views.renderers.MultivalueStringGridItemRenderer\"";
						break;
				}
			}
			return "";
		}
	}
}