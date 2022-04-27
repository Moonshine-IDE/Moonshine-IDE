/*
	Copyright 2022 Prominic.NET, Inc.

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License

	Author: Prominic.NET, Inc.
	No warranty of merchantability or fitness of any kind.
	Use this software at your own risk.
 */

package actionScripts.impls;

import flash.display.NativeMenu;
import flash.display.NativeMenuItem;
import flash.events.Event;
import flash.ui.ContextMenu;
import mx.utils.ObjectUtil;
import actionScripts.interfaces.IContextMenuBridge;
import haxe.Constraints.Function;

class IContextMenuBridgeImp implements IContextMenuBridge {
	public function getContextMenu():ContextMenu {
		return (new ContextMenu());
	}

	public function getContextMenuItem(title:String, ?listener:Dynamic->Void, forState:String = null, hasSeparatorBefore:Bool = false):Dynamic {
		var tmpCMI:NativeMenuItem = (title != null) ? new NativeMenuItem(title, hasSeparatorBefore) : new NativeMenuItem(null, true);
		if (listener != null)
			tmpCMI.addEventListener(forState, listener, false, 0, true);
		return tmpCMI;
	}

	public function subMenu(menuOf:Dynamic, menuItem:Dynamic = null, extendedListner:Dynamic->Void) {
		if (cast(menuOf, NativeMenuItem).submenu == null)
			cast(menuOf, NativeMenuItem).submenu = new NativeMenu();

		if (menuItem != null && (Std.isOfType(menuItem, Array))) {
			for (i in cast(menuItem, Array<Dynamic>)) {
				// TODO: possible hack required
				// flash.net.registerClassAlias("flash.display.NativeMenuItem", NativeMenuItem);
				// var tmpCMI:NativeMenuItem = ObjectUtil.copy(i) as NativeMenuItem;
				var tmpCMI:NativeMenuItem = cast ObjectUtil.copy(i);

				// Dynamic copying removes it's listeners thus adding it again
				if (extendedListner != null)
					tmpCMI.addEventListener(Event.SELECT, extendedListner, false, 0, true);

				cast(menuOf, NativeMenuItem).submenu.addItem(tmpCMI);
			}
		} else if (menuItem != null)
			cast(menuOf, NativeMenuItem).submenu.addItem(cast(menuItem, NativeMenuItem));
	}

	public function removeAll(menuOf:Dynamic) {
		if (cast(menuOf, NativeMenuItem).submenu != null)
			cast(menuOf, NativeMenuItem).submenu.removeAllItems();
	}

	public function addItem(menuOf:Dynamic, menuItem:Dynamic) {
		cast(menuOf, ContextMenu).addItem(cast(menuItem, NativeMenuItem));
	}
}