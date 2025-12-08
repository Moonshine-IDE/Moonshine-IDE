package actionScripts.ui.project;

import actionScripts.data.FileWrapperHierarchicalCollection;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.OpenFileEvent;
import actionScripts.events.ProjectEvent;
import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.workspace.WorkspacePlugin;
import actionScripts.ui.LayoutModifier;
import actionScripts.ui.project.ProjectViewHeader;
import actionScripts.ui.renderers.FileWrapperHierarchicalItemRenderer;
import actionScripts.ui.renderers.FileWrapperNativeContextMenuProvider;
import actionScripts.utils.SharedObjectUtil;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.FileWrapper;
import actionScripts.valueObjects.ProjectVO;
import actionScripts.valueObjects.WorkspaceVO;
import feathers.controls.LayoutGroup;
import feathers.controls.TreeView;
import feathers.data.IFlatCollection;
import feathers.events.TreeViewEvent;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import feathers.utils.DisplayObjectRecycler;
import moonshine.plugin.workspace.events.WorkspaceEvent;
import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.net.SharedObject;

class ProjectTreeView extends LayoutGroup {

	private static final COLLECTION_EVENT_KIND_ADD:String = "add";
	private static final COLLECTION_EVENT_KIND_RESET:String = "reset";
	private static final PROPERTY_NAME_KEY:String = "name";
	private static final PROPERTY_NAME_KEY_VALUE:String = "nativePath";

	private var _header:ProjectViewHeader;
	private var _treeView:TreeView;

	private var model:IDEModel = IDEModel.getInstance();

	private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();

	private var templateToCreate:FileLocation;

	private var _refreshActiveProjectTimeout:Int = -1;

	private var _ignoreTreeBranchChanges:Bool = false;

	private var _ignoreWorkspaceChange:Bool = false;

	private var _oldActiveEditorFileWrapper:FileWrapper;

	public var selectedItem(get, set):FileWrapper;

	private function get_selectedItem():FileWrapper
	{
		if (_treeView == null)
		{
			return null;
		}
		return cast(_treeView.selectedItem, FileWrapper);
	}

	private function set_selectedItem(value:FileWrapper):FileWrapper
	{
		if (_treeView == null)
		{
			return null;
		}
		_treeView.selectedItem = findTreeViewItem(value);
		return cast(_treeView.selectedItem, FileWrapper);
	}

	public var selectedItems(get, set):Array<FileWrapper>;

	private function get_selectedItems():Array<FileWrapper>
	{
		if (_treeView == null)
		{
			return null;
		}
		return cast _treeView.selectedItems;
	}

	private function set_selectedItems(value:Array<FileWrapper>):Array<FileWrapper>
	{
		if (_treeView == null)
		{
			return null;
		}
		if (value != null)
		{
			_treeView.selectedItems = value.map(function(item:FileWrapper):FileWrapper
			{
				return findTreeViewItem(item);
			});
		}
		else
		{
			_treeView.selectedItems = null;
		}
		return cast _treeView.selectedItems;
	}

	private var _activeFile:FileLocation;

	public var activeFile(get, set):FileLocation;

	private function get_activeFile():FileLocation
	{
		return _activeFile;
	}

	private function set_activeFile(value:FileLocation):FileLocation
	{
		if (_activeFile == value)
		{
			return _activeFile;
		}
		_activeFile = value;

		if (_oldActiveEditorFileWrapper != null)
		{
			updateTreeViewItem(_oldActiveEditorFileWrapper);
		}
		if (_activeFile != null)
		{
			var fileWrapper:FileWrapper = new FileWrapper(_activeFile);
			updateTreeViewItem(fileWrapper);
			_oldActiveEditorFileWrapper = fileWrapper;
		}
		else
		{
			_oldActiveEditorFileWrapper = null;
		}
		return _activeFile;
	}

	private var _workspaces:IFlatCollection<WorkspaceVO>;

	public var workspaces(get, set):IFlatCollection<WorkspaceVO>;

	private function get_workspaces():IFlatCollection<WorkspaceVO> {
		return _workspaces;
	}

	private function set_workspaces(value:IFlatCollection<WorkspaceVO>):IFlatCollection<WorkspaceVO> {
		if (_workspaces == value) {
			return _workspaces;
		}
		_workspaces = value;
		if (_header != null)
		{
			_header.workspaces = _workspaces;
		}
		return _workspaces;
	}

