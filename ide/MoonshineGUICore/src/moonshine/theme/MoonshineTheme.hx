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

import feathers.controls.BasicButton;
import feathers.controls.Button;
import feathers.controls.ButtonState;
import feathers.controls.GridView;
import feathers.controls.HDividedBox;
import feathers.controls.HProgressBar;
import feathers.controls.HScrollBar;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.Panel;
import feathers.controls.PopUpListView;
import feathers.controls.Radio;
import feathers.controls.TabBar;
import feathers.controls.TextInput;
import feathers.controls.TextInputState;
import feathers.controls.ToggleButton;
import feathers.controls.ToggleButtonState;
import feathers.controls.TreeGridView;
import feathers.controls.TreeView;
import feathers.controls.VProgressBar;
import feathers.controls.VScrollBar;
import feathers.controls.dataRenderers.HierarchicalItemRenderer;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.controls.dataRenderers.LayoutGroupItemRenderer;
import feathers.controls.dataRenderers.SortOrderHeaderRenderer;
import feathers.controls.navigators.TabNavigator;
import feathers.core.DefaultToolTipManager;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalLayoutData;
import feathers.layout.VerticalListLayout;
import feathers.skins.CircleSkin;
import feathers.skins.RectangleSkin;
import feathers.skins.TriangleSkin;
import feathers.style.Theme;
import flash.display.Bitmap;
import flash.filters.DropShadowFilter;
import moonshine.components.StandardPopupView;
import moonshine.plugin.debugadapter.view.DebugAdapterView;
import moonshine.plugin.debugadapter.view.ThreadOrStackFrameItemRenderer;
import moonshine.plugin.help.view.TourDeFlexHierarchicalItemRenderer;
import moonshine.style.MoonshineButtonSkin;
import moonshine.style.MoonshineControlBarSkin;
import moonshine.style.MoonshineHScrollBarThumbSkin;
import moonshine.style.MoonshineVScrollBarThumbSkin;
import moonshine.theme.SDKInstallerTheme;
import moonshine.theme.assets.DebugPauseIcon;
import moonshine.theme.assets.DebugPlayIcon;
import moonshine.theme.assets.DebugStepIntoIcon;
import moonshine.theme.assets.DebugStepOutIcon;
import moonshine.theme.assets.DebugStepOverIcon;
import moonshine.theme.assets.DebugStopIcon;
import moonshine.theme.assets.RefreshIcon;
import moonshine.ui.ResizableTitleWindow;
import moonshine.ui.SideBarViewHeader;
import moonshine.ui.TitleWindow;
import openfl.display.Shape;
import openfl.filters.GlowFilter;
import openfl.geom.Matrix;

class MoonshineTheme extends SDKInstallerTheme {
	private static var _instance:MoonshineTheme;

	public static function initializeTheme():Void {
		if (_instance != null) {
			return;
		}
		_instance = new MoonshineTheme();
		Theme.setTheme(_instance);
	}

	public static final IMAGE_VARIANT_LARGE_REFRESH_ICON:String = "image-icon-large-refresh";
	public static final THEME_VARIANT_BUSY_LABEL:String = "moonshine-label-busy-status-light";
	public static final THEME_VARIANT_DARK_BUTTON:String = "moonshine-button--dark";
	public static final THEME_VARIANT_HORIZONTAL_DIVIDER = "moonshine-horizontal-divider";
	public static final THEME_VARIANT_LARGE_BUTTON:String = "moonshine-button--large";
	public static final THEME_VARIANT_LIGHT_BUTTON:String = "moonshine-button--light";
	public static final THEME_VARIANT_LIGHT_LABEL:String = "moonshine-label--light";
	public static final THEME_VARIANT_LIGHT_SECONDARY_LABEL:String = "moonshine-label--light-secondary";
	public static final THEME_VARIANT_MAROON_LABEL:String = "moonshine-label--maroon";
	public static final THEME_VARIANT_GREY_LABEL:String = "moonshine-label--grey";
	public static final THEME_VARIANT_GREY_SMALL_LABEL:String = "moonshine-label--grey-small";
	public static final THEME_VARIANT_MENU_ITEM_RENDERER = "moonshine-item-renderer--menu";
	public static final THEME_VARIANT_MENU_LIST_VIEW = "moonshine-list-view--menu";
	public static final THEME_VARIANT_PLUGIN_LARGE_TITLE:String = "moonshine-plugin-large-title";
	public static final THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR = "moonshine-title-window-control-bar";
	public static final THEME_VARIANT_WARNING_BAR:String = "moonshine-warning-bar";
	public static final THEME_VARIANT_LIGHT_GRID_VIEW:String = "moonshine-light-grid-view";
	public static final THEME_VARIANT_LIGHT_GRID_VIEW_TABBAR:String = "moonshine-light-grid-view-tabbar";
	public static final THEME_VARIANT_LIGHT_TAB_NAVIGATOR:String = "moonshine-light-tab-navigator";

	public static final ASSET_LOGO:String = "/elements/moonshine_logo/logo_new_48.png";
	public static final ASSET_COPY_ICON:String = "/elements/images/copy_content_icon.png";

