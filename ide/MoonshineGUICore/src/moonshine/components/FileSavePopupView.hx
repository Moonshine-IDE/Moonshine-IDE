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

import openfl.display.DisplayObject;
import actionScripts.factory.FileLocation;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.HorizontalLayout;
import feathers.controls.Label;
import feathers.controls.TextInput;
import feathers.data.TreeNode;
import actionScripts.valueObjects.FileWrapper;
import feathers.controls.Button;
import feathers.controls.LayoutGroup;
import feathers.controls.TreeView;
import feathers.core.InvalidationFlag;
import feathers.data.TreeCollection;
import feathers.events.TriggerEvent;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import moonshine.theme.MoonshineTheme;
import moonshine.ui.ResizableTitleWindow;
import openfl.events.Event;

class FileSavePopupView extends ResizableTitleWindow {
	public function new() {
		MoonshineTheme.initializeTheme();

		super();
		this.title = "Save As";
		this.width = 600.0;
		this.minWidth = 300.0;
		this.minHeight = 300.0;
		this.closeEnabled = true;
		this.resizeEnabled = true;
	}

	private var foldersTreeView:TreeView;
	private var saveButton:Button;
	private var nameGroup:LayoutGroup;
	private var nameInput:TextInput;
	private var extensionLabel:Label;

	private var _fileName:String;

	@:flash.property
	public var fileName(get, set):String;

	private function get_fileName():String {
		return this._fileName;
	}

	private function set_fileName(value:String):String {
		if (this._fileName == value) {
			return this._fileName;
		}
		this._fileName = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._fileName;
	}

	private var _fileExtension:String;

	@:flash.property
	public var fileExtension(get, set):String;

	private function get_fileExtension():String {
		return this._fileExtension;
	}

	private function set_fileExtension(value:String):String {
		if (this._fileExtension == value) {
			return this._fileExtension;
		}
		this._fileExtension = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._fileExtension;
	}

	private var _projectFolders:TreeCollection<FileWrapper> = new TreeCollection();

	@:flash.property
	public var projectFolders(get, set):TreeCollection<FileWrapper>;

	private function get_projectFolders():TreeCollection<FileWrapper> {
		return this._projectFolders;
	}

	private function set_projectFolders(value:TreeCollection<FileWrapper>):TreeCollection<FileWrapper> {
		if (this._projectFolders == value) {
			return this._projectFolders;
		}
		this._projectFolders = value;
		this._selectedFolder = null;
		this.setInvalid(InvalidationFlag.DATA);
		return this._projectFolders;
	}

	private var _selectedFolder:FileWrapper;

	@:flash.property
	public var selectedFolder(get, never):FileWrapper;

	public function get_selectedFolder():FileWrapper {
		return this._selectedFolder;
	}

	@:style
	public var loaderSkin:DisplayObject = null;

	override private function initialize():Void {
		var viewLayout = new VerticalLayout();
		viewLayout.horizontalAlign = JUSTIFY;
		viewLayout.paddingTop = 10.0;
		viewLayout.paddingRight = 10.0;
		viewLayout.paddingBottom = 10.0;
		viewLayout.paddingLeft = 10.0;
		viewLayout.gap = 10.0;
		this.layout = viewLayout;

		this.foldersTreeView = new TreeView();
		this.foldersTreeView.itemToText = (item:TreeNode<FileWrapper>) -> {
			return item.data.file.name;
		};
		this.foldersTreeView.layoutData = new VerticalLayoutData(null, 100.0);
		this.foldersTreeView.addEventListener(Event.CHANGE, projectsListView_changeHandler);
		this.addChild(this.foldersTreeView);

		var nameGroupLayout = new HorizontalLayout();
		nameGroupLayout.gap = 10.0;
		nameGroupLayout.verticalAlign = MIDDLE;
		nameGroup = new LayoutGroup();
		nameGroup.layout = nameGroupLayout;
		this.addChild(nameGroup);

		this.nameInput = new TextInput();
		this.nameInput.prompt = "File Name";
		this.nameInput.restrict = "0-9a-zA-z_";
		// TODO: uncomment when maxChars is supported
		// this.nameInput.maxChars = 129;
		this.nameInput.layoutData = new HorizontalLayoutData(100.0);
		this.nameInput.addEventListener(Event.CHANGE, nameInput_changeHandler);
		nameGroup.addChild(this.nameInput);
		this.extensionLabel = new Label();
		nameGroup.addChild(this.extensionLabel);

		var footer = new LayoutGroup();
		footer.variant = MoonshineTheme.THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR;
		this.saveButton = new Button();
		this.saveButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.saveButton.enabled = false;
		this.saveButton.text = "Save";
		this.saveButton.addEventListener(TriggerEvent.TRIGGER, saveButton_triggerHandler);
		footer.addChild(this.saveButton);
		this.footer = footer;

		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = this.isInvalid(InvalidationFlag.DATA);

		if (dataInvalid) {
			this.foldersTreeView.dataProvider = this._projectFolders;
			if (this._projectFolders != null && this._projectFolders.getLength() > 0) {
				this.foldersTreeView.selectedLocation = [0];
			}
			this.nameInput.text = this._fileName;
			this.extensionLabel.text = "." + this._fileExtension;
		}

		super.update();
	}

	private function projectsListView_changeHandler(event:Event):Void {
		this.saveButton.enabled = this.foldersTreeView.selectedItem != null;
	}

	private function nameInput_changeHandler(event:Event):Void {
		this._fileName = this.nameInput.text;
	}

	private function saveButton_triggerHandler(event:TriggerEvent):Void {
		if (this.foldersTreeView.selectedItem == null) {
			// this shouldn't happen, but to be safe...
			// TODO: show an alert message to select an item
			return;
		}
		var selectedItem = cast(this.foldersTreeView.selectedItem, TreeNode<Dynamic>);
		this._selectedFolder = selectedItem != null ? cast(selectedItem.data, FileWrapper) : null;
		this.foldersTreeView.enabled = false;
		this.nameInput.enabled = false;
		this.saveButton.enabled = false;
		if (this.loaderSkin != null) {
			var container = new LayoutGroup();
			container.includeInLayout = false;
			this.loaderSkin.width = 10.0;
			this.loaderSkin.height = 10.0;
			container.addChild(this.loaderSkin);
			nameGroup.addChild(container);
			container.x = this.nameInput.x + this.nameInput.width - this.loaderSkin.width - 6.0;
			container.y = this.nameInput.y + (this.nameInput.height - this.loaderSkin.height) / 2.0;
		}
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