	public var projects:IFlatCollection<ProjectVO>;

	private var _dataProvider:FileWrapperHierarchicalCollection;

	public var dataProvider(get, set):FileWrapperHierarchicalCollection;

	private function get_dataProvider():FileWrapperHierarchicalCollection {
		return _dataProvider;
	}

	private function set_dataProvider(value:FileWrapperHierarchicalCollection):FileWrapperHierarchicalCollection {
		if (_dataProvider == value) {
			return _dataProvider;
		}
		_dataProvider = value;
		if (_treeView != null)
		{
			_treeView.dataProvider = _dataProvider;
		}
		if (value != null)
		{
			reopenPreviouslyClosedItems(COLLECTION_EVENT_KIND_RESET, value.roots.copy());
		}
		return _dataProvider;
	}

	public function new() {
		super();
	}
	

	override private function initialize():Void {
		super.initialize();

		layout = new VerticalLayout();

		_header = new ProjectViewHeader();
		_header.layoutData = VerticalLayoutData.fillHorizontal();
		_header.workspaces = _workspaces;
		_header.addEventListener("scrollFromSource", onScrollFromSource);
		_header.addEventListener(Event.CLOSE, handleClose);
		_header.addEventListener(Event.CHANGE, handleWorkspaceChange);
		addChild(_header);

		_treeView = new TreeView();
		_treeView.layoutData = VerticalLayoutData.fill();
		_treeView.variant = feathers.controls.TreeView.VARIANT_BORDERLESS;
		_treeView.dataProvider = _dataProvider;
		_treeView.itemToText = function(item:Any):String {
			if ((item is ProjectVO)) {
				var project:ProjectVO = cast item;
				return project.projectFolder.name;
			}
			if ((item is FileWrapper)) {
				var file:FileWrapper = cast item;
				return file.name;
			}
			return null;
		}
		_treeView.allowMultipleSelection = true;
		_treeView.itemRendererRecycler = DisplayObjectRecycler.withFunction(function():DisplayObject {
			var itemRenderer:FileWrapperHierarchicalItemRenderer = new FileWrapperHierarchicalItemRenderer();
			itemRenderer.doubleClickEnabled = true;
			new FileWrapperNativeContextMenuProvider(itemRenderer);
			return itemRenderer;
		});
		_treeView.addEventListener(TreeViewEvent.BRANCH_OPENING, function(event:TreeViewEvent):Void {
			if (_ignoreTreeBranchChanges) {
				// if a branch is opening programmatically from within
				// this class, ignore this event.
				// we're specifically interested in branches opening
				// outside of the control of this component, such as
				// from user interaction.
				return;
			}
			var fileWrapper:FileWrapper = Std.downcast(event.state.data, FileWrapper);
			if (fileWrapper == null) {
				return;
			}
			refreshItem(fileWrapper);
		});
		_treeView.addEventListener(TreeViewEvent.BRANCH_OPEN, onTreeViewBranchOpen);
		_treeView.addEventListener(TreeViewEvent.BRANCH_CLOSE, onTreeViewBranchClose);
		_treeView.addEventListener(TreeViewEvent.ITEM_TRIGGER, fileSingleClickedInTreeView);
		_treeView.addEventListener(TreeViewEvent.ITEM_DOUBLE_CLICK, fileDoubleClickedInTreeView);
		addChild(_treeView);

		dispatcher.addEventListener(
				WorkspacePlugin.EVENT_WORKSPACE_CHANGED,
				onWorkspaceChanged,
				false, 0, true
		);
		onWorkspaceChanged(null);
	}

	public function isItemVisible(item:Any):Bool
	{
		if (_treeView == null)
		{
			return false;
		}
		var itemRenderer:DisplayObject = _treeView.itemToItemRenderer(item);
		if (itemRenderer == null)
		{
			return false;
		}
		// TODO: Check if item renderer is in view port (it might be
		// just outside of the view port and not actually visible)
		return true;
	}
	
	public function getParentItem(item:FileWrapper):FileWrapper
	{
		if (_treeView == null || item == null)
		{
			return null;
		}

		var location:Array<Int> = _treeView.dataProvider.locationOf(item);
		if (location == null)
		{
			return null;
		}

		location.pop();

		if (location.length == 0)
		{
			return null;
		}

		return cast(_treeView.dataProvider.get(location), FileWrapper);
	}

