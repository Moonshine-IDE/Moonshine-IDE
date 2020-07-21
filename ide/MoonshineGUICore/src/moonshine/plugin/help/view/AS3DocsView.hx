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

import feathers.controls.Panel;
import feathers.controls.TreeView;
import feathers.controls.dataRenderers.TreeViewItemRenderer;
import feathers.data.TreeCollection;
import feathers.data.TreeNode;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.utils.DisplayObjectRecycler;
import moonshine.ui.SideBarViewHeader;
import openfl.Lib;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLRequest;

class AS3DocsView extends Panel {
	public function new() {
		super();
	}

	private var treeView:TreeView;
	private var urlLoader:URLLoader;

	override private function initialize():Void {
		this.layout = new AnchorLayout();

		this.treeView = new TreeView();
		this.treeView.selectable = false;
		this.treeView.layoutData = AnchorLayoutData.fill();
		this.treeView.itemToText = (item:TreeNode<Xml>) -> item.data.get("label");
		// TODO: uncomment when TreeViewEvent exists in alpha.3
		// this.treeView.addEventListener(TreeViewEvent.ITEM_TRIGGER, treeView_itemTriggerHandler);
		this.treeView.itemRendererRecycler = DisplayObjectRecycler.withFunction(() -> {
			var itemRenderer = new TreeViewItemRenderer();
			itemRenderer.addEventListener(TriggerEvent.TRIGGER, treeView_itemTriggerHandler);
			return itemRenderer;
		});
		this.treeView.itemRendererRecycler.destroy = (itemRenderer) -> {
			itemRenderer.removeEventListener(TriggerEvent.TRIGGER, treeView_itemTriggerHandler);
		};
		this.addChild(this.treeView);

		var header = new SideBarViewHeader();
		header.title = "Useful Links";
		header.closeEnabled = true;
		header.addEventListener(Event.CLOSE, header_closeHandler);
		this.header = header;

		super.initialize();

		this.urlLoader = new URLLoader();
		this.urlLoader.addEventListener(Event.COMPLETE, urlLoader_completeHandler);
		this.urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoader_ioErrorHandler);
		this.urlLoader.load(new URLRequest("/elements/data/UsefulLinks.xml"));
	}

	private function cleanupURLLoader():Void {
		if (this.urlLoader == null) {
			return;
		}

		this.urlLoader.close();
		this.urlLoader.removeEventListener(Event.COMPLETE, urlLoader_completeHandler);
		this.urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, urlLoader_ioErrorHandler);
		this.urlLoader = null;
	}

	private function header_closeHandler(event:Event):Void {
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function urlLoader_completeHandler(event:Event):Void {
		var urlLoader = cast(event.currentTarget, URLLoader);

		var xmlData:String = urlLoader.data;
		var treeData:Array<TreeNode<Xml>> = [];
		try {
			var xml = Xml.parse(xmlData);
			var xmlNodes = xml.firstElement().elements();
			for (xmlNode in xmlNodes) {
				var children:Array<TreeNode<Xml>> = null;
				var xmlSubNodes = xmlNode.elements();
				if (xmlSubNodes.hasNext()) {
					children = [];
				}
				for (xmlSubNode in xmlSubNodes) {
					children.push(new TreeNode(xmlSubNode));
				}
				treeData.push(new TreeNode(xmlNode, children));
			}
		} catch (e:Dynamic) {
			treeData = [];
			trace('ERROR: ${e}');
		}

		this.treeView.dataProvider = new TreeCollection(treeData);
		this.cleanupURLLoader();
	}

	private function urlLoader_ioErrorHandler(event:IOErrorEvent):Void {
		// TODO: show Alert with error instead of trace()?
		trace('ERROR: ${event.text} ${event.type}');

		this.cleanupURLLoader();
	}

	// TODO: uncomment when TreeViewEvent exists in alpha.3

	/*private function treeView_itemTriggerHandler(event:TreeViewEvent):Void {
		var treeNode = cast(event.state.data, TreeNode<Dynamic>);
		var xml = cast(treeNode.data, Xml);
		var link = xml.get("link");

		if (link == null) {
			return;
		}

		Lib.navigateToURL(new URLRequest(link), "_blank");
	}*/
	private function treeView_itemTriggerHandler(event:TriggerEvent):Void {
		var itemRenderer = cast(event.currentTarget, TreeViewItemRenderer);
		var treeNode = cast(itemRenderer.data, TreeNode<Dynamic>);
		var xml = cast(treeNode.data, Xml);
		var link = xml.get("link");

		if (link == null) {
			return;
		}

		Lib.navigateToURL(new URLRequest(link), "_blank");
	}
}
