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
package actionScripts.plugins.ui.editor.dominoFormBuilder
{
	import flash.events.Event;
	import flash.filesystem.File;
	
	import mx.events.CloseEvent;
	import mx.managers.IFocusManagerComponent;
	
	import spark.components.Alert;
	import spark.components.Group;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.factory.FileLocation;
	import actionScripts.impls.IDominoFormBuilderLibraryBridgeImp;
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.console.ConsoleOutputEvent;
	import actionScripts.plugin.ondiskproj.vo.OnDiskProjectVO;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.IContentWindowReloadable;
	import actionScripts.ui.IFileContentWindow;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.ui.tabview.TabEvent;
	import actionScripts.utils.FileUtils;
	
	import view.dominoFormBuilder.DominoTabularForm;
	import view.dominoFormBuilder.vo.DominoFormVO;
	import view.suportClasses.events.PropertyEditorChangeEvent;
	import view.suportClasses.events.VisualEditorEvent;
	
	public class DominoFormBuilderWrapper extends Group implements IContentWindow, IFileContentWindow, IFocusManagerComponent, IContentWindowReloadable
	{
		private static const FORM_GENERATION_PATH:String = OnDiskProjectVO.DOMINO_EXPORT_PATH +"/odp/Forms/";
		private static const VIEW_GENERATION_PATH:String = OnDiskProjectVO.DOMINO_EXPORT_PATH +"/odp/Views/";
		
		public function get longLabel():String							{ return "Tabular Interface"; }
		public function get tabularEditorInterface():DominoTabularForm	{ return dominoTabularForm; }
		
		private var _currentFile:FileLocation;
		
		public function get currentFile():FileLocation					{ return _currentFile;	}
		public function set currentFile(value:FileLocation):void		{ throw Error('No SET option available.'); }
		
		public function get projectPath():String						{ return (project ? project.folderLocation.fileBridge.nativePath : null); }
			
		public function get label():String
		{
			var labelChangeIndicator:String = _isChanged ? "*" : "";
			if (!currentFile)
			{
				return labelChangeIndicator + longLabel;
			}
			
			return labelChangeIndicator + currentFile.fileBridge.name;
		}
		
		
		protected var dominoTabularForm:DominoTabularForm;
		
		private var project:OnDiskProjectVO;
		private var visualEditoryLibraryCore:IDominoFormBuilderLibraryBridgeImp;
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var model:IDEModel = IDEModel.getInstance();
		private var formObject:DominoFormVO;
		
		/**
		 * CONSTRUCTOR
		 */
		public function DominoFormBuilderWrapper(file:FileLocation, project:OnDiskProjectVO=null)
		{
			super();
			this.project = project;
			this._currentFile = file;
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
			// text before save
			if (dominoTabularForm.isFormValid)
			{
				formObject = dominoTabularForm.formObject;
				
				// save form-dxl
				saveFormDXL();
			}
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
			
			visualEditoryLibraryCore = new IDominoFormBuilderLibraryBridgeImp();
			dominoTabularForm.moonshineBridge = visualEditoryLibraryCore;
			dominoTabularForm.filePath = currentFile.fileBridge.getFile as File;
			
			dominoTabularForm.addEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_CHANGED, onTabularInterfaceEditorChange, false, 0, true);
			dominoTabularForm.addEventListener(VisualEditorEvent.SAVE_CODE, onTabularInterfaceEditorSaveRequest, false, 0, true);
			
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
		
		protected function onTabularInterfaceEditorSaveRequest(event:VisualEditorEvent):void
		{
			save();
		}
		
		protected function updateChangeStatus():void
		{
			_isChanged = true;
			dispatchEvent(new Event('labelChanged'));
		}
		
		private function closeTabHandler(event:CloseTabEvent):void
		{
			if (event.tab == this)
			{
				removeGlobalListeners();
				dominoTabularForm.dispose();
				
				dominoTabularForm.removeEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_CHANGED, onTabularInterfaceEditorChange);
				dominoTabularForm.removeEventListener(VisualEditorEvent.SAVE_CODE, onTabularInterfaceEditorSaveRequest);
				
				formObject = null;
			}
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
		
		private function saveFormDXL():void
		{
			var formDXL:XML = dominoTabularForm.formDXL;
			var tmpDXLFileName:String = formObject.formName +".form";
			var dxlFile:FileLocation = project.folderLocation.fileBridge.resolvePath(
				FORM_GENERATION_PATH + tmpDXLFileName
			);
			
			// try to validate if the dxl have being
			// generated by the caller .fdb file
			if (dxlFile.fileBridge.exists && 
				(!formObject.dxlGeneratedOn || 
				((dxlFile.fileBridge.modificationDate.getTime() - formObject.dxlGeneratedOn.getTime()) > 1000)))
			{
				Alert.show(
					"Are you sure you want to overwrite the "+ formObject.formName +" Form? Any external changes will be lost.", 
					"Note!",
					Alert.YES | Alert.NO, null, 
					onWriteDXLConfirm
				);
			}
			else
			{
				onWriteDXLConfirm(null);
			}
			
			/*
			 * @local
			 */
			function onWriteDXLConfirm(event:CloseEvent):void 
			{
				if (!event || (event.detail == Alert.YES))
				{
					FileUtils.writeToFile(
						dxlFile.fileBridge.getFile as File,
						"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"+ formDXL.toXMLString()
					);
					
					// going to save in dfb/xml as last
					// modified date of .form
					formObject.dxlGeneratedOn = new Date();
					saveContinue();
				}
			}
		}
		
		private function saveContinue():void
		{
			// save form-xml
			saveFormXML(dominoTabularForm.formXML);
			
			// save view-dxl
			saveViewDXL(dominoTabularForm.viewDXL);
			
			// remove changed marker in tab
			_isChanged = false;
			dispatchEvent(new Event('labelChanged'));
			
			// output in console
			var tmpMessage:String = "Form Builder successfully saved and DXL generated at:\n"+ 
				FORM_GENERATION_PATH + formObject.formName +".form";
			dispatcher.dispatchEvent(
				new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, tmpMessage, false, false, ConsoleOutputEvent.TYPE_SUCCESS)
			);
		}
		
		private function saveViewDXL(value:XML):void
		{
			XML.ignoreComments = false;
			
			var tmpDXLFileName:String = formObject.formName +".view";
			var dxlFile:FileLocation = project.folderLocation.fileBridge.resolvePath(
				VIEW_GENERATION_PATH + tmpDXLFileName
			);
			
			FileUtils.writeToFile(
				dxlFile.fileBridge.getFile as File,
				"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"+ value.toXMLString()
			);
		}
		
		private function saveFormXML(value:XML):void
		{
			if (!currentFile.fileBridge.exists)
			{
				currentFile.fileBridge.createFile();
			}
			
			var data:XML = <root/>;
			XML.ignoreComments = false;
			
			data.appendChild(value);
			
			FileUtils.writeToFile(
				currentFile.fileBridge.getFile as File,
				"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"+ data.toXMLString()
			);
		}
	}
}