	public function scrollToItem(item:Any):Void
	{
		if (_treeView == null)
		{
			return;
		}

		var location:Array<Int> = _treeView.dataProvider.locationOf(item);
		if (location == null)
		{
			return;
		}
		_treeView.scrollToLocation(location);
	}
	
	public function sortChildren(wrapper:FileWrapper):Void
	{
		if (wrapper == null) return;

		if (_treeView.dataProvider.isBranch(wrapper))
		{
			wrapper.sortChildren();
		}
		else
		{
			var location:Array<Int> = _treeView.dataProvider.locationOf(wrapper);
			if (location == null) return;

			location.pop();
			if (location.length == 0) return;

			var parentWrapper:FileWrapper = Std.downcast(_treeView.dataProvider.get(location), FileWrapper);
			if (parentWrapper == null) return;

			parentWrapper.sortChildren();
		}
	}

	public function expandItem(item:FileWrapper, open:Bool):Void
	{
		// get the actual FileWrapper instance used by the collection
		// because the one passed in may have the same path, but be a
		// different instance
		item = findTreeViewItem(item);
		if (item == null)
		{
			return;
		}
		
		if (!_treeView.dataProvider.isBranch(item))
		{
			// nothing to expand
			return;
		}

		var alreadyOpen:Bool = _treeView.openBranches.indexOf(item) != -1;
		if (alreadyOpen != open)
		{
			var oldIgnoreTreeBranchChanges:Bool = _ignoreTreeBranchChanges;
			_ignoreTreeBranchChanges = true;
			_treeView.toggleBranch(item, open);
			_ignoreTreeBranchChanges = oldIgnoreTreeBranchChanges;
			if (open)
			{
				// Flex Tree dispatches an add event when opening a
				// branch, but Feathers does not, so we force it here
				reopenPreviouslyClosedItems(COLLECTION_EVENT_KIND_ADD, item.children.copy());
			}
		}
	}

	public function expandChildrenByName(itemPropertyName:String, childrenForOpen:Array<Any>):Void
	{
		var location:Array<Int> = [];
		var childrenForOpenCount:Int = childrenForOpen.length;
		for (i in 0...childrenForOpenCount)
		{
			var item:Any = childrenForOpen[i];
			var dataProviderCount:Int = _treeView.dataProvider.getLength(location);
			for (j in 0...dataProviderCount)
			{
				location.push(j);
				var childForOpen:FileWrapper = cast(_treeView.dataProvider.get(location), FileWrapper);

				var folderLastSeparator:Int = childForOpen.nativePath.lastIndexOf(childForOpen.file.fileBridge.separator);
				var folder:String = childForOpen.nativePath.substring(folderLastSeparator + 1);

				if (((Reflect.hasField(childForOpen, itemPropertyName) || Reflect.hasField(childForOpen, 'get_$itemPropertyName'))
						&& Reflect.getProperty(childForOpen, itemPropertyName) == item) || folder == item)
				{
					if (_treeView.dataProvider.isBranch(childForOpen)
							&& !_treeView.isBranchOpen(childForOpen))
					{
						saveItemForOpen(childrenForOpen);
						expandItem(childForOpen, true);
					}

					// break to the outer loop, and keep looking with a deeper location
					break;
				}
				location.pop();
			}
		}
	}

