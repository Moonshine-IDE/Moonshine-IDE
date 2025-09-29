////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2025. All rights reserved.
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

package actionScripts.ui.renderers;

import openfl.display.MovieClip;
import feathers.text.TextFormat;
import actionScripts.events.TreeMenuItemEvent;
import actionScripts.interfaces.IExternalEditorVO;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
import actionScripts.plugin.templating.TemplatingHelper;
import actionScripts.plugin.templating.TemplatingPlugin;
import actionScripts.ui.editor.BasicTextEditor;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.FileWrapper;
import actionScripts.valueObjects.ProjectVO;
import feathers.controls.BitmapImage;
import feathers.controls.Menu;
import feathers.controls.TreeView;
import feathers.controls.dataRenderers.HierarchicalItemRenderer;
import feathers.controls.dataRenderers.ITreeViewItemRenderer;
import feathers.core.IValidating;
import feathers.data.ArrayHierarchicalCollection;
import feathers.events.MenuEvent;
import openfl.desktop.Clipboard;
import openfl.desktop.ClipboardFormats;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.filters.GlowFilter;

class FileWrapperHierarchicalItemRenderer extends HierarchicalItemRenderer implements ITreeViewItemRenderer {
	public static final OPEN:String = "Open";
	public static final OPEN_WITH:String = "Open With";
	public static final VAGRANT_GROUP:String = "Vagrant";
	public static final CONFIGURE_VAGRANT:String = "Configure Vagrant";
	public static final CONFIGURE_EXTERNAL_EDITORS:String = "Customize Editors";
	public static final OPEN_FILE_FOLDER:String = "Open File/Folder";
	public static final NEW:String = "New";
	public static final NEW_FOLDER:String = "New Folder";
	public static final COPY_PATH:String = "Copy Path";
	public static final OPEN_PATH_IN_TERMINAL:String = "Open in "+ (ConstantsCoreVO.IS_MACOS ? "Terminal" : "Command Line");
	public static final OPEN_PATH_IN_POWERSHELL:String = "Open in PowerShell";
	public static final SHOW_IN_EXPLORER:String = "Show in Explorer";
	public static final SHOW_IN_FINDER:String = "Show in Finder";
	public static final DUPLICATE_FILE:String = "Duplicate";
	public static final COPY_FILE:String = "Copy";
	public static final PASTE_FILE:String = "Paste";
	public static final MARK_AS_HIDDEN:String = "Mark as Hidden";
	public static final MARK_AS_VISIBLE:String = "Mark as Visible";
	public static final RENAME:String = "Rename";
	public static final SET_AS_DEFAULT_APPLICATION:String = "Set as Default Application";
	public static final DELETE:String = "Delete";
	public static final DELETE_FILE_FOLDER:String = "Delete File/Folder";
	public static final REFRESH:String = "Refresh";
	public static final RUN_ANT_SCRIPT:String = "Run Ant Script";
	public static final SETTINGS:String = "Settings";
	public static final PROJECT_SETUP:String = "Project Setup";
	public static final CLOSE:String = "Close";
	public static final DELETE_PROJECT:String = "Delete Project";
	public static final PREVIEW:String = "Preview";

	public function new() {
		super();
		// addEventListener(MouseEvent.RIGHT_CLICK, fileWrapperHierarchicalItemRenderer_rightClickHandler);
	}

	private var _location:Array<Int>;

	public var location(get, set):Array<Int>;

	private function get_location():Array<Int> {
		return _location;
	}

	private function set_location(value:Array<Int>):Array<Int> {
		_location = value;
		return _location;
	}

	private var _treeViewOwner:TreeView;

	public var treeViewOwner(get, set):TreeView;

	private function get_treeViewOwner():TreeView {
		return _treeViewOwner;
	}

	private function set_treeViewOwner(value:TreeView):TreeView {
		_treeViewOwner = value;
		return _treeViewOwner;
	}

	private var model:IDEModel = IDEModel.getInstance();

	private var isOpenIcon:Sprite;
	private var isSourceFolderIcon:BitmapImage;
	private var isLoadingIcon:MovieClip;

	private var _rootTextFormat:TextFormat;
	private var _deletingTextFormat:TextFormat;
	private var _hiddenTextFormat:TextFormat;
	private var _normalTextFormat:TextFormat;

