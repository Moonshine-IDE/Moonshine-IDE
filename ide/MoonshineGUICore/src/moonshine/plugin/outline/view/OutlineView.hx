/*
	Copyright 2020 Prominic.NET, Inc.

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License

	Author: Prominic.NET, Inc.
	No warranty of merchantability or fitness of any kind.
	Use this software at your own risk.
 */

package moonshine.plugin.outline.view;

import actionScripts.interfaces.IViewWithTitle;
import feathers.controls.Panel;
import feathers.controls.TreeView;
import feathers.controls.dataRenderers.HierarchicalItemRenderer;
import feathers.core.InvalidationFlag;
import feathers.data.ArrayCollection;
import feathers.data.ArrayHierarchicalCollection;
import feathers.data.TreeViewItemState;
import feathers.events.HierarchicalCollectionEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.utils.DisplayObjectRecycler;
import moonshine.lsp.DocumentSymbol;
import moonshine.lsp.SymbolInformation;
import moonshine.plugin.symbols.view.SymbolIcon;
import moonshine.ui.SideBarViewHeader;
import openfl.events.Event;
import openfl.events.EventType;

class OutlineView extends Panel implements IViewWithTitle {
	public static final SORT_BY_POSITION = "position";
	public static final SORT_BY_NAME = "name";
	public static final SORT_BY_CATEGORY = "category";

	public static final EVENT_SORT_CHANGE:EventType<Event> = "sortChange";

	public function new() {
		super();
	}

	private var treeView:TreeView;

	@:flash.property
	public var title(get, never):String;

	public function get_title():String {
		return "Outline";
	}

	private var _outline:ArrayHierarchicalCollection<Dynamic> = new ArrayHierarchicalCollection();

	@:flash.property
	public var outline(get, set):ArrayHierarchicalCollection<Dynamic>;

	private function get_outline():ArrayHierarchicalCollection<Dynamic> {
		return this._outline;
	}

	private function set_outline(value:ArrayHierarchicalCollection<Dynamic>):ArrayHierarchicalCollection<Dynamic> {
		if (this._outline == value) {
			return this._outline;
		}
		if (this._outline != null) {
			this._outline.removeEventListener(HierarchicalCollectionEvent.RESET, outline_resetHandler);
		}
		this._outline = value;
		if (this._outline != null) {
			this._outline.addEventListener(HierarchicalCollectionEvent.RESET, outline_resetHandler);
		}
		this.setInvalid(InvalidationFlag.DATA);
		return this._outline;
	}

	@:flash.property
	public var selectedSymbol(get, never):Dynamic;

	public function get_selectedSymbol():Dynamic {
		if (this.treeView == null) {
			return null;
		}
		return this.treeView.selectedItem;
	}

	private var _sortBy:String = SORT_BY_POSITION;

	@:flash.property
	public var sortBy(get, set):String;

	public function get_sortBy():String {
		return this._sortBy;
	}

	public function set_sortBy(value:String):String {
		if (this._sortBy == value) {
			return this._sortBy;
		}
		this._sortBy = value;
		this.setInvalid(DATA);
		this.dispatchEvent(new Event(EVENT_SORT_CHANGE));
		return this._sortBy;
	}

