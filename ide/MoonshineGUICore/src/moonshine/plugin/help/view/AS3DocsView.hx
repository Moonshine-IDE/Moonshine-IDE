/**

Copyright (C) 2016-present Prominic.NET, Inc.
 
This program is free software: you can redistribute it and/or modify
it under the terms of the Server Side Public License, version 1,
as published by MongoDB, Inc.
 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
Server Side Public License for more details.

You should have received a copy of the Server Side Public License
along with this program. If not, see
http://www.mongodb.com/licensing/server-side-public-license.

As a special exception, the copyright holders give permission to link the
code of portions of this program with the OpenSSL library under certain
conditions as described in each individual source file and distribute
linked combinations including the program with the OpenSSL library. You
must comply with the Server Side Public License in all respects for
all of the code used other than as permitted herein. If you modify file(s)
with this exception, you may extend this exception to your version of the
file(s), but you are not obligated to do so. If you do not wish to do so,
delete this exception statement from your version. If you delete this
exception statement from all source files in the program, then also delete
it in the license file.

*/


package moonshine.plugin.help.view;

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

class AS3DocsView extends Panel implements IViewWithTitle {
	public function new() {
		super();
	}

	private var treeView:TreeView;
	private var urlLoader:URLLoader;

	@:flash.property
	public var title(get, never):String;

	public function get_title():String {
		return "Useful Links";
	}

	override private function initialize():Void {
		this.layout = new AnchorLayout();

		this.treeView = new TreeView();
		this.treeView.variant = TreeView.VARIANT_BORDERLESS;
		this.treeView.selectable = false;
		this.treeView.layoutData = AnchorLayoutData.fill();
		this.treeView.itemToText = (item:TreeNode<Xml>) -> item.data.get("label");
		this.treeView.addEventListener(TreeViewEvent.ITEM_TRIGGER, treeView_itemTriggerHandler);
		this.addChild(this.treeView);

		var header = new SideBarViewHeader();
		header.title = this.title;
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

	private function urlLoader_completeHandler(event:Event):Void {
		var urlLoader = cast(event.currentTarget, URLLoader);

		var xmlData:String = urlLoader.data;
		var treeData:Array<TreeNode<Xml>> = [];
		try {
			var xml = Xml.parse(xmlData);
			var xmlNodes = xml.firstElement().elements();
			addXmlNodes(xmlNodes, treeData);
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

	private function treeView_itemTriggerHandler(event:TreeViewEvent):Void {
		var treeNode = cast(event.state.data, TreeNode<Dynamic>);
		var xml = cast(treeNode.data, Xml);
		var link = xml.get("link");

		if (link == null) {
			return;
		}

		this.dispatchEvent(new HelpViewEvent(HelpViewEvent.OPEN_LINK, link));
	}
}
