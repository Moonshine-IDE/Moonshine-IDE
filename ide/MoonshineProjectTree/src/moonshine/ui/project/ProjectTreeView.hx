package moonshine.ui.project;

import actionScripts.valueObjects.ProjectReferenceVO;
import actionScripts.factory.FileLocation;
import actionScripts.valueObjects.FileWrapper;
import actionScripts.valueObjects.ProjectVO;
import actionScripts.valueObjects.WorkspaceVO;
import moonshine.data.ProjectTreeViewCollection;
import moonshine.events.ProjectTreeViewCollectionEvent;
import moonshine.events.ProjectTreeViewEvent;
import moonshine.ui.project.ProjectViewHeader;
import moonshine.ui.renderers.ProjectTreeViewItemRenderer;
import feathers.controls.LayoutGroup;
import feathers.controls.TreeView;
import feathers.data.IFlatCollection;
import feathers.events.TreeViewEvent;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import feathers.utils.DisplayObjectRecycler;
import openfl.display.DisplayObject;
import openfl.events.Event;

class ProjectTreeView extends LayoutGroup {
	private static final COLLECTION_EVENT_KIND_ADD:String = "add";
	private static final COLLECTION_EVENT_KIND_RESET:String = "reset";

	private var _header:ProjectViewHeader;
	private var _treeView:TreeView;

	private var _ignoreTreeBranchChanges:Bool = false;

	private var _ignoreWorkspaceChange:Bool = false;

	private var _oldActiveEditorFileLocation:FileLocation;

	public var selectedFile(get, set):FileLocation;

	private function get_selectedFile():FileLocation {
		if (_treeView == null || _treeView.selectedItem == null) {
			return null;
		}
		return cast(_treeView.selectedItem, FileWrapper).file;
	}

	private function set_selectedFile(value:FileLocation):FileLocation {
		if (_treeView == null) {
			return null;
		}
		_treeView.selectedItem = findTreeViewItemForLocation(value);
		if (_treeView.selectedItem == null) {
			return null;
		}
		return cast(_treeView.selectedItem, FileWrapper).file;
	}

	public var selectedFiles(get, set):Array<FileLocation>;

	private function get_selectedFiles():Array<FileLocation> {
		if (_treeView == null) {
			return null;
		}
		return _treeView.selectedItems.map(wrapper -> wrapper.file);
	}

	private function set_selectedFiles(value:Array<FileLocation>):Array<FileLocation> {
		if (_treeView == null) {
			return null;
		}
		if (value != null) {
			_treeView.selectedItems = value.map(function(item:FileLocation):FileWrapper {
				return findTreeViewItemForLocation(item);
			}).filter(function(wrapper:FileWrapper):Bool {
				return wrapper != null;
			});
		} else {
			_treeView.selectedItems = null;
		}
		return cast _treeView.selectedItems;
	}

	private var _selectedWorkspace:WorkspaceVO = null;

	@:flash.property
	public var selectedWorkspace(get, set):WorkspaceVO;

	private function get_selectedWorkspace():WorkspaceVO {
		return _selectedWorkspace;
	}

	private function set_selectedWorkspace(value:WorkspaceVO):WorkspaceVO {
		if (_selectedWorkspace == value) {
			return _selectedWorkspace;
		}
		_selectedWorkspace = value;
		setInvalid(SELECTION);
		dispatchEvent(new ProjectTreeViewEvent(ProjectTreeViewEvent.EVENT_WORKSPACE_CHANGE));
		return _selectedWorkspace;
	}

	private var _activeFile:FileLocation;

	public var activeFile(get, set):FileLocation;

	private function get_activeFile():FileLocation {
		return _activeFile;
	}