	public function refresh(dir:FileLocation, markAsDeletion:Bool = false):Void
	{
		var folders:Array<FileWrapper> = model.selectedprojectFolders.source;
		var wrappersToSort:Array<FileWrapper> = [];
		for (fw in folders)
		{
			if(ConstantsCoreVO.IS_AIR)
			{
				if((dir.fileBridge.nativePath + dir.fileBridge.separator).indexOf(fw.nativePath + dir.fileBridge.separator) != -1)
				{
					var tmpFW:FileWrapper = UtilsCore.findFileWrapperAgainstFileLocation(fw, dir);
					if(tmpFW != null)
					{
						if(_treeView.selectedItem)
						{
							var lastSelectedItem:FileWrapper = Std.downcast(_treeView.selectedItem, FileWrapper);
							if(tmpFW.nativePath == lastSelectedItem.nativePath || lastSelectedItem.nativePath.indexOf(tmpFW.nativePath + tmpFW.file.fileBridge.separator) != -1)
								_treeView.selectedItem.isDeleting = markAsDeletion;
						}
						refreshItem(tmpFW);
						wrappersToSort.push(tmpFW);
					}
					break;
				}
			}
			else
			{
				var tmpFW:FileWrapper = UtilsCore.findFileWrapperAgainstFileLocation(fw, dir);
				refreshItem(tmpFW);
				wrappersToSort.push(tmpFW);
			}
		}

		while(wrappersToSort.length > 0)
		{
			var tmpFW = wrappersToSort.shift();
			sortChildren(tmpFW);
			var children:Array<FileWrapper> = tmpFW.children;
			if (children != null)
			{
				var childCount:Int = children.length;
				for(i in 0...childCount)
				{
					var child:FileWrapper = children[i];
					if (_treeView.dataProvider.isBranch(child) && _treeView.isBranchOpen(child))
					{
						// when calling refreshItem(), all children are
						// replaced with new FileWrapper instances, so their
						// children will need to be sorted too
						wrappersToSort.push(child);
					}
				}
			}
		}
	}

	public function refreshItem(fw:FileWrapper):Void
	{
		var location:Array<Int> = _treeView.dataProvider.locationOf(fw);
		if (location == null)
		{
			return;
		}

		_treeView.dataProvider.updateAt(location);
		fw = Std.downcast(_treeView.dataProvider.get(location), FileWrapper);

		if (fw == null)
		{
			return;
		}

		var lastSelectedItem:FileWrapper = Std.downcast(_treeView.selectedItem, FileWrapper);
		var lastSelectedLocation:Array<Int> = _treeView.selectedLocation;
		if (!_treeView.dataProvider.isBranch(fw))
		{
			if (lastSelectedItem != null && lastSelectedItem.nativePath == fw.nativePath)
			{
				_treeView.selectedItem = fw;
			}
			return;
		}
		var openItems:Array<FileWrapper> = cast _treeView.openBranches;
		var items:Array<FileWrapper> = [fw];
		var newItems:Array<FileWrapper> = [];
		do
		{
			for (item in items)
			{
				updateChildrenAndOpenItems(item, openItems, newItems);
			}
			items.resize(0);
			var temp:Array<FileWrapper> = items;
			items = newItems;
			newItems = temp;
		}
		while(items.length > 0);

		var oldIgnoreTreeBranchChanges:Bool = _ignoreTreeBranchChanges;
		_ignoreTreeBranchChanges = true;

		_treeView.openBranches = openItems;

		_ignoreTreeBranchChanges = oldIgnoreTreeBranchChanges;

		_treeView.selectedItem = findTreeViewItem(lastSelectedItem);

		// if still there has no selection to the tree
		if(_treeView.selectedItem == null && lastSelectedItem != null && lastSelectedLocation != null && _treeView.dataProvider.contains(lastSelectedItem))
		{
			_treeView.selectedLocation = lastSelectedLocation;
		}
	}