	override public function new() {
		super();

		this.styleProvider.setStyleFunction(Button, null, setLightButtonStyles);
		this.styleProvider.setStyleFunction(Button, THEME_VARIANT_LIGHT_BUTTON, setLightButtonStyles);
		this.styleProvider.setStyleFunction(Button, THEME_VARIANT_DARK_BUTTON, setDarkButtonStyles);
		this.styleProvider.setStyleFunction(Button, THEME_VARIANT_LARGE_BUTTON, setLargeButtonStyles);

		this.styleProvider.setStyleFunction(DebugAdapterView, null, setDebugAdapterViewStyles);

		this.styleProvider.setStyleFunction(HDividedBox, null, setHDividedBoxStyles);

		this.styleProvider.setStyleFunction(GridView, null, setGridViewStyles);
		this.styleProvider.setStyleFunction(GridView, GridView.VARIANT_BORDERLESS, setBorderlessGridViewStyles);
		this.styleProvider.setStyleFunction(GridView, THEME_VARIANT_LIGHT_GRID_VIEW, setLightGridViewStyles);
		this.styleProvider.setStyleFunction(SortOrderHeaderRenderer, GridView.CHILD_VARIANT_HEADER_RENDERER, setGridViewOrTreeGridViewHeaderStyles);
		this.styleProvider.setStyleFunction(SortOrderHeaderRenderer, THEME_VARIANT_LIGHT_GRID_VIEW, setGridViewOrTreeGridViewHeaderLightStyles);
		this.styleProvider.setStyleFunction(ItemRenderer, THEME_VARIANT_LIGHT_GRID_VIEW, setItemRendererLightStyles);

		this.styleProvider.setStyleFunction(ItemRenderer, null, setItemRendererStyles);
		this.styleProvider.setStyleFunction(LayoutGroupItemRenderer, null, setLayoutGroupItemRendererStyles);
		this.styleProvider.setStyleFunction(ItemRenderer, THEME_VARIANT_MENU_ITEM_RENDERER, setMenuItemRendererStyles);

		this.styleProvider.setStyleFunction(Label, null, setLabelStyles);
		this.styleProvider.setStyleFunction(Label, THEME_VARIANT_LIGHT_LABEL, setLightLabelStyles);
		this.styleProvider.setStyleFunction(Label, THEME_VARIANT_LIGHT_SECONDARY_LABEL, setLightSecondaryLabelStyles);
		this.styleProvider.setStyleFunction(Label, THEME_VARIANT_MAROON_LABEL, setMaroonLabelStyles);
		this.styleProvider.setStyleFunction(Label, THEME_VARIANT_GREY_LABEL, setGreyLabelStyles);
		this.styleProvider.setStyleFunction(Label, THEME_VARIANT_GREY_SMALL_LABEL, setGreySmallLabelStyles);
		this.styleProvider.setStyleFunction(Label, DefaultToolTipManager.CHILD_VARIANT_TOOL_TIP, setToolTipLabelStyles);
		this.styleProvider.setStyleFunction(Label, THEME_VARIANT_BUSY_LABEL, setBusyLabelStyles);
		this.styleProvider.setStyleFunction(Label, THEME_VARIANT_PLUGIN_LARGE_TITLE, setPluginLargeTitleStyles);

		this.styleProvider.setStyleFunction(LayoutGroup, LayoutGroup.VARIANT_TOOL_BAR, setToolBarLayoutGroupStyles);
		this.styleProvider.setStyleFunction(LayoutGroup, THEME_VARIANT_WARNING_BAR, setWarningBarLayoutGroupStyles);
		this.styleProvider.setStyleFunction(LayoutGroup, THEME_VARIANT_HORIZONTAL_DIVIDER, setHorizontalDividerLayoutGroupStyles);

		this.styleProvider.setStyleFunction(ListView, null, setListViewStyles);
		this.styleProvider.setStyleFunction(ListView, THEME_VARIANT_MENU_LIST_VIEW, setMenuListViewStyles);

		this.styleProvider.setStyleFunction(Panel, null, setPanelStyles);

		this.styleProvider.setStyleFunction(Button, PopUpListView.CHILD_VARIANT_BUTTON, setPopUpListViewButtonStyles);

		this.styleProvider.setStyleFunction(HScrollBar, null, setHScrollBarStyles);
		this.styleProvider.setStyleFunction(VScrollBar, null, setVScrollBarStyles);

		this.styleProvider.setStyleFunction(Radio, null, setRadioStyles);

		this.styleProvider.setStyleFunction(SideBarViewHeader, null, setSideBarViewHeaderStyles);
		this.styleProvider.setStyleFunction(Label, SideBarViewHeader.CHILD_VARIANT_TITLE, setSideBarViewHeaderTitleStyles);
		this.styleProvider.setStyleFunction(Button, SideBarViewHeader.CHILD_VARIANT_CLOSE_BUTTON, setSideBarViewHeaderCloseButtonStyles);
		this.styleProvider.setStyleFunction(Button, SideBarViewHeader.CHILD_VARIANT_MENU_BUTTON, setSideBarViewHeaderMenuButtonStyles);

		this.styleProvider.setStyleFunction(StandardPopupView, null, setStandardPopupViewStyles);

		this.styleProvider.setStyleFunction(TitleWindow, null, setTitleWindowStyles);
		this.styleProvider.setStyleFunction(Label, TitleWindow.CHILD_VARIANT_TITLE, setTitleWindowTitleStyles);
		this.styleProvider.setStyleFunction(LayoutGroup, THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR, setTitleWindowControlBarStyles);
		this.styleProvider.setStyleFunction(Button, TitleWindow.CHILD_VARIANT_CLOSE_BUTTON, setTitleWindowCloseButtonStyles);

		this.styleProvider.setStyleFunction(TreeGridView, null, setTreeGridViewStyles);
		this.styleProvider.setStyleFunction(TreeGridView, TreeGridView.VARIANT_BORDERLESS, setBorderlessTreeGridViewStyles);
		this.styleProvider.setStyleFunction(SortOrderHeaderRenderer, TreeGridView.CHILD_VARIANT_HEADER_RENDERER, setGridViewOrTreeGridViewHeaderStyles);

		this.styleProvider.setStyleFunction(TreeView, null, setTreeViewStyles);
		this.styleProvider.setStyleFunction(TreeView, TreeView.VARIANT_BORDERLESS, setBorderlessTreeViewStyles);
		this.styleProvider.setStyleFunction(HierarchicalItemRenderer, null, setHierarchicalItemRendererStyles);
		this.styleProvider.setStyleFunction(TourDeFlexHierarchicalItemRenderer, null, setTourDeFlexHierarchicalItemRendererItemRendererStyles);
		this.styleProvider.setStyleFunction(ToggleButton, HierarchicalItemRenderer.CHILD_VARIANT_DISCLOSURE_BUTTON,
			setHierarchicalItemRendererDisclosureButtonStyles);

		this.styleProvider.setStyleFunction(Button, IMAGE_VARIANT_LARGE_REFRESH_ICON, setImageLargeRefreshStyles);

		this.styleProvider.setStyleFunction(Button, DebugAdapterView.CHILD_VARIANT_PLAY_BUTTON, setDebugPlayButtonStyles);
		this.styleProvider.setStyleFunction(Button, DebugAdapterView.CHILD_VARIANT_PAUSE_BUTTON, setDebugPauseButtonStyles);
		this.styleProvider.setStyleFunction(Button, DebugAdapterView.CHILD_VARIANT_STEP_OVER_BUTTON, setDebugStepOverButtonStyles);
		this.styleProvider.setStyleFunction(Button, DebugAdapterView.CHILD_VARIANT_STEP_INTO_BUTTON, setDebugStepIntoButtonStyles);
		this.styleProvider.setStyleFunction(Button, DebugAdapterView.CHILD_VARIANT_STEP_OUT_BUTTON, setDebugStepOutButtonStyles);
		this.styleProvider.setStyleFunction(Button, DebugAdapterView.CHILD_VARIANT_STOP_BUTTON, setDebugStopButtonStyles);

		this.styleProvider.setStyleFunction(Button, ThreadOrStackFrameItemRenderer.CHILD_VARIANT_PLAY_BUTTON, setMiniDebugPlayButtonStyles);
		this.styleProvider.setStyleFunction(Button, ThreadOrStackFrameItemRenderer.CHILD_VARIANT_PAUSE_BUTTON, setMiniDebugPauseButtonStyles);
		this.styleProvider.setStyleFunction(Button, ThreadOrStackFrameItemRenderer.CHILD_VARIANT_STEP_OVER_BUTTON, setMiniDebugStepOverButtonStyles);
		this.styleProvider.setStyleFunction(Button, ThreadOrStackFrameItemRenderer.CHILD_VARIANT_STEP_INTO_BUTTON, setMiniDebugStepIntoButtonStyles);
		this.styleProvider.setStyleFunction(Button, ThreadOrStackFrameItemRenderer.CHILD_VARIANT_STEP_OUT_BUTTON, setMiniDebugStepOutButtonStyles);

		this.styleProvider.setStyleFunction(HProgressBar, null, setHProgressBarStyles);
		this.styleProvider.setStyleFunction(VProgressBar, null, setVProgressBarStyles);

		//
		// An NPE bug in FeathersUI doesn't allow customizing the style of TabBar
		// this.styleProvider.setStyleFunction(TabBar, TabNavigator.CHILD_VARIANT_TAB_BAR, setLightGridViewTabbarStyles);
		//

		this.styleProvider.setStyleFunction(TabNavigator, THEME_VARIANT_LIGHT_TAB_NAVIGATOR, setLightTabNavigatorStyles);
		this.styleProvider.setStyleFunction(ToggleButton, TabBar.CHILD_VARIANT_TAB, setTabBarToggleButtonStyles);
	}

