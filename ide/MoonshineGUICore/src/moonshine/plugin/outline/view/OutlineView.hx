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

class OutlineView extends Panel implements IViewWithTitle {
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
		header.closeEnabled = true;
		header.addEventListener(Event.CLOSE, header_closeHandler);
		this.header = header;

		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
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
