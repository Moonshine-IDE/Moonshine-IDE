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
import actionScripts.valueObjects.DocumentSymbol;
import actionScripts.valueObjects.SymbolInformation;
import feathers.controls.Panel;
import feathers.controls.TreeView;
import feathers.core.InvalidationFlag;
import feathers.data.TreeCollection;
import feathers.data.TreeNode;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import moonshine.theme.MoonshineTheme;
import moonshine.ui.SideBarViewHeader;
import openfl.events.Event;

class OutlineView extends Panel implements IViewWithTitle {
	public function new() {
		MoonshineTheme.initializeTheme();

		super();
	}

	private var treeView:TreeView;

	@:flash.property
	public var title(get, never):String;

	public function get_title():String {
		return "Outline";
	}

	private var _outline:TreeCollection<Dynamic> = new TreeCollection();

	@:flash.property
	public var outline(get, set):TreeCollection<Dynamic>;

	private function get_outline():TreeCollection<Dynamic> {
		return this._outline;
	}

	private function set_outline(value:TreeCollection<Dynamic>):TreeCollection<Dynamic> {
		if (this._outline == value) {
			return this._outline;
		}
		this._outline = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._outline;
	}

	@:flash.property
	public var selectedSymbol(get, never):Dynamic;

	public function get_selectedSymbol():Dynamic {
		if (this.treeView == null) {
			return null;
		}
		var treeNode = cast(this.treeView.selectedItem, TreeNode<Dynamic>);
		if (treeNode == null) {
			return null;
		}
		return treeNode.data;
	}

	override private function initialize():Void {
		this.layout = new AnchorLayout();

		this.treeView = new TreeView();
		this.treeView.variant = TreeView.VARIANT_BORDERLESS;
		this.treeView.layoutData = AnchorLayoutData.fill();
		this.treeView.itemToText = (item:TreeNode<Dynamic>) -> {
			var symbol = item.data;
			if (Std.is(symbol, SymbolInformation)) {
				return cast(symbol, SymbolInformation).name;
			} else if (Std.is(symbol, DocumentSymbol)) {
				return cast(symbol, DocumentSymbol).name;
			}
			return "";
		};
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
		}

		super.update();

		if (dataInvalid) {
			// TODO: move this back above super.update() after beta.3
			if (this._outline != null && this._outline.getLength() > 0) {
				var rootBranch = this._outline.get([0]);
				if (this._outline.isBranch(rootBranch)) {
					this.treeView.toggleBranch(rootBranch, true);
				}
			}
		}
	}

	private function header_closeHandler(event:Event):Void {
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function treeView_changeHandler(event:Event):Void {
		this.dispatchEvent(new Event(Event.CHANGE));
	}
}
