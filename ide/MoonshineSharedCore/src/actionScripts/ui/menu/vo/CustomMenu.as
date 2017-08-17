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
package actionScripts.ui.menu.vo 
{
	import actionScripts.ui.menu.interfaces.ICustomMenu;
	import actionScripts.ui.menu.interfaces.ICustomMenuItem;
	import actionScripts.ui.menu.interfaces.IMenuEntity;

	/**
	 * ...
	 * @author Conceptual Ideas
	 */
	public class CustomMenu implements ICustomMenu, IMenuEntity
	{
		
		private var _items:Vector.<ICustomMenuItem> = new Vector.<ICustomMenuItem>();
		public function get items():Vector.<ICustomMenuItem> { return _items; }
		
		
		
		
		public function get numItems():int {
			return _items.length;
		}
		
		
		
		private var _label:String
		public function get label():String {
			return _label;
		}
		public function set label(value:String):void {
			if (label == value)  return;
			_label = value;		
			
		}
		
	
	
		public function CustomMenu(label:String="",items:Vector.<IMenuEntity>=null) {			
			this.label = label;			
		}
	
		
		
		
		public function addItem(item:ICustomMenuItem):ICustomMenuItem {			
			// TODO : Check if item is bound to another ICustomMenu
			//if(item.
			_items.push(item);
			return item;
		}
		public function addItemAt(item:ICustomMenuItem, index:int):ICustomMenuItem {
			
			var pos:int = index;
			if(index > _items.length)
				pos = _items.length;	
			
			
			var removeIndex:int = getItemIndex(item);
			
			if(removeIndex ==-1)				
				_items.splice(removeIndex,1);
			
			_items.splice(pos,0,item);
			return item;
		}
		public function addSubmenu(submenu:ICustomMenu, label:String=null):ICustomMenuItem {
			return addItem(new CustomMenuItem(label||submenu.label,false,{
				data:submenu
				
			}))
		}
		public function addSubMenuAt(submenu:ICustomMenu, index:int, label:String=null):ICustomMenuItem {
			return addItemAt(new CustomMenuItem(label || submenu.label,false,{
				data:submenu
			}),index);
			
		}
		
		public function containsItem(item:ICustomMenuItem):Boolean {
			return false;
		}		
		
		public function getItemAt(index:int):ICustomMenuItem {
			if(index > _items.length || index <0) return null;
			return _items[index];
		}
		public function getItemByName(name:String):ICustomMenuItem {
			
				for each(var entity:ICustomMenuItem in _items){
					if(!entity) continue;
					if(entity.label == name) return entity;
				}
				return null;
		}
		public function getItemIndex(item:ICustomMenuItem):int {
			return _items.indexOf(item);
			
		}
		
		/* INTERFACE com.moonshineproject.plugin.menu.interfaces.IMenuEntity */
	
		
		public function get menu():ICustomMenu{
			return null;
		}
		
		public function set menu(value:ICustomMenu):void{
			
		}
		
		
		
	}

}
