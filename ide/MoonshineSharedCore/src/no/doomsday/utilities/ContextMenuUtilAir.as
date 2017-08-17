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
package no.doomsday.utilities
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.ContextMenuEvent;
	import flash.ui.ContextMenu;
	
	import actionScripts.locator.IDEModel;
	
	import no.doomsday.console.core.DConsole;
	import no.doomsday.console.core.introspection.ScopeManager;
	import no.doomsday.console.core.messages.MessageTypes;
	import no.doomsday.console.core.references.ReferenceManager;
	import no.doomsday.utilities.controller.ControllerManager;
	import no.doomsday.utilities.measurement.MeasurementTool;

	/**
	 * ...
	 * @author Andreas Rønning
	 */
	public class ContextMenuUtilAir
	{
		private static var console:DConsole;
		private static var referenceManager:ReferenceManager;
		private static var scopeManager:ScopeManager;
		private static var controllerManager:ControllerManager;
		private static var measureBracket:MeasurementTool;
		private static var consoleMenu:ContextMenu;
		private static var model:IDEModel = IDEModel.getInstance();
		
		public function ContextMenuUtilAir() 
		{
			
		}
		public static function setUp(console:DConsole, root:DisplayObjectContainer = null):void {
			getReferences(console);
			
			consoleMenu = model.contextMenuCore.getContextMenu();
			model.contextMenuCore.addItem(consoleMenu, model.contextMenuCore.getContextMenuItem("Log", console.log, ContextMenuEvent.MENU_ITEM_SELECT));
			model.contextMenuCore.addItem(consoleMenu, model.contextMenuCore.getContextMenuItem("Screenshot", console.screenshot, ContextMenuEvent.MENU_ITEM_SELECT));
			model.contextMenuCore.addItem(consoleMenu, model.contextMenuCore.getContextMenuItem("Hide", console.toggleDisplay, ContextMenuEvent.MENU_ITEM_SELECT));
			model.contextMenuCore.addItem(consoleMenu, model.contextMenuCore.getContextMenuItem("Performance Stats", console.toggleStats, ContextMenuEvent.MENU_ITEM_SELECT));
			console.contextMenu = consoleMenu;
			
			if (!root) return;
			var baseMenu:ContextMenu = model.contextMenuCore.getContextMenu();
			
			model.contextMenuCore.addItem(baseMenu, model.contextMenuCore.getContextMenuItem("Toggle console", onConsoleToggle, ContextMenuEvent.MENU_ITEM_SELECT));
			model.contextMenuCore.addItem(baseMenu, model.contextMenuCore.getContextMenuItem("Set console scope", onSelectionMenu, ContextMenuEvent.MENU_ITEM_SELECT));
			model.contextMenuCore.addItem(baseMenu, model.contextMenuCore.getContextMenuItem("Create controller", onControllerMenu, ContextMenuEvent.MENU_ITEM_SELECT));
			model.contextMenuCore.addItem(baseMenu, model.contextMenuCore.getContextMenuItem("Create reference", onReferenceMenu, ContextMenuEvent.MENU_ITEM_SELECT));
			model.contextMenuCore.addItem(baseMenu, model.contextMenuCore.getContextMenuItem("Get measurements", onMeasureMenu, ContextMenuEvent.MENU_ITEM_SELECT));
			
			if (!root.contextMenu) root.contextMenu = model.contextMenuCore.getContextMenu();
			root.contextMenu = baseMenu;
		}
		private static function getReferences(c:DConsole):void {
			console = c;
			var a:Array = console.getManagerRefs();
			scopeManager = a[0];
			referenceManager = a[1];
			controllerManager = a[2];
			measureBracket = a[3];
		}
		private static function onConsoleToggle(e:ContextMenuEvent):void 
		{
			console.toggleDisplay();
		}
		
		private static function onMeasureMenu(e:ContextMenuEvent):void 
		{
			var target:DisplayObject = e.mouseTarget;
			if (target != console.root) {
				measureBracket.bracket(target);
			}else {
				console.print("Unable to bracket root", MessageTypes.ERROR);
			}
			console.show();
		}
		private static function onReferenceMenu(e:ContextMenuEvent):void 
		{
			var target:DisplayObject = e.mouseTarget;
			console.show();
			referenceManager.createReference(target);
		}
		
		private static function onControllerMenu(e:ContextMenuEvent):void 
		{
			var target:DisplayObject = e.mouseTarget;
			if (target is DisplayObject) {
				console.show();
				if (target == console.root) {
					console.print("Unable to create default controller for root", MessageTypes.ERROR);
					return;
				}
				scopeManager.setScope(target);
				var properties:Array = ["name","x", "y", "width", "height", "rotation", "scaleX", "scaleY"];
				controllerManager.createController(scopeManager.currentScope.obj, properties, e.mouseTarget.x, e.mouseTarget.y);
				console.print("Controller created. Type values to alter, or use the mousewheel on numbers.");
			}
		}
		
		private static function onSelectionMenu(e:ContextMenuEvent):void 
		{
			scopeManager.setScope(e.mouseTarget);
		}
		
	}

}