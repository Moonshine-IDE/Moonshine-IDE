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

package moonshine.components;

import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import actionScripts.valueObjects.ProjectVO;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.core.InvalidationFlag;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import feathers.utils.DisplayObjectRecycler;
import moonshine.theme.MoonshineTheme;
import moonshine.ui.ResizableTitleWindow;
import openfl.events.Event;
import openfl.events.MouseEvent;

class SelectOpenedProjectView extends ResizableTitleWindow {
	public function new() {
		MoonshineTheme.initializeTheme();

		super();
		this.title = "Select Project";
		this.width = 600.0;
		this.minWidth = 300.0;
		this.minHeight = 300.0;
		this.closeEnabled = true;
		this.resizeEnabled = true;
	}

	private var projectsListView:ListView;
	private var selectProjectButton:Button;

	private var _projects:ArrayCollection<ProjectVO> = new ArrayCollection();

	@:flash.property
	public var projects(get, set):ArrayCollection<ProjectVO>;

	private function get_projects():ArrayCollection<ProjectVO> {
		return this._projects;
	}

	private function set_projects(value:ArrayCollection<ProjectVO>):ArrayCollection<ProjectVO> {
		if (this._projects == value) {
			return this._projects;
		}
		this._projects = value;
		this._selectedProject = null;
		this.setInvalid(InvalidationFlag.DATA);
		return this._projects;
	}

	private var _selectedProject:ProjectVO;

	@:flash.property
	public var selectedProject(get, never):ProjectVO;

	public function get_selectedProject():ProjectVO {
		return this._selectedProject;
	}

	override private function initialize():Void {
		var viewLayout = new VerticalLayout();
		viewLayout.horizontalAlign = JUSTIFY;
		viewLayout.paddingTop = 10.0;
		viewLayout.paddingRight = 10.0;
		viewLayout.paddingBottom = 10.0;
		viewLayout.paddingLeft = 10.0;
		viewLayout.gap = 10.0;
		this.layout = viewLayout;

		this.projectsListView = new ListView();
		this.projectsListView.itemToText = (item:ProjectVO) -> {
			return item.projectName;
		};
		this.projectsListView.itemRendererRecycler = DisplayObjectRecycler.withFunction(() -> {
			var itemRenderer = new ItemRenderer();
			itemRenderer.doubleClickEnabled = true;
			// required for double-click too
			itemRenderer.mouseChildren = false;
			itemRenderer.addEventListener(MouseEvent.DOUBLE_CLICK, itemRenderer_doubleClickHandler);
			return itemRenderer;
		});
		this.projectsListView.layoutData = new VerticalLayoutData(null, 100.0);
		this.projectsListView.addEventListener(KeyboardEvent.KEY_DOWN, projectsListView_keyDownHandler);
		this.projectsListView.addEventListener(Event.CHANGE, projectsListView_changeHandler);
		this.addChild(this.projectsListView);

		var footer = new LayoutGroup();
		footer.variant = MoonshineTheme.THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR;
		this.selectProjectButton = new Button();
		this.selectProjectButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.selectProjectButton.enabled = false;
		this.selectProjectButton.text = "Select & Continue";
		this.selectProjectButton.addEventListener(TriggerEvent.TRIGGER, selectProjectButton_triggerHandler);
		footer.addChild(this.selectProjectButton);
		this.footer = footer;

		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			this.projectsListView.dataProvider = this._projects;
		}

		super.update();
	}

	private function projectsListView_keyDownHandler(event:KeyboardEvent):Void {
		if (event.keyCode != Keyboard.ENTER) {
			return;
		}
		if (!this.selectProjectButton.enabled) {
			return;
		}
		this._selectedProject = cast(this.projectsListView.selectedItem, ProjectVO);
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function projectsListView_changeHandler(event:Event):Void {
		this.selectProjectButton.enabled = this.projectsListView.selectedItem != null;
	}

	private function selectProjectButton_triggerHandler(event:TriggerEvent):Void {
		if (this.projectsListView.selectedItem == null) {
			// this shouldn't happen, but to be safe...
			// TODO: show an alert message to select an item
			return;
		}
		this._selectedProject = cast(this.projectsListView.selectedItem, ProjectVO);
		this.dispatchEvent(new Event(Event.CLOSE));
	}

	private function itemRenderer_doubleClickHandler(event:MouseEvent):Void {
		this._selectedProject = cast(this.projectsListView.selectedItem, ProjectVO);
		this.dispatchEvent(new Event(Event.CLOSE));
	}
}