	public function refreshActiveProject(projectFileWrapper:FileWrapper):Void
	{
		if(projectFileWrapper == null) return;

		var activeProject:ProjectVO = UtilsCore.getProjectFromProjectFolder(projectFileWrapper);
		if(activeProject != null)
		{
			if(model.activeProject != activeProject)
			{
				model.activeProject = activeProject;
				UtilsCore.setProjectMenuType(activeProject);

				dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.ACTIVE_PROJECT_CHANGED, activeProject));
			}
		}
	}

	public function getProjectBySelection(orByProjectPath:String = null):ProjectVO
	{
		if(!_treeView.selectedItem && (orByProjectPath == null || orByProjectPath.length == 0)) return null;

		for (i in 0...projects.length)
		{
			if(orByProjectPath == null || orByProjectPath.length == 0)
			{
				if(cast(_treeView.selectedItem, FileWrapper).projectReference.path == projects.get(i).folderPath) return projects.get(i);
			} else
			{
				if(orByProjectPath == projects.get(i).folderPath) return projects.get(i);
			}
		}

		return null;
	}

	private function onWorkspaceChanged(event:Event):Void
	{
		if (_header.workspaces == null) {
			return;
		}
		var workspaces:Array<WorkspaceVO> = WorkspacePlugin.workspacesForViews.source;
		for (workspace in workspaces)
		{
			if (workspace.label == ConstantsCoreVO.CURRENT_WORKSPACE)
			{
				var oldIgnoreWorkspaceChange = _ignoreWorkspaceChange;
				_ignoreWorkspaceChange = true;
				_header.selectedWorkspace = workspace;
				_ignoreWorkspaceChange = oldIgnoreWorkspaceChange;
				break;
			}
		}
	}

	private function updateChildrenAndOpenItems(fw:FileWrapper, openItems:Array<FileWrapper>, newItems:Array<FileWrapper>):Void
	{
		var location:Array<Int> = _treeView.dataProvider.locationOf(fw);
		if (location == null)
		{
			return;
		}
		_treeView.dataProvider.updateAt(location);
		var length:Int = _treeView.dataProvider.getLength(location);
		for (i in 0...length)
		{
			location.push(i);
			var child:FileWrapper = cast(_treeView.dataProvider.get(location), FileWrapper);
			location.pop();
			for(j in 0...openItems.length)
			{
				var openItem:FileWrapper = openItems[j];
				if(openItem.nativePath == child.nativePath && openItem != child)
				{
					openItems[j] = child;
					newItems.push(child);
					break;
				}
			}
		}
	}

	private function setSelectedItem(fw:FileWrapper):Void
	{
		var filew:FileWrapper = null;
		var folders:Array<FileWrapper> = model.selectedprojectFolders.source;
		if(folders.length > 1)
		{
			for (i in 0...folders.length)
			{
				if(fw.nativePath.indexOf(Std.downcast(folders[i], FileWrapper).nativePath) >= 0)
				{
					filew = Std.downcast(folders[i], FileWrapper);
					break;
				}
			}
		}
		else
		{
			filew = Std.downcast(model.selectedprojectFolders[0], FileWrapper);
		}

		_treeView.selectedItem = findTreeViewItem(filew);
	}

	private function findTreeViewItem(itemToFind:FileWrapper):FileWrapper
	{
		if (itemToFind == null)
		{
			return null;
		}
		// locationOf does not check for the exact object. it checks for
		// an object that has the same native path. this allows us to
		// convert into the object that's actually in the data provider.
		var location:Array<Int> = _treeView.dataProvider.locationOf(itemToFind);
		if (location == null)
		{
			return null;
		}
		// this may return the item to find, or it might return a
		// different object that has the same native path
		return Std.downcast(_treeView.dataProvider.get(location), FileWrapper);
	}

	private function handleClose(event:Event):Void
	{
		if(stage != null) LayoutModifier.removeFromSidebar(cast(this.parent, IPanelWindow));
	}

	private function handleWorkspaceChange(event:Event):Void {
		if (_ignoreWorkspaceChange || _header.selectedWorkspace == null) {
			return;
		}
		dispatcher.dispatchEvent(
			new WorkspaceEvent(WorkspaceEvent.LOAD_WORKSPACE_WITH_LABEL, _header.selectedWorkspace.label)
		);
	}

	private function fileSingleClickedInTreeView(event:TreeViewEvent):Void
	{
		var item:FileWrapper = Std.downcast(event.state.data, FileWrapper);
		refreshActiveProject(item);
	}

	private function fileDoubleClickedInTreeView(event:TreeViewEvent):Void
	{
		/*
		* @local
		*/
		function callRefreshActiveProject(value:FileWrapper):Void
		{
			if (_refreshActiveProjectTimeout != -1)
			{
				Lib.clearTimeout(_refreshActiveProjectTimeout);
				_refreshActiveProjectTimeout = -1;
			}
			_refreshActiveProjectTimeout = Lib.setTimeout(function():Void
			{
				_refreshActiveProjectTimeout = -1;
				refreshActiveProject(value);
			}, 300);
		}

		var item:FileWrapper = Std.downcast(event.state.data, FileWrapper);
		if(_treeView.dataProvider.isBranch(item))
		{
			callRefreshActiveProject(item);
			// don't ignore tree branch changes here!
			// this is a user interaction and the opened or closed
			// folder should be saved
			var open:Bool = !_treeView.isBranchOpen(item);
			_treeView.toggleBranch(item, open);
			if (open)
			{
				// Flex Tree dispatches an add event when opening a
				// branch, but Feathers does not, so we force it here
				reopenPreviouslyClosedItems(COLLECTION_EVENT_KIND_ADD, item.children.copy());
			}
		} 
		else
		{
			if(item.file.fileBridge.isDirectory || item.isWorking) return;

			callRefreshActiveProject(item);
			dispatcher.dispatchEvent(
					new OpenFileEvent(OpenFileEvent.OPEN_FILE, [item.file], -1, [item])
			);
		}
	}

	private function onTreeViewBranchOpen(event:TreeViewEvent):Void
	{
		if (_ignoreTreeBranchChanges)
		{
			return;
		}
		saveItemForOpen(event.state.data);
	}

	private function onTreeViewBranchClose(event:TreeViewEvent):Void
	{
		if (_ignoreTreeBranchChanges)
		{
			return;
		}
		removeFromOpenedItems(event.state.data);
	}

	private function onScrollFromSource(event:Event):Void
	{
		dispatcher.dispatchEvent(new ProjectEvent(ProjectEvent.SCROLL_FROM_SOURCE));
	}

	private function reopenPreviouslyClosedItems(eventKind:String, items:Array<Any>):Void
	{
		if (model.selectedprojectFolders == null || _treeView == null)
		{
			return;
		}

		var itemsCount:Int = model.selectedprojectFolders.length;
		if (itemsCount > 0)
		{
			if (eventKind == COLLECTION_EVENT_KIND_ADD || eventKind == COLLECTION_EVENT_KIND_RESET)
			{
				itemsCount = items.length;
				if (eventKind == COLLECTION_EVENT_KIND_RESET)
				{
					if (itemsCount == 0)
					{
						items = model.selectedprojectFolders.source.copy();
						itemsCount = items.length;
					}
				}

				if (itemsCount > 0)
				{
					setItemsAsOpen(items);
				}
			}
		}
	}

	private function saveItemForOpen(item:Any):Void
	{
		SharedObjectUtil.saveProjectTreeItemForOpen(item, PROPERTY_NAME_KEY, PROPERTY_NAME_KEY_VALUE);
	}

	private function removeFromOpenedItems(item:Any):Void
	{
		SharedObjectUtil.removeProjectTreeItemFromOpenedItems(item, PROPERTY_NAME_KEY, PROPERTY_NAME_KEY_VALUE);
	}

	private function setItemsAsOpen(items:Array<Any>):Void
	{
		var cookie:SharedObject = SharedObjectUtil.getMoonshineIDEProjectSO("projectTree");
		if (cookie == null) return;

		var projectTree:Array<Any> = cookie.data.projectTree;
		if (projectTree != null && items.length > 0)
		{
			var fileWrapper:FileWrapper = Std.downcast(items.shift(), FileWrapper);
			if (fileWrapper != null && _treeView.dataProvider.isBranch(fileWrapper))
			{
				var open:Bool = _treeView.openBranches.indexOf(fileWrapper) != -1;
				if (!open)
				{
					var hasItemForOpen:Bool = Lambda.exists(projectTree,
							function hasSomeItemForOpen(itemForOpen:Any):Bool {
								var name:String = Reflect.getProperty(fileWrapper, PROPERTY_NAME_KEY);
								return (Reflect.hasField(itemForOpen, name) || Reflect.hasField(itemForOpen, 'get_$name')) &&
										Reflect.getProperty(itemForOpen, name) == Reflect.getProperty(fileWrapper, PROPERTY_NAME_KEY_VALUE);
							});
					if (hasItemForOpen)
					{
						//updateTreeViewItem(fileWrapper);
						// - or -
						// var location:Array = _treeView.dataProvider.locationOf(fileWrapper);
						// if (location != null) {
						// 	_treeView.dataProvider.updateAt(location);
						// }
						expandItem(fileWrapper, true);
						fileWrapper.sortChildren();
					}
				}
			}
			
			setItemsAsOpen(items);
		}
	}

	private function updateTreeViewItem(item:FileWrapper):Void
	{
		item = findTreeViewItem(item);
		if (item == null)
		{
			return;
		}
		var location:Array<Int> = _treeView.dataProvider.locationOf(item);
		if (location == null)
		{
			return;
		}
		_treeView.dataProvider.updateAt(location);
	}
}