	private function set_activeFile(value:FileLocation):FileLocation {
		if (_activeFile == value) {
			return _activeFile;
		}
		if (_activeFile != null) {
			updateTreeViewItem(_activeFile);
		}

		_activeFile = value;

		if (_activeFile != null) {
			updateTreeViewItem(_activeFile);
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
		if (_header != null) {
			_header.workspaces = _workspaces;
			_header.visible = _header.includeInLayout = _workspaces != null;
		}
		return _workspaces;
	}

	public var projects:IFlatCollection<ProjectVO>;

	private var _hierarchicalCollection:ProjectTreeViewCollection;

	private var _dataProvider:IFlatCollection<FileLocation>;

	public var dataProvider(get, set):IFlatCollection<FileLocation>;

	private function get_dataProvider():IFlatCollection<FileLocation> {
		return _dataProvider;
	}

	private function set_dataProvider(value:IFlatCollection<FileLocation>):IFlatCollection<FileLocation> {
		if (_dataProvider == value) {
			return _dataProvider;
		}
		if (_hierarchicalCollection != null) {
			_hierarchicalCollection.removeEventListener(ProjectTreeViewCollectionEvent.DIRECTORY_LISTING_RECEIVED, onDirectoryListingReceived);
		}
		_dataProvider = value;
		if (value != null) {
			var roots:Array<FileWrapper> = [];
			for (item in value) {
				
				var projRef = new ProjectReferenceVO();
				projRef.path = item.fileBridge.nativePath.toString();
				roots.push(new FileWrapper(item, true, projRef));
			}
			_hierarchicalCollection = new ProjectTreeViewCollection(roots);
		} else {
			_hierarchicalCollection = null;
		}
		if (_treeView != null) {
			_treeView.dataProvider = _hierarchicalCollection;
		}
		if (_hierarchicalCollection != null) {
			_hierarchicalCollection.addEventListener(ProjectTreeViewCollectionEvent.DIRECTORY_LISTING_RECEIVED, onDirectoryListingReceived);
			reopenPreviouslyClosedItems(COLLECTION_EVENT_KIND_RESET, _hierarchicalCollection.roots.copy());
		}
		return _dataProvider;
	}

	public var projectTreeCookieCallback:() -> Array<Any>;
	public var projectTreeCookieName:String;
	public var projectTreeCookiePropertyNameKey:String;
	public var projectTreeCookiePropertyNameKeyValue:String;

	/**
		Used to initialize the item renderer, such as configuring a context
		menu or customizing skins.
	**/
	public var initializeItemRendererCallback:(ProjectTreeViewItemRenderer) -> Void;

	public var isActiveFileCallback:(FileLocation) -> Bool;
	public var isSourceFolderCallback:(FileLocation) -> Bool;

	public function new() {
		super();
	}

	override private function initialize():Void {
		super.initialize();

		layout = new VerticalLayout();

		_header = new ProjectViewHeader();
		_header.layoutData = VerticalLayoutData.fillHorizontal();
		_header.workspaces = _workspaces;
		_header.visible = _header.includeInLayout = _workspaces != null;
		_header.addEventListener(ProjectTreeViewEvent.EVENT_SCROLL_FROM_SOURCE, onHeaderScrollFromSource);
		_header.addEventListener(Event.CLOSE, handleClose);
		_header.addEventListener(Event.CHANGE, handleWorkspaceChange);
		addChild(_header);

		_treeView = new TreeView();
		_treeView.layoutData = VerticalLayoutData.fill();
		_treeView.variant = feathers.controls.TreeView.VARIANT_BORDERLESS;
		_treeView.dataProvider = _hierarchicalCollection;
		_treeView.itemToText = function(item:FileWrapper):String {
			return item.name;
		}
		_treeView.allowMultipleSelection = true;
		_treeView.itemRendererRecycler = DisplayObjectRecycler.withFunction(function():DisplayObject {
			var itemRenderer:ProjectTreeViewItemRenderer = new ProjectTreeViewItemRenderer();
			itemRenderer.doubleClickEnabled = true;
			itemRenderer.isActiveFileCallback = isActiveFileCallback;
			itemRenderer.isSourceFolderCallback = isSourceFolderCallback;
			if (initializeItemRendererCallback != null) {
				initializeItemRendererCallback(itemRenderer);
			}
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
			refreshWrapper(fileWrapper);
		});
		_treeView.addEventListener(TreeViewEvent.BRANCH_OPEN, onTreeViewBranchOpen);
		_treeView.addEventListener(TreeViewEvent.BRANCH_CLOSE, onTreeViewBranchClose);
		_treeView.addEventListener(Event.CHANGE, onTreeViewChange);
		_treeView.addEventListener(TreeViewEvent.ITEM_DOUBLE_CLICK, fileDoubleClickedInTreeView);
		addChild(_treeView);
	}

	public function isItemVisible(item:FileLocation):Bool {
		if (_treeView == null) {
			return false;
		}
		var wrapper:FileWrapper = findTreeViewItemForLocation(item);
		if (wrapper == null) {
			return false;
		}
		var itemRenderer:DisplayObject = _treeView.itemToItemRenderer(wrapper);
		if (itemRenderer == null) {
			return false;
		}
		// TODO: Check if item renderer is in view port (it might be
		// just outside of the view port and not actually visible)
		return true;
	}

	public function scrollToItem(item:FileLocation):Void {
		if (_treeView == null) {
			return;
		}

		var wrapper = findTreeViewItemForLocation(item);
		if (wrapper == null) {
			return;
		}

		var location:Array<Int> = _treeView.dataProvider.locationOf(item);
		if (location == null) {
			return;
		}
		_treeView.scrollToLocation(location);
	}

	public function expandItem(item:FileLocation, open:Bool):Void {
		var wrapper = findTreeViewItemForLocation(item);
		return expandWrapper(wrapper, open);
	}

	public function expandChildrenByName(itemPropertyName:String, childrenForOpen:Array<String>):Void {
		var location:Array<Int> = [];
		var childrenForOpenCount:Int = childrenForOpen.length;
		for (i in 0...childrenForOpenCount) {
			var item:String = childrenForOpen[i];
			var dataProviderCount:Int = _treeView.dataProvider.getLength(location);
			for (j in 0...dataProviderCount) {
				location.push(j);
				var childForOpen:FileWrapper = cast(_treeView.dataProvider.get(location), FileWrapper);

				var folderLastSeparator:Int = childForOpen.nativePath.lastIndexOf(childForOpen.file.fileBridge.separator);
				var folder:String = childForOpen.nativePath.substring(folderLastSeparator + 1);

				if (((Reflect.hasField(childForOpen, itemPropertyName) || Reflect.hasField(childForOpen, 'get_$itemPropertyName'))
					&& Reflect.getProperty(childForOpen, itemPropertyName) == item)
					|| folder == item) {
					if (_treeView.dataProvider.isBranch(childForOpen) && !_treeView.isBranchOpen(childForOpen)) {
						saveItemForOpen(childForOpen);
						expandWrapper(childForOpen, true);
					}

					// break to the outer loop, and keep looking with a deeper location
					break;
				}
				location.pop();
			}
		}
	}

	public function refresh(dir:FileLocation, markAsDeletion:Bool = false):Void {
		var folders:Array<FileWrapper> = _hierarchicalCollection.roots;
		var wrappersToSort:Array<FileWrapper> = [];
		for (fw in folders) {
			#if (air || sys)
			if ((dir.fileBridge.nativePath + dir.fileBridge.separator).indexOf(fw.nativePath + dir.fileBridge.separator) != -1) {
				var tmpFW:FileWrapper = findFileWrapperAgainstFileLocation(fw, dir);
				if (tmpFW != null) {
					if (_treeView.selectedItem != null) {
						var lastSelectedItem:FileWrapper = Std.downcast(_treeView.selectedItem, FileWrapper);
						if (tmpFW.nativePath == lastSelectedItem.nativePath
							|| lastSelectedItem.nativePath.indexOf(tmpFW.nativePath + tmpFW.file.fileBridge.separator) != -1) {
							_treeView.selectedItem.isDeleting = markAsDeletion;
						}
					}
					refreshWrapper(tmpFW);
					wrappersToSort.push(tmpFW);
				}
				break;
			}
			#else
			var tmpFW:FileWrapper = findFileWrapperAgainstFileLocation(fw, dir);
			refreshWrapper(tmpFW);
			wrappersToSort.push(tmpFW);
			#end
		}

		while (wrappersToSort.length > 0) {
			var tmpFW = wrappersToSort.shift();
			tmpFW.sortChildren();
			var children:Array<FileWrapper> = tmpFW.children;
			if (children != null) {
				var childCount:Int = children.length;
				for (i in 0...childCount) {
					var child:FileWrapper = children[i];
					if (_treeView.dataProvider.isBranch(child) && _treeView.isBranchOpen(child)) {
						// when calling refreshItem(), all children are
						// replaced with new FileWrapper instances, so their
						// children will need to be sorted too
						wrappersToSort.push(child);
					}
				}
			}
		}
	}

	public function refreshItem(item:FileLocation):Void {
		var wrapper:FileWrapper = findTreeViewItemForLocation(item);
		if (wrapper == null) {
			return;
		}
		refreshWrapper(wrapper);
	}

	public function getProjectBySelection(orByProjectPath:String = null):ProjectVO {
		if (!_treeView.selectedItem && (orByProjectPath == null || orByProjectPath.length == 0)) {
			return null;
		}

		for (i in 0...projects.length) {
			if (orByProjectPath == null || orByProjectPath.length == 0) {
				if (cast(_treeView.selectedItem, FileWrapper).projectReference.path == projects.get(i).folderPath) {
					return projects.get(i);
				}
			} else {
				if (orByProjectPath == projects.get(i).folderPath) {
					return projects.get(i);
				}
			}
		}

		return null;
	}

	private function refreshWrapper(fw:FileWrapper):Void {
		var location:Array<Int> = _treeView.dataProvider.locationOf(fw);
		if (location == null) {
			return;
		}

		_treeView.dataProvider.updateAt(location);
		fw = Std.downcast(_treeView.dataProvider.get(location), FileWrapper);

		if (fw == null) {
			return;
		}

		var lastSelectedItem:FileWrapper = Std.downcast(_treeView.selectedItem, FileWrapper);
		var lastSelectedLocation:Array<Int> = _treeView.selectedLocation;
		if (!_treeView.dataProvider.isBranch(fw)) {
			if (lastSelectedItem != null && lastSelectedItem.nativePath == fw.nativePath) {
				_treeView.selectedItem = fw;
			}
			return;
		}
		var openItems:Array<FileWrapper> = cast _treeView.openBranches;
		var items:Array<FileWrapper> = [fw];
		var newItems:Array<FileWrapper> = [];
		do {
			for (item in items) {
				updateChildrenAndOpenItems(item, openItems, newItems);
			}
			items.resize(0);
			var temp:Array<FileWrapper> = items;
			items = newItems;
			newItems = temp;
		} while (items.length > 0);

		var oldIgnoreTreeBranchChanges:Bool = _ignoreTreeBranchChanges;
		_ignoreTreeBranchChanges = true;

		_treeView.openBranches = openItems;

		_ignoreTreeBranchChanges = oldIgnoreTreeBranchChanges;

		_treeView.selectedItem = findTreeViewItem(lastSelectedItem);

		// if still there has no selection to the tree
		if (_treeView.selectedItem == null
			&& lastSelectedItem != null
			&& lastSelectedLocation != null
			&& _treeView.dataProvider.contains(lastSelectedItem)) {
			_treeView.selectedLocation = lastSelectedLocation;
		}
	}

	private function expandWrapper(item:FileWrapper, open:Bool):Void {
		// get the actual FileWrapper instance used by the collection
		// because the one passed in may have the same path, but be a
		// different instance
		item = findTreeViewItem(item);
		if (item == null) {
			return;
		}

		if (!_treeView.dataProvider.isBranch(item)) {
			// nothing to expand
			return;
		}

		var alreadyOpen:Bool = _treeView.openBranches.indexOf(item) != -1;
		if (alreadyOpen != open) {
			var oldIgnoreTreeBranchChanges:Bool = _ignoreTreeBranchChanges;
			_ignoreTreeBranchChanges = true;
			_treeView.toggleBranch(item, open);
			_ignoreTreeBranchChanges = oldIgnoreTreeBranchChanges;
			if (open) {
				// Flex Tree dispatches an add event when opening a
				// branch, but Feathers does not, so we force it here
				if (item.children != null) {
					reopenPreviouslyClosedItems(COLLECTION_EVENT_KIND_ADD, item.children.copy());
				}
			}
		}
	}

	override private function update():Void {
		var dataInvalid = isInvalid(DATA);
		var selectionInvalid = isInvalid(SELECTION);

		if (dataInvalid || selectionInvalid) {
			_header.selectedWorkspace = _selectedWorkspace;
		}

		super.update();
	}

	private function updateChildrenAndOpenItems(fw:FileWrapper, openItems:Array<FileWrapper>, newItems:Array<FileWrapper>, refreshItem:Bool = true):Void {
		var location:Array<Int> = _treeView.dataProvider.locationOf(fw);
		if (location == null) {
			return;
		}
		if (refreshItem) {
			_treeView.dataProvider.updateAt(location);
		}
		var length:Int = _treeView.dataProvider.getLength(location);
		for (i in 0...length) {
			location.push(i);
			var child:FileWrapper = cast(_treeView.dataProvider.get(location), FileWrapper);
			location.pop();
			for (j in 0...openItems.length) {
				var openItem:FileWrapper = openItems[j];
				if (openItem.nativePath == child.nativePath && openItem != child) {
					openItems[j] = child;
					newItems.push(child);
					break;
				}
			}
		}
	}

	private function setSelectedItem(fw:FileWrapper):Void {
		var filew:FileWrapper = null;
		var folders:Array<FileWrapper> = _hierarchicalCollection.roots;
		if (folders.length > 1) {
			for (i in 0...folders.length) {
				if (fw.nativePath.indexOf(Std.downcast(folders[i], FileWrapper).nativePath) >= 0) {
					filew = Std.downcast(folders[i], FileWrapper);
					break;
				}
			}
		} else {
			filew = Std.downcast(_hierarchicalCollection.get([0]), FileWrapper);
		}

		_treeView.selectedItem = findTreeViewItem(filew);
	}

	private function findTreeViewItem(itemToFind:FileWrapper):FileWrapper {
		if (itemToFind == null) {
			return null;
		}
		// locationOf does not check for the exact object. it checks for
		// an object that has the same native path. this allows us to
		// convert into the object that's actually in the data provider.
		var location:Array<Int> = _treeView.dataProvider.locationOf(itemToFind);
		if (location == null) {
			return null;
		}
		// this may return the item to find, or it might return a
		// different object that has the same native path
		return Std.downcast(_treeView.dataProvider.get(location), FileWrapper);
	}

	private function findTreeViewItemForLocation(itemToFind:FileLocation):FileWrapper {
		if (itemToFind == null) {
			return null;
		}
		var wrapper = createFileWrapper(itemToFind);
		// locationOf does not check for the exact object. it checks for
		// an object that has the same native path. this allows us to
		// convert into the object that's actually in the data provider.
		var location:Array<Int> = _treeView.dataProvider.locationOf(wrapper);
		if (location == null) {
			return null;
		}
		// this may return the item to find, or it might return a
		// different object that has the same native path
		return Std.downcast(_treeView.dataProvider.get(location), FileWrapper);
	}

	private function handleClose(event:Event):Void {
		dispatchEvent(new Event(Event.CLOSE));
	}

	private function handleWorkspaceChange(event:Event):Void {
		if (_ignoreWorkspaceChange || _header.selectedWorkspace == null) {
			return;
		}
		selectedWorkspace = _header.selectedWorkspace;
	}

	private function onTreeViewChange(event:Event):Void {
		dispatchEvent(new Event(Event.CHANGE));
	}

	private function fileDoubleClickedInTreeView(event:TreeViewEvent):Void {
		var item:FileWrapper = Std.downcast(event.state.data, FileWrapper);
		if (_treeView.dataProvider.isBranch(item)) {
			// don't ignore tree branch changes here!
			// this is a user interaction and the opened or closed
			// folder should be saved
			var open:Bool = !_treeView.isBranchOpen(item);
			_treeView.toggleBranch(item, open);
			if (open) {
				// Flex Tree dispatches an add event when opening a
				// branch, but Feathers does not, so we force it here
				if (item.children != null) {
					reopenPreviouslyClosedItems(COLLECTION_EVENT_KIND_ADD, item.children.copy());
				}
			}
		} else {
			if (item.file.fileBridge.isDirectory || item.isWorking)
				return;

			dispatchEvent(new ProjectTreeViewEvent(ProjectTreeViewEvent.EVENT_OPEN_FILE, item.file));
		}
	}

	private function onTreeViewBranchOpen(event:TreeViewEvent):Void {
		if (_ignoreTreeBranchChanges) {
			return;
		}
		var item:FileWrapper = Std.downcast(event.state.data, FileWrapper);
		if (item != null) {
			saveItemForOpen(item);
		}
	}

	private function onTreeViewBranchClose(event:TreeViewEvent):Void {
		if (_ignoreTreeBranchChanges) {
			return;
		}
		var item:FileWrapper = cast(event.state.data, FileWrapper);
		if (item != null) {
			removeFromOpenedItems(item);
		}
	}

	private function onDirectoryListingReceived(event:ProjectTreeViewCollectionEvent):Void {
		if (_treeView == null || _treeView.dataProvider != _hierarchicalCollection || event.fileWrapper == null) {
			return;
		}
		var item = findTreeViewItem(event.fileWrapper);
		if (item == null || !_treeView.isBranchOpen(item)) {
			return;
		}
		var openItems:Array<FileWrapper> = cast _treeView.openBranches;
		var newItems:Array<FileWrapper> = [];
		updateChildrenAndOpenItems(item, openItems, newItems, false);
		var oldIgnoreTreeBranchChanges:Bool = _ignoreTreeBranchChanges;
		_ignoreTreeBranchChanges = true;
		_treeView.openBranches = openItems;
		_ignoreTreeBranchChanges = oldIgnoreTreeBranchChanges;
		if (item.children != null) {
			reopenPreviouslyClosedItems(COLLECTION_EVENT_KIND_ADD, item.children.copy());
		}
	}

	private function onHeaderScrollFromSource(event:Event):Void {
		dispatchEvent(new ProjectTreeViewEvent(ProjectTreeViewEvent.EVENT_SCROLL_FROM_SOURCE));
	}

	private function reopenPreviouslyClosedItems(eventKind:String, items:Array<Any>):Void {
		if (_hierarchicalCollection == null || _treeView == null) {
			return;
		}

		var itemsCount:Int = _hierarchicalCollection.getLength();
		if (itemsCount > 0) {
			if (eventKind == COLLECTION_EVENT_KIND_ADD || eventKind == COLLECTION_EVENT_KIND_RESET) {
				itemsCount = items.length;
				if (eventKind == COLLECTION_EVENT_KIND_RESET) {
					if (itemsCount == 0) {
						items = _hierarchicalCollection.roots.copy();
						itemsCount = items.length;
					}
				}

				if (itemsCount > 0) {
					setItemsAsOpen(items);
				}
			}
		}
	}

	private function saveItemForOpen(item:FileWrapper):Void {
		dispatchEvent(new ProjectTreeViewEvent(ProjectTreeViewEvent.EVENT_SAVE_TO_OPENED_ITEMS, item.file));
	}

	private function removeFromOpenedItems(item:FileWrapper):Void {
		dispatchEvent(new ProjectTreeViewEvent(ProjectTreeViewEvent.EVENT_REMOVE_FROM_OPENED_ITEMS, item.file));
	}

	private function setItemsAsOpen(items:Array<Any>):Void {
		if (projectTreeCookieCallback == null)
			return;

		var projectTree:Array<Any> = projectTreeCookieCallback();
		if (projectTree != null && items.length > 0) {
			var fileWrapper:FileWrapper = Std.downcast(items.shift(), FileWrapper);
			if (fileWrapper != null && _treeView.dataProvider.isBranch(fileWrapper)) {
				var open:Bool = _treeView.openBranches.indexOf(fileWrapper) != -1;
				if (!open) {
					var hasItemForOpen:Bool = Lambda.exists(projectTree, function hasSomeItemForOpen(itemForOpen:Any):Bool {
						var name:String = Reflect.getProperty(fileWrapper, projectTreeCookiePropertyNameKey);
						return (Reflect.hasField(itemForOpen, name) || Reflect.hasField(itemForOpen, 'get_$name'))
							&& Reflect.getProperty(itemForOpen, name) == Reflect.getProperty(fileWrapper, projectTreeCookiePropertyNameKeyValue);
					});
					if (hasItemForOpen) {
						expandWrapper(fileWrapper, true);
						fileWrapper.sortChildren();
					}
				}
			}

			setItemsAsOpen(items);
		}
	}

	private function updateTreeViewItem(item:FileLocation):Void {
		var wrapper = findTreeViewItemForLocation(item);
		if (wrapper == null) {
			return;
		}
		var location:Array<Int> = _treeView.dataProvider.locationOf(wrapper);
		if (location == null) {
			return;
		}
		_treeView.dataProvider.updateAt(location);
	}
	
	private function createFileWrapper(item:FileLocation):FileWrapper
	{
		var projectReference:ProjectReferenceVO = null;
		for (i in 0..._dataProvider.length) {
			var root = _dataProvider.get(i);
			if (StringTools.startsWith(item.fileBridge.nativePath, root.fileBridge.nativePath + root.fileBridge.separator)) {
				projectReference = new ProjectReferenceVO();
				projectReference.path = root.fileBridge.nativePath;
				break;
			}
		}
		return new FileWrapper(item, false, projectReference, false);
	}

	private function findFileWrapperAgainstFileLocation(current:FileWrapper, target:FileLocation):FileWrapper {
		// Recurse-find filewrapper child
		for (child in current.children) {
			if (target.fileBridge.nativePath == child.nativePath
				|| target.fileBridge.nativePath.indexOf(child.nativePath + target.fileBridge.separator) == 0) {
				if (target.fileBridge.nativePath == child.nativePath) {
					return child;
				}
				if (child.children != null) {
					return findFileWrapperAgainstFileLocation(child, target);
				}
				break;
			}
		}
		return current;
	}
}
