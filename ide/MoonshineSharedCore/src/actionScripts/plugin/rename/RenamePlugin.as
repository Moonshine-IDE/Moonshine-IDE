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
package actionScripts.plugin.rename
{
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.utils.clearTimeout;
    import flash.utils.setTimeout;
    
    import mx.controls.Alert;
    import mx.core.FlexGlobals;
    import mx.events.CloseEvent;
    import mx.managers.PopUpManager;
    
    import actionScripts.events.DuplicateEvent;
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.events.NewFileEvent;
    import actionScripts.events.RenameEvent;
    import actionScripts.events.TreeMenuItemEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.plugin.PluginBase;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.plugin.recentlyOpened.RecentlyOpenedPlugin;
    import moonshine.plugin.rename.view.RenameFileView;
    import moonshine.plugin.rename.view.RenameSymbolView;
    import actionScripts.ui.IContentWindow;
    import actionScripts.ui.editor.BasicTextEditor;
    import actionScripts.ui.editor.LanguageServerTextEditor;
    import actionScripts.utils.CustomTree;
    import actionScripts.utils.TextUtil;
    import actionScripts.utils.UtilsCore;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.FileWrapper;
    import actionScripts.valueObjects.ProjectReferenceVO;
    
    import components.popup.newFile.NewFilePopup;
    import actionScripts.ui.FeathersUIWrapper;
    import actionScripts.ui.menu.MenuPlugin;
    import moonshine.lsp.WorkspaceEdit;
    import moonshine.lsp.Position;
    import actionScripts.utils.applyWorkspaceEdit;

	import flash.filesystem.File;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import actionScripts.plugin.actionscript.as3project.importer.FlashDevelopImporter;

	import actionScripts.utils.DominoUtils;
	import actionScripts.plugins.ui.editor.DominoViewEditor;
	public class RenamePlugin extends PluginBase
	{
		private var renameSymbolViewWrapper:FeathersUIWrapper;
		private var renameSymbolView:RenameSymbolView;
		private var newFilePopup:NewFilePopup;
		private var renameFileViewWrapper:FeathersUIWrapper;
		private var renameFileView:RenameFileView;
		
		public function RenamePlugin()
		{
			renameSymbolView = new RenameSymbolView();
			renameSymbolView.addEventListener(Event.CLOSE, renameSymbolView_closeHandler);
			renameSymbolViewWrapper = new FeathersUIWrapper(renameSymbolView);
		}

		override public function get name():String { return "Rename Plugin"; }
		override public function get author():String { return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String { return "Rename a symbol in a project."; }
		
		private var _line:int;
		private var _startChar:int;
		private var _endChar:int;
		private var _existingFilePath:String;

		override public function activate():void
		{
			super.activate();
			dispatcher.addEventListener(RenameEvent.EVENT_OPEN_RENAME_SYMBOL_VIEW, handleOpenRenameSymbolView);
			dispatcher.addEventListener(RenameEvent.EVENT_OPEN_RENAME_FILE_VIEW, handleOpenRenameFileView);
			dispatcher.addEventListener(DuplicateEvent.EVENT_OPEN_DUPLICATE_FILE_VIEW, handleOpenDuplicateFileView);
		}

		override public function deactivate():void
		{
			super.deactivate();
			dispatcher.removeEventListener(RenameEvent.EVENT_OPEN_RENAME_SYMBOL_VIEW, handleOpenRenameSymbolView);
			dispatcher.removeEventListener(RenameEvent.EVENT_OPEN_RENAME_FILE_VIEW, handleOpenRenameFileView);
			dispatcher.removeEventListener(DuplicateEvent.EVENT_OPEN_DUPLICATE_FILE_VIEW, handleOpenDuplicateFileView);
		}

		private function handleOpenRenameSymbolView(event:Event):void
		{
			var lspEditor:LanguageServerTextEditor = model.activeEditor as LanguageServerTextEditor;
			if (!lspEditor || !lspEditor.languageClient)
			{
				Alert.show("Nothing to rename", ConstantsCoreVO.MOONSHINE_IDE_LABEL);
				return;
			}
			var lineText:String = lspEditor.editor.caretLine.text;
			var caretIndex:int = lspEditor.editor.caretCharIndex;
			this._startChar = TextUtil.startOfWord(lineText, caretIndex);
			this._endChar = TextUtil.endOfWord(lineText, caretIndex);
			this._line = lspEditor.editor.caretLineIndex;
			renameSymbolView.existingSymbolName = lineText.substr(this._startChar, this._endChar - this._startChar);
			PopUpManager.addPopUp(renameSymbolViewWrapper, FlexGlobals.topLevelApplication as DisplayObject, true);
			PopUpManager.centerPopUp(renameSymbolViewWrapper);
			renameSymbolViewWrapper.assignFocus("top");
			renameSymbolViewWrapper.stage.addEventListener(Event.RESIZE, renameSymbolView_stage_resizeHandler, false, 0, true);
		}
		
		private function renameSymbolView_closeHandler(event:Event):void
		{
			var lspEditor:LanguageServerTextEditor = model.activeEditor as LanguageServerTextEditor;
			if(!lspEditor || !lspEditor.languageClient)
			{
				return;
			}
			
			if(renameSymbolView.newSymbolName != null)
			{
				var startLine:int = lspEditor.editor.caretLineIndex;
				var startChar:int = lspEditor.editor.caretCharIndex;
				lspEditor.languageClient.rename({
					textDocument: {
						uri: lspEditor.currentFile.fileBridge.url
					},
					position: new Position(startLine, startChar),
					newName: renameSymbolView.newSymbolName
				}, function(edit:WorkspaceEdit):void
				{
					if(!edit)
					{
						return;
					}
					applyWorkspaceEdit(edit);
				});
			}
			
			renameSymbolViewWrapper.stage.removeEventListener(Event.RESIZE, renameSymbolView_stage_resizeHandler);
			PopUpManager.removePopUp(renameSymbolViewWrapper);
		}

		private function renameSymbolView_stage_resizeHandler(event:Event):void
		{
			PopUpManager.centerPopUp(renameSymbolViewWrapper);
		}

		private function renameFileView_stage_resizeHandler(event:Event):void
		{
			PopUpManager.centerPopUp(renameFileViewWrapper);
		}
		
		private function handleOpenRenameFileView(event:RenameEvent):void
		{
			if (!(event.changes as FileWrapper).file.fileBridge.checkFileExistenceAndReport()) return;
			
			if (!renameFileView)
			{
				renameFileView = new RenameFileView();
				renameFileView.fileWrapper = event.changes as FileWrapper;
				renameFileView.addEventListener(Event.CLOSE, handleRenameFileViewClose);
				renameFileViewWrapper = new FeathersUIWrapper(renameFileView);
		

			

				PopUpManager.addPopUp(renameFileViewWrapper, FlexGlobals.topLevelApplication as DisplayObject, true);
				PopUpManager.centerPopUp(renameFileViewWrapper);
				renameFileViewWrapper.assignFocus("top");
				renameFileViewWrapper.stage.addEventListener(Event.RESIZE, renameFileView_stage_resizeHandler, false, 0, true);
				
				dispatcher.dispatchEvent(new Event(MenuPlugin.CHANGE_MENU_MAC_DISABLE_STATE));
			}
		}
		
		private function handleRenameFileViewClose(event:Event):void
		{
			if(renameFileView.newName != null)
			{
				onFileRenamedRequest(renameFileView.fileWrapper, renameFileView.newName);
			}

			dispatcher.dispatchEvent(new Event(MenuPlugin.CHANGE_MENU_MAC_ENABLE_STATE));

			renameFileView.removeEventListener(CloseEvent.CLOSE, handleRenameFileViewClose);
			renameFileView = null;

			renameFileViewWrapper.stage.removeEventListener(Event.RESIZE, renameFileView_stage_resizeHandler);
			PopUpManager.removePopUp(renameFileViewWrapper);
			renameFileViewWrapper = null;
		}
		
		private function onFileRenamedRequest(fileWrapper:FileWrapper, newName:String):void
		{
			var fileVisualEditor:FileLocation = UtilsCore.getVisualEditorSourceFile(fileWrapper);
			
			var sourceFileName:String =fileWrapper.file.fileBridge.nameWithoutExtension;
			var newFile:FileLocation;
			var sourceFormName:String =null;

			
			if(fileWrapper.file.fileBridge.extension=="column"){
				newName=TextUtil.fixDominoViewName(newName);
			}
			var newFile = fileWrapper.file.fileBridge.parent.resolvePath(newName);
			var newNameWithOutExtension = newFile.fileBridge.nameWithoutExtension;
			if(fileWrapper.file.fileBridge.extension=="form"){
				sourceFormName=sourceFileName;
			}

			if(fileWrapper.file.fileBridge.extension=="view"){
				newFile = fileWrapper.file.fileBridge.parent.resolvePath(TextUtil.fixDominoViewName(newName));
			}else{
				newFile = fileWrapper.file.fileBridge.parent.resolvePath(newName);
			}

			_existingFilePath = fileWrapper.nativePath;
			var newFileNameWithoutExtension:String = newFile.fileBridge.nameWithoutExtension;
			
			fileWrapper.file.fileBridge.moveTo(newFile, false);
			fileWrapper.name = newFile.name;
			fileWrapper.file = newFile;

			//Alert.show("newFile.name:"+newFile.name);

			if (fileVisualEditor)
			{
				var newVisualEditorFile:FileLocation = fileVisualEditor.fileBridge.parent.resolvePath(newFile.fileBridge.nameWithoutExtension + ".xml");
				if(fileWrapper.file.fileBridge.extension=="form" ||fileWrapper.file.fileBridge.extension=="page" ){
					DominoUtils.dominoWindowTitleUpdate(fileVisualEditor,newFileNameWithoutExtension,sourceFileName);
				}

				if(fileWrapper.file.fileBridge.extension=="page"){
					DominoUtils.dominoPageUpdateWithoutSave(newFile,newFileNameWithoutExtension,sourceFileName);
				}
			
				//dominoViewTitleUpdateWithoutSave
				fileVisualEditor.fileBridge.moveTo(newVisualEditorFile, false);	
					
			}

			if(fileWrapper.file.fileBridge.extension=="view"){
				DominoUtils.dominoViewTitleUpdateWithoutSave(newFile,newFileNameWithoutExtension,newFileNameWithoutExtension);
			}

			if(fileWrapper.file.fileBridge.extension=="column"){
				// update and Synchronize column file name into column name
				DominoUtils.dominoSharedColumnNameUpdate(newFile,newFileNameWithoutExtension);
				//sourceFileName
				var replaceName:String= TextUtil.fixDominoViewName(sourceFileName);
				var sourceColumnNameFormat:String= TextUtil.toDominoViewNormalName(replaceName);
				//newFielname
				replaceName=TextUtil.fixDominoViewName(newNameWithOutExtension);
				var newColumnNameFormat:String= TextUtil.toDominoViewNormalName(replaceName);
				var currentProjectPath:String=UtilsCore.getProjectFolder(fileWrapper);
				if(currentProjectPath){
					var currentProjectFolder:FileLocation = new FileLocation(currentProjectPath);
					replaceSharedColumnNameFromAllReferencesView(currentProjectFolder,sourceColumnNameFormat,newColumnNameFormat);
				}

			}

			// we need to update file location of the (if any) opened instance 
			// of the file template
			if (newFile.fileBridge.isDirectory)
			{
				updateChildrenPath(fileWrapper, _existingFilePath + newFile.fileBridge.separator, newFile.fileBridge.nativePath + newFile.fileBridge.separator);
			}
			else
			{
				checkAndUpdateOpenedTabs(_existingFilePath, newFile);
			}
			
			// updating the tree view
			var tree:CustomTree = model.mainView.getTreeViewPanel().tree;
			var tmpParent:FileWrapper = tree.getParentItem(fileWrapper);
		    // update the windows Title name and other name after page rename

			//update subfrom name in the old form/subfrom 
			var projectPath:String=UtilsCore.getProjectFolder(fileWrapper);
			if(projectPath){
				var projectFolder:FileLocation = new FileLocation(projectPath);
				
				replaceSubfromFromAllReferencesFilesXml(projectFolder,sourceFileName,newFileNameWithoutExtension);
				if(sourceFormName){
					replaceFormNameFromAllReferencesView(projectFolder,sourceFormName,newNameWithOutExtension);
					
				}
				
				
				
				//look for the project file from project folder  :
				var listing:Array = projectFolder.fileBridge.getDirectoryListing();
				var projectFile:FileLocation = null;
				for each (var file:Object in listing)
				{
					if (file.extension == "veditorproj")
					{
						projectFile=new FileLocation(file.nativePath);
					}
				}

				if(projectFile!=null){
					//create auto update file:
					var auto_fileLocation:FileLocation=new FileLocation(projectPath+File.separator+".xml_conversion_required");
						auto_fileLocation.fileBridge.save("");

					FlashDevelopImporter.convertDomino(projectFile);
				}
				
				//rename old simple view
				var viewfileToSave:FileLocation = new FileLocation( projectPath+ File.separator+"nsfs"+File.separator+"nsf-moonshine"+File.separator+"odp"+File.separator+"Views"+File.separator + "All By UNID_5cCRUD_5c"+sourceFileName +".view");
				var viewTargetfileToSave:FileLocation = new FileLocation( projectPath+ File.separator+"nsfs"+File.separator+"nsf-moonshine"+File.separator+"odp"+File.separator+"Views"+File.separator + "All By UNID_5cCRUD_5c"+newFileNameWithoutExtension +".view");
				if(viewfileToSave.fileBridge.exists){
					var viewcontent:String = String(viewfileToSave.fileBridge.read());
						var re:RegExp = new RegExp(sourceFileName, "g");
						viewcontent = viewcontent.replace(re, newFileNameWithoutExtension);
						viewTargetfileToSave.fileBridge.save(viewcontent);
						viewfileToSave.fileBridge.deleteFile();
					//create a new simple file with new form name 

				}

				
				
			}
			
			var timeoutValue:uint = setTimeout(function():void 
				{
					model.mainView.getTreeViewPanel().sortChildren(fileWrapper);
					
					var tmpFileW:FileWrapper = UtilsCore.findFileWrapperAgainstProject(fileWrapper, null, tmpParent);
					tree.selectedItem = tmpFileW;
					
					var indexToItemRenderer:int = tree.getItemIndex(tmpFileW);
					tree.callLater(tree.scrollToIndex, [indexToItemRenderer]);
					
					dispatcher.dispatchEvent(new TreeMenuItemEvent(TreeMenuItemEvent.FILE_RENAMED, null, fileWrapper));
					clearTimeout(timeoutValue);
				}, 300);
		}

		private  function replaceSubfromFromAllReferencesFilesXml(projectFolderLocation:FileLocation,sourceSubformName:String,targetSubformName:String):void{
			var xmlFileLocation:FileLocation = projectFolderLocation.resolvePath("visualeditor-src"+File.separator+"main"+File.separator+"webapp");
				var subformXmlFileLocation:FileLocation = projectFolderLocation.resolvePath("visualeditor-src"+File.separator+"main"+File.separator+"webapp"+File.separator+"subforms");
				
				if(xmlFileLocation.fileBridge.exists || subformXmlFileLocation.fileBridge.exists){
					var directory:Array = xmlFileLocation.fileBridge.getDirectoryListing();
					var subdirectory:Array = subformXmlFileLocation.fileBridge.getDirectoryListing();
					if(subdirectory){
						for each (var subxml:File in subdirectory)
						{
							directory.push(subxml);
						}
					}
					//add subfrom xml into directory ;
					

						for each (var xml:File in directory)
						{
							if (xml.extension == "xml" ) {
								var fileLocation:FileLocation=new FileLocation(xml.nativePath);
							
								//var data:String = ;
								var internalxml:XML = new XML(fileLocation.fileBridge.read());
								for each(var subformref:XML in internalxml..Subformref) //no matter of depth Note here
								{
									
									if(subformref.@subFormName==sourceSubformName){
										subformref.@subFormName=targetSubformName;
									}
								}

								// for each(var label:XML in internalxml..Label)
								// {
									
								// 	if(label.text()==sourceSubformName){
								// 		label.text=targetSubformName;
								// 	}
								// }
							

								//remove old file 
								fileLocation.fileBridge.deleteFile();
								var _targetfileStreamMoonshine:FileStream = new FileStream();
								_targetfileStreamMoonshine.open(xml, FileMode.WRITE);
								_targetfileStreamMoonshine.writeUTFBytes(internalxml.toXMLString());
								_targetfileStreamMoonshine.close();
							}
								
								
								//fileLocation.fileBridge.save(internalxml.toXMLString());

							
						}
				}
		}

		private  function replaceSharedColumnNameFromAllReferencesView(projectFolderLocation:FileLocation,sourceColumnName:String,targetColumnName:String):void{
			var viewFileLocation:FileLocation = projectFolderLocation.resolvePath("nsfs"+File.separator+"nsf-moonshine"+File.separator+"odp"+File.separator+"Views");
			if(viewFileLocation.fileBridge.exists){
				var directory:Array = viewFileLocation.fileBridge.getDirectoryListing();
				for each (var xml:File in directory)
				{
					if (xml.extension == "view" ) {
						var fileLocation:FileLocation=new FileLocation(xml.nativePath);
					
						//var data:String = ;
						var _isChangedColumnName:Boolean = false;
						var viewxml:XML = new XML(fileLocation.fileBridge.read());
						for each(var sharedColumn:XML in viewxml..sharedcolumnref){
							if(sharedColumn.@name==sourceColumnName){
								sharedColumn.@name=targetColumnName;
								_isChangedColumnName=true;
							}
						}

						if(_isChangedColumnName){
							fileLocation.fileBridge.deleteFile();
							var _targetfileStreamMoonshine:FileStream = new FileStream();
							_targetfileStreamMoonshine.open(xml, FileMode.WRITE);
							_targetfileStreamMoonshine.writeUTFBytes(viewxml.toXMLString());
							_targetfileStreamMoonshine.close();

							checkAndUpdateOpenedViewsInTab(fileLocation.fileBridge.nativePath);
						}
					}
				}
			}
		}

		private  function replaceFormNameFromAllReferencesView(projectFolderLocation:FileLocation,sourceFormName:String,targetFormName:String):void{
								
			var viewFileLocation:FileLocation = projectFolderLocation.resolvePath("nsfs"+File.separator+"nsf-moonshine"+File.separator+"odp"+File.separator+"Views");
			if(viewFileLocation.fileBridge.exists){
				var directory:Array = viewFileLocation.fileBridge.getDirectoryListing();
				for each (var xml:File in directory)
				{
					if (xml.extension == "view" ) {
						var fileLocation:FileLocation=new FileLocation(xml.nativePath);
					
						//var data:String = ;
						var viewxml:XML = new XML(fileLocation.fileBridge.read());

						if(viewxml.code[0]){
							if(viewxml.code[0].@event=="selection"){
								if(viewxml.code[0].formula[0]){
									var formulaNode:XML=viewxml.code[0].formula[0];
									var formulaText=formulaNode.text();
									if(formulaText.indexOf(sourceFormName)>0){

										var formulaText1:String=formulaText.substring(0,formulaText.indexOf(sourceFormName));
										var formulaText2:String=formulaText.substring(formulaText.indexOf(sourceFormName)+sourceFormName.length);
										
										formulaText=formulaText1+targetFormName+formulaText2;
										var newFormulaNode:XML = new XML("<formula>"+formulaText+"</formula>");
										formulaNode.parent().appendChild(newFormulaNode);
										delete formulaNode.parent().children()[formulaNode.childIndex()];
										fileLocation.fileBridge.deleteFile();
										var _targetfileStreamMoonshine:FileStream = new FileStream();
										_targetfileStreamMoonshine.open(xml, FileMode.WRITE);
										_targetfileStreamMoonshine.writeUTFBytes(viewxml.toXMLString());
										_targetfileStreamMoonshine.close();

										checkAndUpdateOpenedViewsInTab(fileLocation.fileBridge.nativePath);
									}
								}
								
							}
						}
					}
				}
			}

		}

		private  function replaceSubfromFromAllReferencesFiles(projectFolderLocation:FileLocation,sourceSubformName:String,targetSubformName:String):void{
			
			var formFolderPath:String = "nsfs"+File.separator+"nsf-moonshine"+File.separator+"odp"+File.separator+"Forms";
			var subFormFolderPath:String = "nsfs"+File.separator+"nsf-moonshine"+File.separator+"odp"+File.separator+"SharedElements"+File.separator+"Subforms";
			var formFileLocation:FileLocation = projectFolderLocation.resolvePath(formFolderPath);
			var subformFileLocation:FileLocation = projectFolderLocation.resolvePath(subFormFolderPath);
			
			if(formFileLocation.fileBridge.exists || subformFileLocation.fileBridge.exists){
				
				var directory:Array = formFileLocation.fileBridge.getDirectoryListing();
				var subdirectory:Array = subformFileLocation.fileBridge.getDirectoryListing();
				if(subdirectory){
					for each (var subxml:File in subdirectory)
					{
						directory.push(subxml);
					}
				}

				for each (var form:File in directory)
				{
					if (form.extension == "form" || form.extension == "subform") {
						
						var _fileStreamMoonshine:FileStream = new FileStream();
						_fileStreamMoonshine.open(form, FileMode.READ);
						var data:String = _fileStreamMoonshine.readUTFBytes(_fileStreamMoonshine.bytesAvailable);
						var xml:XML = new XML(data);
						
						var xmlns:Namespace = new Namespace("http://www.lotus.com/dxl");
						
						var subformList:XMLList=xml.xmlns::subform;
					
						for each(var subform:XML in xml..subform){
							
							if(subform.@name==sourceSubformName){
								subform.@name=targetSubformName;
							}
						}

						
						var subformrefList:XMLList=xml.xmlns::subformref;
						
	
						for each(var subform:XML in xml..subformref) //no matter of depth Note here
						{
							
							if(subform.@name==sourceSubformName){
								
								subform.@name=targetSubformName;
							}
						}

						//overwrite the old file  
										
						//_fileStreamMoonshine.writeUTFBytes(internalForm.toXMLString());
						_fileStreamMoonshine.close();
						//remove old file 
						// var fileLocation:FileLocation=new FileLocation(form.nativePath);
						// fileLocation.fileBridge.deleteFile();
						// fileLocation.fileBridge.save(internalForm);
					}
				}
			}
			
		}
		
		private function handleOpenDuplicateFileView(event:DuplicateEvent):void
		{
			if (!event.fileWrapper.file.fileBridge.checkFileExistenceAndReport()) return;
			
			if (!newFilePopup)
			{
				newFilePopup = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, NewFilePopup, true) as NewFilePopup;
				newFilePopup.addEventListener(CloseEvent.CLOSE, handleFilePopupClose);
				newFilePopup.addEventListener(DuplicateEvent.EVENT_APPLY_DUPLICATE, onFileDuplicateRequest);
				newFilePopup.openType = NewFilePopup.AS_DUPLICATE_FILE;
				newFilePopup.folderFileLocation = event.fileWrapper.file;
				
				var creatingItemIn:FileWrapper = FileWrapper(model.mainView.getTreeViewPanel().tree.getParentItem(event.fileWrapper));
				newFilePopup.wrapperOfFolderLocation = creatingItemIn;
				newFilePopup.wrapperBelongToProject = UtilsCore.getProjectFromProjectFolder(creatingItemIn);

				PopUpManager.centerPopUp(newFilePopup);
			}
		}
		
		private function handleFilePopupClose(event:CloseEvent):void
		{
			newFilePopup.removeEventListener(CloseEvent.CLOSE, handleFilePopupClose);
			newFilePopup.removeEventListener(NewFileEvent.EVENT_NEW_FILE, onFileDuplicateRequest);
			newFilePopup = null;
		}
		
		private function onFileDuplicateRequest(event:DuplicateEvent):void
		{
			var fileName:String=event.fileName ;
			if(event.fileLocation.fileBridge.extension && event.fileLocation.fileBridge.extension == "view"){
				fileName=TextUtil.fixDominoViewName(fileName);
			}
			var fileToSave:FileLocation = event.fileWrapper.file.fileBridge.resolvePath(fileName + 
				(event.fileLocation.fileBridge.extension ? "."+ event.fileLocation.fileBridge.extension : ""));
			
			// based on request, we also updates class name and package path
			// to the duplicated file, in case of actionScript class
			if (event.fileLocation.fileBridge.extension && event.fileLocation.fileBridge.extension == "as")
			{
				var updatedContent:String = getUpdatedFileContent(event.fileWrapper, event.fileLocation, event.fileName);
				fileToSave.fileBridge.save(updatedContent);
			}else if(event.fileLocation.fileBridge.extension && event.fileLocation.fileBridge.extension == "view"){
				var updatedViewContent:String =getDominoUpdatedFileContent(event.fileWrapper, event.fileLocation, event.fileName);
				fileToSave.fileBridge.save(updatedViewContent);
			}
			else
			{
				event.fileLocation.fileBridge.copyTo(fileToSave, true);
			}
			
			// opens the file after writing done
			/*dispatcher.dispatchEvent(
				new OpenFileEvent(OpenFileEvent.OPEN_FILE, fileToSave, -1, event.insideLocation)
			);*/
			
			// notify the tree view if it needs to refresh
			// the containing folder to make newly created file show
			if (event.fileWrapper)
			{
				dispatcher.dispatchEvent(
					new TreeMenuItemEvent(TreeMenuItemEvent.NEW_FILE_CREATED, fileToSave.fileBridge.nativePath, event.fileWrapper)
				);
			}
		}


		private function getDominoUpdatedFileContent(projectRef:FileWrapper, source:FileLocation, newFileName:String):String
		{
			var sourceContentXML:XML=new XML(source.fileBridge.read());
			
			newFileName=newFileName.replace(/[\/\\]+/g, "_5c");
			newFileName=newFileName.replace(/_5c/g, "\\");
			sourceContentXML.@name=newFileName;
			
			return sourceContentXML.toXMLString();
		}
		
		private function getUpdatedFileContent(projectRef:FileWrapper, source:FileLocation, newFileName:String):String
		{
			var sourceContentLines:Array = String(source.fileBridge.read()).split("\n");
			var classNameStartIndex:int;
			
			var nameOnly:Array = source.fileBridge.name.split(".");
			nameOnly.pop();
			var sourceFileName:String = nameOnly.join(".");
			
			var isPackageFound:Boolean;
			var isClassDecFound:Boolean;
			var isConstructorFound:Boolean;
			
			sourceContentLines = sourceContentLines.map(function(line:String, index:int, arr:Array):String
			{
				if (!isPackageFound && line.indexOf("package") !== -1)
				{
					isPackageFound = true;
					
					var project:AS3ProjectVO = UtilsCore.getProjectFromProjectFolder(projectRef) as AS3ProjectVO;
					var isInsideSourceDirectory:Boolean = source.fileBridge.nativePath.indexOf(project.sourceFolder.fileBridge.nativePath + source.fileBridge.separator) != -1;
					
					// do not update package path if not inside source directory
					if (isInsideSourceDirectory)
					{
						var tmpPackagePath:String = UtilsCore.getPackageReferenceByProjectPath(Vector.<FileLocation>([project.sourceFolder]), projectRef.nativePath, null, null, false);
						if (tmpPackagePath.charAt(0) == ".")
						{
							tmpPackagePath = tmpPackagePath.substr(1, tmpPackagePath.length);
						}
						
						return "package "+ tmpPackagePath;
					}
				}

                classNameStartIndex = line.indexOf(" class "+ sourceFileName);
				if (!isClassDecFound && classNameStartIndex !== -1)
				{
					isClassDecFound = true;
					return line.substr(0, classNameStartIndex + 7) + newFileName + line.substr(classNameStartIndex + 7 + sourceFileName.length, line.length);
				}

                classNameStartIndex = line.indexOf(" function "+ sourceFileName +"(");
				if (!isConstructorFound && classNameStartIndex !== -1)
				{
					isConstructorFound = true;
					return line.substr(0, classNameStartIndex + 10) + newFileName + line.substr(classNameStartIndex + 10 + sourceFileName.length, line.length);
				}

				return line;
			});

			return sourceContentLines.join("\n");
		}
		
		private function updateChildrenPath(fw:FileWrapper, oldPath:String, newPath:String):void
		{
			for each (var i:FileWrapper in fw.children)
			{
				_existingFilePath = i.file.fileBridge.nativePath;
				i.file = new FileLocation(i.file.fileBridge.nativePath.replace(oldPath, newPath));
				if (!i.children) 
				{
					checkAndUpdateOpenedTabs(_existingFilePath, i.file);
				}
				else updateChildrenPath(i, oldPath, newPath);
			}
		}

		//dominoViewEditor.dominoViewVisualEditor.loadFile(filePath);
		private function checkAndUpdateOpenedViewsInTab(filePath:String):void
		{
			for each (var tab:IContentWindow in model.editors)
			{
				var ed:BasicTextEditor = tab as BasicTextEditor;
				if (ed 
					&& ed.currentFile
					&& ed.currentFile.fileBridge.nativePath == filePath)
				{
					if(ed is DominoViewEditor){
						(ed as DominoViewEditor).openLoadingFile(filePath);
					}
					
					break;
				}
			}
		}
		private function checkAndUpdateOpenedTabs(oldPath:String, newFile:FileLocation):void
		{
			// updates to tab
			for each (var tab:IContentWindow in model.editors)
			{
				var ed:BasicTextEditor = tab as BasicTextEditor;
				if (ed 
					&& ed.currentFile
					&& ed.currentFile.fileBridge.nativePath == oldPath)
				{
					ed.currentFile = newFile;
					break;
				}
			}
			
			// updates entry in recent files list
			for each (var i:ProjectReferenceVO in model.recentlyOpenedFiles)
			{
				if (i.path == oldPath)
				{
					i.path = newFile.fileBridge.nativePath;
					i.name = newFile.name;
					GlobalEventDispatcher.getInstance().dispatchEvent(new Event(RecentlyOpenedPlugin.RECENT_FILES_LIST_UPDATED));
					break;
				}
			}
		}
	}
}