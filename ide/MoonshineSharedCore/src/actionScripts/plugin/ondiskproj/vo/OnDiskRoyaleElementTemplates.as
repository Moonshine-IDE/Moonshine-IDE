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
package actionScripts.plugin.ondiskproj.vo
{
	public class OnDiskRoyaleElementTemplates
	{
		public static const DATAGRID_COLUMN_WITH_RENDERER:XML = <j:DataGridColumn label="$label" itemRenderer="$renderer"/>;
		public static const DATAGRID_COLUMN:XML = <j:DataGridColumn label="$label" dataField="$dataField"/>;
		public static const BEAD_STRING_VALIDATOR:XML = <j:StringValidator required="1"/>;
		public static const FORM_ITEM:XML = <j:FormItem label="$label" required="$required"
			className="horizontalContentShrinkFormItem">
			%FormItemContent%
</j:FormItem>;
		public static const BEADS:XML = <j:beads>
	%BeadsContent%
</j:beads>;
		public static const TEXT_INPUT:XML = <j:TextInput localId="$localId" percentWidth="100">
	%Beads%
</j:TextInput>;
	}
}