	override private function initialize():Void {
		this.layout = new AnchorLayout();

		this.treeView = new TreeView();
		this.treeView.variant = TreeView.VARIANT_BORDERLESS;
		this.treeView.layoutData = AnchorLayoutData.fill();
		this.treeView.itemToText = (item:Dynamic) -> {
			if (Std.isOfType(item, SymbolInformation)) {
				return cast(item, SymbolInformation).name;
			} else if (Std.isOfType(item, DocumentSymbol)) {
				return cast(item, DocumentSymbol).name;
			}
			return "";
		};
		this.treeView.itemRendererRecycler = DisplayObjectRecycler.withFunction(() -> {
			var itemRenderer = new HierarchicalItemRenderer();
			itemRenderer.icon = new SymbolIcon();
			return itemRenderer;
		}, (itemRenderer, state:TreeViewItemState) -> {
			var item = state.data;
			var icon = cast(itemRenderer.icon, SymbolIcon);
			icon.data = item;
			itemRenderer.text = state.text;
			if ((item is DocumentSymbol)) {
				var documentSymbol = cast(item, DocumentSymbol);
				var detail = documentSymbol.detail;
				itemRenderer.toolTip = (detail != null && detail.length > 0) ? detail : null;
			} else {
				itemRenderer.toolTip = null;
			}
		});
		this.treeView.addEventListener(Event.CHANGE, treeView_changeHandler);
		this.addChild(this.treeView);

		var header = new SideBarViewHeader();
		header.title = this.title;
		header.menuDataProvider = new ArrayCollection([
			new SideBarViewHeaderMenuItem("Sort By: Position", (item) -> {
				this.sortBy = SORT_BY_POSITION;
			}),
			new SideBarViewHeaderMenuItem("Sort By: Name", (item) -> {
				this.sortBy = SORT_BY_NAME;
			}),
			new SideBarViewHeaderMenuItem("Sort By: Category", (item) -> {
				this.sortBy = SORT_BY_CATEGORY;
			})
		]);
		header.closeEnabled = true;
		header.addEventListener(Event.CLOSE, header_closeHandler);
		this.header = header;

		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			this._outline.sortCompareFunction = switch (this._sortBy) {
				case SORT_BY_NAME: sortByName;
				case SORT_BY_CATEGORY: sortByCategory;
				default: sortByPosition;
			}
			this.treeView.dataProvider = this._outline;
			if (this._outline != null && this._outline.getLength() > 0) {
				// open the first branch, if possible
				var rootBranch = this._outline.get([0]);
				if (this._outline.isBranch(rootBranch)) {
					this.treeView.toggleBranch(rootBranch, true);
				}
			}
		}
		super.update();
	}

	private function sortByPosition(s1:Dynamic, s2:Dynamic):Int {
		var l1 = 0;
		var c1 = 0;
		var l2 = 0;
		var c2 = 0;
		if (Std.isOfType(s1, SymbolInformation)) {
			var si1 = (s1 : SymbolInformation);
			var rangeStart = si1.location.range.start;
			l1 = rangeStart.line;
			c1 = rangeStart.character;
		} else if (Std.isOfType(s1, DocumentSymbol)) {
			var ds1 = (s1 : DocumentSymbol);
			var rangeStart = ds1.range.start;
			l1 = rangeStart.line;
			c1 = rangeStart.character;
		}
		if (Std.isOfType(s2, SymbolInformation)) {
			var si2 = (s2 : SymbolInformation);
			var rangeStart = si2.location.range.start;
			l2 = rangeStart.line;
			c2 = rangeStart.character;
		} else if (Std.isOfType(s2, DocumentSymbol)) {
			var ds2 = (s2 : DocumentSymbol);
			var rangeStart = ds2.range.start;
			l2 = rangeStart.line;
			c2 = rangeStart.character;
		}
		if (l1 < l2) {
			return -1;
		}
		if (l1 > l2) {
			return 1;
		}
		if (c1 < c2) {
			return -1;
		}
		if (c1 > c2) {
			return 1;
		}
		return 0;
	}

	private function sortByCategory(s1:Dynamic, s2:Dynamic):Int {
		var c1 = 0;
		var c2 = 0;
		if (Std.isOfType(s1, SymbolInformation)) {
			var si1 = (s1 : SymbolInformation);
			c1 = si1.kind;
		} else if (Std.isOfType(s1, DocumentSymbol)) {
			var ds1 = (s1 : DocumentSymbol);
			c1 = ds1.kind;
		}
		if (Std.isOfType(s2, SymbolInformation)) {
			var si2 = (s2 : SymbolInformation);
			c2 = si2.kind;
		} else if (Std.isOfType(s2, DocumentSymbol)) {
			var ds2 = (s2 : DocumentSymbol);
			c2 = ds2.kind;
		}
		if (c1 < c2) {
			return -1;
		}
		if (c1 > c2) {
			return 1;
		}
		return sortByName(s1, s2);
	}

	private function sortByName(s1:Dynamic, s2:Dynamic):Int {
		var text1 = this.treeView.itemToText(s1).toLowerCase();
		var text2 = this.treeView.itemToText(s2).toLowerCase();
		if (text1 < text2) {
			return -1;
		}
		if (text1 > text2) {
			return 1;
		}
		return 0;
	}

	private function header_closeHandler(event:Event):Void {
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function treeView_changeHandler(event:Event):Void {
		this.dispatchEvent(new Event(Event.CHANGE));
	}

	private function outline_resetHandler(event:HierarchicalCollectionEvent):Void {
		// ensure that update() is run so that the root branches are opened
		this.setInvalid(InvalidationFlag.DATA);
	}
}
