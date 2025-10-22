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
import feathers.controls.TreeView;
import openfl.desktop.Clipboard;
import openfl.desktop.ClipboardFormats;
import openfl.events.Event;

class FileWrapperNativeContextMenuProvider {
	private var contextMenuOwner:FileWrapperHierarchicalItemRenderer;
	private var model:IDEModel = IDEModel.getInstance();

	public function new(target:FileWrapperHierarchicalItemRenderer) {
		contextMenuOwner = target;
		contextMenuOwner.nativeContextMenuFactory = provide;
	}

	public function provide(data:Dynamic):#if flash flash.ui.ContextMenu #else Dynamic #end {
		var fw:FileWrapper = Std.downcast(contextMenuOwner.data, FileWrapper);
		if (fw == null)
		{
			return null;
		}
		var fwExtension:String = fw.file.fileBridge.extension;

		var contextMenu = model.contextMenuCore.getContextMenu();

		var project:ProjectVO = UtilsCore.getProjectFromProjectFolder(fw);

		model.contextMenuCore.addItem(contextMenu,
			model.contextMenuCore.getContextMenuItem(ProjectTreeContextMenuItem.COPY_PATH, updateOverMultiSelectionOption, "displaying"));
		model.contextMenuCore.addItem(contextMenu,
				model.contextMenuCore.getContextMenuItem(ProjectTreeContextMenuItem.OPEN_PATH_IN_TERMINAL, populateOpenInTerminalMenu, "displaying"));
		if (!ConstantsCoreVO.IS_MACOS)
		{
			model.contextMenuCore.addItem(contextMenu,
				model.contextMenuCore.getContextMenuItem(ProjectTreeContextMenuItem.OPEN_PATH_IN_POWERSHELL, updateOverMultiSelectionOption, "displaying"));
		}
		model.contextMenuCore.addItem(contextMenu,
			model.contextMenuCore.getContextMenuItem(
				ConstantsCoreVO.IS_MACOS ? ProjectTreeContextMenuItem.SHOW_IN_FINDER : ProjectTreeContextMenuItem.SHOW_IN_EXPLORER, 
				updateOverMultiSelectionOption, "displaying"));