	private function setLightButtonStyles(button:Button):Void {
		var backgroundSkin = new MoonshineButtonSkin();
		backgroundSkin.outerBorderFill = SolidColor(MoonshineColor.GREY_FC);
		backgroundSkin.outerBorderSize = 3.0;
		backgroundSkin.outerBorderRadius = 6.0;
		backgroundSkin.innerBorderFill = SolidColor(MoonshineColor.GREY_D3);
		backgroundSkin.innerBorderSize = 1.0;
		backgroundSkin.innerBorderRadius = 4.0;
		backgroundSkin.fill = Gradient(LINEAR, [0xF9F9F7, 0xF9F9F7, 0xEFEFED, 0xEFEFED], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		backgroundSkin.borderRadius = 4.0;
		backgroundSkin.filters = [new GlowFilter(MoonshineColor.GREY_E5, 1.0, 2.0, 2.0, 3.0)];
		button.backgroundSkin = backgroundSkin;

		var hoverSkin = new MoonshineButtonSkin();
		hoverSkin.outerBorderFill = SolidColor(MoonshineColor.GREY_FC);
		hoverSkin.outerBorderSize = 3.0;
		hoverSkin.outerBorderRadius = 6.0;
		hoverSkin.innerBorderFill = SolidColor(MoonshineColor.GREY_D3);
		hoverSkin.innerBorderSize = 1.0;
		hoverSkin.innerBorderRadius = 4.0;
		hoverSkin.fill = Gradient(LINEAR, [0xF9F9F7, 0xF9F9F7, 0xEAEAE8, 0xEAEAE8], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		hoverSkin.borderRadius = 4.0;
		hoverSkin.filters = [new GlowFilter(MoonshineColor.GREY_E5, 1.0, 2.0, 2.0, 3.0)];
		button.setSkinForState(HOVER, hoverSkin);

		var downSkin = new MoonshineButtonSkin();
		downSkin.outerBorderFill = SolidColor(MoonshineColor.GREY_FC);
		downSkin.outerBorderSize = 3.0;
		downSkin.outerBorderRadius = 6.0;
		downSkin.innerBorderFill = SolidColor(MoonshineColor.GREY_D3);
		downSkin.innerBorderSize = 1.0;
		downSkin.innerBorderRadius = 4.0;
		downSkin.fill = Gradient(LINEAR, [0xF1F1F1, 0xF1F1F1, 0xE7E7E7, 0xE7E7E7], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		downSkin.borderRadius = 4.0;
		downSkin.filters = [new GlowFilter(MoonshineColor.GREY_D, 1.0, 2.0, 2.0, 3.0)];
		button.setSkinForState(DOWN, downSkin);

		var disabledSkin = new MoonshineButtonSkin();
		disabledSkin.outerBorderFill = SolidColor(MoonshineColor.GREY_C);
		disabledSkin.outerBorderSize = 3.0;
		disabledSkin.outerBorderRadius = 6.0;
		disabledSkin.innerBorderFill = SolidColor(MoonshineColor.WHITE);
		disabledSkin.innerBorderSize = 1.0;
		disabledSkin.innerBorderRadius = 4.0;
		disabledSkin.fill = Gradient(LINEAR, [0xE1E1E1, 0xE1E1E1, 0xD6D6D6, 0xD6D6D6], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		disabledSkin.borderRadius = 4.0;
		disabledSkin.alpha = 0.5;
		disabledSkin.filters = [new GlowFilter(MoonshineColor.GREY_E5, 1.0, 2.0, 2.0, 3.0)];
		button.setSkinForState(DISABLED, disabledSkin);

		var focusRectSkin = new RectangleSkin();
		focusRectSkin.fill = null;
		focusRectSkin.border = SolidColor(1.0, MoonshineColor.PINK_2);
		focusRectSkin.cornerRadius = 5.0;
		button.focusRectSkin = focusRectSkin;

		button.textFormat = MoonshineTypography.getGreyTextFormat();
		button.setTextFormatForState(DISABLED, MoonshineTypography.getDarkOnLightDisabledTextFormat());
		// button.embedFonts = true;

		button.paddingTop = 8.0;
		button.paddingRight = 16.0;
		button.paddingBottom = 8.0;
		button.paddingLeft = 16.0;
		button.gap = 4.0;
	}

	private function setDarkButtonStyles(button:Button):Void {
		var backgroundSkin = new MoonshineButtonSkin();
		backgroundSkin.outerBorderFill = SolidColor(MoonshineColor.GREY_2);
		backgroundSkin.outerBorderSize = 3.0;
		backgroundSkin.outerBorderRadius = 6.0;
		backgroundSkin.innerBorderFill = SolidColor(MoonshineColor.GREY_4C);
		backgroundSkin.innerBorderSize = 1.0;
		backgroundSkin.innerBorderRadius = 4.0;
		backgroundSkin.fill = Gradient(LINEAR, [0x444444, 0x444444, 0x404040, 0x404040], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		backgroundSkin.borderRadius = 4.0;
		button.backgroundSkin = backgroundSkin;

		var hoverSkin = new MoonshineButtonSkin();
		hoverSkin.outerBorderFill = SolidColor(MoonshineColor.GREY_2);
		hoverSkin.outerBorderSize = 3.0;
		hoverSkin.outerBorderRadius = 6.0;
		hoverSkin.innerBorderFill = SolidColor(MoonshineColor.GREY_4C);
		hoverSkin.innerBorderSize = 1.0;
		hoverSkin.innerBorderRadius = 4.0;
		hoverSkin.fill = Gradient(LINEAR, [0x444444, 0x444444, 0x3E3E3E, 0x3E3E3E], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		hoverSkin.borderRadius = 4.0;
		button.setSkinForState(HOVER, hoverSkin);

		var downSkin = new MoonshineButtonSkin();
		downSkin.outerBorderFill = SolidColor(MoonshineColor.GREY_29);
		downSkin.outerBorderSize = 3.0;
		downSkin.outerBorderRadius = 6.0;
		downSkin.innerBorderFill = SolidColor(0x474747);
		downSkin.innerBorderSize = 1.0;
		downSkin.innerBorderRadius = 4.0;
		downSkin.fill = Gradient(LINEAR, [0x3F3F3F, 0x3F3F3F, 0x3C3C3C, 0x3C3C3C], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		downSkin.borderRadius = 4.0;
		button.setSkinForState(DOWN, downSkin);

		var disabledSkin = new MoonshineButtonSkin();
		disabledSkin.outerBorderFill = SolidColor(MoonshineColor.GREY_29);
		disabledSkin.outerBorderSize = 3.0;
		disabledSkin.outerBorderRadius = 6.0;
		disabledSkin.innerBorderFill = SolidColor(MoonshineColor.GREY_4C);
		disabledSkin.innerBorderSize = 1.0;
		disabledSkin.innerBorderRadius = 4.0;
		disabledSkin.fill = Gradient(LINEAR, [0x444444, 0x444444, 0x404040, 0x404040], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		disabledSkin.alpha = 0.5;
		button.setSkinForState(DISABLED, disabledSkin);

		var focusRectSkin = new RectangleSkin();
		focusRectSkin.fill = null;
		focusRectSkin.border = SolidColor(1.0, MoonshineColor.PINK_2);
		focusRectSkin.cornerRadius = 5.0;
		button.focusRectSkin = focusRectSkin;

		button.textFormat = MoonshineTypography.getLightOnDarkSecondaryTextFormat();
		button.setTextFormatForState(DISABLED, MoonshineTypography.getTextFormat(MoonshineTypography.DEFAULT_FONT_SIZE, MoonshineColor.GREY_6));
		// button.embedFonts = true;

		button.paddingTop = 8.0;
		button.paddingRight = 8.0;
		button.paddingBottom = 8.0;
		button.paddingLeft = 8.0;
		button.gap = 4.0;
	}

	private function setLargeButtonStyles(button:Button):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.border = SolidColor(4.0, MoonshineColor.GREY_6);
		backgroundSkin.cornerRadius = 7.0;
		backgroundSkin.fill = Gradient(LINEAR, [0xe2e2e2, 0xe2e2e2, 0xd7d5d7, 0xd7d5d7], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		button.backgroundSkin = backgroundSkin;

		var hoverSkin = new RectangleSkin();
		hoverSkin.border = SolidColor(4.0, MoonshineColor.GREY_6);
		hoverSkin.cornerRadius = 7.0;
		hoverSkin.fill = Gradient(LINEAR, [0xe2e2e2, 0xe2e2e2, 0xd4d0d1, 0xd4d0d1], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		button.setSkinForState(HOVER, hoverSkin);

		var downSkin = new RectangleSkin();
		downSkin.border = SolidColor(4.0, MoonshineColor.GREY_6);
		downSkin.cornerRadius = 7.0;
		downSkin.fill = Gradient(LINEAR, [0xcccccc, 0xcccccc, 0x999999, 0x999999], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		button.setSkinForState(DOWN, downSkin);

		var disabledSkin = new RectangleSkin();
		disabledSkin.border = SolidColor(4.0, MoonshineColor.GREY_6);
		disabledSkin.cornerRadius = 7.0;
		disabledSkin.fill = Gradient(LINEAR, [0x444444, 0x444444, 0x404040, 0x404040], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		button.setSkinForState(DISABLED, disabledSkin);

		var focusRectSkin = new RectangleSkin();
		focusRectSkin.fill = null;
		focusRectSkin.border = SolidColor(1.0, MoonshineColor.PINK_2);
		focusRectSkin.cornerRadius = 6.0;
		button.focusRectSkin = focusRectSkin;

		button.textFormat = MoonshineTypography.getTextFormat(MoonshineTypography.LARGE_FONT_SIZE, MoonshineColor.GREY_3);
		button.setTextFormatForState(DISABLED, MoonshineTypography.getTextFormat(MoonshineTypography.LARGE_FONT_SIZE, MoonshineColor.GREY_9));
		// button.embedFonts = true;

		button.paddingTop = button.paddingBottom = 8.0;
		button.paddingRight = button.paddingLeft = 20.0;
		button.gap = 4.0;
	}

	private function setGridViewStyles(gridView:GridView):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(MoonshineColor.GREY_4);
		backgroundSkin.border = SolidColor(1.0, MoonshineColor.GREY_6);
		backgroundSkin.cornerRadius = 0.0;
		backgroundSkin.minWidth = 160.0;
		backgroundSkin.minHeight = 160.0;
		gridView.backgroundSkin = backgroundSkin;

		var columnResizeSkin = new RectangleSkin(SolidColor(MoonshineColor.PINK_2), null);
		columnResizeSkin.width = 2.0;
		columnResizeSkin.height = 2.0;
		gridView.columnResizeSkin = columnResizeSkin;

		var focusRectSkin = new RectangleSkin();
		focusRectSkin.fill = null;
		focusRectSkin.border = SolidColor(1.0, MoonshineColor.PINK_2);
		gridView.focusRectSkin = focusRectSkin;

		var layout = new VerticalListLayout();
		layout.requestedRowCount = 5;
		gridView.layout = layout;

		gridView.fixedScrollBars = true;
	}

	private function setBorderlessGridViewStyles(gridView:GridView):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(MoonshineColor.GREY_4);
		backgroundSkin.border = null;
		backgroundSkin.cornerRadius = 0.0;
		backgroundSkin.minWidth = 160.0;
		backgroundSkin.minHeight = 160.0;
		gridView.backgroundSkin = backgroundSkin;

		var columnResizeSkin = new RectangleSkin(SolidColor(MoonshineColor.PINK_2), null);
		columnResizeSkin.width = 2.0;
		columnResizeSkin.height = 2.0;
		gridView.columnResizeSkin = columnResizeSkin;

		var focusRectSkin = new RectangleSkin();
		focusRectSkin.fill = null;
		focusRectSkin.border = SolidColor(1.0, MoonshineColor.PINK_2);
		gridView.focusRectSkin = focusRectSkin;

		var layout = new VerticalListLayout();
		layout.requestedRowCount = 5;
		gridView.layout = layout;

		gridView.fixedScrollBars = true;
	}

	private function setLightGridViewStyles(gridView:GridView):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(MoonshineColor.WHITE);
		backgroundSkin.border = SolidColor(1, MoonshineColor.GREY_6);
		backgroundSkin.cornerRadius = 0.0;
		backgroundSkin.minWidth = 160.0;
		backgroundSkin.minHeight = 160.0;
		gridView.backgroundSkin = backgroundSkin;

		var columnResizeSkin = new RectangleSkin(SolidColor(MoonshineColor.PINK_2), null);
		columnResizeSkin.width = 2.0;
		columnResizeSkin.height = 2.0;
		gridView.columnResizeSkin = columnResizeSkin;

		var focusRectSkin = new RectangleSkin();
		focusRectSkin.fill = null;
		focusRectSkin.border = SolidColor(1.0, MoonshineColor.PINK_2);
		gridView.focusRectSkin = focusRectSkin;

		var layout = new VerticalListLayout();
		layout.requestedRowCount = 5;
		layout.setPadding( 1 );
		gridView.layout = layout;

		gridView.fixedScrollBars = true;
	}

	private function setGridViewOrTreeGridViewHeaderStyles(headerRenderer:SortOrderHeaderRenderer):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(MoonshineColor.GREY_5);
		headerRenderer.backgroundSkin = backgroundSkin;

		headerRenderer.textFormat = MoonshineTypography.getLightOnDarkTextFormat();
		headerRenderer.disabledTextFormat = MoonshineTypography.getLightOnDarkDisabledTextFormat();
		// headerRenderer.embedFonts = true;

		headerRenderer.horizontalAlign = LEFT;
		headerRenderer.paddingTop = 4.0;
		headerRenderer.paddingRight = 4.0;
		headerRenderer.paddingBottom = 4.0;
		headerRenderer.paddingLeft = 4.0;
		headerRenderer.gap = 4.0;
	}

	private function setGridViewOrTreeGridViewHeaderLightStyles(headerRenderer:SortOrderHeaderRenderer):Void {
		headerRenderer.backgroundSkin = null;
		headerRenderer.visible = headerRenderer.includeInLayout = false;
		headerRenderer.height = 0;
	}

	private function setRadioStyles(radio:Radio):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(MoonshineColor.BLACK, 0.0);
		backgroundSkin.border = null;
		radio.backgroundSkin = backgroundSkin;

		var icon = new MoonshineButtonSkin();
		icon.outerBorderFill = SolidColor(MoonshineColor.GREY_6);
		icon.outerBorderSize = 2.0;
		icon.outerBorderRadius = 10.0;
		icon.innerBorderFill = SolidColor(MoonshineColor.WHITE);
		icon.innerBorderSize = 1.0;
		icon.innerBorderRadius = 8.0;
		icon.fill = Gradient(LINEAR, [0xE1E1E1, 0xE1E1E1, 0xD6D6D6, 0xD6D6D6], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		icon.borderRadius = 8.0;
		icon.width = 20.0;
		icon.height = 20.0;
		radio.icon = icon;

		var disabledIcon = new MoonshineButtonSkin();
		disabledIcon.outerBorderFill = SolidColor(MoonshineColor.GREY_C);
		disabledIcon.outerBorderSize = 2.0;
		disabledIcon.outerBorderRadius = 10.0;
		disabledIcon.innerBorderFill = SolidColor(MoonshineColor.WHITE);
		disabledIcon.innerBorderSize = 1.0;
		disabledIcon.innerBorderRadius = 8.0;
		disabledIcon.fill = Gradient(LINEAR, [0xE1E1E1, 0xE1E1E1, 0xD6D6D6, 0xD6D6D6], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		disabledIcon.borderRadius = 8.0;
		disabledIcon.alpha = 0.5;
		disabledIcon.width = 20.0;
		disabledIcon.height = 20.0;
		radio.disabledIcon = disabledIcon;

		var downIcon = new MoonshineButtonSkin();
		downIcon.outerBorderFill = SolidColor(MoonshineColor.GREY_6);
		downIcon.outerBorderSize = 2.0;
		downIcon.outerBorderRadius = 10.0;
		downIcon.innerBorderFill = SolidColor(MoonshineColor.WHITE);
		downIcon.innerBorderSize = 1.0;
		downIcon.innerBorderRadius = 8.0;
		downIcon.fill = Gradient(LINEAR, [0xD6D6D6, 0xD6D6D6, 0xDFDFDF, 0xDFDFDF], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		downIcon.borderRadius = 8.0;
		downIcon.alpha = 0.5;
		downIcon.width = 20.0;
		downIcon.height = 20.0;
		radio.setIconForState(DOWN(false), downIcon);

		var selectedIcon = new MoonshineButtonSkin();
		selectedIcon.outerBorderFill = SolidColor(MoonshineColor.GREY_6);
		selectedIcon.outerBorderSize = 2.0;
		selectedIcon.outerBorderRadius = 10.0;
		selectedIcon.innerBorderFill = SolidColor(MoonshineColor.WHITE);
		selectedIcon.innerBorderSize = 1.0;
		selectedIcon.innerBorderRadius = 8.0;
		selectedIcon.fill = Gradient(LINEAR, [0xE1E1E1, 0xE1E1E1, 0xD6D6D6, 0xD6D6D6], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		selectedIcon.borderRadius = 8.0;
		selectedIcon.width = 20.0;
		selectedIcon.height = 20.0;
		radio.selectedIcon = selectedIcon;
		var symbol = new Shape();
		symbol.graphics.beginFill(MoonshineColor.GREY_29);
		symbol.graphics.drawCircle(4.0, 4.0, 4.0);
		symbol.graphics.endFill();
		symbol.x = 6.0;
		symbol.y = 6.0;
		selectedIcon.addChild(symbol);

		var selectedDownIcon = new MoonshineButtonSkin();
		selectedDownIcon.outerBorderFill = SolidColor(MoonshineColor.GREY_6);
		selectedDownIcon.outerBorderSize = 2.0;
		selectedDownIcon.outerBorderRadius = 10.0;
		selectedDownIcon.innerBorderFill = SolidColor(MoonshineColor.WHITE);
		selectedDownIcon.innerBorderSize = 1.0;
		selectedDownIcon.innerBorderRadius = 8.0;
		selectedDownIcon.fill = Gradient(LINEAR, [0xD6D6D6, 0xD6D6D6, 0xDFDFDF, 0xDFDFDF], [1.0, 1.0, 1.0, 1.0], [0x00, 0x7F, 0x80, 0xFF], Math.PI / 2.0);
		selectedDownIcon.borderRadius = 8.0;
		selectedDownIcon.alpha = 0.5;
		selectedDownIcon.width = 20.0;
		selectedDownIcon.height = 20.0;
		radio.setIconForState(DOWN(true), selectedDownIcon);
		var downSymbol = new Shape();
		downSymbol.graphics.beginFill(MoonshineColor.GREY_29);
		downSymbol.graphics.drawCircle(4.0, 4.0, 4.0);
		downSymbol.graphics.endFill();
		downSymbol.x = 6.0;
		downSymbol.y = 6.0;
		selectedDownIcon.addChild(downSymbol);

		var focusRectSkin = new RectangleSkin();
		focusRectSkin.fill = null;
		focusRectSkin.border = SolidColor(1.0, MoonshineColor.PINK_2);
		focusRectSkin.cornerRadius = 4.0;
		radio.focusRectSkin = focusRectSkin;
		radio.focusPaddingTop = 2.0;
		radio.focusPaddingRight = 2.0;
		radio.focusPaddingBottom = 2.0;
		radio.focusPaddingLeft = 2.0;

		radio.textFormat = MoonshineTypography.getDarkOnLightTextFormat();
		radio.disabledTextFormat = MoonshineTypography.getDarkOnLightDisabledTextFormat();
		// radio.embedFonts = true;

		radio.horizontalAlign = LEFT;
		radio.gap = 4.0;
	}

	private function setItemRendererStyles(itemRenderer:ItemRenderer):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(MoonshineColor.GREY_4);
		backgroundSkin.selectedFill = SolidColor(MoonshineColor.PINK_2);
		backgroundSkin.setFillForState(ToggleButtonState.HOVER(false), SolidColor(MoonshineColor.GREY_39));
		itemRenderer.backgroundSkin = backgroundSkin;

		var alternateBackgroundSkin = new RectangleSkin();
		alternateBackgroundSkin.fill = SolidColor(MoonshineColor.GREY_4C);
		alternateBackgroundSkin.selectedFill = SolidColor(MoonshineColor.PINK_2);
		alternateBackgroundSkin.setFillForState(ToggleButtonState.HOVER(false), SolidColor(MoonshineColor.GREY_39));
		itemRenderer.alternateBackgroundSkin = alternateBackgroundSkin;

		itemRenderer.textFormat = MoonshineTypography.getLightOnDarkTextFormat();
		itemRenderer.disabledTextFormat = MoonshineTypography.getLightOnDarkDisabledTextFormat();
		itemRenderer.secondaryTextFormat = MoonshineTypography.getLightOnDarkSecondaryTextFormat();
		itemRenderer.disabledSecondaryTextFormat = MoonshineTypography.getLightOnDarkSecondaryDisabledTextFormat();
		// itemRenderer.embedFonts = true;

		itemRenderer.horizontalAlign = LEFT;
		itemRenderer.paddingTop = 4.0;
		itemRenderer.paddingRight = 4.0;
		itemRenderer.paddingBottom = 4.0;
		itemRenderer.paddingLeft = 4.0;
		itemRenderer.gap = 4.0;
	}

	private function setItemRendererLightStyles(itemRenderer:ItemRenderer):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(MoonshineColor.WHITE);
		backgroundSkin.selectedFill = SolidColor(MoonshineColor.GREY_B);
		backgroundSkin.setFillForState(ToggleButtonState.HOVER(false), SolidColor(MoonshineColor.GREY_D));
		itemRenderer.backgroundSkin = backgroundSkin;

		var alternateBackgroundSkin = new RectangleSkin();
		alternateBackgroundSkin.fill = SolidColor(MoonshineColor.GREY_E);
		alternateBackgroundSkin.selectedFill = SolidColor(MoonshineColor.GREY_B);
		alternateBackgroundSkin.setFillForState(ToggleButtonState.HOVER(false), SolidColor(MoonshineColor.GREY_C));
		itemRenderer.alternateBackgroundSkin = alternateBackgroundSkin;

		itemRenderer.textFormat = MoonshineTypography.getGreyTextFormat();
		itemRenderer.disabledTextFormat = MoonshineTypography.getGreyTextFormat();
		itemRenderer.secondaryTextFormat = MoonshineTypography.getGreyTextFormat();
		itemRenderer.disabledSecondaryTextFormat = MoonshineTypography.getGreyTextFormat();
		// itemRenderer.embedFonts = true;

		itemRenderer.horizontalAlign = LEFT;
		itemRenderer.paddingTop = 4.0;
		itemRenderer.paddingRight = 4.0;
		itemRenderer.paddingBottom = 4.0;
		itemRenderer.paddingLeft = 4.0;
		itemRenderer.gap = 4.0;
	}

	private function setLayoutGroupItemRendererStyles(itemRenderer:LayoutGroupItemRenderer):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(MoonshineColor.GREY_4);
		backgroundSkin.selectedFill = SolidColor(MoonshineColor.PINK_2);
		backgroundSkin.setFillForState(ToggleButtonState.HOVER(false), SolidColor(MoonshineColor.GREY_39));
		itemRenderer.backgroundSkin = backgroundSkin;

		var alternateBackgroundSkin = new RectangleSkin();
		alternateBackgroundSkin.fill = SolidColor(MoonshineColor.GREY_4C);
		alternateBackgroundSkin.selectedFill = SolidColor(MoonshineColor.PINK_2);
		alternateBackgroundSkin.setFillForState(ToggleButtonState.HOVER(false), SolidColor(MoonshineColor.GREY_39));
		// TODO: enable with feathersui-beta.9
		// itemRenderer.alternateBackgroundSkin = alternateBackgroundSkin;
	}

	private function setTitleWindowCloseButtonStyles(button:Button):Void {
		var backgroundSkin = new CircleSkin();
		backgroundSkin.border = SolidColor(1.0, MoonshineColor.WHITE);
		backgroundSkin.fill = SolidColor(MoonshineColor.PURPLE, 0.0);
		backgroundSkin.width = 16.0;
		backgroundSkin.height = 16.0;
		button.backgroundSkin = backgroundSkin;

		var icon = new Shape();
		icon.graphics.beginFill(MoonshineColor.PURPLE, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 8.0, 8.0);
		icon.graphics.lineStyle(3.0, MoonshineColor.WHITE, 1.0, true, NORMAL, SQUARE);
		icon.graphics.moveTo(2.0, 2.0);
		icon.graphics.lineTo(6.0, 6.0);
		icon.graphics.moveTo(2.0, 6.0);
		icon.graphics.lineTo(6.0, 2.0);
		button.icon = icon;

		button.horizontalAlign = CENTER;
		button.verticalAlign = MIDDLE;
	}

	private function setLabelStyles(label:Label):Void {
		label.textFormat = MoonshineTypography.getDarkOnLightTextFormat();
		label.disabledTextFormat = MoonshineTypography.getDarkOnLightDisabledTextFormat();
		// label.embedFonts = true;
	}

	private function setLightLabelStyles(label:Label):Void {
		label.textFormat = MoonshineTypography.getLightOnDarkTextFormat();
		label.disabledTextFormat = MoonshineTypography.getLightOnDarkDisabledTextFormat();
		// label.embedFonts = true;
	}

	private function setLightSecondaryLabelStyles(label:Label):Void {
		label.textFormat = MoonshineTypography.getLightOnDarkSecondaryTextFormat();
		label.disabledTextFormat = MoonshineTypography.getLightOnDarkSecondaryDisabledTextFormat();
		// label.embedFonts = true;
	}

	private function setMaroonLabelStyles(label:Label):Void {
		label.textFormat = MoonshineTypography.getMaroonTextFormat();
		// label.embedFonts = true;
	}

	private function setGreyLabelStyles(label:Label):Void {
		label.textFormat = MoonshineTypography.getGreyTextFormat();
		// label.embedFonts = true;
	}

	private function setGreySmallLabelStyles(label:Label):Void {
		label.textFormat = MoonshineTypography.getGreySmallTextFormat();
		// label.embedFonts = true;
	}

	override public function setItalicLabelStyles(label:Label):Void {
		label.textFormat = MoonshineTypography.getTextFormat(MoonshineTypography.DEFAULT_FONT_SIZE, MoonshineColor.GREY_2, false, true);
		label.disabledTextFormat = MoonshineTypography.getTextFormat(MoonshineTypography.DEFAULT_FONT_SIZE, MoonshineColor.GREY_9, false, true);
		// label.embedFonts = true;
	}

	private function setToolTipLabelStyles(toolTip:Label):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(MoonshineColor.GREY_2);
		backgroundSkin.border = SolidColor(1.0, MoonshineColor.BLACK);
		toolTip.backgroundSkin = backgroundSkin;

		toolTip.textFormat = MoonshineTypography.getLightOnDarkTextFormat();
		toolTip.disabledTextFormat = MoonshineTypography.getLightOnDarkDisabledTextFormat();
		// toolTip.embedFonts = true;

		toolTip.paddingTop = 4.0;
		toolTip.paddingRight = 4.0;
		toolTip.paddingBottom = 4.0;
		toolTip.paddingLeft = 4.0;
	}

	private function setListViewStyles(listView:ListView):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(MoonshineColor.GREY_4);
		backgroundSkin.border = SolidColor(1.0, MoonshineColor.GREY_6);
		backgroundSkin.cornerRadius = 0.0;
		backgroundSkin.minWidth = 160.0;
		backgroundSkin.minHeight = 160.0;
		listView.backgroundSkin = backgroundSkin;

		var focusRectSkin = new RectangleSkin();
		focusRectSkin.fill = null;
		focusRectSkin.border = SolidColor(1.0, MoonshineColor.PINK_2);
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

	/*override public function setBorderlessListViewStyles(listView:ListView):Void 
		{
			var backgroundSkin = new RectangleSkin();
			backgroundSkin.fill = SolidColor(0x444444);
			backgroundSkin.border = null;
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
	}*/
	private function setPanelStyles(panel:Panel):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(MoonshineColor.GREY_A0);
		backgroundSkin.border = null;
		backgroundSkin.cornerRadius = 7.0;
		panel.backgroundSkin = backgroundSkin;
	}

	private function setPopUpListViewButtonStyles(button:Button):Void {
		setLightButtonStyles(button);

		button.horizontalAlign = LEFT;
		button.gap = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround
		button.minGap = 6.0;

		if (button.icon == null) {
			var icon = new TriangleSkin();
			icon.pointPosition = BOTTOM;
			icon.fill = SolidColor(MoonshineColor.GREY_5);
			icon.disabledFill = SolidColor(MoonshineColor.GREY_9);
			icon.width = 8.0;
			icon.height = 4.0;
			button.icon = icon;
		}

		button.iconPosition = RIGHT;
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
		layout.gap = 6.0;
		header.layout = layout;
	}

	private function setSideBarViewHeaderTitleStyles(label:Label):Void {
		label.textFormat = MoonshineTypography.getTextFormat(MoonshineTypography.SMALL_FONT_SIZE, MoonshineColor.GREY_2);
		// label.embedFonts = true;
		label.layoutData = new HorizontalLayoutData(100.0);
	}

	private function setSideBarViewHeaderCloseButtonStyles(button:Button):Void {
		var backgroundSkin = new CircleSkin();
		backgroundSkin.border = SolidColor(1.0, MoonshineColor.GREY_4, 0.8);
		backgroundSkin.fill = SolidColor(MoonshineColor.PURPLE, 0.0);
		backgroundSkin.width = 14.0;
		backgroundSkin.height = 14.0;
		button.backgroundSkin = backgroundSkin;

		var icon = new Shape();
		icon.graphics.beginFill(MoonshineColor.PURPLE, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 8.0, 8.0);
		icon.graphics.lineStyle(2.0, MoonshineColor.GREY_4, 0.8, true, NORMAL, SQUARE);
		icon.graphics.moveTo(2.0, 2.0);
		icon.graphics.lineTo(6.0, 6.0);
		icon.graphics.moveTo(2.0, 6.0);
		icon.graphics.lineTo(6.0, 2.0);
		button.icon = icon;

		button.horizontalAlign = CENTER;
		button.verticalAlign = MIDDLE;
	}

	private function setSideBarViewHeaderMenuButtonStyles(button:Button):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.border = None;
		backgroundSkin.fill = SolidColor(MoonshineColor.PURPLE, 0.0);
		backgroundSkin.width = 12.0;
		backgroundSkin.height = 12.0;
		button.backgroundSkin = backgroundSkin;

		var icon = new Shape();
		icon.graphics.lineStyle(2.0, MoonshineColor.GREY_4, 0.8, true, NORMAL, SQUARE);
		icon.graphics.moveTo(1.0, 1.0);
		icon.graphics.lineTo(11.0, 1.0);
		icon.graphics.moveTo(1.0, 6.0);
		icon.graphics.lineTo(11.0, 6.0);
		icon.graphics.moveTo(1.0, 11.0);
		icon.graphics.lineTo(11.0, 11.0);
		button.icon = icon;

		button.horizontalAlign = CENTER;
		button.verticalAlign = MIDDLE;
	}

	private function setMenuListViewStyles(listView:ListView):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(MoonshineColor.GREY_4C);
		backgroundSkin.border = SolidColor(1.0, MoonshineColor.GREY_6);
		backgroundSkin.minWidth = 260.0;
		backgroundSkin.minHeight = 10.0;
		backgroundSkin.cornerRadius = 10.0;
		listView.backgroundSkin = backgroundSkin;

		var maskSkin = new RectangleSkin();
		maskSkin.fill = SolidColor(MoonshineColor.PURPLE);
		maskSkin.cornerRadius = 6.0;
		listView.viewPortMaskSkin = maskSkin;

		var focusRectSkin = new RectangleSkin();
		focusRectSkin.fill = null;
		focusRectSkin.border = SolidColor(1.0, MoonshineColor.PINK_2);
		focusRectSkin.cornerRadius = 10.0;
		listView.focusRectSkin = focusRectSkin;

		var layout = new VerticalListLayout();
		layout.requestedMinRowCount = 1;
		listView.layout = layout;

		listView.setPadding(6.0);

		listView.fixedScrollBars = true;

		listView.filters = [new DropShadowFilter(3, 60, MoonshineColor.BLACK, 0.45, 6.0, 6.0)];

		listView.customItemRendererVariant = THEME_VARIANT_MENU_ITEM_RENDERER;
	}

	private function setMenuItemRendererStyles(itemRenderer:ItemRenderer):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(MoonshineColor.GREY_4C, 0.0);
		backgroundSkin.selectedFill = SolidColor(MoonshineColor.PINK_2);
		backgroundSkin.setFillForState(ToggleButtonState.HOVER(false), SolidColor(MoonshineColor.PINK_2));
		backgroundSkin.cornerRadius = 6.0;
		itemRenderer.backgroundSkin = backgroundSkin;

		itemRenderer.textFormat = MoonshineTypography.getLightOnDarkTextFormat();
		itemRenderer.disabledTextFormat = MoonshineTypography.getLightOnDarkDisabledTextFormat();
		itemRenderer.secondaryTextFormat = MoonshineTypography.getLightOnDarkSecondaryTextFormat();
		itemRenderer.disabledSecondaryTextFormat = MoonshineTypography.getLightOnDarkSecondaryDisabledTextFormat();

		itemRenderer.horizontalAlign = LEFT;
		itemRenderer.paddingTop = 4.0;
		itemRenderer.paddingRight = 6.0;
		itemRenderer.paddingBottom = 4.0;
		itemRenderer.paddingLeft = 6.0;
		itemRenderer.gap = 4.0;
	}

	private function setStandardPopupViewStyles(view:LayoutGroup):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(MoonshineColor.GREY_F9);
		backgroundSkin.cornerRadius = 0.0;
		view.backgroundSkin = backgroundSkin;

		view.filters = [new GlowFilter(MoonshineColor.BLACK, 0.3, 6, 6, 2)];
	}

	private function setTitleWindowStyles(window:TitleWindow):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(MoonshineColor.GREY_A0);
		backgroundSkin.border = SolidColor(1.0, MoonshineColor.GREY_29);
		backgroundSkin.cornerRadius = 7.0;
		window.backgroundSkin = backgroundSkin;

		if (Std.isOfType(window, ResizableTitleWindow)) {
			var resizableWindow = cast(window, ResizableTitleWindow);

			var resizeHandleSkin = new Shape();
			resizeHandleSkin.graphics.beginFill(MoonshineColor.PURPLE, 0.0);
			resizeHandleSkin.graphics.drawRect(0.0, 0.0, 16.0, 16.0);
			resizeHandleSkin.graphics.endFill();

			resizeHandleSkin.graphics.lineStyle(1.0, MoonshineColor.GREY_A6, 1.0, true, NORMAL, SQUARE);
			resizeHandleSkin.graphics.moveTo(2.0, 14.0);
			resizeHandleSkin.graphics.lineTo(14.0, 2.0);
			resizeHandleSkin.graphics.moveTo(6.0, 14.0);
			resizeHandleSkin.graphics.lineTo(14.0, 6.0);
			resizeHandleSkin.graphics.moveTo(10.0, 14.0);
			resizeHandleSkin.graphics.lineTo(14.0, 10.0);

			resizeHandleSkin.graphics.lineStyle(1.0, MoonshineColor.GREY_29, 1.0, true, NORMAL, SQUARE);
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
		label.textFormat = MoonshineTypography.getTextFormat(MoonshineTypography.DEFAULT_FONT_SIZE, MoonshineColor.GREY_2, true);
		// label.embedFonts = true;
	}

	private function setBusyLabelStyles(label:Label):Void {
		label.textFormat = MoonshineTypography.getTextFormat(MoonshineTypography.DEFAULT_FONT_SIZE, MoonshineColor.WHITE);
		// label.embedFonts = true;
	}

	private function setPluginLargeTitleStyles(label:Label):Void {
		label.textFormat = MoonshineTypography.getTextFormat(MoonshineTypography.FONT_SIZE_22, MoonshineColor.PINK);
		// label.embedFonts = true;
	}

	private function setTitleWindowControlBarStyles(controlBar:LayoutGroup):Void {
		controlBar.backgroundSkin = new MoonshineControlBarSkin();

		var layout = new HorizontalLayout();
		layout.horizontalAlign = RIGHT;
		layout.verticalAlign = MIDDLE;
		layout.paddingTop = 10.0;
		layout.paddingRight = 10.0;
		layout.paddingBottom = 10.0;
		layout.paddingLeft = 10.0;
		layout.gap = 4.0;
		controlBar.layout = layout;
	}

	private function setToolBarLayoutGroupStyles(group:LayoutGroup):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(MoonshineColor.GREY_4);
		backgroundSkin.cornerRadius = 7.0;
		group.backgroundSkin = backgroundSkin;

		var layout = new HorizontalLayout();
		layout.horizontalAlign = RIGHT;
		layout.verticalAlign = MIDDLE;
		layout.paddingTop = 10.0;
		layout.paddingRight = 10.0;
		layout.paddingBottom = 10.0;
		layout.paddingLeft = 10.0;
		layout.gap = 4.0;
		group.layout = layout;
	}

