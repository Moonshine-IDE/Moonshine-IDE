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
package actionScripts.ui.editor
{
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.utils.clearInterval;
    import flash.utils.setTimeout;

    import mx.core.FlexGlobals;
    import mx.events.FlexEvent;
    import mx.managers.IFocusManagerComponent;
    import mx.managers.PopUpManager;
    import mx.utils.ObjectUtil;

    import spark.components.Group;

    import actionScripts.controllers.DataAgent;
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.events.RefreshTreeEvent;
    import actionScripts.events.SaveFileEvent;
    import actionScripts.events.UpdateTabEvent;
    import actionScripts.factory.FileLocation;
    import actionScripts.locator.IDEModel;
    import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
    import actionScripts.plugin.console.ConsoleOutputEvent;
    import actionScripts.plugin.texteditor.TextEditorPlugin;
    import actionScripts.plugin.texteditor.events.TextEditorSettingsEvent;
    import actionScripts.ui.FeathersUIWrapper;
    import actionScripts.ui.IContentWindow;
    import actionScripts.ui.IContentWindowReloadable;
    import actionScripts.ui.IFileContentWindow;
    import actionScripts.ui.editor.text.DebugHighlightManager;
    import actionScripts.ui.editor.text.events.DebugLineEvent;
    import actionScripts.ui.tabview.CloseTabEvent;
    import actionScripts.ui.tabview.TabEvent;
    import actionScripts.utils.SharedObjectUtil;
    import actionScripts.valueObjects.ConstantsCoreVO;
    import actionScripts.valueObjects.ProjectVO;
    import actionScripts.valueObjects.Settings;
    import actionScripts.valueObjects.URLDescriptorVO;

    import components.popup.FileSavePopup;
    import components.popup.SelectOpenedProject;
    import components.views.project.ProjectTreeView;

    import feathers.graphics.FillStyle;
    import feathers.skins.RectangleSkin;
    import feathers.utils.DisplayObjectFactory;

    import haxe.IMap;

    import moonshine.editor.text.TextEditor;
    import moonshine.editor.text.TextEditorSearchResult;
    import moonshine.editor.text.events.TextEditorChangeEvent;
    import moonshine.editor.text.events.TextEditorLineEvent;
    import moonshine.editor.text.lines.TextLineRenderer;
    import moonshine.editor.text.lsp.LspTextEditor;
    import moonshine.editor.text.lsp.lines.LspTextLineRenderer;
    import moonshine.editor.text.syntax.format.PlainTextFormatBuilder;
    import moonshine.editor.text.syntax.format.SyntaxColorSettings;
    import moonshine.editor.text.syntax.format.SyntaxFontSettings;
    import moonshine.editor.text.syntax.parser.PlainTextLineParser;

    public class BasicTextEditor extends Group implements IContentWindow, IFileContentWindow, IFocusManagerComponent, IContentWindowReloadable
	{
		public var defaultLabel:String = "New";
		public var projectPath:String;
		public var editor:TextEditor;
		public var lastOpenType:String;

		protected var editorWrapper:FeathersUIWrapper;		
		protected var lastOpenedUpdatedInMoonshine:Date;
		protected var file:FileLocation;
		protected var created:Boolean;
		protected var loadingFile:Boolean;
		protected var tempScrollTo:int = -1;
		protected var tempScrollToCaret:Boolean = false;
		protected var tempSelectionStartLineIndex:int = -1;
		protected var tempSelectionStartCharIndex:int = -1;
		protected var tempSelectionEndLineIndex:int = -1;
		protected var tempSelectionEndCharIndex:int = -1;
		protected var loader: DataAgent;
		protected var model:IDEModel = IDEModel.getInstance();
        protected var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
        protected var _isChanged:Boolean;

		private var pop:FileSavePopup;
		private var selectProjectPopup:SelectOpenedProject;
		protected var isVisualEditor:Boolean;

		private var _readOnly:Boolean = false;
		public function get readOnly():Boolean
		{
			return this._readOnly;
		}
		
		public function get label():String
		{
			var labelChangeIndicator:String = _isChanged ? "*" : "";
			if (!file)
            {
                return labelChangeIndicator + defaultLabel;
            }

			return labelChangeIndicator + file.fileBridge.name;
		}
		public function get longLabel():String
		{
			if (!file) 
				return defaultLabel;
			return file.fileBridge.nativePath;	
		}

		public function get currentFile():FileLocation
		{
			return file;
		}
		public function set currentFile(value:FileLocation):void
		{
			if (file != value)
            {
                file = value;
                dispatchEvent(new Event('labelChanged'));
            }
		}

		public function get text():String
		{
			return editor.text;
		}
		public function set text(value:String):void
		{
			editor.text = value;
		}

		private var _prevSearch:*;

		public function BasicTextEditor(readOnly:Boolean = false)
		{
			super();
			_readOnly = readOnly;
			
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
			
			percentHeight = 100;
			percentWidth = 100;
			addEventListener(FlexEvent.CREATION_COMPLETE, basicTextEditorCreationCompleteHandler);
			initializeChildrens();
		}

		public function isEmpty():Boolean
		{
			if (!file && text == "")
				return true;
			return false;
		}

		public function isChanged():Boolean
		{
			return _isChanged;
		}

		public function getEditorComponent():TextEditor
		{
			return editor;
		}
		
		// Search may be RegExp or String
		public function search(search:*, backwards:Boolean=false):TextEditorSearchResult
		{
			if(checkIfNewSearchMatchesPrevious(search))
			{
				return editor.findNext(backwards, true);
			}
			return editor.find(search, backwards);
		}
		
		// Search all instances and highlight
		// Preferably used in 'search in project' sequence
		public function searchAndShowAll(search:*):void
		{
			//editor.searchAndShowAll(search);
		}
		
		// Search may be RegExp or String
		public function searchReplace(search:*, replace:String, all:Boolean=false):TextEditorSearchResult
		{
			if(!checkIfNewSearchMatchesPrevious(search))
			{
				editor.find(search);
			}
			if(all)
			{
				return editor.replaceAll(replace)
			}
			return editor.replaceOne(replace);
		}

		public function clearSearch():void
		{
			_prevSearch = null;
			editor.clearFind();
		}

		protected function checkIfNewSearchMatchesPrevious(search:*):Boolean
		{
			var matches:Boolean = false;
			if(search is RegExp && _prevSearch is RegExp)
			{
				matches = search.toString() == _prevSearch.toString();
			}
			else if(search is String && _prevSearch is String)
			{
				matches = search == _prevSearch;
			}
			_prevSearch = search;
			return matches;
		}
		
		protected function addedToStageHandler(event:Event):void
		{
			this.addGlobalListeners();
			updateSyntaxColorScheme();
		}
		
		protected function removedFromStageHandler(event:Event):void
		{
			this.removeGlobalListeners();
		}
		
		protected function addGlobalListeners():void
		{
			dispatcher.addEventListener(CloseTabEvent.EVENT_CLOSE_TAB, closeTabHandler, false, 0, true);
			dispatcher.addEventListener(TabEvent.EVENT_TAB_SELECT, tabSelectHandler, false, 0, true);
			dispatcher.addEventListener(DebugLineEvent.SET_DEBUG_FINISH, setDebugFinishHandler, false, 0, true);
			dispatcher.addEventListener(TextEditorSettingsEvent.SYNTAX_COLOR_SCHEME_CHANGE, syntaxColorSchemeChangeHandler, false, 0, true);
		}
		
		protected function removeGlobalListeners():void
		{
			dispatcher.removeEventListener(CloseTabEvent.EVENT_CLOSE_TAB, closeTabHandler);
			dispatcher.removeEventListener(TabEvent.EVENT_TAB_SELECT, tabSelectHandler);
			dispatcher.removeEventListener(DebugLineEvent.SET_DEBUG_FINISH, setDebugFinishHandler);
			dispatcher.removeEventListener(TextEditorSettingsEvent.SYNTAX_COLOR_SCHEME_CHANGE, syntaxColorSchemeChangeHandler);
		}
		
		protected function closeTabHandler(event:Event):void
		{
			if (event is CloseTabEvent)
			{
				var closeEvent:CloseTabEvent = CloseTabEvent(event);
				if (closeEvent.tab != this || !closeEvent.isUserTriggered)
				{
					return;
				}
				SharedObjectUtil.removeLocationOfEditorFile(
					closeEvent.tab as IContentWindow
				);
			}
			// can be dispatched by menu item as a regular Event
			// instead of CloseTabEvent
			else if (model.activeEditor == this)
			{
				SharedObjectUtil.removeLocationOfEditorFile(model.activeEditor);
			}
		}
		
		protected function tabSelectHandler(event:TabEvent):void
		{
			if (event.child == this)
			{
				// check for any externally update
				checkFileIfChanged();
				editorWrapper.enabled = true;
			}
			else
			{
				editorWrapper.enabled = false;
			}
		}
		
		protected function initializeChildrens():void
		{
			if(!editor)
			{
				editor = new TextEditor(null, _readOnly);
			}
			if(!editor.parser)
			{
				editor.parser = new PlainTextLineParser();
			}
			editor.addEventListener(TextEditorChangeEvent.TEXT_CHANGE, handleTextChange);
			editor.addEventListener(TextEditorLineEvent.TOGGLE_BREAKPOINT, handleToggleBreakpoint);
			editorWrapper = new FeathersUIWrapper(editor);
			editorWrapper.percentHeight = 100;
			editorWrapper.percentWidth = 100;
			text = "";
		}

		override public function setFocus():void
		{
			if (editor)
			{
				editorWrapper.setFocus();
			}
		}

		override protected function createChildren():void
		{
			if (!isVisualEditor)
            {
				this.addElement(editorWrapper);
            }
			
			super.createChildren();
			
			// @note
			// https://github.com/Moonshine-IDE/Moonshine-IDE/issues/31
			// to ensure if the file has a pending debug/breakpoint call
			// call extended from OpenFileCommand/openFile(..)
			if (currentFile && currentFile.fileBridge.nativePath == DebugHighlightManager.NONOPENED_DEBUG_FILE_PATH)
			{
				editor.debuggerLineIndex = DebugHighlightManager.NONOPENED_DEBUG_FILE_LINE;
			}
		}

		protected function basicTextEditorCreationCompleteHandler(event:FlexEvent):void
		{
			removeEventListener(FlexEvent.CREATION_COMPLETE, basicTextEditorCreationCompleteHandler);
			
			created = true;
			if (file)
				callLater(open, [file]);
		}

		public function setSelection(startLine:int, startChar:int, endLine:int, endChar:int):void
		{
			if (loadingFile)
			{
				tempSelectionStartLineIndex = startLine;
				tempSelectionStartCharIndex = startChar;
				tempSelectionEndLineIndex = endLine;
				tempSelectionEndCharIndex = endChar;
			}
			else
			{
				editor.setSelection(startLine, startChar, endLine, endChar);
			}
		}

		public function scrollToCaret():void
		{
			if (loadingFile)
			{
				tempScrollTo = -1;
				tempScrollToCaret = true;
			}
			else
			{
				editor.scrollToCaret();
			}
		}

		public function scrollTo(line:int, eventType:String=null):void
		{
			if (loadingFile)
			{
				tempScrollToCaret = false;
				tempScrollTo = line;
			}
			else
			{
				editor.lineScrollY = line;
			}
		}
		
		public function setContent(content:String):void
		{
			editor.text = content;
			updateChangeStatus();
		}
		
		public function open(newFile:FileLocation, fileData:Object=null):void
		{
			loadingFile = true;
			currentFile = newFile;
			if (fileData) 
			{
				openFileAsStringHandler(fileData as String);
				return;
			}
			else if (!created || !file.fileBridge.exists)	return;
			
			file.fileBridge.getFile.addEventListener(Event.COMPLETE, openHandler);
			
			// Load later so we have time to draw before everything happens
			callLater(file.fileBridge.load);
		}
		
		public function checkFileIfChanged():void
		{
			// physical file do not exist anymore
			if (file && !file.fileBridge.exists)
			{
				dispatcher.dispatchEvent(new UpdateTabEvent(UpdateTabEvent.EVENT_TAB_FILE_EXIST_NOMORE, this));
			}
			
			// physical file is an updated one
			else if (lastOpenedUpdatedInMoonshine && 
				ObjectUtil.dateCompare(file.fileBridge.modificationDate, lastOpenedUpdatedInMoonshine) != 0)
			{
				dispatcher.dispatchEvent(new UpdateTabEvent(UpdateTabEvent.EVENT_TAB_UPDATED_OUTSIDE, this));
			}
		}
		
		public function reload():void
		{
			loadingFile = true;
			file.fileBridge.getFile.addEventListener(Event.COMPLETE, openHandler);
			callLater(file.fileBridge.load);
		}
		
		protected function openFileAsStringHandler(data:String):void
		{
			loadingFile = false;
			// Get data from file
			text = data;
			commitTempValues();
		}

		protected function openHandler(event:Event):void
		{
			loadingFile = false;
			// Get data from file
			text = file.fileBridge.data.toString();

			commitTempValues();
			updateChangeStatus();
			file.fileBridge.getFile.removeEventListener(Event.COMPLETE, openHandler);
		}

		public function save():void
		{
			if (!file)
			{
				saveAs();
				return;
			}

			if (ConstantsCoreVO.IS_AIR && !file.fileBridge.exists)
			{
				file.fileBridge.createFile();
				file.fileBridge.save(text);
				editor.save();
				updateChangeStatus();
				
				// Tell the world we've changed
				dispatcher.dispatchEvent(
					new SaveFileEvent(SaveFileEvent.FILE_SAVED, file, this)
				);
			}
			else if (ConstantsCoreVO.IS_AIR)
			{
				file.fileBridge.save(text);
				editor.save();
				updateChangeStatus();
				
				// Tell the world we've changed
				dispatcher.dispatchEvent(
					new SaveFileEvent(SaveFileEvent.FILE_SAVED, file, this)
				);
			}
			else if (!ConstantsCoreVO.IS_AIR)
			{
				dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, file.fileBridge.name +": Saving in process..."));
				loader = new DataAgent(URLDescriptorVO.FILE_MODIFY, onSaveSuccess, onSaveFault,
						{path:file.fileBridge.nativePath,text:text});
			}
		}
		
		private function onSaveFault(message:String):void
		{
			//Alert.show("Save Fault"+message);
			dispatcher.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, file.fileBridge.name +": Save error!"));
			loader = null;
		}
		
		private function onSaveSuccess(value:Object, message:String=null):void
		{
			//Alert.show("Save Fault"+message);
			loader = null;
			editor.save();
			updateChangeStatus();
			dispatcher.dispatchEvent(
					new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_OUTPUT, file.fileBridge.name +": Saving successful."));
			dispatcher.dispatchEvent(new SaveFileEvent(SaveFileEvent.FILE_SAVED, file, this));
		}
 
		public function saveAs(file:FileLocation=null):void
		{
			if (file)
			{
				currentFile = file;
				save();
				// Update labels
				dispatchEvent(new Event('labelChanged'));
				dispatcher.dispatchEvent(new RefreshTreeEvent(file));
			    return;
			}
			
			if (ConstantsCoreVO.IS_AIR)
			{ 
				if(this.file)
                {
                    saveAsPath(this.file.fileBridge.parent.fileBridge.nativePath);
                }
				else if (model.projects.length > 1 )
				{
					if (model.mainView.isProjectViewAdded)
					{
						var tmpTreeView:ProjectTreeView = model.mainView.getTreeViewPanel();
						if(tmpTreeView) //might be null if closed by user
						{
							var projectReference:ProjectVO = tmpTreeView.getProjectBySelection();
							if (projectReference)
							{
								saveAsPath(projectReference.folderPath);
								return;
							}
						}
					}
					selectProjectPopup = new SelectOpenedProject();
					PopUpManager.addPopUp(selectProjectPopup, FlexGlobals.topLevelApplication as DisplayObject, false);
					PopUpManager.centerPopUp(selectProjectPopup);
					selectProjectPopup.addEventListener(SelectOpenedProject.PROJECT_SELECTED, onProjectSelected);
					selectProjectPopup.addEventListener(SelectOpenedProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
				}
				else if (model.projects.length != 0)
				{
					saveAsPath((model.projects[0] as ProjectVO).folderPath);
				}
			    else
					saveAsPath(null)
			}
			else
			{
				pop = new FileSavePopup();
				PopUpManager.addPopUp(pop, FlexGlobals.topLevelApplication as DisplayObject, false);
				PopUpManager.centerPopUp(pop);
			}
			function saveAsPath(path:String):void{
				model.fileCore.browseForSave(handleSaveAsSelect, null, "Save As", path);
			}
			function onProjectSelected(event:Event):void
			{
				saveAsPath((selectProjectPopup.selectedProject as AS3ProjectVO).folderPath );
				onProjectSelectionCancelled(null);
			}
			function onProjectSelectionCancelled(event:Event):void
			{
				selectProjectPopup.removeEventListener(SelectOpenedProject.PROJECT_SELECTED, onProjectSelected);
				selectProjectPopup.removeEventListener(SelectOpenedProject.PROJECT_SELECTION_CANCELLED, onProjectSelectionCancelled);
				selectProjectPopup = null;
			}
		}
		
		public function onFileSaveSuccess(file:FileLocation=null):void
		{
			//saveAs(file);
			currentFile = file;
			dispatchEvent(new Event('labelChanged'));
			editor.save();
			dispatcher.dispatchEvent(new SaveFileEvent(SaveFileEvent.FILE_SAVED, file, this));
			updateChangeStatus();
		}
		
		protected function handleTextChange(event:TextEditorChangeEvent):void
		{
			if (editor.edited != _isChanged)
			{
				updateChangeStatus();	
			}
		}

		protected function handleToggleBreakpoint(event:TextEditorLineEvent):void
		{
			var lineIndex:int = event.lineIndex;
			var enabled:Boolean = editor.breakpoints.indexOf(lineIndex) != -1;
			dispatcher.dispatchEvent(new DebugLineEvent(DebugLineEvent.SET_DEBUG_LINE, lineIndex, enabled));
		}
		
		protected function updateChangeStatus():void
		{
			_isChanged = editor.edited;
			dispatchEvent(new Event('labelChanged'));
			
			var setLastUpdateTime:uint = setTimeout(function():void
			{
				clearInterval(setLastUpdateTime);
				lastOpenedUpdatedInMoonshine = file.fileBridge.modificationDate;
			}, 1000);
		}

		private function getColorSettings():SyntaxColorSettings
		{
			var colorSettings:SyntaxColorSettings;
			switch(model.syntaxColorScheme)
			{
				case TextEditorPlugin.SYNTAX_COLOR_SCHEME_DARK:
					return SyntaxColorSettings.defaultDark();
				case TextEditorPlugin.SYNTAX_COLOR_SCHEME_MONOKAI:
					return SyntaxColorSettings.monokai();
				default: // light
					return SyntaxColorSettings.defaultLight();
			}
		}

		private function updateSyntaxColorScheme():void
		{
			var colorSettings:SyntaxColorSettings = getColorSettings();
			if (editor.parser is PlainTextLineParser)
			{
				var formatBuilder:PlainTextFormatBuilder = new PlainTextFormatBuilder();
				formatBuilder.setFontSettings(new SyntaxFontSettings(Settings.font.defaultFontFamily, Settings.font.defaultFontSize));
				formatBuilder.setColorSettings(colorSettings);
				var formats:IMap = formatBuilder.build();
				editor.textStyles = formats;
				editor.embedFonts = Settings.font.defaultFontEmbedded;
			}
			editor.backgroundSkin = new RectangleSkin(FillStyle.SolidColor(colorSettings.backgroundColor));
			editor.textLineRendererFactory = DisplayObjectFactory.withFunction(function():TextLineRenderer
			{
				var textLineRenderer:TextLineRenderer = (editor is LspTextEditor) ? new LspTextLineRenderer() : new TextLineRenderer();
				textLineRenderer.backgroundSkin = new RectangleSkin(FillStyle.SolidColor(colorSettings.backgroundColor));
				textLineRenderer.gutterBackgroundSkin = new RectangleSkin(FillStyle.SolidColor(colorSettings.backgroundColor));
				textLineRenderer.selectedTextBackgroundSkin = new RectangleSkin(FillStyle.SolidColor(colorSettings.selectionBackgroundColor,
					colorSettings.selectionBackgroundAlpha));
				textLineRenderer.selectedTextBackgroundSkin = new RectangleSkin(FillStyle.SolidColor(colorSettings.selectionUnfocusedBackgroundColor,
					colorSettings.selectionUnfocusedBackgroundAlpha));
				textLineRenderer.focusedBackgroundSkin = new RectangleSkin(FillStyle.SolidColor(colorSettings.focusedLineBackgroundColor));
				textLineRenderer.debuggerStoppedBackgroundSkin = new RectangleSkin(FillStyle.SolidColor(colorSettings.debuggerStoppedLineBackgroundColor));
				textLineRenderer.searchResultBackgroundSkinFactory = function():RectangleSkin
				{
					return new RectangleSkin(FillStyle.SolidColor(colorSettings.searchResultBackgroundColor));
				}
				return textLineRenderer;
			});
		}

		protected function handleSaveAsSelect(fileObj:Object):void
		{
			saveAs(new FileLocation(fileObj.nativePath));
		}

        private function commitTempValues():void
        {
			if (loadingFile)
			{
				//not ready yet
				return;
			}
            if (tempSelectionStartLineIndex != -1)
            {
                setSelection(tempSelectionStartLineIndex, tempSelectionStartCharIndex, tempSelectionEndLineIndex, tempSelectionEndCharIndex);
                tempSelectionStartLineIndex = -1;
                tempSelectionStartCharIndex = -1;
                tempSelectionEndLineIndex = -1;
                tempSelectionEndCharIndex = -1;
            }
            if (tempScrollToCaret)
            {
                scrollToCaret();
                tempScrollToCaret = false;
            }
            if (tempScrollTo != -1)
            {
                scrollTo(tempScrollTo, lastOpenType);
                tempScrollTo = -1;
            }
        }

		private function setDebugFinishHandler(event:DebugLineEvent):void
		{
			editor.debuggerLineIndex = -1;
		}

		private function syntaxColorSchemeChangeHandler(event:TextEditorSettingsEvent):void
		{
			updateSyntaxColorScheme();
		}
    }
}