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

import feathers.controls.ToggleButtonState;
import feathers.controls.ToggleButton;
import feathers.controls.dataRenderers.TreeViewItemRenderer;
import feathers.layout.HorizontalLayoutData;
import feathers.controls.TreeView;
import moonshine.ui.SideBarViewHeader;
import moonshine.ui.ResizableTitleWindow;
import feathers.layout.VerticalListLayout;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.controls.ListView;
import feathers.controls.TextInputState;
import feathers.controls.TextInput;
import feathers.controls.Button;
import feathers.controls.ButtonState;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalLayout;
import feathers.skins.CircleSkin;
import feathers.skins.RectangleSkin;
import feathers.style.Theme;
import feathers.themes.ClassVariantTheme;
import moonshine.style.MoonshineButtonSkin;
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

		this.styleProvider.setStyleFunction(ItemRenderer, null, setItemRendererStyles);

		this.styleProvider.setStyleFunction(Label, null, setLabelStyles);

		this.styleProvider.setStyleFunction(LayoutGroup, LayoutGroup.VARIANT_TOOL_BAR, setToolBarLayoutGroupStyles);

		this.styleProvider.setStyleFunction(ListView, null, setListViewStyles);

		this.styleProvider.setStyleFunction(SideBarViewHeader, null, setSideBarViewHeaderStyles);
		this.styleProvider.setStyleFunction(Label, SideBarViewHeader.CHILD_VARIANT_TITLE, setSideBarViewHeaderTitleStyles);
		this.styleProvider.setStyleFunction(Button, SideBarViewHeader.CHILD_VARIANT_CLOSE_BUTTON, setSideBarViewHeaderCloseButtonStyles);

		this.styleProvider.setStyleFunction(TitleWindow, null, setTitleWindowStyles);
		this.styleProvider.setStyleFunction(Label, TitleWindow.CHILD_VARIANT_TITLE, setTitleWindowTitleStyles);
		this.styleProvider.setStyleFunction(LayoutGroup, THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR, setTitleWindowControlBarStyles);
		this.styleProvider.setStyleFunction(Button, TitleWindow.CHILD_VARIANT_CLOSE_BUTTON, setTitleWindowCloseButtonStyles);

		this.styleProvider.setStyleFunction(TextInput, null, setTextInputStyles);

		this.styleProvider.setStyleFunction(TreeView, null, setTreeViewStyles);
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
		downSkin.outerBorderFill = SolidColor(0xCCCCCC);
		downSkin.outerBorderSize = 3.0;
		downSkin.outerBorderRadius = 10.0;
		downSkin.innerBorderFill = SolidColor(0xEFEFEF);
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

	private function setItemRendererStyles(itemRenderer:ItemRenderer):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0x464646);
		backgroundSkin.selectedFill = SolidColor(0xC165B8);
		// TODO: uncomment when ToggleButtonState is handled correctly by BasicToggleButton
		// backgroundSkin.setFillForState(ToggleButtonState.HOVER(false), SolidColor(0x393939));
		itemRenderer.backgroundSkin = backgroundSkin;

		itemRenderer.textFormat = new TextFormat("DejaVuSansTF", 12, 0xf3f3f3);
		itemRenderer.disabledTextFormat = new TextFormat("DejaVuSansTF", 12, 0x555555);
		itemRenderer.embedFonts = true;

		itemRenderer.paddingTop = 4.0;
		itemRenderer.paddingRight = 4.0;
		itemRenderer.paddingBottom = 4.0;
		itemRenderer.paddingLeft = 4.0;
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
		backgroundSkin.fill = SolidColor(0x464646);
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
		backgroundSkin.fill = SolidColor(0x464646);
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
	}

	private function setTreeViewItemRendererStyles(itemRenderer:TreeViewItemRenderer):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(0x464646);
		backgroundSkin.selectedFill = SolidColor(0xC165B8);
		// TODO: uncomment when ToggleButtonState is handled correctly by BasicToggleButton
		// backgroundSkin.setFillForState(ToggleButtonState.HOVER(false), SolidColor(0x393939));
		itemRenderer.backgroundSkin = backgroundSkin;

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
