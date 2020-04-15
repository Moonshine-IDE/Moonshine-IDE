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
package actionScripts.plugins.ui.editor.tabularInterface
{
	import flash.events.Event;
	import flash.filesystem.File;
	
	import mx.managers.IFocusManagerComponent;
	
	import spark.components.Group;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.factory.FileLocation;
	import actionScripts.impls.ITabularInterfaceEditorLibraryBridgeImp;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.ondiskproj.vo.OnDiskProjectVO;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.IContentWindowReloadable;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.ui.tabview.TabEvent;
	
	import view.suportClasses.events.PropertyEditorChangeEvent;
	import view.tabularInterface.DominoTabularForm;
	
	public class TabularInterfaceEditorWrapper extends Group implements IContentWindow, IFocusManagerComponent, IContentWindowReloadable
	{
		public function get longLabel():String							{ return "Tabular Interface"; }
		public function get tabularEditorInterface():DominoTabularForm	{ return dominoTabularForm; }
		
		private var _file:FileLocation;
		public function get file():FileLocation							{ return _file; }

		public function get label():String
		{
			var labelChangeIndicator:String = _isChanged ? "*" : "";
			if (!file)
			{
				return labelChangeIndicator + longLabel;
			}
			
			return labelChangeIndicator + file.fileBridge.name;
		}
		
		protected var dominoTabularForm:DominoTabularForm;
		
		private var project:OnDiskProjectVO;
		private var visualEditoryLibraryCore:ITabularInterfaceEditorLibraryBridgeImp;
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var model:IDEModel = IDEModel.getInstance();
		
		/**
		 * CONSTRUCTOR
		 */
		public function TabularInterfaceEditorWrapper(file:FileLocation, project:OnDiskProjectVO=null)
		{
			super();
			this.project = project;
			this._file = file;
			this.percentWidth = this.percentHeight = 100;
			
			addGlobalListeners();
			
			addDominoTabularForm();
		}
		
		//--------------------------------------------------------------------------
		//
		//  INTERFACE API
		//
		//--------------------------------------------------------------------------
		
		public function save():void
		{
		}
		
		private var _isChanged:Boolean;
		public function isChanged():Boolean
		{
			return _isChanged;
		}
		
		public function isEmpty():Boolean
		{
			return false;
		}
		
		public function reload():void
		{
		}
		
		public function checkFileIfChanged():void
		{
		}
		
		//--------------------------------------------------------------------------
		//
		//  PROTECTED API
		//
		//--------------------------------------------------------------------------
		
		protected function addDominoTabularForm():void
		{
			dominoTabularForm = new DominoTabularForm();
			dominoTabularForm.percentWidth = dominoTabularForm.percentHeight = 100;
			
			visualEditoryLibraryCore = new ITabularInterfaceEditorLibraryBridgeImp();
			dominoTabularForm.moonshineBridge = visualEditoryLibraryCore;
			dominoTabularForm.filePath = file.fileBridge.getFile as File;
			
			dominoTabularForm.addEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_CHANGED, onTabularInterfaceEditorChange, false, 0, true);
			
			addElement(dominoTabularForm);
		}
		
		//--------------------------------------------------------------------------
		//
		//  LISTENERS API
		//
		//--------------------------------------------------------------------------
		
		protected function onTabularInterfaceEditorChange(event:PropertyEditorChangeEvent):void
		{
			updateChangeStatus()
		}
		
		protected function updateChangeStatus():void
		{
			_isChanged = true;
			dispatchEvent(new Event('labelChanged'));
		}
		
		private function closeTabHandler(event:CloseTabEvent):void
		{
			removeGlobalListeners();
			dominoTabularForm.dispose();
			
			dominoTabularForm.removeEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_CHANGED, onTabularInterfaceEditorChange);
		}
		
		private function tabSelectHandler(event:TabEvent):void
		{
			if (event.child == this)
			{
				model.activeProject = project;
				this.setFocus();
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  PRIVATE API
		//
		//--------------------------------------------------------------------------
		
		private function addGlobalListeners():void
		{
			dispatcher.addEventListener(CloseTabEvent.EVENT_CLOSE_TAB, closeTabHandler);
			dispatcher.addEventListener(TabEvent.EVENT_TAB_SELECT, tabSelectHandler);
		}
		
		private function removeGlobalListeners():void
		{
			dispatcher.removeEventListener(CloseTabEvent.EVENT_CLOSE_TAB, closeTabHandler);
			dispatcher.removeEventListener(TabEvent.EVENT_TAB_SELECT, tabSelectHandler);
		}
	}
}