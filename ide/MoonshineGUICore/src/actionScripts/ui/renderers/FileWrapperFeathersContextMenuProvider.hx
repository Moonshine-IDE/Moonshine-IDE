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

import actionScripts.events.TreeMenuItemEvent;
import actionScripts.interfaces.IExternalEditorVO;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
import actionScripts.plugin.templating.TemplatingHelper;
import actionScripts.plugin.templating.TemplatingPlugin;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.FileWrapper;
import actionScripts.valueObjects.ProjectVO;
import components.views.project.ProjectTreeContextMenuItem;
import feathers.controls.Menu;
import feathers.controls.TreeView;
import feathers.data.ArrayHierarchicalCollection;
import feathers.events.MenuEvent;
import openfl.desktop.Clipboard;
import openfl.desktop.ClipboardFormats;
import openfl.events.Event;

class FileWrapperFeathersContextMenuProvider {
	private var contextMenuOwner:FileWrapperHierarchicalItemRenderer;
	private var model:IDEModel = IDEModel.getInstance();
	private var dataProvider:ArrayHierarchicalCollection<MenuItem>;

	public function new(target:FileWrapperHierarchicalItemRenderer) {
		contextMenuOwner = target;
		contextMenuOwner.feathersContextMenuFactory = provide;
	}

	private function getContextMenuItem(text:String, ?triggerListener:(Dynamic) -> Void, ?displayingListener:(MenuItem) -> Void):MenuItem {
		return {
			text: text,
			triggerListener: triggerListener,
			displayingListener: displayingListener,
		};
	}
	