	override private function set_textFormat(value:TextFormat):TextFormat {
		if (get_textFormat() == value) {
			return get_textFormat();
		}
		_rootTextFormat = null;
		_deletingTextFormat = null;
		_hiddenTextFormat = null;
		_normalTextFormat = null;
		super.set_textFormat(value);
		if (value != null)
		{
			_rootTextFormat = value.clone();
			_rootTextFormat.color = 0xffffcc;
			_hiddenTextFormat = value.clone();
			_hiddenTextFormat.color = 0xff4848;
			_normalTextFormat = value.clone();
			_normalTextFormat.color = 0xe0e0e0;
			_deletingTextFormat = value.clone();
			// #if (feathersui >= "1.4.0" && openfl >= "9.5.0")
			// _deletingTextFormat.strikethrough = true;
			// #end
		}
		return get_textFormat();
	}

	override private function initialize():Void {
		super.initialize();
		
		if (isOpenIcon == null) {
			isOpenIcon = new Sprite();
			isOpenIcon.mouseEnabled = false;
			isOpenIcon.mouseChildren = false;
			isOpenIcon.graphics.clear();
			isOpenIcon.graphics.beginFill(0xe15fd5);
			isOpenIcon.graphics.drawCircle(2, 2, 2);
			isOpenIcon.graphics.endFill();
			isOpenIcon.visible = false;
			var glow:GlowFilter = new GlowFilter(0xff00e4, .4, 6, 6, 2);
			isOpenIcon.filters = [glow];
			addChild(isOpenIcon);
		}

		if (isSourceFolderIcon == null) {
			isSourceFolderIcon = new BitmapImage();
			isSourceFolderIcon.toolTip = "Source folder";
			isSourceFolderIcon.source = Type.createInstance(ConstantsCoreVO.sourceFolderIcon, []).bitmapData;
			isSourceFolderIcon.visible = false;
			addChild(isSourceFolderIcon);
		}

		if (isLoadingIcon == null) {
			isLoadingIcon = Type.createInstance(ConstantsCoreVO.loaderIcon, []);
			isLoadingIcon.stop();
			isLoadingIcon.visible = false;
			addChild(isLoadingIcon);
		}
	}

	override private function update():Void {
		var dataInvalid = isInvalid(DATA);
		var stylesInvalid = isInvalid(STYLES);

		if (dataInvalid) {
			populateContextMenu();
			updateIcons();
			updateToolTip();
		}

		if (dataInvalid || stylesInvalid) {
			updateTextFormat();
		}

		super.update();
	}

	private function updateTextFormat():Void {
		this.runWithInvalidationFlagsOnly(() -> {
			var fw:FileWrapper = Std.downcast(data, FileWrapper);
			if (fw == null)
			{
				textFormat = _normalTextFormat;
				return;
			}
			if (fw.isRoot) {
				textFormat = _rootTextFormat;
			} else if (!ConstantsCoreVO.IS_AIR && fw.isDeleting) {
				textFormat = _deletingTextFormat;
			} else if (fw.isHidden) {
				textFormat = _hiddenTextFormat;
			} else {
				textFormat = _normalTextFormat;
			}
		});
	}

	override private function layoutChildren():Void {
		super.layoutChildren();

		if ((isOpenIcon is IValidating))
		{
			(cast isOpenIcon : IValidating).validateNow();
		}

		if ((isSourceFolderIcon is IValidating))
		{
			(cast isSourceFolderIcon : IValidating).validateNow();
		}

		if ((isLoadingIcon is IValidating))
		{
			(cast isLoadingIcon : IValidating).validateNow();
		}

		if (isOpenIcon != null) {
			isOpenIcon.x = textField.x-8;
			isOpenIcon.y = (actualHeight - isOpenIcon.height) / 2.0;
		}
		if (isSourceFolderIcon != null) {
			isSourceFolderIcon.width = isSourceFolderIcon.height = 14;
			isSourceFolderIcon.x = textField.x - (this.icon != null ? 44 : 29);
			isSourceFolderIcon.y = (actualHeight - isSourceFolderIcon.height) / 2.0;
		}
		if (isLoadingIcon != null) {
			isLoadingIcon.width = isLoadingIcon.height = 10;
			isLoadingIcon.x = textField.x - isLoadingIcon.width - 10;
			isLoadingIcon.y = (actualHeight - isLoadingIcon.height) / 2.0;
		}
	}