		var as3Project:AS3ProjectVO = Std.downcast(project, AS3ProjectVO);
		if (as3Project != null && as3Project.isPrimeFacesVisualEditorProject)
		{
			model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(ProjectTreeContextMenuItem.PREVIEW, redispatch, Event.SELECT));
		}

		model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(null));

		model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(ConstantsCoreVO.IS_AIR ? ProjectTreeContextMenuItem.OPEN : ProjectTreeContextMenuItem.OPEN_FILE_FOLDER, redispatch, Event.SELECT));

		if (ConstantsCoreVO.IS_AIR)
		{
			if (!fw.file.fileBridge.isDirectory)
			{
				var openWithMenu:Dynamic = model.contextMenuCore.getContextMenuItem(ProjectTreeContextMenuItem.OPEN_WITH, populateOpenWithMenu, "displaying");
				model.contextMenuCore.addItem(contextMenu, openWithMenu);
			}
			
			var newMenu:Dynamic = model.contextMenuCore.getContextMenuItem(ProjectTreeContextMenuItem.NEW, populateTemplatingMenu, "displaying");
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
				model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(ProjectTreeContextMenuItem.MARK_AS_VISIBLE, redispatch, Event.SELECT));
			}
			else
			{
				model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(ProjectTreeContextMenuItem.MARK_AS_HIDDEN, redispatch, Event.SELECT));
			}
		}
		
		// menu item for file-paste to be use in different locations based upon fw property
		// also update this every time it displays
		var tmpPasteMenuItem:Dynamic = model.contextMenuCore.getContextMenuItem(ProjectTreeContextMenuItem.PASTE_FILE, updatePasteMenuOption, "displaying");
		
		if (fw.children != null && ConstantsCoreVO.IS_AIR) model.contextMenuCore.addItem(contextMenu, tmpPasteMenuItem);
		if (!fw.isRoot)
		{
			if (ConstantsCoreVO.IS_AIR) model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(ProjectTreeContextMenuItem.COPY_FILE, redispatch, Event.SELECT));
			if (fw.children == null)
			{
				if (ConstantsCoreVO.IS_AIR)
				{
					model.contextMenuCore.addItem(contextMenu, tmpPasteMenuItem);
				}
				model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(ProjectTreeContextMenuItem.DUPLICATE_FILE, updateOverMultiSelectionOption, "displaying"));
			}
			
			if (!fw.isSourceFolder)
			{
				model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(ProjectTreeContextMenuItem.RENAME, updateOverMultiSelectionOption, "displaying"));
			}

			var javaProject:JavaProjectVO = Std.downcast(project, JavaProjectVO);

			// avail only for .as and .mxml files
			if (fwExtension == "as" || fwExtension == "mxml")
			{
				// make this option available for the files Only inside the source folder location
				if (as3Project != null && !as3Project.isVisualEditorProject && !as3Project.isLibraryProject && as3Project.targets[0].fileBridge.nativePath != fw.file.fileBridge.nativePath)
				{
					if (fw.file.fileBridge.nativePath.indexOf(project.sourceFolder.fileBridge.nativePath + fw.file.fileBridge.separator) != -1)
						model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(ProjectTreeContextMenuItem.SET_AS_DEFAULT_APPLICATION, redispatch, Event.SELECT));
				}
			}
			else if (fwExtension == "java" && javaProject != null && !javaProject.hasGradleBuild())
			{
				model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(ProjectTreeContextMenuItem.SET_AS_DEFAULT_APPLICATION, redispatch, Event.SELECT));
			}
			
			model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(null));
			//contextMenu.addItem(new ContextMenuItem(null, true));
			
			if (!fw.isSourceFolder)
			{
				model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(ConstantsCoreVO.IS_AIR ? ProjectTreeContextMenuItem.DELETE : ProjectTreeContextMenuItem.DELETE_FILE_FOLDER, redispatch, Event.SELECT));
			}

			if (ConstantsCoreVO.IS_AIR && (fw.file.fileBridge.name.toLowerCase() == "vagrantfile"))
			{
				if (!fw.file.fileBridge.isDirectory)
				{
					model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(null));

					var vagrantMenu:Dynamic = model.contextMenuCore.getContextMenuItem(ProjectTreeContextMenuItem.VAGRANT_GROUP, populateVagrantMenu, "displaying");
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
						var str:String = Std.string(fwResult);
						if ((str.indexOf("<project ") != -1) || (str.indexOf("<project>") != -1))
						{
							model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(ProjectTreeContextMenuItem.RUN_ANT_SCRIPT, redispatch, Event.SELECT));
						}
					}
				}
			}
		}
		else
		{
			if (ConstantsCoreVO.IS_AIR && !fw.projectReference.isTemplate)
			{
				model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(ConstantsCoreVO.IS_AIR ? ProjectTreeContextMenuItem.SETTINGS : ProjectTreeContextMenuItem.PROJECT_SETUP, redispatch, Event.SELECT));
			}
			model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(ProjectTreeContextMenuItem.CLOSE, redispatch, Event.SELECT));
			if (ConstantsCoreVO.IS_AIR)
			{
				if (!fw.projectReference.isTemplate)
				{
					// for some reason separatorBefore is not working through Constructor in desktop hence this separate null entry addition
					model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(null));
					model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(ProjectTreeContextMenuItem.DELETE, redispatch, Event.SELECT));
				}
			}
			else
			{
				model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(ProjectTreeContextMenuItem.DELETE_PROJECT, redispatch, Event.SELECT, true));
			}
		}

		// avail the refresh option against folders only
		if ((fw.isRoot || ConstantsCoreVO.IS_AIR) && fw.children != null)
		{
			model.contextMenuCore.addItem(contextMenu, model.contextMenuCore.getContextMenuItem(ProjectTreeContextMenuItem.REFRESH, redispatch, Event.SELECT));
		}

		return contextMenu;
	}
		
	private function populateOpenWithMenu(event:Event):Void
	{
		model.contextMenuCore.removeAll(event.target);
		
		var activeProject:ProjectVO = UtilsCore.getProjectFromProjectFolder(Std.downcast(contextMenuOwner.data, FileWrapper));
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
				isFileTypeAccessible = (editor.fileTypes.indexOf(Std.downcast(contextMenuOwner.data, FileWrapper).file.fileBridge.extension) != -1);
			}

			var eventType:String = "eventOpenWithExternalEditor"+ editor.localID;
			var item:Dynamic = model.contextMenuCore.getContextMenuItem(editor.title, redispatchOpenWith, Event.SELECT);
			item.data = eventType;
			item.enabled = editor.isValid && editor.isEnabled && isFileTypeAccessible;
			
			model.contextMenuCore.subMenu(event.target, item);
		}

		model.contextMenuCore.subMenu(event.target, model.contextMenuCore.getContextMenuItem(null));
		
		var customize:Dynamic = model.contextMenuCore.getContextMenuItem(ProjectTreeContextMenuItem.CONFIGURE_EXTERNAL_EDITORS, redispatchOpenWith, Event.SELECT);
		customize.data = ProjectTreeContextMenuItem.CONFIGURE_EXTERNAL_EDITORS;
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
		var activeProject:ProjectVO = UtilsCore.getProjectFromProjectFolder(Std.downcast(contextMenuOwner.data, FileWrapper));
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

			var customize:Dynamic = model.contextMenuCore.getContextMenuItem(ProjectTreeContextMenuItem.CONFIGURE_VAGRANT, redispatchOpenWith, Event.SELECT);
			customize.data = ProjectTreeContextMenuItem.CONFIGURE_VAGRANT;
			model.contextMenuCore.subMenu(event.target, customize);
		}
	}

	private function populateTemplatingMenu(e:Event):Void
	{
		model.contextMenuCore.removeAll(e.target);

		var activeProject:ProjectVO = UtilsCore.getProjectFromProjectFolder(Std.downcast(contextMenuOwner.data, FileWrapper));
		if (activeProject != null)
		{
			model.activeProject = activeProject;
		}
		
		var folder:Dynamic = model.contextMenuCore.getContextMenuItem("Folder", redispatchNew, Event.SELECT);
		folder.data = ProjectTreeContextMenuItem.NEW_FOLDER;
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
		contextMenuItem.enabled = Std.downcast(contextMenuOwner.parent.parent, TreeView).selectedItems.length == 1;
		if (contextMenuItem.enabled) contextMenuItem.addEventListener(Event.SELECT, redispatch, false, 0, true);
	}
		
	private function redispatch(event:Event):Void
	{
		contextMenuOwner.dispatchEvent(
			getNewTreeMenuItemEvent(event)
		);
	}
		
	private function redispatchNew(event:Event):Void
	{
		var e:TreeMenuItemEvent = getNewTreeMenuItemEvent(event);
		if (event.target.hasOwnProperty("data") && event.target.data != null)
		{
			e.menuLabel = ProjectTreeContextMenuItem.NEW;
			e.extra = event.target.data;
		}
		
		contextMenuOwner.dispatchEvent(e);
	}
		
	private function redispatchOpenWith(event:Event):Void
	{
		var e:TreeMenuItemEvent = getNewTreeMenuItemEvent(event);
		if (event.target.hasOwnProperty("data") && event.target.data != null)
		{
			e.menuLabel = ProjectTreeContextMenuItem.OPEN_WITH;
			e.extra = event.target.data;
		}
		
		contextMenuOwner.dispatchEvent(e);
	}

	private function redispatchOpenInTerminal(event:Event):Void
	{
		var e:TreeMenuItemEvent = getNewTreeMenuItemEvent(event);
		if (event.target.hasOwnProperty("data") && event.target.data != null)
		{
			e.menuLabel = ProjectTreeContextMenuItem.OPEN_PATH_IN_TERMINAL;
			e.extra = event.target.data;
		}

		contextMenuOwner.dispatchEvent(e);
	}
		
	private function getNewTreeMenuItemEvent(event:Event):TreeMenuItemEvent
	{
		var type:String = (event.target is flash.ui.ContextMenuItem) ? event.target.caption : event.target.label;
		var e:TreeMenuItemEvent = new TreeMenuItemEvent(TreeMenuItemEvent.RIGHT_CLICK_ITEM_SELECTED, 
			type, 
			cast(contextMenuOwner.data, FileWrapper));
		e.renderer = contextMenuOwner;
		return e;
	}
}