	public function provide(data:Dynamic):Menu {
		var fw:FileWrapper = Std.downcast(contextMenuOwner.data, FileWrapper);
		if (fw == null)
		{
			return null;
		}
		var fwExtension:String = fw.file.fileBridge.extension;

		var menu = new Menu();
		menu.addEventListener(MenuEvent.ITEM_TRIGGER, event -> {
			var item = (cast event.state.data : MenuItem);
			if (item.triggerListener != null) {
				item.triggerListener(event);
			}
		});
		// some items need to updated when the menu is shown
		menu.addEventListener(Event.ADDED_TO_STAGE, event -> {
			var needsUpdate = false;
			var length = menu.dataProvider.getLength();
			for (i in 0...length) {
				var item:MenuItem = cast menu.dataProvider.get([i]);
				if (item.displayingListener != null) {
					item.displayingListener(item);
					needsUpdate = true;
				}
			}
			if (needsUpdate) {
				menu.dataProvider.updateAll();
			}
		});
		menu.itemToText = (item:MenuItem) -> item.text;
		menu.itemToSeparator = (item:MenuItem) -> item.separator == true;
		menu.itemToEnabled = (item:MenuItem) -> item.enabled != false;

		var project:ProjectVO = UtilsCore.getProjectFromProjectFolder(fw);

		var items:Array<MenuItem> = [];
		items.push(getContextMenuItem(ProjectTreeContextMenuItem.COPY_PATH, redispatch, updateOverMultiSelectionOption));
		items.push(getContextMenuItem(ProjectTreeContextMenuItem.OPEN_PATH_IN_TERMINAL, redispatch, populateOpenInTerminalMenu));
		if (!ConstantsCoreVO.IS_MACOS)
		{
			items.push(getContextMenuItem(ProjectTreeContextMenuItem.OPEN_PATH_IN_POWERSHELL, redispatch, updateOverMultiSelectionOption));
		}
		items.push(getContextMenuItem(
			ConstantsCoreVO.IS_MACOS ? ProjectTreeContextMenuItem.SHOW_IN_FINDER : ProjectTreeContextMenuItem.SHOW_IN_EXPLORER,
			redispatch, updateOverMultiSelectionOption));

		var as3Project:AS3ProjectVO = Std.downcast(project, AS3ProjectVO);
		if (as3Project != null && as3Project.isPrimeFacesVisualEditorProject)
		{
			items.push(getContextMenuItem(ProjectTreeContextMenuItem.PREVIEW, redispatch));
		}

		items.push({separator: true});

		items.push(getContextMenuItem(
			ConstantsCoreVO.IS_AIR ? ProjectTreeContextMenuItem.OPEN : ProjectTreeContextMenuItem.OPEN_FILE_FOLDER,
			redispatch));

		if (ConstantsCoreVO.IS_AIR)
		{
			if (!fw.file.fileBridge.isDirectory)
			{

				items.push(getContextMenuItem(ProjectTreeContextMenuItem.OPEN_WITH, null, populateOpenWithMenu));
			}
			
			items.push(getContextMenuItem(ProjectTreeContextMenuItem.NEW, null, populateTemplatingMenu));
		}

		if (model.showHiddenPaths)
		{
			if (fw.isHidden)
			{
				items.push(getContextMenuItem(ProjectTreeContextMenuItem.MARK_AS_VISIBLE, redispatch));
			}
			else
			{
				items.push(getContextMenuItem(ProjectTreeContextMenuItem.MARK_AS_HIDDEN, redispatch));
			}
		}
		
		// menu item for file-paste to be use in different locations based upon fw property
		// also update this every time it displays
		var tmpPasteMenuItem:MenuItem = getContextMenuItem(ProjectTreeContextMenuItem.PASTE_FILE, redispatch, updatePasteMenuOption);
		
		if (fw.children != null && ConstantsCoreVO.IS_AIR)
		{
			items.push(tmpPasteMenuItem);
		}
		if (!fw.isRoot)
		{
			if (ConstantsCoreVO.IS_AIR)
			{
				items.push(getContextMenuItem(ProjectTreeContextMenuItem.COPY_FILE, redispatch));
			}
			if (fw.children == null)
			{
				if (ConstantsCoreVO.IS_AIR)
				{
					items.push(tmpPasteMenuItem);
				}
				items.push(getContextMenuItem(ProjectTreeContextMenuItem.DUPLICATE_FILE, redispatch, updateOverMultiSelectionOption));
			}
			
			if (!fw.isSourceFolder)
			{
				items.push(getContextMenuItem(ProjectTreeContextMenuItem.RENAME, redispatch, updateOverMultiSelectionOption));
			}

			var javaProject:JavaProjectVO = Std.downcast(project, JavaProjectVO);

			// avail only for .as and .mxml files
			if (fwExtension == "as" || fwExtension == "mxml")
			{
				// make this option available for the files Only inside the source folder location
				if (as3Project != null && !as3Project.isVisualEditorProject && !as3Project.isLibraryProject && as3Project.targets[0].fileBridge.nativePath != fw.file.fileBridge.nativePath)
				{
					if (fw.file.fileBridge.nativePath.indexOf(project.sourceFolder.fileBridge.nativePath + fw.file.fileBridge.separator) != -1)
					{
						items.push(getContextMenuItem(ProjectTreeContextMenuItem.SET_AS_DEFAULT_APPLICATION, redispatch));
					}
				}
			}
			else if (fwExtension == "java" && javaProject != null && !javaProject.hasGradleBuild())
			{
				items.push(getContextMenuItem(ProjectTreeContextMenuItem.SET_AS_DEFAULT_APPLICATION, redispatch));
			}

			items.push({separator: true});
			
			if (!fw.isSourceFolder)
			{
				items.push(getContextMenuItem(
					ConstantsCoreVO.IS_AIR ? ProjectTreeContextMenuItem.DELETE : ProjectTreeContextMenuItem.DELETE_FILE_FOLDER,
					redispatch));
			}

			if (ConstantsCoreVO.IS_AIR && (fw.file.fileBridge.name.toLowerCase() == "vagrantfile"))
			{
				if (!fw.file.fileBridge.isDirectory)
				{
					items.push({separator: true});
					items.push(getContextMenuItem(ProjectTreeContextMenuItem.VAGRANT_GROUP, null, populateVagrantMenu));
				}
			}
			
			if (fw.file.fileBridge.extension=="xml")
			{
				items.push({separator: true});

				if (fw.file.fileBridge.exists)
				{
					var fwResult:Dynamic = fw.file.fileBridge.read();
					if (fwResult != null)
					{
						var str:String = Std.string(fwResult);
						if ((str.indexOf("<project ") != -1) || (str.indexOf("<project>") != -1))
						{
							items.push(getContextMenuItem(ProjectTreeContextMenuItem.RUN_ANT_SCRIPT, redispatch));
						}
					}
				}
			}
		}
		else
		{
			if (ConstantsCoreVO.IS_AIR && !fw.projectReference.isTemplate)
			{
				items.push(getContextMenuItem(
					ConstantsCoreVO.IS_AIR ? ProjectTreeContextMenuItem.SETTINGS : ProjectTreeContextMenuItem.PROJECT_SETUP,
					redispatch));
			}
			items.push(getContextMenuItem(ProjectTreeContextMenuItem.CLOSE, redispatch));
			if (ConstantsCoreVO.IS_AIR)
			{
				if (!fw.projectReference.isTemplate)
				{
					items.push({separator: true});
					items.push(getContextMenuItem(ProjectTreeContextMenuItem.DELETE, redispatch));
				}
			}
			else
			{
				items.push({separator: true});
				items.push(getContextMenuItem(ProjectTreeContextMenuItem.DELETE_PROJECT, redispatch));
			}
		}

		// avail the refresh option against folders only
		if ((fw.isRoot || ConstantsCoreVO.IS_AIR) && fw.children != null)
		{
			items.push(getContextMenuItem(ProjectTreeContextMenuItem.REFRESH, redispatch));
		}
		
		menu.dataProvider = dataProvider = new ArrayHierarchicalCollection(items, (item:MenuItem) -> item.children);
		return menu;
	}
		