	private function updateToolTip():Void {
		var fw:FileWrapper = Std.downcast(data, FileWrapper);
		if (fw != null) {
			toolTip = fw.nativePath;
		} else {
			toolTip = null;
		}
	}

	private function updateIcons():Void {
		var fw:FileWrapper = Std.downcast(data, FileWrapper);
		if (fw != null)
		{
			// Show lil' dot if we are the currently opened file
			var isActiveFile:Bool = false;
			if ((model.activeEditor is BasicTextEditor))
			{
				var textEditor:BasicTextEditor = cast model.activeEditor;
				if (textEditor.currentFile != null)
				{
					if (fw.nativePath != null
						&& fw.nativePath == textEditor.currentFile.fileBridge.nativePath)
					{
						isActiveFile = true;
					}
				}
			}
			isOpenIcon.visible = isActiveFile;
			
			var isSourceFolder = fw.isSourceFolder;
			if (!isSourceFolder && fw.projectReference != null)
			{
				isSourceFolder = fw.nativePath == fw.projectReference.sourceFolder.fileBridge.nativePath;	
			}
			isSourceFolderIcon.visible = isSourceFolder;

			if (fw.isWorking)
			{
				isLoadingIcon.visible = true;
				isLoadingIcon.play();
			}
			else
			{
				isLoadingIcon.visible = false;
				isLoadingIcon.stop();
			}
		}
		else
		{
			isOpenIcon.visible = false;
			isSourceFolderIcon.visible = false;
			isLoadingIcon.visible = false;
			isLoadingIcon.stop();
		}
	}
	

	private function populateContextMenu():Void {
		var fw:FileWrapper = Std.downcast(this.data, FileWrapper);
		if (fw != null)
		{
			var fwExtension:String = fw.file.fileBridge.extension;

			contextMenu = model.contextMenuCore.getContextMenu();

			var project:ProjectVO = UtilsCore.getProjectFromProjectFolder(fw);

			model.contextMenuCore.addItem(contextMenu,
				model.contextMenuCore.getContextMenuItem(COPY_PATH, updateOverMultiSelectionOption, "displaying"));
			model.contextMenuCore.addItem(contextMenu,
					model.contextMenuCore.getContextMenuItem(OPEN_PATH_IN_TERMINAL, populateOpenInTerminalMenu, "displaying"));
			if (!ConstantsCoreVO.IS_MACOS)
			{
				model.contextMenuCore.addItem(contextMenu,
					model.contextMenuCore.getContextMenuItem(OPEN_PATH_IN_POWERSHELL, updateOverMultiSelectionOption, "displaying"));
			}
			model.contextMenuCore.addItem(contextMenu,
				model.contextMenuCore.getContextMenuItem(
					ConstantsCoreVO.IS_MACOS ? SHOW_IN_FINDER : SHOW_IN_EXPLORER, 
					updateOverMultiSelectionOption, "displaying"));

			var as3Project:AS3ProjectVO = Std.downcast(project, AS3ProjectVO);
			if (as3Project != null && as3Project.isPrimeFacesVisualEditorProject)
			{
				model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(PREVIEW, redispatch, Event.SELECT));
			}

			model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(null));

