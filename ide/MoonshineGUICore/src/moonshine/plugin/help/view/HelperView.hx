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

import feathers.skins.RectangleSkin;
import feathers.layout.VerticalLayoutData;
import feathers.layout.VerticalLayout;
import actionScripts.plugin.settings.vo.PluginSetting;
import feathers.controls.TextArea;
import feathers.controls.Label;
import actionScripts.factory.FileLocation;
import actionScripts.interfaces.IViewWithTitle;
import actionScripts.valueObjects.Location;
import feathers.controls.LayoutGroup;
import feathers.core.InvalidationFlag;
import feathers.data.ArrayCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import moonshine.theme.MoonshineTheme;
import openfl.events.Event;
import feathers.controls.ListView;

class HelperView extends LayoutGroup
{
	public function new() 
	{
		MoonshineTheme.initializeTheme();
		super();
	}
	
	private var resultsListView:ListView;
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

	override private function initialize():Void 
	{
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0xffff00);
		backgroundSkin.cornerRadius = 0.0;
		this.backgroundSkin = backgroundSkin;

		super.initialize();
	}

	override private function update():Void 
	{
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			//this.resultsListView.dataProvider = this._references;
		}

		super.update();
	}
}