	private function populateOpenWithMenu(menuItem:MenuItem):Void
	{
		var items:Array<MenuItem> = [];
		
		var activeProject:ProjectVO = UtilsCore.getProjectFromProjectFolder(Std.downcast(contextMenuOwner.data, FileWrapper));
		if (activeProject != null)
		{
			model.activeProject = activeProject;
		}

		var editors:Array<IExternalEditorVO> = cast model.flexCore.getExternalEditors().source;
		for (editor in editors)
		{
			var isFileTypeAccessible:Bool = (editor.fileTypes == null || editor.fileTypes.length == 0);
			if (!isFileTypeAccessible)
			{
				isFileTypeAccessible = (editor.fileTypes.indexOf(Std.downcast(contextMenuOwner.data, FileWrapper).file.fileBridge.extension) != -1);
			}

			var eventType:String = "eventOpenWithExternalEditor"+ editor.localID;
			var item:MenuItem = getContextMenuItem(editor.title, redispatchOpenWith);
			item.data = eventType;
			item.enabled = editor.isValid && editor.isEnabled && isFileTypeAccessible;
			items.push(item);
		}

		items.push({separator: true});
		
		var customize:MenuItem = getContextMenuItem(ProjectTreeContextMenuItem.CONFIGURE_EXTERNAL_EDITORS, redispatchOpenWith);
		customize.data = ProjectTreeContextMenuItem.CONFIGURE_EXTERNAL_EDITORS;
		items.push(customize);

		var location = dataProvider.locationOf(menuItem);
		menuItem.children = items;
		dataProvider.updateAt(location);
	}

	private function populateOpenInTerminalMenu(menuItem:MenuItem):Void
	{
		// in case of Windows, for now, we don't
		// have to support for theme
		if (!ConstantsCoreVO.IS_MACOS)
		{
			updateOverMultiSelectionOption(menuItem);
			return;
		}

		var items:Array<MenuItem> = [];

		var defaultOption:MenuItem = getContextMenuItem("Default", redispatchOpenInTerminal);
		defaultOption.data = "eventOpenInTerminalDefault";
		items.push(defaultOption);

		items.push({separator: true});

		var themes = model.flexCore.getTerminalThemeList();
		for (theme in themes)
		{
			var eventType:String = "eventOpenInTerminal"+ theme;
			var item:MenuItem = getContextMenuItem(theme, redispatchOpenInTerminal);
			item.data = eventType;
			items.push(item);
		}

		var location = dataProvider.locationOf(menuItem);
		menuItem.children = items;
		dataProvider.updateAt(location);
	}

