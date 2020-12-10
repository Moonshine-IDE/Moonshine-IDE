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

package moonshine.plugin.help.view;

import feathers.data.TreeViewItemState;
import feathers.utils.DisplayObjectRecycler;
import feathers.core.InvalidationFlag;
import moonshine.plugin.help.events.HelpViewEvent;
import actionScripts.interfaces.IViewWithTitle;
import feathers.controls.Panel;
import feathers.controls.TreeView;
import feathers.data.TreeCollection;
import feathers.data.TreeNode;
import feathers.events.TreeViewEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import moonshine.ui.SideBarViewHeader;
import openfl.Lib;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;

class TourDeFlexContentsView extends Panel implements IViewWithTitle {
	public function new() {
		super();
	}

	private var treeView:TreeView;
	private var urlLoader:URLLoader;

	@:flash.property
	public var title(get, never):String;

	public function get_title():String {
		return "Tour De Flex";
	}

	private var _activeFilePath:String;

	@:flash.property
	public var activeFilePath(get, set):String;

	private function get_activeFilePath():String {
		return this._activeFilePath;
	}

	private function set_activeFilePath(value:String):String {
		if (this._activeFilePath == value) {
			return this._activeFilePath;
		}
		this._activeFilePath = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._activeFilePath;
	}

	override private function initialize():Void {
		this.layout = new AnchorLayout();

		var itemRendererRecycler = DisplayObjectRecycler.withClass(TourDeFlexTreeViewItemRenderer, (itemRenderer, state:TreeViewItemState) -> {
			var treeNode = cast(state.data, TreeNode<Dynamic>);
			var xml = cast(treeNode.data, Xml);
			itemRenderer.text = state.text;
			var app = xml.get("app");
			if (this._activeFilePath == null || app == null) {
				itemRenderer.showActiveFileIndicator = false;
			} else {
				var activeFilePath = ~/\\/g.replace(this._activeFilePath, "/");
				itemRenderer.showActiveFileIndicator = activeFilePath.indexOf(app) != -1;
			}
		});

		this.treeView = new TreeView();
		this.treeView.variant = TreeView.VARIANT_BORDERLESS;
		this.treeView.dataProvider = new TreeCollection();
		this.treeView.selectable = false;
		this.treeView.layoutData = AnchorLayoutData.fill();
		this.treeView.itemToText = (item:TreeNode<Xml>) -> item.data.get("label");
		this.treeView.itemRendererRecycler = itemRendererRecycler;
		this.treeView.addEventListener(TreeViewEvent.ITEM_TRIGGER, treeView_itemTriggerHandler);
		this.addChild(this.treeView);

		var header = new SideBarViewHeader();
		header.title = this.title;
		header.closeEnabled = true;
		header.addEventListener(Event.CLOSE, header_closeHandler);
		this.header = header;

		super.initialize();

		this.urlLoader = new URLLoader();
		this.urlLoader.addEventListener(Event.COMPLETE, urlLoader1_completeHandler);
		this.urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoader_ioErrorHandler);
		this.urlLoader.load(new URLRequest("/tourDeFlex/explorer.xml"));
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			this.treeView.dataProvider.updateAll();
		}

		super.update();
	}

	private function cleanupURLLoader():Void {
		if (this.urlLoader == null) {
			return;
		}

		this.urlLoader.close();
		this.urlLoader.removeEventListener(Event.COMPLETE, urlLoader1_completeHandler);
		this.urlLoader.removeEventListener(Event.COMPLETE, urlLoader2_completeHandler);
		this.urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, urlLoader_ioErrorHandler);
		this.urlLoader = null;
	}

	private function addXmlNodes(xmlNodes:Iterator<Xml>, treeData:Array<TreeNode<Xml>>):Void {
		for (xmlNode in xmlNodes) {
			var children:Array<TreeNode<Xml>> = null;
			var xmlSubNodes = xmlNode.elements();
			if (xmlSubNodes.hasNext()) {
				children = [];
				this.addXmlNodes(xmlSubNodes, children);
			}
			treeData.push(new TreeNode(xmlNode, children));
		}
	}

	private function header_closeHandler(event:Event):Void {
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function urlLoader1_completeHandler(event:Event):Void {
		var urlLoader = cast(event.currentTarget, URLLoader);

		var xmlData:String = urlLoader.data;
		var treeData:Array<TreeNode<Xml>> = [];
		try {
			var xml = Xml.parse(xmlData);
			var xmlNodes = xml.firstElement().firstElement().elements();
			this.addXmlNodes(xmlNodes, treeData);
		} catch (e:Dynamic) {
			treeData = [];
			trace('ERROR: ${e}');
		}

		this.treeView.dataProvider = new TreeCollection(treeData);
		this.cleanupURLLoader();

		this.urlLoader = new URLLoader();
		this.urlLoader.addEventListener(Event.COMPLETE, urlLoader2_completeHandler);
		this.urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoader_ioErrorHandler);
		this.urlLoader.load(new URLRequest("/tourDeFlex/3rdParty.xml"));
	}

	private function urlLoader2_completeHandler(event:Event):Void {
		var urlLoader = cast(event.currentTarget, URLLoader);

		var xmlData:String = urlLoader.data;
		var treeData:Array<TreeNode<Xml>> = [];
		try {
			var xml = Xml.parse(xmlData);
			var xmlNodes = xml.firstElement().elements();
			this.addXmlNodes(xmlNodes, treeData);
		} catch (e:Dynamic) {
			treeData = [];
			trace('ERROR: ${e}');
		}

		for (node in treeData) {
			this.treeView.dataProvider.addAt(node, [this.treeView.dataProvider.getLength()]);
		}
		this.cleanupURLLoader();
	}

	private function urlLoader_ioErrorHandler(event:IOErrorEvent):Void {
		// TODO: show Alert with error instead of trace()?
		trace('ERROR: ${event.text} ${event.type}');

		this.cleanupURLLoader();
	}

	private function treeView_itemTriggerHandler(event:TreeViewEvent):Void {
		var treeNode = cast(event.state.data, TreeNode<Dynamic>);
		var xml = cast(treeNode.data, Xml);
		var app = xml.get("app");
		var thirdParty = xml.get("thirdParty") == "true";
		if (thirdParty) {
			var definedName = xml.get("label").split(" ").join("");
			app = definedName + "_ThirdParty.txt";
		}
		if (app == null) {
			return;
		}
		var link = xml.get("link");

		if (thirdParty) {
			this.dispatchEvent(new HelpViewEvent(HelpViewEvent.OPEN_FILE, link, app));
		} else {
			var swfLink = "";
			if (app.indexOf(".swf") != -1) {
				swfLink = app;
			} else if (app.indexOf(".jpg") != -1 || app.indexOf(".png") != -1) {
				swfLink = app;
			} else {
				swfLink = app + ".swf";
			}
			this.dispatchEvent(new HelpViewEvent(HelpViewEvent.OPEN_FILE, "http://flex.apache.org/tourdeflex/" + swfLink, app));
		}
	}

	private function loadApp(application:String, thirdParty:Bool, link:String = ""):Void {}
}
