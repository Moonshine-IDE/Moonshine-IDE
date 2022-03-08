/*
	Copyright 2022 Prominic.NET, Inc.

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

package moonshine.plugin.search.view;

import feathers.utils.DisplayObjectRecycler;
import actionScripts.factory.FileLocation;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalDistributedLayout;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import moonshine.editor.text.TextEditor;
import moonshine.editor.text.TextEditorPosition;
import moonshine.theme.MoonshineTheme;
import moonshine.ui.ResizableTitleWindow;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.geom.Rectangle;

class ProjectSearchReplacePreviewView extends ResizableTitleWindow {
	public static final EVENT_REPLACE_SELECTED = "replaceSelected";

	public function new() {
		super();
		this.title = "Replace Text Matches";
		this.width = 500.0;
		this.minWidth = 350.0;
		this.minHeight = 350.0;
		this.closeEnabled = true;
		this.resizeEnabled = true;
	}

	private var descriptionLabel:Label;
	private var filesListView:ListView;
	private var leftEditor:TextEditor;
	private var rightEditor:TextEditor;
	private var replaceAllButton:Button;
	private var leftBackground:LayoutGroup;
	private var rightBackground:LayoutGroup;

	private var _originalValue:String;

	public var originalValue(get, set):String;

	private function get_originalValue():String {
		return _originalValue;
	}

	private function set_originalValue(value:String):String {
		if (_originalValue == value) {
			return _originalValue;
		}
		_originalValue = value;
		setInvalid(DATA);
		return _originalValue;
	}

	private var _replacementValue:String;

	public var replacementValue(get, set):String;

	private function get_replacementValue():String {
		return _replacementValue;
	}

	private function set_replacementValue(value:String):String {
		if (_replacementValue == value) {
			return _replacementValue;
		}
		_replacementValue = value;
		setInvalid(DATA);
		return _replacementValue;
	}

	private var _search:EReg;

	public var search(get, set):EReg;

	private function get_search():EReg {
		return _search;
	}

	private function set_search(value:EReg):EReg {
		if (_search == value) {
			return _search;
		}
		_search = value;
		setInvalid(DATA);
		return _search;
	}

	private var _files:ArrayCollection<Dynamic>;

	public var files(get, set):ArrayCollection<Dynamic>;

	private function get_files():ArrayCollection<Dynamic> {
		return _files;
	}

	private function set_files(value:ArrayCollection<Dynamic>):ArrayCollection<Dynamic> {
		if (_files == value) {
			return _files;
		}
		_files = value;
		setInvalid(DATA);
		return _files;
	}

	private var _fileText:String = "";

	override private function initialize():Void {
		var viewLayout = new VerticalLayout();
		viewLayout.gap = 10.0;
		viewLayout.setPadding(12.0);
		layout = viewLayout;

		if (descriptionLabel == null) {
			descriptionLabel = new Label();
			descriptionLabel.wordWrap = true;
			addChild(descriptionLabel);
		}
		if (filesListView == null) {
			filesListView = new ListView();
			filesListView.itemToText = item -> item.label;
			filesListView.itemRendererRecycler = DisplayObjectRecycler.withClass(ProjectSearchReplacePreviewItemRenderer);
			filesListView.layoutData = new VerticalLayoutData(100.0, 20.0);
			filesListView.addEventListener(Event.CHANGE, filesListView_changeHandler);
			addChild(filesListView);
		}

		var compareLabelLayout = new HorizontalDistributedLayout();
		compareLabelLayout.gap = 10.0;
		var compareLabelContainer = new LayoutGroup();
		compareLabelContainer.layout = compareLabelLayout;
		compareLabelContainer.layoutData = VerticalLayoutData.fillHorizontal();
		addChild(compareLabelContainer);
		compareLabelContainer.addChild(new Label("Original source:"));
		compareLabelContainer.addChild(new Label("Modified source:"));

		var compareEditorLayout = new HorizontalDistributedLayout();
		compareEditorLayout.gap = 10.0;
		compareEditorLayout.verticalAlign = JUSTIFY;

		var compareContainer = new LayoutGroup();
		compareContainer.layout = compareEditorLayout;
		compareContainer.layoutData = new VerticalLayoutData(100.0, 80.0);
		addChild(compareContainer);

		leftEditor = new TextEditor("", true);
		leftEditor.addEventListener(Event.SCROLL, leftEditor_scrollHandler);
		compareContainer.addChild(leftEditor);

		rightEditor = new TextEditor("", true);
		rightEditor.addEventListener(Event.SCROLL, rightEditor_scrollHandler);
		compareContainer.addChild(rightEditor);

		leftBackground = new LayoutGroup();
		leftBackground.blendMode = MULTIPLY;
		leftBackground.includeInLayout = false;
		leftBackground.mouseEnabled = false;
		leftBackground.mouseChildren = false;
		compareContainer.addChild(leftBackground);

		rightBackground = new LayoutGroup();
		rightBackground.blendMode = MULTIPLY;
		rightBackground.includeInLayout = false;
		rightBackground.mouseEnabled = false;
		rightBackground.mouseChildren = false;
		compareContainer.addChild(rightBackground);

		var footer = new LayoutGroup();
		footer.variant = MoonshineTheme.THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR;

		replaceAllButton = new Button();
		replaceAllButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		replaceAllButton.text = "Replace All Selected";
		replaceAllButton.addEventListener(TriggerEvent.TRIGGER, replaceAllButton_triggerHandler);
		footer.addChild(replaceAllButton);

		this.footer = footer;

		super.initialize();
	}

	override private function update():Void {
		var dataInvalid = isInvalid(DATA);
		var selectionInvalid = isInvalid(SELECTION);
		var sizeInvalid = isInvalid(SIZE);

		if (dataInvalid) {
			var filesCount = (files != null) ? files.length : 0;
			descriptionLabel.text = (filesCount > 0) ? 'Changes can be performed in ${filesCount} files:' : 'Loading...';
			filesListView.dataProvider = files;
			if (filesCount > 0) {
				filesListView.selectedIndex = 0;
			}
		}

		if (dataInvalid || selectionInvalid) {
			if (filesListView.selectedIndex != -1) {
				var file = filesListView.selectedItem;
				var fileContents = new FileLocation(file.label).fileBridge.read();
				_fileText = (fileContents is String) ? fileContents : "";
				var replacementFileText = search.replace(_fileText, replacementValue);
				leftEditor.text = _fileText;
				rightEditor.text = replacementFileText;
			} else {
				leftEditor.text = "";
				rightEditor.text = "";
			}
		}

		super.update();

		if (sizeInvalid || dataInvalid || selectionInvalid) {
			findAndDrawHighlights();
		}
	}

	private function findAndDrawHighlights():Void {
		leftEditor.validateNow();
		rightEditor.validateNow();
		var positions:Array<TextEditorPosition> = [];
		var lines = _fileText.split(leftEditor.lineDelimiter);
		var numVisibleLines = leftEditor.lineScrollY + leftEditor.visibleLines;
		if (numVisibleLines >= lines.length) {
			numVisibleLines = lines.length;
		}
		// highlight only the lines that are currently visible
		// because that's much better for performance
		for (i in leftEditor.lineScrollY...numVisibleLines) {
			var line = lines[i];
			var startIndex = 0;
			while (startIndex < line.length && search.matchSub(line, startIndex)) {
				var matchedPos = search.matchedPos();
				positions.push(new TextEditorPosition(i, matchedPos.pos));
				startIndex = matchedPos.pos + matchedPos.len;
			}
		}
		drawHighlights(leftBackground, leftEditor, originalValue, positions);
		drawHighlights(rightBackground, rightEditor, replacementValue, positions);
	}

	private function drawHighlights(highlightShape:Sprite, editor:TextEditor, word:String, positions:Array<TextEditorPosition>):Void {
		highlightShape.x = editor.x + editor.gutterWidth;
		highlightShape.y = editor.y;
		highlightShape.width = editor.width - editor.gutterWidth;
		highlightShape.height = editor.height;
		highlightShape.scrollRect = new Rectangle(0.0, 0.0, highlightShape.width, highlightShape.height);
		highlightShape.graphics.clear();
		var prevLine = -1;
		var offset = 0;
		for (position in positions) {
			if (prevLine != position.line) {
				offset = 0;
			}
			var char = position.character;
			position.character += offset;
			var startBounds = editor.getTextEditorPositionBoundaries(position);
			position.character += (word.length - 1);
			var endBounds = editor.getTextEditorPositionBoundaries(position);
			position.character = char;

			if (startBounds == null || endBounds == null) {
				trace("highlight position not found: " + position.line, position.character);
				continue;
			}

			if (editor == rightEditor) {
				offset += (word.length - _originalValue.length);
			}

			if (prevLine != position.line) {
				highlightShape.graphics.beginFill(0xffff00, 0.5);
				highlightShape.graphics.drawRect(0.0, startBounds.y, highlightShape.width, startBounds.height);
				highlightShape.graphics.endFill();
			}

			highlightShape.graphics.beginFill(0xff00ff, 0.5);
			highlightShape.graphics.drawRect(startBounds.x
				- editor.gutterWidth, startBounds.y, endBounds.x
				+ endBounds.width
				- startBounds.x,
				endBounds.y
				+ endBounds.height
				- startBounds.y);
			highlightShape.graphics.endFill();

			prevLine = position.line;
		}
	}

	private function leftEditor_scrollHandler(event:Event):Void {
		var changed = false;
		if (rightEditor.scrollX != leftEditor.scrollX) {
			rightEditor.scrollX = leftEditor.scrollX;
			changed = true;
		}
		if (rightEditor.scrollY != leftEditor.scrollY) {
			rightEditor.scrollY = leftEditor.scrollY;
			changed = true;
		}
		if (!changed || _validating) {
			return;
		}
		findAndDrawHighlights();
	}

	private function rightEditor_scrollHandler(event:Event):Void {
		var changed = false;
		if (leftEditor.scrollX != rightEditor.scrollX) {
			leftEditor.scrollX = rightEditor.scrollX;
			changed = true;
		}
		if (leftEditor.scrollY != rightEditor.scrollY) {
			leftEditor.scrollY = rightEditor.scrollY;
			changed = true;
		}
		if (!changed || _validating) {
			return;
		}
		findAndDrawHighlights();
	}

	private function filesListView_changeHandler(event:Event):Void {
		setInvalid(SELECTION);
	}

	private function replaceAllButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(EVENT_REPLACE_SELECTED));
		this.dispatchEvent(new Event(Event.CLOSE));
	}
}
