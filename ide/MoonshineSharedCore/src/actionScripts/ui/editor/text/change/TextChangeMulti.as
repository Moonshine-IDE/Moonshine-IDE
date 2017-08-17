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
package actionScripts.ui.editor.text.change
{
	public class TextChangeMulti extends TextChangeBase
	{
		private var _changes:Vector.<TextChangeBase>;
		
		public function get changes():Vector.<TextChangeBase>	{ return _changes; }
		
		public function TextChangeMulti(... changes)
		{
			super(TextChangeBase.UNBLOCK);
			
			if (changes[0] is Vector.<TextChangeBase>)
			{
				_changes = Vector.<TextChangeBase>(changes[0]);
			}
			else
			{
				_changes = Vector.<TextChangeBase>(changes);
			}
		}
		
		public override function getReverse():TextChangeBase
		{
			var revChanges:Vector.<TextChangeBase> = new Vector.<TextChangeBase>();
			
			for (var i:int = changes.length; i--; )
			{
				revChanges.push(changes[i].getReverse());
			}
			
			return new TextChangeMulti(revChanges);
		}
		
	}

}