	private function setWarningBarLayoutGroupStyles(group:LayoutGroup):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(MoonshineColor.LIGHT_YELLOW);
		backgroundSkin.cornerRadius = 4.0;
		group.backgroundSkin = backgroundSkin;

		var layout = new HorizontalLayout();
		layout.horizontalAlign = LEFT;
		layout.verticalAlign = MIDDLE;
		layout.paddingTop = 10.0;
		layout.paddingRight = 10.0;
		layout.paddingBottom = 10.0;
		layout.paddingLeft = 10.0;
		layout.gap = 4.0;
		group.layout = layout;
	}

	override public function setTextInputStyles(textInput:TextInput):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(MoonshineColor.GREY_46);
		backgroundSkin.border = SolidColor(1.0, MoonshineColor.GREY_6);
		backgroundSkin.setBorderForState(TextInputState.FOCUSED, SolidColor(1.0, MoonshineColor.PINK_2));
		backgroundSkin.cornerRadius = 0.0;
		textInput.backgroundSkin = backgroundSkin;

		textInput.textFormat = MoonshineTypography.getLightOnDarkTextFormat();
		textInput.promptTextFormat = MoonshineTypography.getTextFormat(MoonshineTypography.DEFAULT_FONT_SIZE, MoonshineColor.GREY_A6);
		textInput.setTextFormatForState(DISABLED, MoonshineTypography.getLightOnDarkDisabledTextFormat());
		// textInput.embedFonts = true;

		textInput.paddingTop = 5.0;
		textInput.paddingRight = 5.0;
		textInput.paddingBottom = 5.0;
		textInput.paddingLeft = 5.0;
	}

	private function setTreeViewStyles(treeView:TreeView):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(MoonshineColor.GREY_4);
		backgroundSkin.border = SolidColor(1.0, MoonshineColor.GREY_6);
		backgroundSkin.cornerRadius = 0.0;
		backgroundSkin.minWidth = 160.0;
		backgroundSkin.minHeight = 160.0;
		treeView.backgroundSkin = backgroundSkin;

		var focusRectSkin = new RectangleSkin();
		focusRectSkin.fill = null;
		focusRectSkin.border = SolidColor(1.0, MoonshineColor.PINK_2);
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
		backgroundSkin.fill = SolidColor(MoonshineColor.GREY_4);
		backgroundSkin.border = null;
		backgroundSkin.cornerRadius = 0.0;
		backgroundSkin.minWidth = 160.0;
		backgroundSkin.minHeight = 160.0;
		treeView.backgroundSkin = backgroundSkin;

		var focusRectSkin = new RectangleSkin();
		focusRectSkin.fill = null;
		focusRectSkin.border = SolidColor(1.0, MoonshineColor.PINK_2);
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

	private function setHierarchicalItemRendererStyles(itemRenderer:HierarchicalItemRenderer):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(MoonshineColor.GREY_4);
		backgroundSkin.selectedFill = SolidColor(MoonshineColor.PINK_2);
		backgroundSkin.setFillForState(ToggleButtonState.HOVER(false), SolidColor(MoonshineColor.GREY_39));
		itemRenderer.backgroundSkin = backgroundSkin;

		var alternateBackgroundSkin = new RectangleSkin();
		alternateBackgroundSkin.fill = SolidColor(MoonshineColor.GREY_4C);
		alternateBackgroundSkin.selectedFill = SolidColor(MoonshineColor.PINK_2);
		alternateBackgroundSkin.setFillForState(ToggleButtonState.HOVER(false), SolidColor(MoonshineColor.GREY_39));
		itemRenderer.alternateBackgroundSkin = alternateBackgroundSkin;

		itemRenderer.textFormat = MoonshineTypography.getLightOnDarkTextFormat();
		itemRenderer.disabledTextFormat = MoonshineTypography.getLightOnDarkDisabledTextFormat();
		itemRenderer.secondaryTextFormat = MoonshineTypography.getLightOnDarkSecondaryTextFormat();
		itemRenderer.disabledSecondaryTextFormat = MoonshineTypography.getLightOnDarkSecondaryDisabledTextFormat();
		// itemRenderer.embedFonts = true;

		itemRenderer.horizontalAlign = LEFT;
		itemRenderer.paddingTop = 4.0;
		itemRenderer.paddingRight = 4.0;
		itemRenderer.paddingBottom = 4.0;
		itemRenderer.paddingLeft = 4.0;
		itemRenderer.gap = 4.0;
		itemRenderer.indentation = 12.0;
	}

	private function setTourDeFlexHierarchicalItemRendererItemRendererStyles(itemRenderer:TourDeFlexHierarchicalItemRenderer):Void {
		this.setHierarchicalItemRendererStyles(itemRenderer);

		var activeFileIndicator = new Shape();
		activeFileIndicator.graphics.clear();
		activeFileIndicator.graphics.beginFill(MoonshineColor.PINK);
		activeFileIndicator.graphics.drawCircle(2.0, 2.0, 2.0);
		activeFileIndicator.graphics.endFill();
		activeFileIndicator.filters = [new GlowFilter(MoonshineColor.PINK_3, 0.4, 6, 6, 2)];
		itemRenderer.activeFileIndicator = activeFileIndicator;
	}

	private function setHierarchicalItemRendererDisclosureButtonStyles(button:ToggleButton):Void {
		var icon = new Shape();
		icon.graphics.beginFill(MoonshineColor.PURPLE, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 12.0, 12.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(MoonshineColor.DARK_TEAL);
		icon.graphics.moveTo(2.0, 2.0);
		icon.graphics.lineTo(10.0, 6.0);
		icon.graphics.lineTo(2.0, 10.0);
		icon.graphics.lineTo(2.0, 2.0);
		icon.graphics.endFill();
		button.icon = icon;

		var selectedIcon = new Shape();
		selectedIcon.graphics.beginFill(MoonshineColor.PURPLE, 0.0);
		selectedIcon.graphics.drawRect(0.0, 0.0, 12.0, 12.0);
		selectedIcon.graphics.endFill();
		selectedIcon.graphics.beginFill(MoonshineColor.DARK_TEAL);
		selectedIcon.graphics.moveTo(2.0, 2.0);
		selectedIcon.graphics.lineTo(10.0, 2.0);
		selectedIcon.graphics.lineTo(6.0, 10.0);
		selectedIcon.graphics.lineTo(2.0, 2.0);
		selectedIcon.graphics.endFill();
		button.selectedIcon = selectedIcon;
	}

	private function setImageLargeRefreshStyles(layout:Button):Void {
		var refreshIconBitmap = new RefreshIcon(cast(layout.width, Int), cast(layout.height, Int));
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = Bitmap(refreshIconBitmap, new Matrix(), false);
		backgroundSkin.width = layout.width;
		backgroundSkin.height = layout.height;

		layout.backgroundSkin = backgroundSkin;
	}

	private function setTreeGridViewStyles(treeGridView:TreeGridView):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(MoonshineColor.GREY_4);
		backgroundSkin.border = SolidColor(1.0, MoonshineColor.GREY_6);
		backgroundSkin.cornerRadius = 0.0;
		backgroundSkin.minWidth = 160.0;
		backgroundSkin.minHeight = 160.0;
		treeGridView.backgroundSkin = backgroundSkin;

		var columnResizeSkin = new RectangleSkin(SolidColor(MoonshineColor.PINK_2), null);
		columnResizeSkin.width = 2.0;
		columnResizeSkin.height = 2.0;
		treeGridView.columnResizeSkin = columnResizeSkin;

		var focusRectSkin = new RectangleSkin();
		focusRectSkin.fill = null;
		focusRectSkin.border = SolidColor(1.0, MoonshineColor.PINK_2);
		treeGridView.focusRectSkin = focusRectSkin;

		var layout = new VerticalListLayout();
		layout.requestedRowCount = 5;
		treeGridView.layout = layout;

		treeGridView.fixedScrollBars = true;
	}

	private function setBorderlessTreeGridViewStyles(treeGridView:TreeGridView):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(MoonshineColor.GREY_4);
		backgroundSkin.border = null;
		backgroundSkin.cornerRadius = 0.0;
		backgroundSkin.minWidth = 160.0;
		backgroundSkin.minHeight = 160.0;
		treeGridView.backgroundSkin = backgroundSkin;

		var columnResizeSkin = new RectangleSkin(SolidColor(MoonshineColor.PINK_2), null);
		columnResizeSkin.width = 2.0;
		columnResizeSkin.height = 2.0;
		treeGridView.columnResizeSkin = columnResizeSkin;

		var focusRectSkin = new RectangleSkin();
		focusRectSkin.fill = null;
		focusRectSkin.border = SolidColor(1.0, MoonshineColor.PINK_2);
		treeGridView.focusRectSkin = focusRectSkin;

		var layout = new VerticalListLayout();
		layout.requestedRowCount = 5;
		treeGridView.layout = layout;

		treeGridView.fixedScrollBars = true;
	}

	private function setDebugAdapterViewStyles(view:DebugAdapterView):Void {
		var backgroundSkin = new RectangleSkin();
		backgroundSkin.fill = SolidColor(MoonshineColor.GREY_4);
		backgroundSkin.border = None;
		view.backgroundSkin = backgroundSkin;
	}

	private function setHDividedBoxStyles(dividedBox:HDividedBox):Void {
		dividedBox.dividerFactory = () -> {
			var divider = new BasicButton();
			divider.keepDownStateOnRollOut = true;
			var backgroundSkin = new RectangleSkin();
			backgroundSkin.fill = SolidColor(MoonshineColor.GREY_29);
			backgroundSkin.setFillForState(ButtonState.HOVER, SolidColor(MoonshineColor.GREY_F3));
			backgroundSkin.setFillForState(ButtonState.DOWN, SolidColor(MoonshineColor.PINK_2));
			backgroundSkin.border = None;
			backgroundSkin.width = 2.0;
			backgroundSkin.height = 2.0;
			divider.backgroundSkin = backgroundSkin;
			return divider;
		};
	}

	private function setDebugPlayButtonStyles(button:Button):Void {
		setDarkButtonStyles(button);

		button.icon = new Bitmap(new DebugPlayIcon());
		var disabledIcon = new Bitmap(new DebugPlayIcon());
		disabledIcon.alpha = 0.5;
		button.setIconForState(DISABLED, disabledIcon);

		button.setPadding(6.0);
	}

	private function setDebugPauseButtonStyles(button:Button):Void {
		setDarkButtonStyles(button);

		button.icon = new Bitmap(new DebugPauseIcon());
		var disabledIcon = new Bitmap(new DebugPauseIcon());
		disabledIcon.alpha = 0.5;
		button.setIconForState(DISABLED, disabledIcon);

		button.setPadding(6.0);
	}

	private function setDebugStepOverButtonStyles(button:Button):Void {
		setDarkButtonStyles(button);

		button.icon = new Bitmap(new DebugStepOverIcon());
		var disabledIcon = new Bitmap(new DebugStepOverIcon());
		disabledIcon.alpha = 0.5;
		button.setIconForState(DISABLED, disabledIcon);

		button.setPadding(6.0);
	}

	private function setDebugStepIntoButtonStyles(button:Button):Void {
		setDarkButtonStyles(button);

		button.icon = new Bitmap(new DebugStepIntoIcon());
		var disabledIcon = new Bitmap(new DebugStepIntoIcon());
		disabledIcon.alpha = 0.5;
		button.setIconForState(DISABLED, disabledIcon);

		button.setPadding(6.0);
	}

	private function setDebugStepOutButtonStyles(button:Button):Void {
		setDarkButtonStyles(button);

		button.icon = new Bitmap(new DebugStepOutIcon());
		var disabledIcon = new Bitmap(new DebugStepOutIcon());
		disabledIcon.alpha = 0.5;
		button.setIconForState(DISABLED, disabledIcon);

		button.setPadding(6.0);
	}

	private function setDebugStopButtonStyles(button:Button):Void {
		setDarkButtonStyles(button);

		button.icon = new Bitmap(new DebugStopIcon());
		var disabledIcon = new Bitmap(new DebugStopIcon());
		disabledIcon.alpha = 0.5;
		button.setIconForState(DISABLED, disabledIcon);

		button.setPadding(6.0);
	}

	private function setMiniDebugPlayButtonStyles(button:Button):Void {
		setDarkButtonStyles(button);

		var icon = new Bitmap(new DebugPlayIcon());
		icon.width = 8.0;
		icon.height = 8.0;
		button.icon = icon;
		var disabledIcon = new Bitmap(new DebugPlayIcon());
		disabledIcon.scaleX = 0.5;
		disabledIcon.scaleY = 0.5;
		disabledIcon.alpha = 0.5;
		button.setIconForState(DISABLED, disabledIcon);

		button.setPadding(6.0);
	}

	private function setMiniDebugPauseButtonStyles(button:Button):Void {
		setDarkButtonStyles(button);

		var icon = new Bitmap(new DebugPauseIcon());
		icon.scaleX = 0.5;
		icon.scaleY = 0.5;
		button.icon = icon;
		var disabledIcon = new Bitmap(new DebugPauseIcon());
		disabledIcon.scaleX = 0.5;
		disabledIcon.scaleY = 0.5;
		disabledIcon.alpha = 0.5;
		button.setIconForState(DISABLED, disabledIcon);

		button.setPadding(6.0);
	}

	private function setMiniDebugStepOverButtonStyles(button:Button):Void {
		setDarkButtonStyles(button);

		var icon = new Bitmap(new DebugStepOverIcon());
		icon.scaleX = 0.5;
		icon.scaleY = 0.5;
		button.icon = icon;
		var disabledIcon = new Bitmap(new DebugStepOverIcon());
		disabledIcon.scaleX = 0.5;
		disabledIcon.scaleY = 0.5;
		disabledIcon.alpha = 0.5;
		button.setIconForState(DISABLED, disabledIcon);

		button.setPadding(6.0);
	}

	private function setMiniDebugStepIntoButtonStyles(button:Button):Void {
		setDarkButtonStyles(button);

		var icon = new Bitmap(new DebugStepIntoIcon());
		icon.scaleX = 0.5;
		icon.scaleY = 0.5;
		button.icon = icon;
		var disabledIcon = new Bitmap(new DebugStepIntoIcon());
		disabledIcon.scaleX = 0.5;
		disabledIcon.scaleY = 0.5;
		disabledIcon.alpha = 0.5;
		button.setIconForState(DISABLED, disabledIcon);

		button.setPadding(6.0);
	}

	private function setMiniDebugStepOutButtonStyles(button:Button):Void {
		setDarkButtonStyles(button);

		var icon = new Bitmap(new DebugStepOutIcon());
		icon.scaleX = 0.5;
		icon.scaleY = 0.5;
		button.icon = icon;
		var disabledIcon = new Bitmap(new DebugStepOutIcon());
		disabledIcon.scaleX = 0.5;
		disabledIcon.scaleY = 0.5;
		disabledIcon.alpha = 0.5;
		button.setIconForState(DISABLED, disabledIcon);

		button.setPadding(6.0);
	}

	private function setMiniDebugStopButtonStyles(button:Button):Void {
		setDarkButtonStyles(button);

		var icon = new Bitmap(new DebugStopIcon());
		icon.scaleX = 0.5;
		icon.scaleY = 0.5;
		button.icon = icon;
		var disabledIcon = new Bitmap(new DebugStopIcon());
		disabledIcon.scaleX = 0.5;
		disabledIcon.scaleY = 0.5;
		disabledIcon.alpha = 0.5;
		button.setIconForState(DISABLED, disabledIcon);

		button.setPadding(6.0);
	}

	private function setHProgressBarStyles(progressBar:HProgressBar):Void {
		if (progressBar.fillSkin == null) {
			var fillSkin = new RectangleSkin();
			fillSkin.fill = SolidColor(MoonshineColor.PINK_2);
			fillSkin.border = SolidColor(1.0, MoonshineColor.GREY_46);
			fillSkin.cornerRadius = 8.0;
			fillSkin.width = 8.0;
			fillSkin.height = 8.0;
			progressBar.fillSkin = fillSkin;
		}

		if (progressBar.backgroundSkin == null) {
			var backgroundSkin = new RectangleSkin();
			backgroundSkin.fill = SolidColor(MoonshineColor.GREY_6);
			backgroundSkin.border = SolidColor(1.0, MoonshineColor.GREY_46);
			backgroundSkin.cornerRadius = 8.0;
			backgroundSkin.width = 200.0;
			backgroundSkin.height = 8.0;
			progressBar.backgroundSkin = backgroundSkin;
		}
	}

	private function setVProgressBarStyles(progressBar:VProgressBar):Void {
		if (progressBar.fillSkin == null) {
			var fillSkin = new RectangleSkin();
			fillSkin.fill = SolidColor(MoonshineColor.PINK_2);
			fillSkin.border = SolidColor(1.0, MoonshineColor.GREY_46);
			fillSkin.cornerRadius = 8.0;
			fillSkin.width = 8.0;
			fillSkin.height = 8.0;
			progressBar.fillSkin = fillSkin;
		}

		if (progressBar.backgroundSkin == null) {
			var backgroundSkin = new RectangleSkin();
			backgroundSkin.fill = SolidColor(MoonshineColor.GREY_6);
			backgroundSkin.border = SolidColor(1.0, MoonshineColor.GREY_46);
			backgroundSkin.cornerRadius = 8.0;
			backgroundSkin.width = 8.0;
			backgroundSkin.height = 200.0;
			progressBar.backgroundSkin = backgroundSkin;
		}
	}

	private function setHorizontalDividerLayoutGroupStyles(layoutGroup:LayoutGroup):Void {
		layoutGroup.height = 1;
		layoutGroup.backgroundSkin = new RectangleSkin(FillStyle.SolidColor(MoonshineColor.GREY_9));
		layoutGroup.layoutData = new VerticalLayoutData( 100 );
	}

	private function setTabBarToggleButtonStyles(button:ToggleButton):Void {
		var greySkin = new RectangleSkin(FillStyle.SolidColor(MoonshineColor.GREY_4));
		var maroonSkin = new RectangleSkin(FillStyle.SolidColor(MoonshineColor.MAROON));

		button.setSkinForState(ToggleButtonState.UP(false), greySkin);
		button.setSkinForState(ToggleButtonState.UP(true), maroonSkin);
		button.setSkinForState(ToggleButtonState.DOWN(false), maroonSkin);
		button.setSkinForState(ToggleButtonState.DOWN(true), maroonSkin);
		button.setSkinForState(ToggleButtonState.HOVER(false), greySkin);
		button.setSkinForState(ToggleButtonState.HOVER(true), maroonSkin);

		button.textFormat = MoonshineTypography.getTextFormat( MoonshineTypography.SMALL_FONT_SIZE, MoonshineColor.WHITE );
		button.paddingLeft = button.paddingRight = 8;
		button.paddingTop = button.paddingBottom = 3;
	}

	private function setLightGridViewTabbarStyles(tabbar:TabBar):Void {

		//
		// An NPE bug in FeathersUI doesn't allow customizing the style of TabBar
		// tabbar.backgroundSkin = new RectangleSkin(FillStyle.SolidColor(MoonshineColor.WHITE));
		//

	}

	private function setLightTabNavigatorStyles(navigator:TabNavigator):Void {

		navigator.tabBarFactory = () -> {

            var tb:TabBar = new TabBar();
            var lyt = new HorizontalLayout();
            lyt.gap = 1;
            tb.layout = lyt;
            tb.backgroundSkin = new RectangleSkin( FillStyle.SolidColor( MoonshineColor.WHITE ) );
            return tb;

        };

	}

}
