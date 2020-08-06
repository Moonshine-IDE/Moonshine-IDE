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

package moonshine.theme;

import moonshine.style.MoonshineHScrollBarThumbSkin;
import moonshine.style.MoonshineVScrollBarThumbSkin;
import feathers.controls.Panel;
import feathers.controls.BasicButton;
import feathers.controls.VScrollBar;
import feathers.controls.HScrollBar;
import feathers.controls.Callout;
import openfl.events.Event;
import feathers.controls.ToggleButtonState;
import feathers.controls.Check;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.TextInput;
import feathers.controls.TextInputState;
import feathers.controls.ToggleButton;
import feathers.controls.TreeView;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.controls.dataRenderers.TreeViewItemRenderer;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalListLayout;
import feathers.skins.CircleSkin;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.ClassVariantTheme;
import moonshine.style.MoonshineButtonSkin;
import moonshine.ui.ResizableTitleWindow;
import moonshine.ui.SideBarViewHeader;
import moonshine.ui.TitleWindow;
import openfl.display.Shape;
import openfl.text.TextFormat;

class MoonshineTheme extends ClassVariantTheme {
	private static var _instance:MoonshineTheme;

	public static function initializeTheme():Void {
		if (_instance != null) {
			return;
		}
		_instance = new MoonshineTheme();
		Theme.setTheme(_instance);
	}

	public static final THEME_VARIANT_DARK_BUTTON:String = "moonshine-button--dark";
	public static final THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR = "moonshine-title-window-control-bar";

	public function new() {
		super();

		this.styleProvider.setStyleFunction(Button, null, setLightButtonStyles);
		this.styleProvider.setStyleFunction(Button, THEME_VARIANT_DARK_BUTTON, setDarkButtonStyles);

		this.styleProvider.setStyleFunction(Callout, null, setCalloutStyles);

		this.styleProvider.setStyleFunction(Check, null, setCheckStyles);

		this.styleProvider.setStyleFunction(ItemRenderer, null, setItemRendererStyles);

		this.styleProvider.setStyleFunction(Label, null, setLabelStyles);

		this.styleProvider.setStyleFunction(LayoutGroup, LayoutGroup.VARIANT_TOOL_BAR, setToolBarLayoutGroupStyles);

		this.styleProvider.setStyleFunction(ListView, null, setListViewStyles);
		this.styleProvider.setStyleFunction(ListView, ListView.VARIANT_BORDERLESS, setBorderlessListViewStyles);

		this.styleProvider.setStyleFunction(Panel, null, setPanelStyles);

		this.styleProvider.setStyleFunction(HScrollBar, null, setHScrollBarStyles);
		this.styleProvider.setStyleFunction(VScrollBar, null, setVScrollBarStyles);

		this.styleProvider.setStyleFunction(SideBarViewHeader, null, setSideBarViewHeaderStyles);
		this.styleProvider.setStyleFunction(Label, SideBarViewHeader.CHILD_VARIANT_TITLE, setSideBarViewHeaderTitleStyles);
		this.styleProvider.setStyleFunction(Button, SideBarViewHeader.CHILD_VARIANT_CLOSE_BUTTON, setSideBarViewHeaderCloseButtonStyles);

		this.styleProvider.setStyleFunction(TitleWindow, null, setTitleWindowStyles);
		this.styleProvider.setStyleFunction(Label, TitleWindow.CHILD_VARIANT_TITLE, setTitleWindowTitleStyles);
		this.styleProvider.setStyleFunction(LayoutGroup, THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR, setTitleWindowControlBarStyles);
		this.styleProvider.setStyleFunction(Button, TitleWindow.CHILD_VARIANT_CLOSE_BUTTON, setTitleWindowCloseButtonStyles);

		this.styleProvider.setStyleFunction(TextInput, null, setTextInputStyles);

		this.styleProvider.setStyleFunction(TreeView, null, setTreeViewStyles);
		this.styleProvider.setStyleFunction(TreeView, TreeView.VARIANT_BORDERLESS, setBorderlessTreeViewStyles);
		this.styleProvider.setStyleFunction(TreeViewItemRenderer, null, setTreeViewItemRendererStyles);
		this.styleProvider.setStyleFunction(ToggleButton, TreeViewItemRenderer.CHILD_VARIANT_DISCLOSURE_BUTTON, setTreeViewItemRendererDisclosureButtonStyles);
	}