	private function populateVagrantMenu(menuItem:MenuItem):Void
	{
		var items:Array<MenuItem> = [];

		var isVagrantAvailable:Bool = UtilsCore.isVagrantAvailable();
		var activeProject:ProjectVO = UtilsCore.getProjectFromProjectFolder(Std.downcast(contextMenuOwner.data, FileWrapper));
		if (activeProject != null)
		{
			model.activeProject = activeProject;
		}

		for (option in model.flexCore.vagrantMenuOptions)
		{
			var eventType:String = "eventVagrant"+ option;
			var item:MenuItem = getContextMenuItem(option, redispatchOpenWith);
			item.data = eventType;
			item.enabled = isVagrantAvailable;
			items.push(item);
		}

		if (!isVagrantAvailable)
		{
			items.push({separator: true});

			var customize:MenuItem = getContextMenuItem(ProjectTreeContextMenuItem.CONFIGURE_VAGRANT, redispatchOpenWith);
			customize.data = ProjectTreeContextMenuItem.CONFIGURE_VAGRANT;
			items.push(customize);
		}

		var location = dataProvider.locationOf(menuItem);
		menuItem.children = items;
		dataProvider.updateAt(location);
	}

	private function populateTemplatingMenu(menuItem:MenuItem):Void
	{
		var items:Array<MenuItem> = [];

		var activeProject:ProjectVO = UtilsCore.getProjectFromProjectFolder(Std.downcast(contextMenuOwner.data, FileWrapper));
		if (activeProject != null)
		{
			model.activeProject = activeProject;
		}
		
		var folder:MenuItem = getContextMenuItem("Folder", redispatchNew);
		folder.data = ProjectTreeContextMenuItem.NEW_FOLDER;
		items.push(folder);

		items.push({separator: true});
		
		for (file in TemplatingPlugin.fileTemplates)
		{
			var label:String = TemplatingHelper.getTemplateLabel(file);
			
			var eventType:String = "eventNewFileFromTemplate"+label;
		
			var item:MenuItem = getContextMenuItem(label, redispatchNew);
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
			items.push(item);
		}

		var location = dataProvider.locationOf(menuItem);
		menuItem.children = items;
		dataProvider.updateAt(location);
	}
		
	private function updatePasteMenuOption(contextMenuItem:MenuItem):Void
	{
		contextMenuItem.enabled = #if air Clipboard.generalClipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT) #else false #end;
	}
		
	private function updateOverMultiSelectionOption(contextMenuItem:MenuItem):Void
	{
		contextMenuItem.enabled = Std.downcast(contextMenuOwner.parent.parent, TreeView).selectedItems.length == 1;
	}
		
	private function redispatch(event:MenuEvent):Void
	{
		contextMenuOwner.dispatchEvent(
			getNewTreeMenuItemEvent(event)
		);
	}
		
	private function redispatchNew(event:MenuEvent):Void
	{
		var e:TreeMenuItemEvent = getNewTreeMenuItemEvent(event);
		var menuItem:MenuItem = cast event.state.data;
		if (menuItem.data != null)
		{
			e.menuLabel = ProjectTreeContextMenuItem.NEW;
			e.extra = menuItem.data;
		}
		
		contextMenuOwner.dispatchEvent(e);
	}
		
	private function redispatchOpenWith(event:MenuEvent):Void
	{
		var e:TreeMenuItemEvent = getNewTreeMenuItemEvent(event);
		var menuItem:MenuItem = cast event.state.data;
		if (menuItem.data != null)
		{
			e.menuLabel = ProjectTreeContextMenuItem.OPEN_WITH;
			e.extra = menuItem.data;
		}
		
		contextMenuOwner.dispatchEvent(e);
	}

	private function redispatchOpenInTerminal(event:MenuEvent):Void
	{
		var e:TreeMenuItemEvent = getNewTreeMenuItemEvent(event);
		var menuItem:MenuItem = cast event.state.data;
		if (menuItem.data != null)
		{
			e.menuLabel = ProjectTreeContextMenuItem.OPEN_PATH_IN_TERMINAL;
			e.extra = menuItem.data;
		}

		contextMenuOwner.dispatchEvent(e);
	}
		
	private function getNewTreeMenuItemEvent(event:MenuEvent):TreeMenuItemEvent
	{
		var type:String = event.state.text;
		var e:TreeMenuItemEvent = new TreeMenuItemEvent(TreeMenuItemEvent.RIGHT_CLICK_ITEM_SELECTED, 
			type, 
			cast(contextMenuOwner.data, FileWrapper));
		e.renderer = contextMenuOwner;
		return e;
	}
}

private typedef MenuItem = {
	?text:String,
	?separator:Bool,
	?enabled:Bool,
	?triggerListener:(Dynamic) -> Void,
	?displayingListener:(MenuItem) -> Void,
	?children:Array<MenuItem>,
	?data:Dynamic,
}