			model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(ConstantsCoreVO.IS_AIR ? OPEN : OPEN_FILE_FOLDER, redispatch, Event.SELECT));

			if (ConstantsCoreVO.IS_AIR)
			{
				if (!fw.file.fileBridge.isDirectory)
				{
					var openWithMenu:Dynamic = model.contextMenuCore.getContextMenuItem(OPEN_WITH, populateOpenWithMenu, "displaying");
					model.contextMenuCore.addItem(contextMenu, openWithMenu);
				}
				
				var newMenu:Dynamic = model.contextMenuCore.getContextMenuItem(NEW, populateTemplatingMenu, "displaying");
				model.contextMenuCore.addItem(contextMenu, newMenu);
			}
			
			if (fw.sourceController != null)
			{
				model.contextMenuCore.addItem(contextMenu, fw.sourceController.getTreeRightClickMenu(fw.file));
			}

			if (model.showHiddenPaths)
			{
				if (fw.isHidden)
				{
					model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(MARK_AS_VISIBLE, redispatch, Event.SELECT));
				}
				else
				{
					model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(MARK_AS_HIDDEN, redispatch, Event.SELECT));
				}
			}
			
			// menu item for file-paste to be use in different locations based upon fw property
			// also update this every time it displays
			var tmpPasteMenuItem:Dynamic = model.contextMenuCore.getContextMenuItem(PASTE_FILE, updatePasteMenuOption, "displaying");
			
			if (fw.children != null && ConstantsCoreVO.IS_AIR) model.contextMenuCore.addItem(contextMenu, tmpPasteMenuItem);
			if (!fw.isRoot)
			{
				if (ConstantsCoreVO.IS_AIR) model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(COPY_FILE, redispatch, Event.SELECT));
				if (fw.children == null)
				{
					if (ConstantsCoreVO.IS_AIR)
					{
						model.contextMenuCore.addItem(contextMenu, tmpPasteMenuItem);
					}
					model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(DUPLICATE_FILE, updateOverMultiSelectionOption, "displaying"));
				}
				
				if (!fw.isSourceFolder)
				{
					model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(RENAME, updateOverMultiSelectionOption, "displaying"));
				}

				var javaProject:JavaProjectVO = Std.downcast(project, JavaProjectVO);

				// avail only for .as and .mxml files
				if (fwExtension == "as" || fwExtension == "mxml")
				{
					// make this option available for the files Only inside the source folder location
					if (as3Project != null && !as3Project.isVisualEditorProject && !as3Project.isLibraryProject && as3Project.targets[0].fileBridge.nativePath != fw.file.fileBridge.nativePath)
					{
						if (fw.file.fileBridge.nativePath.indexOf(project.sourceFolder.fileBridge.nativePath + fw.file.fileBridge.separator) != -1)
							model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(SET_AS_DEFAULT_APPLICATION, redispatch, Event.SELECT));
					}
				}
				else if (fwExtension == "java" && javaProject != null && !javaProject.hasGradleBuild())
				{
					model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(SET_AS_DEFAULT_APPLICATION, redispatch, Event.SELECT));
				}
				
				model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(null));
				//contextMenu.addItem(new ContextMenuItem(null, true));
				
				if (!fw.isSourceFolder)
				{
					model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(ConstantsCoreVO.IS_AIR ? DELETE : DELETE_FILE_FOLDER, redispatch, Event.SELECT));
				}

				if (ConstantsCoreVO.IS_AIR && (fw.file.fileBridge.name.toLowerCase() == "vagrantfile"))
				{
					if (!fw.file.fileBridge.isDirectory)
					{
						model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(null));

						var vagrantMenu:Dynamic = model.contextMenuCore.getContextMenuItem(VAGRANT_GROUP, populateVagrantMenu, "displaying");
						model.contextMenuCore.addItem(contextMenu, vagrantMenu);
					}
				}
				
				if (fw.file.fileBridge.extension=="xml")
				{
					model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(null));

					if (fw.file.fileBridge.exists)
					{
						var fwResult:Dynamic = fw.file.fileBridge.read();
						if (fwResult != null)
						{
							var str:String = fwResult.toString();
							if ((str.indexOf("<project ") != -1) || (str.indexOf("<project>") != -1))
							{
								model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(RUN_ANT_SCRIPT, redispatch, Event.SELECT));
							}
						}
					}
				}
			}
			else
			{
				if (ConstantsCoreVO.IS_AIR && !fw.projectReference.isTemplate)
				{
					model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(ConstantsCoreVO.IS_AIR ? SETTINGS : PROJECT_SETUP, redispatch, Event.SELECT));
				}
				model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(CLOSE, redispatch, Event.SELECT));
				if (ConstantsCoreVO.IS_AIR)
				{
					if (!fw.projectReference.isTemplate)
					{
						// for some reason separatorBefore is not working through Constructor in desktop hence this separate null entry addition
						model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(null));
						model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(DELETE, redispatch, Event.SELECT));
					}
				}
				else
				{
					model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(DELETE_PROJECT, redispatch, Event.SELECT, true));
				}
			}

			// avail the refresh option against folders only
			if ((fw.isRoot || ConstantsCoreVO.IS_AIR) && fw.children != null)
			{
				model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(REFRESH, redispatch, Event.SELECT));
			}
		}
	}
		
	private function populateOpenWithMenu(event:Event):Void
	{
		model.contextMenuCore.removeAll(event.target);
		
		var activeProject:ProjectVO = UtilsCore.getProjectFromProjectFolder(Std.downcast(data, FileWrapper));
		if (activeProject != null)
		{
			model.activeProject = activeProject;
		}

		var editors:Dynamic = model.flexCore.getExternalEditors();
		for (editor in (editors.source : Array<IExternalEditorVO>))
		{
			var isFileTypeAccessible:Bool = (editor.fileTypes == null || editor.fileTypes.length == 0);
			if (!isFileTypeAccessible)
			{
				isFileTypeAccessible = (editor.fileTypes.indexOf(Std.downcast(data, FileWrapper).file.fileBridge.extension) != -1);
			}

			var eventType:String = "eventOpenWithExternalEditor"+ editor.localID;
			var item:Dynamic = model.contextMenuCore.getContextMenuItem(editor.title, redispatchOpenWith, Event.SELECT);
			item.data = eventType;
			item.enabled = editor.isValid && editor.isEnabled && isFileTypeAccessible;
			
			model.contextMenuCore.subMenu(event.target, item);
		}

		model.contextMenuCore.subMenu(event.target, model.contextMenuCore.getContextMenuItem(null));
		
		var customize:Dynamic = model.contextMenuCore.getContextMenuItem(CONFIGURE_EXTERNAL_EDITORS, redispatchOpenWith, Event.SELECT);
		customize.data = CONFIGURE_EXTERNAL_EDITORS;
		model.contextMenuCore.subMenu(event.target, customize);
	}

	private function populateOpenInTerminalMenu(event:Event):Void
	{
		// in case of Windows, for now, we don't
		// have to support for theme
		if (!ConstantsCoreVO.IS_MACOS)
		{
			updateOverMultiSelectionOption(event);
			return;
		}

		model.contextMenuCore.removeAll(event.target);

		var defaultOption:Dynamic = model.contextMenuCore.getContextMenuItem("Default", redispatchOpenInTerminal, Event.SELECT);
		defaultOption.data = "eventOpenInTerminalDefault";
		model.contextMenuCore.subMenu(event.target, defaultOption);

		model.contextMenuCore.subMenu(event.target, model.contextMenuCore.getContextMenuItem(null));

		var themes = model.flexCore.getTerminalThemeList();
		for (theme in themes)
		{
			var eventType:String = "eventOpenInTerminal"+ theme;
			var item:Dynamic = model.contextMenuCore.getContextMenuItem(theme, redispatchOpenInTerminal, Event.SELECT);
			item.data = eventType;

			model.contextMenuCore.subMenu(event.target, item);
		}
	}

	private function populateVagrantMenu(event:Event):Void
	{
		model.contextMenuCore.removeAll(event.target);

		var isVagrantAvailable:Bool = UtilsCore.isVagrantAvailable();
		var activeProject:ProjectVO = UtilsCore.getProjectFromProjectFolder(Std.downcast(data, FileWrapper));
		if (activeProject != null)
		{
			model.activeProject = activeProject;
		}

		for (option in model.flexCore.vagrantMenuOptions)
		{
			var eventType:String = "eventVagrant"+ option;
			var item:Dynamic = model.contextMenuCore.getContextMenuItem(option, redispatchOpenWith, Event.SELECT);
			item.data = eventType;
			item.enabled = isVagrantAvailable;

			model.contextMenuCore.subMenu(event.target, item);
		}

		if (!isVagrantAvailable)
		{
			model.contextMenuCore.subMenu(event.target, model.contextMenuCore.getContextMenuItem(null));

			var customize:Dynamic = model.contextMenuCore.getContextMenuItem(CONFIGURE_VAGRANT, redispatchOpenWith, Event.SELECT);
			customize.data = CONFIGURE_VAGRANT;
			model.contextMenuCore.subMenu(event.target, customize);
		}
	}

	private function populateTemplatingMenu(e:Event):Void
	{
		model.contextMenuCore.removeAll(e.target);

		var activeProject:ProjectVO = UtilsCore.getProjectFromProjectFolder(Std.downcast(data, FileWrapper));
		if (activeProject != null)
		{
			model.activeProject = activeProject;
		}
		
		var folder:Dynamic = model.contextMenuCore.getContextMenuItem("Folder", redispatchNew, Event.SELECT);
		folder.data = NEW_FOLDER;
		model.contextMenuCore.subMenu(e.target, folder);
		model.contextMenuCore.subMenu(e.target, model.contextMenuCore.getContextMenuItem(null));
		
		for (file in TemplatingPlugin.fileTemplates)
		{
			var label:String = TemplatingHelper.getTemplateLabel(file);
			
			var eventType:String = "eventNewFileFromTemplate"+label;
		
			var item:Dynamic = model.contextMenuCore.getContextMenuItem(label, redispatchNew, Event.SELECT);
			item.data = eventType;
			
			var enableTypes = TemplatingHelper.getTemplateMenuType(label);
			if (enableTypes.length == 0)
			{
				item.enabled = true;
			}
			else
			{
				item.enabled = Lambda.exists(enableTypes, function(item:String):Bool
				{
					return activeProject.menuType.indexOf(item) != -1;
				});
			}
			
			model.contextMenuCore.subMenu(e.target, item);
		}
	}
		
	private function updatePasteMenuOption(event:Event):Void
	{
		var contextMenuItem:Dynamic = event.target;
		contextMenuItem.enabled = Clipboard.generalClipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT);
		if (contextMenuItem.enabled) contextMenuItem.addEventListener(Event.SELECT, redispatch, false, 0, true);
	}
		
	private function updateOverMultiSelectionOption(event:Event):Void
	{
		var contextMenuItem:Dynamic = event.target;
		contextMenuItem.enabled = Std.downcast(this.parent.parent, TreeView).selectedItems.length == 1;
		if (contextMenuItem.enabled) contextMenuItem.addEventListener(Event.SELECT, redispatch, false, 0, true);
	}
		
	private function redispatch(event:Event):Void
	{
		dispatchEvent(
			getNewTreeMenuItemEvent(event)
		);
	}
		
	private function redispatchNew(event:Event):Void
	{
		var e:TreeMenuItemEvent = getNewTreeMenuItemEvent(event);
		if (event.target.hasOwnProperty("data") && event.target.data != null)
		{
			e.menuLabel = NEW;
			e.extra = event.target.data;
		}
		
		dispatchEvent(e);
	}
		
	private function redispatchOpenWith(event:Event):Void
	{
		var e:TreeMenuItemEvent = getNewTreeMenuItemEvent(event);
		if (event.target.hasOwnProperty("data") && event.target.data != null)
		{
			e.menuLabel = OPEN_WITH;
			e.extra = event.target.data;
		}
		
		dispatchEvent(e);
	}

	private function redispatchOpenInTerminal(event:Event):Void
	{
		var e:TreeMenuItemEvent = getNewTreeMenuItemEvent(event);
		if (event.target.hasOwnProperty("data") && event.target.data != null)
		{
			e.menuLabel = OPEN_PATH_IN_TERMINAL;
			e.extra = event.target.data;
		}

		dispatchEvent(e);
	}
		
	private function getNewTreeMenuItemEvent(event:Event):TreeMenuItemEvent
	{
		var type:String = (event.target is flash.ui.ContextMenuItem) ? event.target.caption : event.target.label;
		var e:TreeMenuItemEvent = new TreeMenuItemEvent(TreeMenuItemEvent.RIGHT_CLICK_ITEM_SELECTED, 
			type, 
			cast(data, FileWrapper));
		e.renderer = this;
		return e;
	}

	private function fileWrapperHierarchicalItemRenderer_rightClickHandler(event:MouseEvent):Void {
		event.preventDefault();

		// add to selection, if not currently selected
		// TODO: set flag and remove from selection when menu closes
		if (_treeViewOwner.selectedItems.indexOf(_data) == -1) {
			var selectedItems = _treeViewOwner.selectedItems.copy();
			selectedItems.push(_data);
			_treeViewOwner.selectedItems = selectedItems;
		}

		var menu:Menu = new Menu();
		menu.dataProvider = new ArrayHierarchicalCollection([{text: OPEN}]);
		menu.itemToText = function(item:Dynamic):String {
			return item.text;
		};
		menu.addEventListener(MenuEvent.ITEM_TRIGGER, fileWrapperHierarchicalItemRenderer_contextMenu_itemTriggerHandler);
		menu.showAtPosition(stage.mouseX, stage.mouseY, this);
	}

	private function fileWrapperHierarchicalItemRenderer_contextMenu_itemTriggerHandler(event:MenuEvent):Void {
		trace("*** context menu trigger: " + event.state.text);
		if (event.state.text == OPEN) {
			// var location:Array = fileTreeCollection.locationOf(item);
			// if (location != null) {
			// 	fileTreeCollection.updateAt(location);
			// }
		}
	}
}