	private function setLightButtonStyles(button:Button):Void {
		var backgroundSkin = new MoonshineButtonSkin();
		backgroundSkin.outerBorderFill = SolidColor(0x666666);
		backgroundSkin.outerBorderSize = 3.0;
		backgroundSkin.outerBorderRadius = 10.0;
		backgroundSkin.innerBorderFill = SolidColor(0xFFFFFF);
		backgroundSkin.innerBorderSize = 1.0;
		backgroundSkin.innerBorderRadius = 7.0;
		backgroundSkin.fill = Gradient(LINEAR, [0xE1E1E1, 0xE1E1E1, 0xD6D6D6, 0xD6D6D6], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		backgroundSkin.borderRadius = 7.0;
		button.backgroundSkin = backgroundSkin;

		var disabledSkin = new MoonshineButtonSkin();
		disabledSkin.outerBorderFill = SolidColor(0xCCCCCC);
		disabledSkin.outerBorderSize = 3.0;
		disabledSkin.outerBorderRadius = 10.0;
		disabledSkin.innerBorderFill = SolidColor(0xFFFFFF);
		disabledSkin.innerBorderSize = 1.0;
		disabledSkin.innerBorderRadius = 7.0;
		disabledSkin.fill = Gradient(LINEAR, [0xE1E1E1, 0xE1E1E1, 0xD6D6D6, 0xD6D6D6], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		disabledSkin.borderRadius = 7.0;
		disabledSkin.alpha = 0.5;
		button.setSkinForState(DISABLED, disabledSkin);

		var downSkin = new MoonshineButtonSkin();
		downSkin.outerBorderFill = SolidColor(0x666666);
		downSkin.outerBorderSize = 3.0;
		downSkin.outerBorderRadius = 10.0;
		downSkin.innerBorderFill = SolidColor(0xFFFFFF);
		downSkin.innerBorderSize = 1.0;
		downSkin.innerBorderRadius = 7.0;
		downSkin.fill = Gradient(LINEAR, [0xD6D6D6, 0xD6D6D6, 0xDFDFDF, 0xDFDFDF], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		downSkin.borderRadius = 7.0;
		downSkin.alpha = 0.5;
		button.setSkinForState(DOWN, downSkin);

		button.textFormat = new TextFormat("DejaVuSansTF", 12, 0x555555);
		button.setTextFormatForState(DISABLED, new TextFormat("DejaVuSansTF", 12, 0x999999));
		button.embedFonts = true;

		button.paddingTop = 8.0;
		button.paddingRight = 8.0;
		button.paddingBottom = 8.0;
		button.paddingLeft = 8.0;
		button.gap = 4.0;
	}

	private function setDarkButtonStyles(button:Button):Void {
		var backgroundSkin = new MoonshineButtonSkin();
		backgroundSkin.outerBorderFill = SolidColor(0x292929);
		backgroundSkin.outerBorderSize = 3.0;
		backgroundSkin.outerBorderRadius = 10.0;
		backgroundSkin.innerBorderFill = SolidColor(0x4C4C4C);
		backgroundSkin.innerBorderSize = 1.0;
		backgroundSkin.innerBorderRadius = 7.0;
		backgroundSkin.fill = Gradient(LINEAR, [0x444444, 0x444444, 0x404040, 0x404040], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		backgroundSkin.borderRadius = 7.0;
		button.backgroundSkin = backgroundSkin;

		var hoverSkin = new MoonshineButtonSkin();
		hoverSkin.outerBorderFill = SolidColor(0x292929);
		hoverSkin.outerBorderSize = 3.0;
		hoverSkin.outerBorderRadius = 10.0;
		hoverSkin.innerBorderFill = SolidColor(0x4C4C4C);
		hoverSkin.innerBorderSize = 1.0;
		hoverSkin.innerBorderRadius = 7.0;
		hoverSkin.fill = Gradient(LINEAR, [0x3F3F3F, 0x3F3F3F, 0x3B3B3B, 0x3B3B3B], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		hoverSkin.borderRadius = 7.0;
		button.setSkinForState(HOVER, hoverSkin);

		var disabledSkin = new MoonshineButtonSkin();
		disabledSkin.outerBorderFill = SolidColor(0x292929);
		disabledSkin.outerBorderSize = 3.0;
		disabledSkin.outerBorderRadius = 10.0;
		disabledSkin.innerBorderFill = SolidColor(0x4C4C4C);
		disabledSkin.innerBorderSize = 1.0;
		disabledSkin.innerBorderRadius = 7.0;
		disabledSkin.fill = Gradient(LINEAR, [0x444444, 0x444444, 0x404040, 0x404040], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		disabledSkin.borderRadius = 7.0;
		disabledSkin.alpha = 0.5;
		button.setSkinForState(DISABLED, disabledSkin);

		var downSkin = new MoonshineButtonSkin();
		downSkin.outerBorderFill = SolidColor(0x292929);
		downSkin.outerBorderSize = 3.0;
		downSkin.outerBorderRadius = 10.0;
		downSkin.innerBorderFill = SolidColor(0x474747);
		downSkin.innerBorderSize = 1.0;
		downSkin.innerBorderRadius = 7.0;
		downSkin.fill = Gradient(LINEAR, [0x3F3F3F, 0x3F3F3F, 0x3C3C3C, 0x3C3C3C], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		downSkin.borderRadius = 7.0;
		downSkin.alpha = 0.5;
		button.setSkinForState(DOWN, downSkin);

		var focusRectSkin = new RectangleSkin();
		focusRectSkin.fill = null;
		focusRectSkin.border = SolidColor(1.0, 0xC165B8);
		focusRectSkin.cornerRadius = 10.0;
		button.focusRectSkin = focusRectSkin;

		button.textFormat = new TextFormat("DejaVuSansTF", 12, 0xBBBBBB);
		button.setTextFormatForState(DISABLED, new TextFormat("DejaVuSansTF", 12, 0x666666));
		button.embedFonts = true;

		button.paddingTop = 8.0;
		button.paddingRight = 8.0;
		button.paddingBottom = 8.0;
		button.paddingLeft = 8.0;
		button.gap = 4.0;
	}

	private function setCalloutStyles(callout:Callout):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0xA0A0A0);
		backgroundSkin.border = SolidColor(1.0, 0x292929);
		backgroundSkin.cornerRadius = 7.0;
		callout.backgroundSkin = backgroundSkin;
	}

	private function setCheckStyles(check:Check):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0x000000, 0.0);
		backgroundSkin.border = null;
		check.backgroundSkin = backgroundSkin;

		var icon = new MoonshineButtonSkin();
		icon.outerBorderFill = SolidColor(0x666666);
		icon.outerBorderSize = 2.0;
		icon.outerBorderRadius = 4.0;
		icon.innerBorderFill = SolidColor(0xFFFFFF);
		icon.innerBorderSize = 1.0;
		icon.innerBorderRadius = 2.0;
		icon.fill = Gradient(LINEAR, [0xE1E1E1, 0xE1E1E1, 0xD6D6D6, 0xD6D6D6], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		icon.borderRadius = 0.0;
		icon.width = 20.0;
		icon.height = 20.0;
		check.icon = icon;

		var disabledIcon = new MoonshineButtonSkin();
		disabledIcon.outerBorderFill = SolidColor(0xCCCCCC);
		disabledIcon.outerBorderSize = 2.0;
		disabledIcon.outerBorderRadius = 4.0;
		disabledIcon.innerBorderFill = SolidColor(0xFFFFFF);
		disabledIcon.innerBorderSize = 1.0;
		disabledIcon.innerBorderRadius = 2.0;
		disabledIcon.fill = Gradient(LINEAR, [0xE1E1E1, 0xE1E1E1, 0xD6D6D6, 0xD6D6D6], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		disabledIcon.borderRadius = 0.0;
		disabledIcon.alpha = 0.5;
		disabledIcon.width = 20.0;
		disabledIcon.height = 20.0;
		check.disabledIcon = disabledIcon;

		var downSkin = new MoonshineButtonSkin();
		downSkin.outerBorderFill = SolidColor(0x666666);
		downSkin.outerBorderSize = 2.0;
		downSkin.outerBorderRadius = 4.0;
		downSkin.innerBorderFill = SolidColor(0xFFFFFF);
		downSkin.innerBorderSize = 1.0;
		downSkin.innerBorderRadius = 2.0;
		downSkin.fill = Gradient(LINEAR, [0xD6D6D6, 0xD6D6D6, 0xDFDFDF, 0xDFDFDF], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		downSkin.borderRadius = 0.0;
		downSkin.alpha = 0.5;
		downSkin.width = 20.0;
		downSkin.height = 20.0;
		check.setIconForState(DOWN(false), downSkin);

		var selectedIcon = new MoonshineButtonSkin();
		selectedIcon.outerBorderFill = SolidColor(0x666666);
		selectedIcon.outerBorderSize = 2.0;
		selectedIcon.outerBorderRadius = 4.0;
		selectedIcon.innerBorderFill = SolidColor(0xFFFFFF);
		selectedIcon.innerBorderSize = 1.0;
		selectedIcon.innerBorderRadius = 2.0;
		selectedIcon.fill = Gradient(LINEAR, [0xE1E1E1, 0xE1E1E1, 0xD6D6D6, 0xD6D6D6], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		selectedIcon.borderRadius = 0.0;
		selectedIcon.width = 20.0;
		selectedIcon.height = 20.0;
		check.selectedIcon = selectedIcon;
		var checkMark = new Shape();
		checkMark.graphics.beginFill(0x292929);
		checkMark.graphics.drawRect(-0.0, -7.0, 3.0, 13.0);
		checkMark.graphics.drawRect(-5.0, 3.0, 5.0, 3.0);
		checkMark.graphics.endFill();
		checkMark.rotation = 45.0;
		checkMark.x = 10.0;
		checkMark.y = 9.0;
		selectedIcon.addChild(checkMark);

		var selectedDownIcon = new MoonshineButtonSkin();
		selectedDownIcon.outerBorderFill = SolidColor(0x666666);
		selectedDownIcon.outerBorderSize = 2.0;
		selectedDownIcon.outerBorderRadius = 4.0;
		selectedDownIcon.innerBorderFill = SolidColor(0xFFFFFF);
		selectedDownIcon.innerBorderSize = 1.0;
		selectedDownIcon.innerBorderRadius = 2.0;
		selectedDownIcon.fill = Gradient(LINEAR, [0xD6D6D6, 0xD6D6D6, 0xDFDFDF, 0xDFDFDF], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		selectedDownIcon.borderRadius = 0.0;
		selectedDownIcon.alpha = 0.5;
		selectedDownIcon.width = 20.0;
		selectedDownIcon.height = 20.0;
		check.setIconForState(DOWN(true), selectedDownIcon);
		var downCheckMark = new Shape();
		downCheckMark.graphics.beginFill(0x292929);
		downCheckMark.graphics.drawRect(-0.0, -7.0, 3.0, 13.0);
		downCheckMark.graphics.drawRect(-5.0, 3.0, 5.0, 3.0);
		downCheckMark.graphics.endFill();
		downCheckMark.rotation = 45.0;
		downCheckMark.x = 10.0;
		downCheckMark.y = 9.0;
		selectedDownIcon.addChild(downCheckMark);

		var focusRectSkin = new RectangleSkin();
		focusRectSkin.fill = null;
		focusRectSkin.border = SolidColor(1.0, 0xC165B8);
		focusRectSkin.cornerRadius = 10.0;
		check.focusRectSkin = focusRectSkin;

		check.textFormat = new TextFormat("DejaVuSansTF", 12, 0x292929);
		check.disabledTextFormat = new TextFormat("DejaVuSansTF", 12, 0x999999);
		check.embedFonts = true;

		check.horizontalAlign = LEFT;
		check.gap = 4.0;
	}

	private function setItemRendererStyles(itemRenderer:ItemRenderer):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0x444444);
		backgroundSkin.selectedFill = SolidColor(0xC165B8);
		// TODO: uncomment when ToggleButtonState is handled correctly by BasicToggleButton
		// backgroundSkin.setFillForState(ToggleButtonState.HOVER(false), SolidColor(0x393939));
		itemRenderer.backgroundSkin = backgroundSkin;

		// TODO: uncomment when alternateBackgroundSkin is supported in alpha.3
		/*var alternateBackgroundSkin = new RectangleSkin();
			alternateBackgroundSkin.fill = SolidColor(0x4D4C4C);
			alternateBackgroundSkin.selectedFill = SolidColor(0xC165B8);
			alternateBackgroundSkin.setFillForState(ToggleButtonState.HOVER(false), SolidColor(0x393939));
			itemRenderer.alternateBackgroundSkin = alternateBackgroundSkin; */

		itemRenderer.textFormat = new TextFormat("DejaVuSansTF", 12, 0xf3f3f3);
		itemRenderer.disabledTextFormat = new TextFormat("DejaVuSansTF", 12, 0x555555);
		itemRenderer.embedFonts = true;

		itemRenderer.horizontalAlign = LEFT;
		itemRenderer.paddingTop = 4.0;
		itemRenderer.paddingRight = 4.0;
		itemRenderer.paddingBottom = 4.0;
		itemRenderer.paddingLeft = 4.0;
		itemRenderer.gap = 4.0;
	}

	private function setTitleWindowCloseButtonStyles(button:Button):Void {
		var backgroundSkin = new CircleSkin();
		backgroundSkin.border = SolidColor(1.0, 0xffffff);
		backgroundSkin.fill = null;
		backgroundSkin.width = 16.0;
		backgroundSkin.height = 16.0;
		button.backgroundSkin = backgroundSkin;

		var icon = new Shape();
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 8.0, 8.0);
		icon.graphics.lineStyle(3.0, 0xffffff, 1.0, true, NORMAL, SQUARE);
		icon.graphics.moveTo(2.0, 2.0);
		icon.graphics.lineTo(6.0, 6.0);
		icon.graphics.moveTo(2.0, 6.0);
		icon.graphics.lineTo(6.0, 2.0);
		button.icon = icon;

		button.horizontalAlign = CENTER;
		button.verticalAlign = MIDDLE;
	}

	private function setLabelStyles(label:Label):Void {
		label.textFormat = new TextFormat("DejaVuSansTF", 12, 0x292929);
		label.disabledTextFormat = new TextFormat("DejaVuSansTF", 12, 0x999999);
		label.embedFonts = true;
	}

	private function setListViewStyles(listView:ListView):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0x444444);
		backgroundSkin.border = SolidColor(1.0, 0x666666);
		backgroundSkin.setBorderForState(TextInputState.FOCUSED, SolidColor(1.0, 0xC165B8));
		backgroundSkin.cornerRadius = 0.0;
		backgroundSkin.minWidth = 160.0;
		backgroundSkin.minHeight = 160.0;
		listView.backgroundSkin = backgroundSkin;

		var focusRectSkin = new RectangleSkin();
		focusRectSkin.fill = null;
		focusRectSkin.border = SolidColor(1.0, 0xC165B8);
		listView.focusRectSkin = focusRectSkin;

		var layout = new VerticalListLayout();
		layout.requestedRowCount = 5;
		listView.layout = layout;

		listView.paddingTop = 1.0;
		listView.paddingRight = 1.0;
		listView.paddingBottom = 1.0;
		listView.paddingLeft = 1.0;

		listView.fixedScrollBars = true;
	}

	private function setBorderlessListViewStyles(listView:ListView):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0x444444);
		backgroundSkin.border = null;
		backgroundSkin.setBorderForState(TextInputState.FOCUSED, SolidColor(1.0, 0xC165B8));
		backgroundSkin.cornerRadius = 0.0;
		backgroundSkin.minWidth = 160.0;
		backgroundSkin.minHeight = 160.0;
		listView.backgroundSkin = backgroundSkin;

		var focusRectSkin = new RectangleSkin();
		focusRectSkin.fill = null;
		focusRectSkin.border = SolidColor(1.0, 0xC165B8);
		listView.focusRectSkin = focusRectSkin;

		var layout = new VerticalListLayout();
		layout.requestedRowCount = 5;
		listView.layout = layout;

		listView.paddingTop = 0.0;
		listView.paddingRight = 0.0;
		listView.paddingBottom = 0.0;
		listView.paddingLeft = 0.0;

		listView.fixedScrollBars = true;
	}

	private function setPanelStyles(panel:Panel):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0xA0A0A0);
		backgroundSkin.border = null;
		backgroundSkin.cornerRadius = 7.0;
		panel.backgroundSkin = backgroundSkin;
	}

	private function setHScrollBarStyles(scrollBar:HScrollBar):Void {
		var trackSkin = new RectangleSkin();
		trackSkin.fill = Gradient(LINEAR, [0x3A3A3A, 0x414141, 0x414141], [1.0, 1.0, 1.0], [0x00, 0x3F, 0xFF], 90.0 * Math.PI / 180.0);
		trackSkin.width = 16.0;
		trackSkin.height = 16.0;
		trackSkin.minWidth = 16.0;
		trackSkin.minHeight = 16.0;
		scrollBar.trackSkin = trackSkin;

		var thumbSkin = new MoonshineHScrollBarThumbSkin();
		thumbSkin.width = 15.0;
		thumbSkin.height = 15.0;
		thumbSkin.minWidth = 15.0;
		thumbSkin.minHeight = 15.0;
		scrollBar.thumbSkin = thumbSkin;
	}

	private function setVScrollBarStyles(scrollBar:VScrollBar):Void {
		var trackSkin = new RectangleSkin();
		trackSkin.fill = Gradient(LINEAR, [0x3A3A3A, 0x414141, 0x414141], [1.0, 1.0, 1.0], [0x00, 0x3F, 0xFF]);
		trackSkin.width = 15.0;
		trackSkin.height = 15.0;
		trackSkin.minWidth = 15.0;
		trackSkin.minHeight = 15.0;
		scrollBar.trackSkin = trackSkin;

		var thumbSkin = new MoonshineVScrollBarThumbSkin();
		thumbSkin.width = 15.0;
		thumbSkin.height = 15.0;
		thumbSkin.minWidth = 15.0;
		thumbSkin.minHeight = 15.0;
		scrollBar.thumbSkin = thumbSkin;
	}

	private function setSideBarViewHeaderStyles(header:SideBarViewHeader):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = Gradient(LINEAR, [0xF2F2F2, 0xEEEEEE, 0xEEEEEE, 0xD8D8D8], [1.0, 1.0, 1.0, 1.0], [0x00, 0x3F, 0xCF, 0xFF],
			90.0 * Math.PI / 180.0);
		backgroundSkin.border = null;
		header.backgroundSkin = backgroundSkin;

		var layout = new HorizontalLayout();
		layout.horizontalAlign = LEFT;
		layout.verticalAlign = MIDDLE;
		layout.paddingTop = 6.0;
		layout.paddingRight = 6.0;
		layout.paddingBottom = 6.0;
		layout.paddingLeft = 6.0;
		layout.gap = 4.0;
		header.layout = layout;
	}

	private function setSideBarViewHeaderTitleStyles(label:Label):Void {
		label.textFormat = new TextFormat("DejaVuSansTF", 11, 0x292929);
		label.embedFonts = true;
		label.layoutData = new HorizontalLayoutData(100.0);
	}

	private function setSideBarViewHeaderCloseButtonStyles(button:Button):Void {
		var backgroundSkin = new CircleSkin();
		backgroundSkin.border = SolidColor(1.0, 0x444444, 0.8);
		backgroundSkin.fill = null;
		backgroundSkin.width = 14.0;
		backgroundSkin.height = 14.0;
		button.backgroundSkin = backgroundSkin;

		var icon = new Shape();
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 8.0, 8.0);
		icon.graphics.lineStyle(2.0, 0x444444, 0.8, true, NORMAL, SQUARE);
		icon.graphics.moveTo(2.0, 2.0);
		icon.graphics.lineTo(6.0, 6.0);
		icon.graphics.moveTo(2.0, 6.0);
		icon.graphics.lineTo(6.0, 2.0);
		button.icon = icon;

		button.horizontalAlign = CENTER;
		button.verticalAlign = MIDDLE;
	}

	private function setTitleWindowStyles(window:TitleWindow):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0xA0A0A0);
		backgroundSkin.border = SolidColor(1.0, 0x292929);
		backgroundSkin.cornerRadius = 7.0;
		window.backgroundSkin = backgroundSkin;

		if (Std.is(window, ResizableTitleWindow)) {
			var resizableWindow = cast(window, ResizableTitleWindow);

			var resizeHandleSkin = new Shape();
			resizeHandleSkin.graphics.beginFill(0xff00ff, 0.0);
			resizeHandleSkin.graphics.drawRect(0.0, 0.0, 16.0, 16.0);
			resizeHandleSkin.graphics.endFill();

			resizeHandleSkin.graphics.lineStyle(1.0, 0xa6a6a6, 1.0, true, NORMAL, SQUARE);
			resizeHandleSkin.graphics.moveTo(2.0, 14.0);
			resizeHandleSkin.graphics.lineTo(14.0, 2.0);
			resizeHandleSkin.graphics.moveTo(6.0, 14.0);
			resizeHandleSkin.graphics.lineTo(14.0, 6.0);
			resizeHandleSkin.graphics.moveTo(10.0, 14.0);
			resizeHandleSkin.graphics.lineTo(14.0, 10.0);

			resizeHandleSkin.graphics.lineStyle(1.0, 0x292929, 1.0, true, NORMAL, SQUARE);
			resizeHandleSkin.graphics.moveTo(3.0, 14.0);
			resizeHandleSkin.graphics.lineTo(14.0, 3.0);
			resizeHandleSkin.graphics.moveTo(7.0, 14.0);
			resizeHandleSkin.graphics.lineTo(14.0, 7.0);
			resizeHandleSkin.graphics.moveTo(11.0, 14.0);
			resizeHandleSkin.graphics.lineTo(14.0, 11.0);
			resizableWindow.resizeHandleSkin = resizeHandleSkin;
		}

		window.paddingTop = 1.0;
		window.paddingRight = 1.0;
		window.paddingBottom = 1.0;
		window.paddingLeft = 1.0;

		window.fixedScrollBars = true;
	}

	private function setTitleWindowTitleStyles(label:Label):Void {
		label.textFormat = new TextFormat("DejaVuSansTF", 12, 0x292929, true);
		label.embedFonts = true;
	}

	private function setTitleWindowControlBarStyles(controlBar:LayoutGroup):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0x444444);
		backgroundSkin.cornerRadius = 7.0;
		controlBar.backgroundSkin = backgroundSkin;

		var layout = new HorizontalLayout();
		layout.horizontalAlign = RIGHT;
		layout.verticalAlign = MIDDLE;
		layout.paddingTop = 10.0;
		// TODO: should be 10.0, but there's a temporary bug in Feathers UI HorizontalLayout when using RIGHT
		layout.paddingRight = 0.0;
		layout.paddingBottom = 10.0;
		layout.paddingLeft = 10.0;
		layout.gap = 4.0;
		controlBar.layout = layout;
	}

	private function setToolBarLayoutGroupStyles(group:LayoutGroup):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0x444444);
		backgroundSkin.cornerRadius = 7.0;
		group.backgroundSkin = backgroundSkin;

		var layout = new HorizontalLayout();
		layout.horizontalAlign = RIGHT;
		layout.verticalAlign = MIDDLE;
		layout.paddingTop = 10.0;
		// TODO: should be 10.0, but there's a temporary bug in Feathers UI HorizontalLayout when using RIGHT
		layout.paddingRight = 0.0;
		layout.paddingBottom = 10.0;
		layout.paddingLeft = 10.0;
		layout.gap = 4.0;
		group.layout = layout;
	}

	private function setTextInputStyles(textInput:TextInput):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0x464646);
		backgroundSkin.border = SolidColor(1.0, 0x666666);
		backgroundSkin.setBorderForState(TextInputState.FOCUSED, SolidColor(1.0, 0xC165B8));
		backgroundSkin.cornerRadius = 0.0;
		textInput.backgroundSkin = backgroundSkin;

		textInput.textFormat = new TextFormat("DejaVuSansTF", 12, 0xf3f3f3);
		textInput.promptTextFormat = new TextFormat("DejaVuSansTF", 12, 0xa6a6a6);
		textInput.setTextFormatForState(DISABLED, new TextFormat("DejaVuSansTF", 12, 0x555555));
		textInput.embedFonts = true;

		textInput.paddingTop = 5.0;
		textInput.paddingRight = 5.0;
		textInput.paddingBottom = 5.0;
		textInput.paddingLeft = 5.0;
	}

	private function setTreeViewStyles(treeView:TreeView):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0x444444);
		backgroundSkin.border = SolidColor(1.0, 0x666666);
		backgroundSkin.setBorderForState(TextInputState.FOCUSED, SolidColor(1.0, 0xC165B8));
		backgroundSkin.cornerRadius = 0.0;
		backgroundSkin.minWidth = 160.0;
		backgroundSkin.minHeight = 160.0;
		treeView.backgroundSkin = backgroundSkin;

		var focusRectSkin = new RectangleSkin();
		focusRectSkin.fill = null;
		focusRectSkin.border = SolidColor(1.0, 0xC165B8);
		treeView.focusRectSkin = focusRectSkin;

		var layout = new VerticalListLayout();
		layout.requestedRowCount = 5;
		treeView.layout = layout;

		treeView.paddingTop = 1.0;
		treeView.paddingRight = 1.0;
		treeView.paddingBottom = 1.0;
		treeView.paddingLeft = 1.0;

		treeView.fixedScrollBars = true;
	}

	private function setBorderlessTreeViewStyles(treeView:TreeView):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0x444444);
		backgroundSkin.border = null;
		backgroundSkin.setBorderForState(TextInputState.FOCUSED, SolidColor(1.0, 0xC165B8));
		backgroundSkin.cornerRadius = 0.0;
		backgroundSkin.minWidth = 160.0;
		backgroundSkin.minHeight = 160.0;
		treeView.backgroundSkin = backgroundSkin;

		var focusRectSkin = new RectangleSkin();
		focusRectSkin.fill = null;
		focusRectSkin.border = SolidColor(1.0, 0xC165B8);
		treeView.focusRectSkin = focusRectSkin;

		var layout = new VerticalListLayout();
		layout.requestedRowCount = 5;
		treeView.layout = layout;

		treeView.paddingTop = 0.0;
		treeView.paddingRight = 0.0;
		treeView.paddingBottom = 0.0;
		treeView.paddingLeft = 0.0;

		treeView.fixedScrollBars = true;
	}

	private function setTreeViewItemRendererStyles(itemRenderer:TreeViewItemRenderer):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0x444444);
		backgroundSkin.selectedFill = SolidColor(0xC165B8);
		// TODO: uncomment when ToggleButtonState is handled correctly by BasicToggleButton
		// backgroundSkin.setFillForState(ToggleButtonState.HOVER(false), SolidColor(0x393939));
		itemRenderer.backgroundSkin = backgroundSkin;

		// TODO: uncomment when alternateBackgroundSkin is supported in alpha.3
		/*var alternateBackgroundSkin = new RectangleSkin();
			alternateBackgroundSkin.fill = SolidColor(0x4D4C4C);
			alternateBackgroundSkin.selectedFill = SolidColor(0xC165B8);
			alternateBackgroundSkin.setFillForState(ToggleButtonState.HOVER(false), SolidColor(0x393939));
			itemRenderer.alternateBackgroundSkin = alternateBackgroundSkin; */

		itemRenderer.textFormat = new TextFormat("DejaVuSansTF", 12, 0xf3f3f3);
		itemRenderer.disabledTextFormat = new TextFormat("DejaVuSansTF", 12, 0x555555);
		itemRenderer.embedFonts = true;

		itemRenderer.paddingTop = 4.0;
		itemRenderer.paddingRight = 4.0;
		itemRenderer.paddingBottom = 4.0;
		itemRenderer.paddingLeft = 4.0;
		itemRenderer.indentation = 12.0;
	}

	private function setTreeViewItemRendererDisclosureButtonStyles(button:ToggleButton):Void {
		var icon = new Shape();
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 12.0, 12.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(0x6F7777);
		icon.graphics.moveTo(2.0, 2.0);
		icon.graphics.lineTo(10.0, 6.0);
		icon.graphics.lineTo(2.0, 10.0);
		icon.graphics.lineTo(2.0, 2.0);
		icon.graphics.endFill();
		button.icon = icon;

		var selectedIcon = new Shape();
		selectedIcon.graphics.beginFill(0xff00ff, 0.0);
		selectedIcon.graphics.drawRect(0.0, 0.0, 12.0, 12.0);
		selectedIcon.graphics.endFill();
		selectedIcon.graphics.beginFill(0x6F7777);
		selectedIcon.graphics.moveTo(2.0, 2.0);
		selectedIcon.graphics.lineTo(10.0, 2.0);
		selectedIcon.graphics.lineTo(6.0, 10.0);
		selectedIcon.graphics.lineTo(2.0, 2.0);
		selectedIcon.graphics.endFill();
		button.selectedIcon = selectedIcon;
	}
}
