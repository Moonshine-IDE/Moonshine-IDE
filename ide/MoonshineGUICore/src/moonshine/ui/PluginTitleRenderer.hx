////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
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


package moonshine.ui;

import moonshine.theme.SDKInstallerTheme;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalLayoutData;
import feathers.layout.VerticalLayout;
import actionScripts.plugin.settings.vo.PluginSetting;
import feathers.controls.TextArea;
import feathers.controls.Label;
import actionScripts.factory.FileLocation;
import actionScripts.interfaces.IViewWithTitle;
import moonshine.lsp.Location;
import feathers.controls.LayoutGroup;
import feathers.core.InvalidationFlag;
import feathers.data.ArrayCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import moonshine.theme.MoonshineTheme;
import openfl.events.Event;

class PluginTitleRenderer extends LayoutGroup {
	public function new() {
		MoonshineTheme.initializeTheme();
		super();
	}

	private var largeTitle:Label;
	private var authorTitle:Label;
	private var description:Label;

	private var _setting:PluginSetting;

	@:flash.property
	public var setting(get, set):PluginSetting;

	private function get_setting():PluginSetting {
		return this._setting;
	}

	private function set_setting(value:PluginSetting):PluginSetting {
		if (this._setting == value) {
			return this._setting;
		}
		this._setting = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._setting;
	}

	override private function initialize():Void {
		var viewLayout = new VerticalLayout();
		viewLayout.horizontalAlign = JUSTIFY;
		viewLayout.paddingTop = 20.0;
		viewLayout.paddingRight = 2.0;
		viewLayout.paddingLeft = 2.0;
		viewLayout.paddingBottom = 10.0;
		viewLayout.gap = 0;
		this.layout = viewLayout;

		this.largeTitle = new Label();
		this.largeTitle.text = this.setting.name;
		this.largeTitle.variant = MoonshineTheme.THEME_VARIANT_PLUGIN_LARGE_TITLE;
		this.addChild(this.largeTitle);

		this.authorTitle = new Label();
		this.authorTitle.text = this.setting.author;
		this.authorTitle.variant = SDKInstallerTheme.THEME_VARIANT_ITALIC_LABEL;
		this.addChild(this.authorTitle);

		var descriptionContainer = new LayoutGroup();
		descriptionContainer.layout = new AnchorLayout();
		descriptionContainer.layoutData = new VerticalLayoutData(100, null);
		this.addChild(descriptionContainer);

		this.description = new Label();
		this.description.layoutData = new AnchorLayoutData(20, 0, null, 0);
		this.description.text = this.setting.description;
		this.description.wordWrap = true;
		descriptionContainer.addChild(this.description);

		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			// this.resultsListView.dataProvider = this._references;
		}

		super.update();
	}
}
