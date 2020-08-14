////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.ui.editor
{
	import flash.events.Event;
	
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.FlexEvent;
	
	import actionScripts.events.AddTabEvent;
	import actionScripts.events.ChangeEvent;
	import actionScripts.events.PreviewPluginEvent;
	import actionScripts.factory.FileLocation;
    import actionScripts.utils.MavenPomUtil;

    import flash.events.Event;

	import mx.events.CollectionEvent;
    import mx.events.CollectionEventKind;
    import mx.events.FlexEvent;
    
    import actionScripts.events.AddTabEvent;
    import actionScripts.events.ChangeEvent;
    import actionScripts.impls.IVisualEditorLibraryBridgeImp;
    import actionScripts.interfaces.IVisualEditorViewer;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.plugins.help.view.VisualEditorView;
    import actionScripts.plugins.help.view.events.VisualEditorEvent;
    import actionScripts.plugins.help.view.events.VisualEditorViewChangeEvent;
    import actionScripts.plugins.ui.editor.text.UndoManagerVisualEditor;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.ui.editor.text.TextEditor;
    import actionScripts.ui.tabview.CloseTabEvent;
    import actionScripts.ui.tabview.TabEvent;

    import view.suportClasses.events.PropertyEditorChangeEvent;
	import flash.filesystem.File;
	import actionScripts.impls.IVisualEditorLibraryBridgeImp;
	import actionScripts.interfaces.IVisualEditorProjectVO;
	import actionScripts.interfaces.IVisualEditorViewer;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.ondiskproj.vo.OnDiskProjectVO;
	import actionScripts.plugins.help.view.VisualEditorView;
	import actionScripts.plugins.help.view.events.VisualEditorEvent;
	import actionScripts.plugins.help.view.events.VisualEditorViewChangeEvent;
	import actionScripts.plugins.ui.editor.text.UndoManagerVisualEditor;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.editor.text.TextEditor;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.ui.tabview.TabEvent;
	import actionScripts.utils.MavenPomUtil;
	import actionScripts.valueObjects.ProjectVO;
	
	import view.suportClasses.events.PropertyEditorChangeEvent;

	import mx.controls.Alert;
	
	public class VisualEditorViewer extends BasicTextEditor implements IVisualEditorViewer
	{
		private static const EVENT_SWITCH_TAB_TO_CODE:String = "switchTabToCode";

		private var visualEditorView:VisualEditorView;
		private var hasChangedProperties:Boolean;
		
		private var visualEditorProject:ProjectVO;
		private var visualEditoryLibraryCore:IVisualEditorLibraryBridgeImp;
		private var undoManager:UndoManagerVisualEditor;
		
		public function get editorView():VisualEditorView
		{
			return visualEditorView;
		}
		
		public function VisualEditorViewer(visualEditorProject:ProjectVO = null)
		{
			this.visualEditorProject = visualEditorProject;
			
			super();
		}
		
		override protected function initializeChildrens():void
		{
			isVisualEditor = true;
			
			// at this moment prifefaces projects only using the bridge
			// this condition can be remove if requires
			if ((visualEditorProject as IVisualEditorProjectVO).isPrimeFacesVisualEditorProject || (visualEditorProject as IVisualEditorProjectVO).isDominoVisualEditorProject)
			{
				visualEditoryLibraryCore = new IVisualEditorLibraryBridgeImp();
				visualEditoryLibraryCore.visualEditorProject = visualEditorProject;
			}
			
			visualEditorView = new VisualEditorView();
			
			if((visualEditorProject as IVisualEditorProjectVO).isDominoVisualEditorProject){
				visualEditorView.currentState = "dominoVisualEditor" 
			}else if((visualEditorProject as IVisualEditorProjectVO).isPrimeFacesVisualEditorProject){
				visualEditorView.currentState = "primeFacesVisualEditor" 
			}else{
				visualEditorView.currentState = "flexVisualEditor";
			}

			
			visualEditorView.visualEditorProject = visualEditorProject;
			
			visualEditorView.percentWidth = 100;
			visualEditorView.percentHeight = 100;
			visualEditorView.addEventListener(FlexEvent.CREATION_COMPLETE, onVisualEditorCreationComplete);
			visualEditorView.addEventListener(VisualEditorViewChangeEvent.CODE_CHANGE, onVisualEditorViewCodeChange);
			
			undoManager = new UndoManagerVisualEditor(visualEditorView);
			
			editor = new TextEditor(true);
			editor.percentHeight = 100;
			editor.percentWidth = 100;
			editor.addEventListener(ChangeEvent.TEXT_CHANGE, handleTextChange);
			editor.dataProvider = "";
			
			visualEditorView.codeEditor = editor;
			
			dispatcher.addEventListener(AddTabEvent.EVENT_ADD_TAB, addTabHandler);
			dispatcher.addEventListener(CloseTabEvent.EVENT_CLOSE_TAB, closeTabHandler);
			dispatcher.addEventListener(TabEvent.EVENT_TAB_SELECT, tabSelectHandler);
			dispatcher.addEventListener(VisualEditorEvent.DUPLICATE_ELEMENT, duplicateSelectedElementHandler);
			dispatcher.addEventListener(PreviewPluginEvent.PREVIEW_START_COMPLETE, previewStartCompleteHandler);
			dispatcher.addEventListener(PreviewPluginEvent.PREVIEW_STOPPED, previewStoppedHandler);
			dispatcher.addEventListener(PreviewPluginEvent.PREVIEW_START_FAILED, previewStartFailedHandler);
			dispatcher.addEventListener(PreviewPluginEvent.PREVIEW_STARTING, previewStartingHandler);

			model.editors.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleEditorCollectionChange);
		}

		protected function handleEditorCollectionChange(event:CollectionEvent):void
		{
			if (event.kind == CollectionEventKind.REMOVE && event.items[0] == this)
			{
				visualEditorView.removeEventListener(FlexEvent.CREATION_COMPLETE, onVisualEditorCreationComplete);
				visualEditorView.removeEventListener(VisualEditorViewChangeEvent.CODE_CHANGE, onVisualEditorViewCodeChange);
				
				if (visualEditorView.visualEditor)
				{
					visualEditorView.visualEditor.editingSurface.removeEventListener(Event.CHANGE, onEditingSurfaceChange);
					visualEditorView.visualEditor.editingSurface.removeEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_ITEM_ADDING, onEditingSurfaceItemAdded);
					visualEditorView.visualEditor.componentsOrganizer.removeEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_ITEM_MOVED, onPropertyEditorChanged);
					visualEditorView.visualEditor.propertyEditor.removeEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_CHANGED, onPropertyEditorChanged);
					visualEditorView.visualEditor.propertyEditor.removeEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_ITEM_DELETING, onPropertyEditorChanged);
					visualEditorView.visualEditor.removeEventListener("saveCode", onVisualEditorSaveCode);
				}
				
				dispatcher.removeEventListener(AddTabEvent.EVENT_ADD_TAB, addTabHandler);
				dispatcher.removeEventListener(VisualEditorEvent.DUPLICATE_ELEMENT, duplicateSelectedElementHandler);
				dispatcher.removeEventListener(PreviewPluginEvent.PREVIEW_START_COMPLETE, previewStartCompleteHandler);
				dispatcher.removeEventListener(PreviewPluginEvent.PREVIEW_STOPPED, previewStoppedHandler);
				dispatcher.removeEventListener(PreviewPluginEvent.PREVIEW_START_FAILED, previewStartFailedHandler);
				dispatcher.removeEventListener(PreviewPluginEvent.PREVIEW_STARTING, previewStartingHandler);
				dispatcher.removeEventListener(EVENT_SWITCH_TAB_TO_CODE, switchTabToCodeHandler);

				model.editors.removeEventListener(CollectionEvent.COLLECTION_CHANGE, handleEditorCollectionChange);
				undoManager.dispose();
			}
		}

		private function onVisualEditorCreationComplete(event:FlexEvent):void
		{
			visualEditorView.removeEventListener(FlexEvent.CREATION_COMPLETE, onVisualEditorCreationComplete);
			
			visualEditorView.visualEditor.editingSurface.addEventListener(Event.CHANGE, onEditingSurfaceChange);
			visualEditorView.visualEditor.editingSurface.addEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_ITEM_ADDING, onEditingSurfaceItemAdded);
			visualEditorView.visualEditor.componentsOrganizer.addEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_ITEM_MOVED, onPropertyEditorChanged);
			visualEditorView.visualEditor.propertyEditor.addEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_CHANGED, onPropertyEditorChanged);
			visualEditorView.visualEditor.propertyEditor.addEventListener(PropertyEditorChangeEvent.PROPERTY_EDITOR_ITEM_DELETING, onPropertyEditorChanged);
            visualEditorView.visualEditor.addEventListener("saveCode", onVisualEditorSaveCode);
			visualEditorView.addEventListener("startPreview", onStartPreview);

			visualEditorView.visualEditor.moonshineBridge = visualEditoryLibraryCore;
			visualEditorView.visualEditor.visualEditorFilePath = this.currentFile.fileBridge.nativePath;

			dispatcher.addEventListener(EVENT_SWITCH_TAB_TO_CODE, switchTabToCodeHandler);
		}

		private function previewStartCompleteHandler(event:PreviewPluginEvent):void
		{
			visualEditorView.currentState = "primeFacesVisualEditor";
		}

		private function previewStartingHandler(event:PreviewPluginEvent):void
		{
			visualEditorView.currentState = "primeFacesPreviewStarting";
		}

		private function previewStoppedHandler(event:PreviewPluginEvent):void
		{
			visualEditorView.currentState = "primeFacesVisualEditor";
		}

		private function previewStartFailedHandler(event:PreviewPluginEvent):void
		{
			visualEditorView.currentState = "primeFacesVisualEditor";
		}

		private function onVisualEditorSaveCode(event:Event):void
		{
            _isChanged = true;
			this.save();
		}

		private function switchTabToCodeHandler(event:Event):void
		{
			visualEditorView.viewStack.selectedIndex = 1;
		}

        private function duplicateSelectedElementHandler(event:Event):void
        {
			visualEditorView.visualEditor.duplicateSelectedElement();
        }

        override protected function createChildren():void
		{
			addElement(visualEditorView);
			
			super.createChildren();
		}
		
		override public function save():void
		{
			visualEditorView.visualEditor.saveEditedFile();
			editor.dataProvider = getMxmlCode();
			hasChangedProperties = false;
			
			super.save();

			refreshFileForPreview();
		}

        private function refreshFileForPreview():void
        {
			if ((visualEditorProject as IVisualEditorProjectVO).isPrimeFacesVisualEditorProject)
			{
				var mavenBuildPath:String;
				if (visualEditorProject is AS3ProjectVO)
				{
					mavenBuildPath = (visualEditorProject as AS3ProjectVO).mavenBuildOptions.buildPath;
				}
				else if (visualEditorProject is OnDiskProjectVO)
				{
					mavenBuildPath = (visualEditorProject as OnDiskProjectVO).mavenBuildOptions.buildPath;
				}
				
				var separator:String = file.fileBridge.separator;
				var mavenPomPath:String = mavenBuildPath.concat(separator, "pom.xml");
				var targetPath:String = mavenBuildPath.concat(separator, "target");

				var pomLocation:FileLocation = new FileLocation(mavenPomPath);
				var targetLocation:FileLocation = new FileLocation(targetPath);

				if (pomLocation.fileBridge.exists && targetLocation.fileBridge.exists)
                {
                    var projectName:String = MavenPomUtil.getProjectId(pomLocation);
                    var projectVersion:String = MavenPomUtil.getProjectVersion(pomLocation);
					var destinationFolderLocation:FileLocation = new FileLocation(targetPath.concat(separator, projectName, "-", projectVersion));
					if (destinationFolderLocation.fileBridge.exists)
					{
						var srcFolderLocation:FileLocation = visualEditorProject.sourceFolder;
						var relativePath:String = currentFile.fileBridge.nativePath.replace(srcFolderLocation.fileBridge.nativePath, "");
						var destinationFilePath:String = destinationFolderLocation.fileBridge.nativePath.concat(relativePath);
						var destinationFile:FileLocation = destinationFolderLocation.resolvePath(destinationFilePath);

						currentFile.fileBridge.copyTo(destinationFile, true);
					}
                }
			}
        }
		
		override protected function openHandler(event:Event):void
		{
			super.openHandler(event);
			
			createVisualEditorFile();
		}
		
		override protected function updateChangeStatus():void
		{
			if (hasChangedProperties)
			{
				_isChanged = true;
			}
			else
			{
				_isChanged = editor.hasChanged;
				if (!_isChanged)
				{
					_isChanged = visualEditorView.visualEditor.editingSurface.hasChanged;
				}
			}
			
			dispatchEvent(new Event('labelChanged'));
		}
		
		private function onEditingSurfaceChange(event:Event):void
		{
			updateChangeStatus();
		}
		
		private function onPropertyEditorChanged(event:PropertyEditorChangeEvent):void
		{
			undoManager.handleChange(event);
			
			hasChangedProperties = _isChanged = true;
			dispatchEvent(new Event('labelChanged'));
		}
		
		private function onEditingSurfaceItemAdded(event:PropertyEditorChangeEvent):void
		{
			undoManager.handleChange(event);
		}

		private function onVisualEditorViewCodeChange(event:VisualEditorViewChangeEvent):void
		{
			editor.dataProvider = getMxmlCode();

			updateChangeStatus()
		}

		private function addTabHandler(event:Event):void
		{
			if (!visualEditorView.visualEditor) return;
			
			visualEditorView.visualEditor.editingSurface.selectedItem = null;
		}
		
		override protected function closeTabHandler(event:CloseTabEvent):void
		{
			super.closeTabHandler(event);
			
			if (!visualEditorView.visualEditor) return;

			var tmpEvent:CloseTabEvent = event as CloseTabEvent;
			if (tmpEvent.tab.hasOwnProperty("editor") && tmpEvent.tab["editor"] == this.editor)
			{
				visualEditorView.visualEditor.editingSurface.removeEventListener(Event.CHANGE, onEditingSurfaceChange);
				visualEditorView.visualEditor.propertyEditor.removeEventListener("propertyEditorChanged", onPropertyEditorChanged);
				visualEditorView.visualEditor.editingSurface.selectedItem = null;
			}
		}
		
		override protected function tabSelectHandler(event:TabEvent):void
		{
			if (!visualEditorView.visualEditor) return;
			super.tabSelectHandler(event);
			
			if (!event.child.hasOwnProperty("editor") || event.child["editor"] != this.editor)
			{
				visualEditorView.visualEditor.editingSurface.selectedItem = null;
			}
			else
			{
				visualEditorView.setFocus();
				visualEditorView.visualEditor.visualEditorFilePath = this.currentFile.fileBridge.nativePath;
				visualEditorView.visualEditor.moonshineBridge = visualEditoryLibraryCore;
			}
		}

		private function onStartPreview(event:Event):void
		{
			if (visualEditorView.currentState == "primeFacesVisualEditor")
			{
				dispatcher.dispatchEvent(new PreviewPluginEvent(PreviewPluginEvent.START_VISUALEDITOR_PREVIEW, file, visualEditorProject as AS3ProjectVO));
			}
		}

		private function getMxmlCode():String
		{
			var mxmlCode:XML = null;

			if((visualEditorProject as IVisualEditorProjectVO).isDominoVisualEditorProject){			
				mxmlCode=visualEditorView.visualEditor.editingSurface.toDominoCode(getDominoFormFileName());
			}else if(file.fileBridge.nativePath.lastIndexOf(".form")>=0){
				mxmlCode=visualEditorView.visualEditor.editingSurface.toDominoCode(getDominoFormFileName());
			} 
			else{
				mxmlCode=visualEditorView.visualEditor.editingSurface.toCode();
			
			}
			var markAsXml:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
			
			return markAsXml + mxmlCode.toXMLString();
		}
		
		private function createVisualEditorFile():void
		{
			var veFilePath:String = getVisualEditorFilePath();
			if (veFilePath)
			{
				visualEditorView.visualEditor.loadFile(veFilePath);
			}
		}

		private function getDominoFormFileName():String
		{
			var fullPath:String = getVisualEditorFilePath();
			//maybe this will broken on windows env ,it need be improve in next
			var fileName:String = fullPath.substr(fullPath.lastIndexOf("/") + 1);
			fileName = fileName.slice(0, -4);
			return fileName;
		}
		
		private function getVisualEditorFilePath():String
		{
			if ((visualEditorProject as IVisualEditorProjectVO).visualEditorSourceFolder)
			{
				var filePath:String = file.fileBridge.nativePath
						.replace(visualEditorProject.sourceFolder.fileBridge.nativePath,
								(visualEditorProject as IVisualEditorProjectVO).visualEditorSourceFolder.fileBridge.nativePath)
						.replace(/.mxml$|.xhtml$|.form$/, ".xml");
			
				return filePath;
			}

			return null;
		}
	}
}