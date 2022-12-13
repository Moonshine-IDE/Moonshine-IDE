////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.ui.editor
{
	import flash.events.Event;
	import flash.filesystem.File;
	import actionScripts.utils.UtilsCore;

	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.FlexEvent;

	import actionScripts.events.AddTabEvent;
	import actionScripts.events.PreviewPluginEvent;
	import actionScripts.events.TreeMenuItemEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.impls.IVisualEditorLibraryBridgeImp;
	import actionScripts.interfaces.IVisualEditorProjectVO;
	import actionScripts.interfaces.IVisualEditorViewer;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.ondiskproj.vo.OnDiskProjectVO;
	import actionScripts.plugins.help.view.VisualEditorView;
	import actionScripts.plugins.help.view.events.VisualEditorEvent;
	import actionScripts.plugins.help.view.events.VisualEditorViewChangeEvent;
	import actionScripts.plugins.ui.editor.text.UndoManagerVisualEditor;
	import actionScripts.ui.FeathersUIWrapper;
	import actionScripts.ui.editor.BasicTextEditor;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.ui.tabview.TabEvent;
	import actionScripts.utils.MavenPomUtil;
	import actionScripts.utils.SharedObjectUtil;
	import actionScripts.valueObjects.ProjectVO;

	import moonshine.editor.text.TextEditor;
	import moonshine.editor.text.events.TextEditorChangeEvent;

	import view.suportClasses.events.PropertyEditorChangeEvent;
	import flash.filesystem.File;
	import actionScripts.utils.DominoUtils;
	import spark.components.Alert;
	import mx.collections.ArrayList;

	import utils.GenericUtils;
	import mx.collections.ArrayCollection;

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
			
			editor = new TextEditor("", true);
			editorWrapper = new FeathersUIWrapper(editor);
			editorWrapper.percentHeight = 100;
			editorWrapper.percentWidth = 100;
			editor.addEventListener(TextEditorChangeEvent.TEXT_CHANGE, handleTextChange);
			
			visualEditorView.codeEditor = editorWrapper;
			
			dispatcher.addEventListener(AddTabEvent.EVENT_ADD_TAB, addTabHandler);
			dispatcher.addEventListener(CloseTabEvent.EVENT_CLOSE_TAB, closeTabHandler);
			dispatcher.addEventListener(TabEvent.EVENT_TAB_SELECT, tabSelectHandler);
			dispatcher.addEventListener(VisualEditorEvent.DUPLICATE_ELEMENT, duplicateSelectedElementHandler);
			dispatcher.addEventListener(PreviewPluginEvent.PREVIEW_START_COMPLETE, previewStartCompleteHandler);
			dispatcher.addEventListener(PreviewPluginEvent.PREVIEW_STOPPED, previewStoppedHandler);
			dispatcher.addEventListener(PreviewPluginEvent.PREVIEW_START_FAILED, previewStartFailedHandler);
			dispatcher.addEventListener(PreviewPluginEvent.PREVIEW_STARTING, previewStartingHandler);
			dispatcher.addEventListener(TreeMenuItemEvent.FILE_RENAMED, fileRenamedHandler);

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
				dispatcher.removeEventListener(TreeMenuItemEvent.FILE_RENAMED, fileRenamedHandler);

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

			visualEditorView.visualEditor.editingSurface.subFormList=getSubFromList();
			visualEditorView.visualEditor.dominoActionOrganizer.dominoActionsProEditor=getDominoActionList();
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

		private function fileRenamedHandler(event:TreeMenuItemEvent):void
		{
			reload();

			//if we rename the subfrom , we already update the intermedial xml,
			//so we must force update the form/subfrom in the visualEditor,otherwise,after user save it .
			//the update will be overwrite and we will got some duplication element in the dxl and xml both all.
			//Alert.show("tab:"+visualEditorView.tabBar.dataProvider.length);
			for(var i:int=0;i<visualEditorView.tabBar.dataProvider.length;i++){
				var	visualeEditorView:Object =visualEditorView.tabBar.dataProvider.getItemAt(i);
				if(visualeEditorView){
					
					var visualEditor:Object=  visualeEditorView.contentGroup.getElementAt(0) ;
					if(visualEditor){
						if( visualEditor.hasOwnProperty("visualEditorFilePath")){
							var fileLocation:FileLocation=new FileLocation(visualEditor.visualEditorFilePath);
							if(fileLocation.fileBridge.exists){
								//we should only let follow code with form&subfrom file.
								//these code clean the old design element in the surface editor and inital it again,
								//after user click the tab, it will loading latest xml into surface, this is why we get the duplication element .
								if(fileLocation.fileBridge.extension=="form" || fileLocation.fileBridge.extension=="subform"){
									var data:Object=fileLocation.fileBridge.read();
									visualEditor.editingSurface.deleteAllByEditingSureface(visualEditor.editingSurface);
									
									var xml:XML = new XML("<mockup/>");
									visualEditor.editingSurface.fromXMLByEditingSurface(xml,visualEditor.editingSurface);
								}

								
							
							}
							
						}
						
					}
				}
				
			}

			//update the subform for rename action
			if(visualEditorView.visualEditor.editingSurface){
				visualEditorView.visualEditor.editingSurface.subFormList=getSubFromList();
				visualEditorView.visualEditor.dominoActionOrganizer.dominoActionsProEditor=getDominoActionList();
			}

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
			editor.text = getMxmlCode();
			hasChangedProperties = false;
			
			super.save();

			//this line for sync .dve file to ODP form folder file
			if(visualEditorProject is OnDiskProjectVO){
				if((visualEditorProject as OnDiskProjectVO).isDominoVisualEditorProject){
					var sourceVisualPath:String=(visualEditorProject as OnDiskProjectVO).visualEditorSourceFolder.fileBridge.nativePath;
					//visualeditor-src/main/webapp
					var targetProjectPath:String = sourceVisualPath.substring(0, sourceVisualPath.lastIndexOf("visualeditor-src"));
					var targetProject:FileLocation=new FileLocation(targetProjectPath);
					var fileName:String=this.currentFile.fileBridge.name;
					fileName= fileName.substring(0, fileName.lastIndexOf(".dve"));
					
					//this.currentFile.fileBridge.nativePath
					// var original_form:FileLocation =  templateDir.resolvePath("src_domino_nsfs"+File.separator +"nsf-moonshine"+File.separator+"odp"+File.separator+"Forms"+File.separator+"Template.form");
					if(this.currentFile.fileBridge.exists){
						var newFormFile:FileLocation =  targetProject.resolvePath("nsfs"+File.separator+"nsf-moonshine"+File.separator+"odp"+File.separator+"Forms"+File.separator+fileName + ".form"); 
						this.currentFile.fileBridge.copyTo(newFormFile, true); 
					}
				}
			}

			refreshFileForPreview();
		}

		/**
		 *When user rename the form file, it require the title match the file name.
		 *So in this case , we need save the form file again
		 */

		public function renameDominoFormFileSave(fileName:String):String 
		{
			//visualEditorView.visualEditor.saveEditedFile();
			return getDominoMxmlCode(fileName);
			

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
				_isChanged = editor.edited;
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
			editor.text = getMxmlCode();

			updateChangeStatus()
		}

		private function addTabHandler(event:Event):void
		{
			if (!visualEditorView.visualEditor) return;
			
			visualEditorView.visualEditor.editingSurface.selectedItem = null;
		}
		
		override protected function closeTabHandler(event:Event):void
		{
			super.closeTabHandler(event);
			
			if (!visualEditorView.visualEditor) return;

			if (model.activeEditor == this)
			{
				visualEditorView.visualEditor.editingSurface.removeEventListener(Event.CHANGE, onEditingSurfaceChange);
				visualEditorView.visualEditor.propertyEditor.removeEventListener("propertyEditorChanged", onPropertyEditorChanged);
				visualEditorView.visualEditor.editingSurface.selectedItem = null;
				
				SharedObjectUtil.removeLocationOfEditorFile(model.activeEditor);
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
				//when it swtich back the current view edtior , it need reload the sub from again
				if(visualEditorView.visualEditor.editingSurface){
					visualEditorView.visualEditor.editingSurface.subFormList=getSubFromList();
					visualEditorView.visualEditor.dominoActionOrganizer.dominoActionsProEditor=getDominoActionList();
				}


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
			var mxmlString:String="";
			

			if((visualEditorProject as IVisualEditorProjectVO).isDominoVisualEditorProject){			
				mxmlCode=visualEditorView.visualEditor.editingSurface.toDominoCode(getDominoFormFileName());
				mxmlString=DominoUtils.fixDominButton(mxmlCode);
			}else if(file.fileBridge.nativePath.lastIndexOf(".form")>=0 || file.fileBridge.nativePath.lastIndexOf(".subform")>=0){
				mxmlCode=visualEditorView.visualEditor.editingSurface.toDominoCode(getDominoFormFileName());
				mxmlString=DominoUtils.fixDominButton(mxmlCode);
			} 
			else{
				mxmlCode=visualEditorView.visualEditor.editingSurface.toCode();
				mxmlString= mxmlCode.toXMLString();
			
			}
			//mxmlString=mxmlString.replace(/(?=\s)[^\r\n\t]/g, ' ');
			var markAsXml:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
			
			return markAsXml +mxmlString;
		}

		private function getDominoMxmlCode(fileName:String):String
		{
			var mxmlCode:XML = null;
			mxmlCode=visualEditorView.visualEditor.editingSurface.toDominoCode(fileName);
			var markAsXml:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
			var mxmlString:String=DominoUtils.fixDominButton(mxmlCode);
			return markAsXml + mxmlString;
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
			var visualEditorProjectSourcedPath:String = (visualEditorProject as IVisualEditorProjectVO).visualEditorSourceFolder.fileBridge.nativePath;
			
			if ((visualEditorProject as IVisualEditorProjectVO).visualEditorSourceFolder)
			{
				
				var filePath:String = file.fileBridge.nativePath;
				var fileSoucePath:String = visualEditorProject.sourceFolder.fileBridge.nativePath

				
				if(filePath.indexOf(".page")>=0){
					fileSoucePath=fileSoucePath.replace("Forms","");
					filePath=filePath.replace(fileSoucePath,visualEditorProjectSourcedPath+File.separator);

					filePath=filePath.replace(/.mxml$|.xhtml$|.form$|.page$|.dve$/, ".xml");
					filePath=filePath.replace("Pages","pages");	
				}if(filePath.indexOf(".subform")>=0){
					filePath= visualEditorProjectSourcedPath+File.separator+"subforms"+File.separator+file.fileBridge.name;
					filePath=filePath.replace(/.mxml$|.xhtml$|.subform$|.page$|.dve$/, ".xml");
					
				}else{
					filePath=filePath.replace(visualEditorProject.sourceFolder.fileBridge.nativePath,visualEditorProjectSourcedPath).replace(/.mxml$|.xhtml$|.form$|.dve$|.subform$/, ".xml");	
				}
				
							
				return filePath;
			}

			return null;
		}

		/** 
		* This function will loading the subfrom list file from project folder
		*/

		private function getSubFromList():ArrayList {
			var subforms:ArrayList = new ArrayList();
				subforms.addItem({label: "none",value: "none",description:"none"});
			var fileSoucePath:String = visualEditorProject.sourceFolder.fileBridge.nativePath
			fileSoucePath=fileSoucePath.replace("Forms","SharedElements");
			fileSoucePath=fileSoucePath+File.separator+"Subforms";
			var directory:File = new File(fileSoucePath);
			if (directory.exists) {
				var list:Array = directory.getDirectoryListing();
				for (var i:uint = 0; i < list.length; i++) {
					if(UtilsCore.endsWith(list[i].nativePath,"form")){
						var subFromFile:String=list[i].name.substring(0,list[i].nativePath.length-5);
						subFromFile=subFromFile.replace(".subform","");
						subforms.addItem(  {label: subFromFile,value: subFromFile,description:list[i].nativePath});
						
							
					}
					
				}
			}
			
			

			//sort the subfrom 
			 if(subforms.length>0){
                var arry:ArrayCollection= new ArrayCollection(subforms.toArray());

                arry=GenericUtils.arrayCollectionSort(arry,"label",false);
                
				subforms=new ArrayList();
				for each(var item:Object in arry)
				{
					subforms.addItem(item);
					
				}
				

            }
			
			
			return subforms;
		}

		/** 
		* This function will loading the domino action list file from project folder
		*/
		public function getDominoActionList():ArrayList {
			
			var actionsList:ArrayList = new ArrayList();
				actionsList.addItem({label: "none",value: "none",description:"none"});
			var fileSoucePath:String = visualEditorProject.sourceFolder.fileBridge.nativePath
			fileSoucePath=fileSoucePath.replace("Forms","SharedElements");
			fileSoucePath=fileSoucePath+File.separator+"Actions";
			var directory:File = new File(fileSoucePath);
			if (directory.exists) {
				var list:Array = directory.getDirectoryListing();
				for (var i:uint = 0; i < list.length; i++) {
					
						var actionFile:String=list[i].name.substring(0,list[i].nativePath.length-4);
						actionFile=actionFile.replace(".xml","");
						actionsList.addItem(  {label: actionFile,value: actionFile,description:list[i].nativePath});		
					
				}
			}
			
			

			//sort the actionsList 
			 if(actionsList.length>0){
                var arry:ArrayCollection= new ArrayCollection(actionsList.toArray());

                arry=GenericUtils.arrayCollectionSort(arry,"label",false);
                
				actionsList=new ArrayList();
				for each(var item:Object in arry)
				{
					actionsList.addItem(item);
					
				}
				

            }
			
			
			return actionsList;

		}
	}
}