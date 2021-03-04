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

import feathers.events.TriggerEvent;
import moonshine.plugin.help.events.GettingStartedViewEvent;
import feathers.controls.Check;
import moonshine.plugin.help.view.HelperView;
import feathers.controls.Label;
import feathers.controls.Button;
import actionScripts.plugin.settings.vo.PluginSetting;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import moonshine.ui.PluginTitleRenderer;
import actionScripts.factory.FileLocation;
import actionScripts.interfaces.IViewWithTitle;
import actionScripts.valueObjects.Location;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.core.InvalidationFlag;
import feathers.data.ArrayCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import moonshine.theme.MoonshineTheme;
import openfl.events.Event;

class GettingStartedView extends LayoutGroup implements IViewWithTitle 
{
	public static final EVENT_OPEN_SELECTED_REFERENCE = "openSelectedReference";
	public static final EVENT_DOWNLOAD_3RDPARTY_SOFTWARE = "eventDownload3rdPartySoftware";

	public function new() 
	{
		MoonshineTheme.initializeTheme();
		super();
	}

	private var resultsListView:ListView;
	private var titleRenderer:PluginTitleRenderer;
	private var downloadThirdPartyButton:Button;
	private var sdkInstallerInstallationMessageLabel:Label;
	private var helperView:HelperView;
	private var doNotShowCheckbox:Check;

	@:flash.property
	public var title(get, never):String;

	public function get_title():String 
	{
		return "Getting Started";
	}
	
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
	
	private var _sdkInstallerInstallingMess:String;

	@:flash.property
	public var sdkInstallerInstallingMess(get, set):String;

	private function get_sdkInstallerInstallingMess():String {
		return this._sdkInstallerInstallingMess;
	}

	private function set_sdkInstallerInstallingMess(value:String):String {
		if (this._sdkInstallerInstallingMess == value) {
			return this._sdkInstallerInstallingMess;
		}
		this._sdkInstallerInstallingMess = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._sdkInstallerInstallingMess;
	}

	private var _references:ArrayCollection<Location> = new ArrayCollection();

	@:flash.property
	public var references(get, set):ArrayCollection<Location>;

	private function get_references():ArrayCollection<Location> 
	{
		return this._references;
	}

	private function set_references(value:ArrayCollection<Location>):ArrayCollection<Location> 
	{
		if (this._references == value) {
			return this._references;
		}
		this._references = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._references;
	}

	@:flash.property
	public var selectedReference(get, never):Location;

	public function get_selectedReference():Location 
	{
		if (this.resultsListView == null) {
			return null;
		}
		return cast(this.resultsListView.selectedItem, Location);
	}

	override private function initialize():Void 
	{
		this.variant = MoonshineTheme.THEME_VARIANT_BODY_WITH_GREY_BACKGROUND;
		
		// root container
		var viewLayout = new VerticalLayout();
		viewLayout.horizontalAlign = CENTER;
		viewLayout.paddingTop = 10.0;
		viewLayout.paddingRight = 10.0;
		viewLayout.paddingBottom = 4.0;
		viewLayout.paddingLeft = 10.0;
		viewLayout.gap = 10.0;
		this.layout = viewLayout;
		
		// title area
		this.titleRenderer = new PluginTitleRenderer();
		this.titleRenderer.setting = this.setting;
		this.titleRenderer.layoutData = new VerticalLayoutData(100, null);
		this.titleRenderer.layout = new AnchorLayout();
		this.addChild(this.titleRenderer);
		
		// 3rd-party button
		this.downloadThirdPartyButton = new Button();
		this.downloadThirdPartyButton.text = "Download Third-Party Software";
		this.downloadThirdPartyButton.addEventListener(TriggerEvent.TRIGGER, onDownload3rdPatySoftware);
		this.addChild(this.downloadThirdPartyButton);
		
		// 3rd-party software-installation message
		this.sdkInstallerInstallationMessageLabel = new Label();
		this.sdkInstallerInstallationMessageLabel.text = this.sdkInstallerInstallingMess;
		this.addChild(this.sdkInstallerInstallationMessageLabel);
		
		// helper view
		this.helperView = new HelperView();
		this.helperView.layoutData = new VerticalLayoutData(100, 96);
		this.addChild(this.helperView);
		
		// do not show
		this.doNotShowCheckbox = new Check();
		this.doNotShowCheckbox.text = "Do not show this tab on startup";
		this.doNotShowCheckbox.addEventListener(Event.CHANGE, onDoNotShowCheckChangeHandler);
		this.addChild(this.doNotShowCheckbox);

		super.initialize();
	}

	override private function update():Void 
	{
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			//this.resultsListView.dataProvider = this._references;
			this.titleRenderer.setting = this.setting;
			this.sdkInstallerInstallationMessageLabel.text = this.sdkInstallerInstallingMess;
		}

		super.update();
	}

	private function resultsListView_changeHandler(event:Event):Void 
	{
		/*if (this.resultsListView.selectedItem == null) {
			return;
		}*/
		this.dispatchEvent(new Event(EVENT_OPEN_SELECTED_REFERENCE));
	}
	
	private function onDoNotShowCheckChangeHandler(event:Event):Void 
	{
    	this.dispatchEvent(
    		new GettingStartedViewEvent(
    			GettingStartedViewEvent.EVENT_DO_NOT_SHOW,
    			this.doNotShowCheckbox.selected
    		)
    	);
	}
	
	private function onDownload3rdPatySoftware(event:TriggerEvent):Void
	{
		this.dispatchEvent(new Event(EVENT_DOWNLOAD_3RDPARTY_SOFTWARE));
	}
}
