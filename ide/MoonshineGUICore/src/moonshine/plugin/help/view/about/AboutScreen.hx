package moonshine.plugin.help.view.about;

import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.SettingsEvent;
import actionScripts.locator.HelperModel;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.console.ConsoleOutputEvent;
import actionScripts.plugins.externalEditors.ExternalEditorsPlugin;
import actionScripts.plugins.externalEditors.vo.ExternalEditorVO;
import actionScripts.plugins.startup.StartupHelperPlugin;
import actionScripts.utils.FileUtils;
import actionScripts.utils.SDKUtils;
import actionScripts.utils.SoftwareVersionChecker;
import actionScripts.valueObjects.ComponentTypes;
import actionScripts.valueObjects.ComponentVO;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.SDKReferenceVO;
import components.popup.InfoBackgroundPopup;
import feathers.controls.AssetLoader;
import feathers.controls.Button;
import feathers.controls.GridView;
import feathers.controls.GridViewColumn;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.ToggleButtonState;
import feathers.controls.dataRenderers.LayoutGroupItemRenderer;
import feathers.controls.navigators.TabItem;
import feathers.data.ArrayCollection;
import feathers.data.GridViewCellState;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.RelativePosition;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import feathers.skins.RectangleSkin;
import feathers.utils.DisplayObjectRecycler;
import flash.desktop.NativeApplication;
import haxe.xml.Access;
import moonshine.components.HDivider;
import moonshine.components.MoonshineTabNavigator;
import moonshine.theme.MoonshineColor;
import moonshine.theme.MoonshineTheme;
import moonshine.theme.MoonshineTypography;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import openfl.desktop.Clipboard;
import openfl.desktop.ClipboardFormats;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.system.Capabilities;

using moonshine.utils.data.ArrayCollectionUtil;

@:styleContext
class AboutScreen extends LayoutGroup {
	//
	// Static properties
	//
	//
	// Private vars
	//
	var _aboutLabel1:Label;
	var _aboutLabel2:Label;
	var _aboutLabel3:Label;
	var _assetLoader:AssetLoader;
	var _bottomGroup:LayoutGroup;
	var _bottomGroupLabel:Label;
	var _bottomGroupLabel2:Label;
	var _bottomGroupLayout:VerticalLayout;
	var _contentGroup:LayoutGroup;
	var _contentGroupLayout:VerticalLayout;
	var _copyButton:Button;
	var _copyIconLoader:AssetLoader;
	var _editorComponents:ArrayCollection<ExternalEditorVO>;
	var _editorGrid:EditorGrid;
	var _editorVersionChecker:SoftwareVersionChecker;
	var _hDivider:HDivider;
	var _header:LayoutGroup;
	var _headerLayout:HorizontalLayout;
	var _headerMiddle:LayoutGroup;
	var _headerMiddleLayout:VerticalLayout;
	var _model:IDEModel;
	var _navigator:MoonshineTabNavigator;
	var _screen:LayoutGroup;
	var _screenLayout:VerticalLayout;
	var _sdkComponents:ArrayCollection<ComponentVO>;
	var _sdkGrid:SDKGrid;
	var _softwareVersionChecker:SoftwareVersionChecker;
	var _tabs:ArrayCollection<TabItem>;
	var _infoBackground:InfoBackgroundPopup;

	//
	// Public vars
	//
	public var isChanged(get, never):Bool;
	public var isEmpty(get, never):Bool;
	public var label(get, never):String;
	public var longLabel(get, never):String;

	//
	// Getters, Setters
	//

	function get_isChanged():Bool
		return false;

	function get_isEmpty():Bool
		return false;

	function get_label():String
		return "About Moonshine";

	function get_longLabel():String
		return "About Moonshine";

	//
	// Public methods
	//

	public function new() {
		MoonshineTheme.initializeTheme();
		super();
	}

	override function initialize() {
		super.initialize();

		this.layout = new AnchorLayout();

		this.backgroundSkin = new RectangleSkin(FillStyle.SolidColor(0xFFFFFF));

		_screenLayout = new VerticalLayout();
		_screenLayout.paddingTop = 20;
		_screenLayout.horizontalAlign = HorizontalAlign.CENTER;
		this.layout = _screenLayout;

		_contentGroupLayout = new VerticalLayout();
		_contentGroupLayout.gap = 10;

		_contentGroup = new LayoutGroup();
		_contentGroup.backgroundSkin = new RectangleSkin(FillStyle.SolidColor(0xFFFFFF));
		_contentGroup.layoutData = new VerticalLayoutData(80, 100);
		_contentGroup.layout = _contentGroupLayout;

		_headerLayout = new HorizontalLayout();
		_headerLayout.verticalAlign = VerticalAlign.MIDDLE;
		_headerLayout.gap = 10;

		_header = new LayoutGroup();
		_header.layoutData = new VerticalLayoutData(100);
		_header.layout = _headerLayout;

		_assetLoader = new AssetLoader(MoonshineTheme.ASSET_LOGO);
		_header.addChild(_assetLoader);

		_headerMiddleLayout = new VerticalLayout();
		_headerMiddleLayout.verticalAlign = VerticalAlign.MIDDLE;
		_headerMiddle = new LayoutGroup();
		_headerMiddle.layoutData = new HorizontalLayoutData(100, 100);
		_headerMiddle.layout = _headerMiddleLayout;
		_header.addChild(_headerMiddle);

		_aboutLabel1 = new Label(ConstantsCoreVO.MOONSHINE_IDE_LABEL);
		_aboutLabel1.variant = MoonshineTheme.THEME_VARIANT_MAROON_LABEL;
		_headerMiddle.addChild(_aboutLabel1);

		_aboutLabel2 = new Label();
		_aboutLabel2.variant = MoonshineTheme.THEME_VARIANT_GREY_LABEL;
		_headerMiddle.addChild(_aboutLabel2);

		_aboutLabel3 = new Label();
		_aboutLabel3.variant = MoonshineTheme.THEME_VARIANT_GREY_SMALL_LABEL;
		_headerMiddle.addChild(_aboutLabel3);

		_copyIconLoader = new AssetLoader(MoonshineTheme.ASSET_COPY_ICON);

		_copyButton = new Button();
		_copyButton.toolTip = "Copy Moonshine About Information";
		// _copyButton.setPadding( 0 );
		_copyButton.icon = _copyIconLoader;
		_copyButton.addEventListener(TriggerEvent.TRIGGER, copyInfoToClipboard);
		_header.addChild(_copyButton);

		_contentGroup.addChild(_header);

		_hDivider = new HDivider();
		_contentGroup.addChild(_hDivider);

		_sdkGrid = new SDKGrid();
		_sdkGrid.enabled = false;
		_sdkGrid.alpha = .5;
		_editorGrid = new EditorGrid();
		_editorGrid.enabled = false;
		_editorGrid.alpha = .5;

		_tabs = new ArrayCollection<TabItem>();
		var tabItem = TabItem.withDisplayObject("Configured SDKs", _sdkGrid);
		_tabs.add(tabItem);
		var tabItem = TabItem.withDisplayObject("External Editors", _editorGrid);
		_tabs.add(tabItem);

		_navigator = new MoonshineTabNavigator();
		_navigator.layoutData = new VerticalLayoutData(100, 100);
		_navigator.dataProvider = _tabs;
		_navigator.tabBarPosition = RelativePosition.BOTTOM;

		_contentGroup.addChild(_navigator);

		_bottomGroupLayout = new VerticalLayout();
		_bottomGroupLayout.horizontalAlign = HorizontalAlign.CENTER;
		_bottomGroupLayout.setPadding(10);
		_bottomGroup = new LayoutGroup();
		_bottomGroup.layout = _bottomGroupLayout;
		_bottomGroup.layoutData = new VerticalLayoutData(100);

		_bottomGroupLabel = new Label("About the background image");
		_bottomGroupLabel.textFormat = MoonshineTypography.getTextFormat(MoonshineTypography.SECONDARY_FONT_SIZE, MoonshineColor.MAROON, false, false, true);
		_bottomGroupLabel.useHandCursor = _bottomGroupLabel.buttonMode = _bottomGroupLabel.mouseEnabled = true;
		_bottomGroupLabel.mouseChildren = false;
		_bottomGroupLabel.addEventListener(MouseEvent.CLICK, bottomGroupLabelClicked);
		_bottomGroup.addChild(_bottomGroupLabel);

		_bottomGroupLabel2 = new Label(ConstantsCoreVO.MOONSHINE_IDE_COPYRIGHT_LABEL);
		_bottomGroupLabel2.textFormat = MoonshineTypography.getTextFormat(MoonshineTypography.SECONDARY_FONT_SIZE);
		_bottomGroup.addChild(_bottomGroupLabel2);

		_contentGroup.addChild(_bottomGroup);

		this.addChild(_contentGroup);

		_model = IDEModel.getInstance();
	}

	override function layoutGroup_addedToStageHandler(event:Event) {
		super.layoutGroup_addedToStageHandler(event);

		getSDKs();
		getEditors();
	}

	function copyInfoToClipboard(e:TriggerEvent) {
		var aboutInformation:String = ConstantsCoreVO.MOONSHINE_IDE_LABEL + "\n" + getAIRVersion() + "\n" + getOS() + "\n\n";

		var versions:String = "Configured SDKs in Moonshine:\n===========================================\n\n";
		for (component in _sdkComponents) {
			versions += component.title + ": " + ((component.version != null) ? component.version : "Not Installed") + "\n";
		}

		versions += "\nConfigured External Editors in Moonshine:\n===========================================\n\n";
		for (component in _editorComponents) {
			versions += component.title
				+ ": "
				+ ((component.version != null) ? component.version : "Not Installed")
				+ " ["
				+ ((component.isEnabled) ? "Enabled" : "Disabled")
				+ "]\n";
		}

		aboutInformation += versions;
		Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, aboutInformation);
		GlobalEventDispatcher.getInstance()
			.dispatchEvent(new ConsoleOutputEvent(ConsoleOutputEvent.CONSOLE_PRINT, "Copied Moonshine About information to clipboard.", false, false,
				ConsoleOutputEvent.TYPE_SUCCESS));
	}

	override function feathersControl_addedToStageHandler(event:Event) {
		super.feathersControl_addedToStageHandler(event);

		_aboutLabel2.text = getAIRVersion();
		_aboutLabel3.text = getOS();
	}

	function getAIRVersion():String {
		var versionString:String = IDEModel.getInstance().getVersionWithBuildNumber();
		if (ConstantsCoreVO.IS_MACOS && ConstantsCoreVO.IS_APP_STORE_VERSION)
			versionString += " (App Store Version)";

		var applicationDescriptorString:String = NativeApplication.nativeApplication.applicationDescriptor.toXMLString();
		var applicationDescriptor:Xml = Xml.parse(applicationDescriptorString);
		var applicationDescriptorAccess:Access = new Access(applicationDescriptor);
		var applicationNode = applicationDescriptorAccess.node.application;

		if (applicationNode.has.xmlns) {
			var nameSpace = applicationNode.att.xmlns;
			var namespaceArraySplit:Array<String> = nameSpace.split("/");
			var airVersion:Float = Std.parseFloat(namespaceArraySplit[namespaceArraySplit.length - 1]);
			var isHarman:Bool = airVersion > 32;
			versionString += ", Player: " + airVersion + "(" + (isHarman ? "Harman" : "Adobe") + ")";
		}

		return versionString;
	}

	function getOS():String {
		return "Running on: " + Capabilities.os;
	}

	function getSDKs() {
		_softwareVersionChecker = new SoftwareVersionChecker();

		_sdkComponents = new ArrayCollection<ComponentVO>();

		for (component in HelperModel.getInstance().components) {
			var cloned = component.clone();
			// cloned.addEventListener(ComponentVO.EVENT_UPDATED, componentUpdated);
			_sdkComponents.add(cloned);
		}

		updateSDKWithMoonshinePaths();

		var tmpAddition:ComponentVO = new ComponentVO();
		tmpAddition.title = "Default SDK";
		if (_model.defaultSDK != null && _model.defaultSDK.fileBridge.exists) {
			var sdkReference:SDKReferenceVO = SDKUtils.getSDKFromSavedList(_model.defaultSDK.fileBridge.nativePath);
			tmpAddition.type = sdkReference.type;
			tmpAddition.installToPath = sdkReference.path;
			// tmpAddition.addEventListener(ComponentVO.EVENT_UPDATED, componentUpdated);
		}
		_sdkComponents.addAt(tmpAddition, 0);

		tmpAddition = new ComponentVO();
		tmpAddition.title = "VirtualBox";
		if (_model.virtualBoxPath != null && FileUtils.isPathExists(_model.virtualBoxPath)) {
			tmpAddition.type = ComponentTypes.TYPE_VIRTUALBOX;
			tmpAddition.installToPath = _model.virtualBoxPath;
			// tmpAddition.addEventListener(ComponentVO.EVENT_UPDATED, componentUpdated);
		}
		_sdkComponents.add(tmpAddition);

		_sdkGrid.setData(_sdkComponents);

		_softwareVersionChecker.addEventListener(Event.COMPLETE, onSDKRetrievalComplete);
		_softwareVersionChecker.versionCheckType = SoftwareVersionChecker.VERSION_CHECK_TYPE_SDK;
		_softwareVersionChecker.retrieveSDKsInformation(_sdkComponents.toMXCollection());
	}

	function componentUpdated(e:Event) {
		trace("componentUpdated");
		var component:ComponentVO = cast e.target;
		component.removeEventListener(ComponentVO.EVENT_UPDATED, componentUpdated);
		_sdkComponents.refresh();
		_sdkComponents.updateAll();
	}

	function onSDKRetrievalComplete(e:Event) {
		_softwareVersionChecker.removeEventListener(Event.COMPLETE, onSDKRetrievalComplete);
		_sdkGrid.enabled = true;
		_sdkGrid.alpha = 1;
		_sdkComponents.refresh();
		_sdkComponents.updateAll();
		dispatchEvent(e);
	}

	function getEditors() {
		_editorComponents = ExternalEditorsPlugin.editors.fromMXCollection();
		_editorGrid.setData(_editorComponents);
		_editorVersionChecker = new SoftwareVersionChecker();
		_editorVersionChecker.addEventListener(Event.COMPLETE, onEditorRetrievalComplete, false, 0, true);
		_editorVersionChecker.versionCheckType = SoftwareVersionChecker.VERSION_CHECK_TYPE_EDITOR;
		_editorVersionChecker.retrieveEditorsInformation(ExternalEditorsPlugin.editors);
	}

	function onEditorRetrievalComplete(e:Event) {
		_editorVersionChecker.removeEventListener(Event.COMPLETE, onEditorRetrievalComplete);
		_editorGrid.enabled = true;
		_editorGrid.alpha = 1;
		_editorComponents.refresh();
		_editorComponents.updateAll();
		dispatchEvent(e);
	}

	function updateSDKWithMoonshinePaths() {
		var sdkReference:SDKReferenceVO;
		for (component in _sdkComponents) {
			sdkReference = null;
			component.installToPath = null;
			switch (component.type) {
				case ComponentTypes.TYPE_FLEX | ComponentTypes.TYPE_FLEX_HARMAN | ComponentTypes.TYPE_FEATHERS | ComponentTypes.TYPE_ROYALE | ComponentTypes.TYPE_FLEXJS:
					sdkReference = SDKUtils.checkSDKTypeInSDKList(component.type);
					component.installToPath = (sdkReference != null) ? sdkReference.path : null;
				case ComponentTypes.TYPE_OPENJAVA:
					if (_model.javaPathForTypeAhead != null && _model.javaPathForTypeAhead.fileBridge.exists)
						component.installToPath = _model.javaPathForTypeAhead.fileBridge.nativePath;
				case ComponentTypes.TYPE_OPENJAVA_V8:
					if (_model.java8Path != null && _model.java8Path.fileBridge.exists)
						component.installToPath = _model.java8Path.fileBridge.nativePath;
				case ComponentTypes.TYPE_GIT:
					if (_model.gitPath != null && FileUtils.isPathExists(_model.gitPath))
						component.installToPath = _model.gitPath;
				case ComponentTypes.TYPE_MAVEN:
					if (_model.mavenPath != null && FileUtils.isPathExists(_model.mavenPath))
						component.installToPath = _model.mavenPath;
				case ComponentTypes.TYPE_SVN:
					if (_model.svnPath != null && FileUtils.isPathExists(_model.svnPath))
						component.installToPath = _model.svnPath;
				case ComponentTypes.TYPE_GRADLE:
					if (_model.gradlePath != null && FileUtils.isPathExists(_model.gradlePath))
						component.installToPath = _model.gradlePath;
				case ComponentTypes.TYPE_GRAILS:
					if (_model.grailsPath != null && FileUtils.isPathExists(_model.grailsPath))
						component.installToPath = _model.grailsPath;
				case ComponentTypes.TYPE_ANT:
					if (_model.antHomePath != null && _model.antHomePath.fileBridge.exists)
						component.installToPath = _model.antHomePath.fileBridge.nativePath;
				case ComponentTypes.TYPE_NODEJS:
					if (_model.nodePath != null && FileUtils.isPathExists(_model.nodePath))
						component.installToPath = _model.nodePath;
				case ComponentTypes.TYPE_NOTES:
					if (_model.notesPath != null && FileUtils.isPathExists(_model.notesPath))
						component.installToPath = _model.notesPath;
				case ComponentTypes.TYPE_VAGRANT:
					if (_model.vagrantPath != null && FileUtils.isPathExists(_model.vagrantPath))
						component.installToPath = _model.vagrantPath;
				case ComponentTypes.TYPE_MACPORTS:
					if (ConstantsCoreVO.IS_MACOS && _model.macportsPath != null && FileUtils.isPathExists(_model.macportsPath))
						component.installToPath = _model.macportsPath;
				case ComponentTypes.TYPE_HAXE:
					if (_model.haxePath != null && FileUtils.isPathExists(_model.haxePath))
						component.installToPath = _model.haxePath;
				case ComponentTypes.TYPE_NEKO:
					if (_model.nekoPath != null && FileUtils.isPathExists(_model.nekoPath))
						component.installToPath = _model.nekoPath;
			}

			component.version = null;
		}
	}

	function bottomGroupLabelClicked(e:MouseEvent) {
		if (_infoBackground == null) {
			_infoBackground = cast(PopUpManager.createPopUp(cast(FlexGlobals.topLevelApplication, DisplayObject), InfoBackgroundPopup,
				true), InfoBackgroundPopup);
			_infoBackground.addEventListener(CloseEvent.CLOSE, handleInfoBackgroundPopupClose);
			_infoBackground.height = cast(FlexGlobals.topLevelApplication, DisplayObject).height - 100;

			PopUpManager.centerPopUp(cast(_infoBackground));
		} else {
			_infoBackground.setFocus();
		}
	}

	private function handleInfoBackgroundPopupClose(event:CloseEvent) {
		_infoBackground.removeEventListener(CloseEvent.CLOSE, handleInfoBackgroundPopupClose);
		PopUpManager.removePopUp( cast _infoBackground );
		_infoBackground = null;
	}

	public function dispose() {
		if (_softwareVersionChecker != null)
			_softwareVersionChecker.dispose();
		if (_editorVersionChecker != null)
			_editorVersionChecker.dispose();
		if (_editorComponents != null)
			_editorComponents.removeAll();
		if (_sdkComponents != null)
			_sdkComponents.removeAll();
	}
}

class SDKGrid extends GridView {
	public function new() {
		super();
		this.virtualLayout = true;
		this.sortableColumns = false;
		this.variant = MoonshineTheme.THEME_VARIANT_LIGHT_GRID_VIEW;
		this.customHeaderRendererVariant = MoonshineTheme.THEME_VARIANT_LIGHT_GRID_VIEW;
		this.customCellRendererVariant = MoonshineTheme.THEME_VARIANT_LIGHT_GRID_VIEW;
	}

	override function columnToHeaderRenderer(column:GridViewColumn):DisplayObject {
		return new LayoutGroup();
	}

	function headerRenderer(column:GridViewColumn):DisplayObject {
		return null;
	}

	public function setData(data:ArrayCollection<ComponentVO>) {
		this.dataProvider = data;

		var recycler = DisplayObjectRecycler.withFunction(() -> {
			var cellRenderer = new LayoutGroupItemRenderer();

			var backgroundSkin = new RectangleSkin();
			backgroundSkin.fill = SolidColor(MoonshineColor.WHITE);
			backgroundSkin.selectedFill = SolidColor(MoonshineColor.GREY_B);
			backgroundSkin.setFillForState(ToggleButtonState.HOVER(false), SolidColor(MoonshineColor.GREY_D));
			cellRenderer.backgroundSkin = backgroundSkin;

			var alternateBackgroundSkin = new RectangleSkin();
			alternateBackgroundSkin.fill = SolidColor(MoonshineColor.GREY_E);
			alternateBackgroundSkin.selectedFill = SolidColor(MoonshineColor.GREY_B);
			alternateBackgroundSkin.setFillForState(ToggleButtonState.HOVER(false), SolidColor(MoonshineColor.GREY_C));
			cellRenderer.alternateBackgroundSkin = alternateBackgroundSkin;

			var layout = new HorizontalLayout();
			layout.gap = 4.0;
			layout.paddingTop = 4.0;
			layout.paddingBottom = 4.0;
			layout.paddingLeft = 6.0;
			layout.paddingRight = 6.0;
			cellRenderer.layout = layout;
			cellRenderer.mouseChildren = true;
			cellRenderer.mouseEnabled = true;

			/*
				var icon = new AssetLoader();
				icon.name = "loader";
				cellRenderer.addChild(icon);
			 */

			var labelLoading = new Label();
			labelLoading.name = "labelLoading";
			labelLoading.text = "Loading...";
			labelLoading.textFormat = MoonshineTypography.getGreyTextFormat();
			cellRenderer.addChild(labelLoading);

			var labelVersion = new Label();
			labelVersion.name = "labelVersion";
			labelVersion.includeInLayout = labelVersion.visible = false;
			labelVersion.textFormat = MoonshineTypography.getGreyTextFormat();
			cellRenderer.addChild(labelVersion);

			var labelFix = new DataLabel();
			labelFix.name = "labelFix";
			labelFix.text = "Fix this";
			labelFix.includeInLayout = labelFix.visible = false;
			labelFix.textFormat = MoonshineTypography.getTextFormat(MoonshineTypography.DEFAULT_FONT_SIZE, MoonshineColor.MAROON, false, false, true);
			labelFix.useHandCursor = labelFix.buttonMode = labelFix.mouseEnabled = true;
			labelFix.mouseChildren = false;
			labelFix.addEventListener(MouseEvent.CLICK, labelFixClicked);
			cellRenderer.addChild(labelFix);

			return cellRenderer;
		});

		recycler.update = (cellRenderer:LayoutGroupItemRenderer, state:GridViewCellState) -> {
			var labelLoading = cast(cellRenderer.getChildByName("labelLoading"), Label);
			var labelVersion = cast(cellRenderer.getChildByName("labelVersion"), Label);
			var labelFix = cast(cellRenderer.getChildByName("labelFix"), DataLabel);
			labelFix.data = state.data;

			if (state.text == null || state.text == "") {
				labelLoading.visible = labelLoading.includeInLayout = false;
				labelVersion.visible = labelVersion.includeInLayout = true;
				labelFix.visible = labelFix.includeInLayout = true;
				labelVersion.text = "Not installed.";
			} else {
				labelLoading.visible = labelLoading.includeInLayout = false;
				labelFix.visible = labelFix.includeInLayout = false;
				labelVersion.visible = labelVersion.includeInLayout = true;
				labelVersion.text = state.text;
			}

			// var loader = cast(cellRenderer.getChildByName("loader"), AssetLoader);
			// loader.source = state.data.icon;
		};

		var gvc1 = new GridViewColumn("Name", getNameLabel);
		var gvc2 = new GridViewColumn("Info", getInfoLabel);
		gvc2.cellRendererRecycler = recycler;
		this.columns = new ArrayCollection([gvc1, gvc2]);
	}

	function getNameLabel(data:ComponentVO):String {
		return data.title;
	}

	function getInfoLabel(data:ComponentVO):String {
		return data.version;
	}

	function labelFixClicked(e:MouseEvent) {
		var label:DataLabel = cast e.target;
		GlobalEventDispatcher.getInstance().dispatchEvent(new Event(StartupHelperPlugin.EVENT_GETTING_STARTED));
	}
}

class EditorGrid extends GridView {
	public function new() {
		super();
		this.virtualLayout = true;
		this.sortableColumns = false;
		this.variant = MoonshineTheme.THEME_VARIANT_LIGHT_GRID_VIEW;
		this.customHeaderRendererVariant = MoonshineTheme.THEME_VARIANT_LIGHT_GRID_VIEW;
		this.customCellRendererVariant = MoonshineTheme.THEME_VARIANT_LIGHT_GRID_VIEW;
	}

	override function columnToHeaderRenderer(column:GridViewColumn):DisplayObject {
		return new LayoutGroup();
	}

	function headerRenderer(column:GridViewColumn):DisplayObject {
		return null;
	}

	public function setData(data:ArrayCollection<ExternalEditorVO>) {
		this.dataProvider = data;

		var recycler = DisplayObjectRecycler.withFunction(() -> {
			var cellRenderer = new LayoutGroupItemRenderer();

			var backgroundSkin = new RectangleSkin();
			backgroundSkin.fill = SolidColor(MoonshineColor.WHITE);
			backgroundSkin.selectedFill = SolidColor(MoonshineColor.GREY_B);
			backgroundSkin.setFillForState(ToggleButtonState.HOVER(false), SolidColor(MoonshineColor.GREY_D));
			cellRenderer.backgroundSkin = backgroundSkin;

			var alternateBackgroundSkin = new RectangleSkin();
			alternateBackgroundSkin.fill = SolidColor(MoonshineColor.GREY_E);
			alternateBackgroundSkin.selectedFill = SolidColor(MoonshineColor.GREY_B);
			alternateBackgroundSkin.setFillForState(ToggleButtonState.HOVER(false), SolidColor(MoonshineColor.GREY_C));
			cellRenderer.alternateBackgroundSkin = alternateBackgroundSkin;

			var layout = new HorizontalLayout();
			layout.gap = 4.0;
			layout.paddingTop = 4.0;
			layout.paddingBottom = 4.0;
			layout.paddingLeft = 6.0;
			layout.paddingRight = 6.0;
			cellRenderer.layout = layout;
			cellRenderer.mouseChildren = true;
			cellRenderer.mouseEnabled = true;

			/*
				var icon = new AssetLoader();
				icon.name = "loader";
				cellRenderer.addChild(icon);
			 */

			var labelLoading = new Label();
			labelLoading.name = "labelLoading";
			labelLoading.text = "Loading...";
			labelLoading.textFormat = MoonshineTypography.getGreyTextFormat();
			cellRenderer.addChild(labelLoading);

			var labelVersion = new Label();
			labelVersion.name = "labelVersion";
			labelVersion.includeInLayout = labelVersion.visible = false;
			labelVersion.textFormat = MoonshineTypography.getGreyTextFormat();
			cellRenderer.addChild(labelVersion);

			var labelFix = new DataLabel();
			labelFix.name = "labelFix";
			labelFix.text = "Fix this";
			labelFix.includeInLayout = labelFix.visible = false;
			labelFix.textFormat = MoonshineTypography.getTextFormat(MoonshineTypography.DEFAULT_FONT_SIZE, MoonshineColor.MAROON, false, false, true);
			labelFix.useHandCursor = labelFix.buttonMode = labelFix.mouseEnabled = true;
			labelFix.mouseChildren = false;
			labelFix.addEventListener(MouseEvent.CLICK, labelFixClicked);
			cellRenderer.addChild(labelFix);

			return cellRenderer;
		});

		recycler.update = (cellRenderer:LayoutGroupItemRenderer, state:GridViewCellState) -> {
			var labelLoading = cast(cellRenderer.getChildByName("labelLoading"), Label);
			var labelVersion = cast(cellRenderer.getChildByName("labelVersion"), Label);
			var labelFix = cast(cellRenderer.getChildByName("labelFix"), DataLabel);
			labelFix.data = state.data;

			if (state.text == null || state.text == "") {
				labelLoading.visible = labelLoading.includeInLayout = false;
				labelVersion.visible = labelVersion.includeInLayout = true;
				labelFix.visible = labelFix.includeInLayout = true;
				labelVersion.text = "Not installed.";
			} else {
				labelLoading.visible = labelLoading.includeInLayout = false;
				labelFix.visible = labelFix.includeInLayout = false;
				labelVersion.visible = labelVersion.includeInLayout = true;
				labelVersion.text = state.text;
			}

			// var loader = cast(cellRenderer.getChildByName("loader"), AssetLoader);
			// loader.source = state.data.icon;
		};

		var gvc1 = new GridViewColumn("Name", getNameLabel);
		var gvc2 = new GridViewColumn("Info", getInfoLabel);
		gvc2.cellRendererRecycler = recycler;
		this.columns = new ArrayCollection([gvc1, gvc2]);
	}

	function getNameLabel(data:ExternalEditorVO):String {
		return data.title;
	}

	function getInfoLabel(data:ExternalEditorVO):String {
		return data.version;
	}

	function labelFixClicked(e:MouseEvent) {
		var label:DataLabel = cast e.target;
		GlobalEventDispatcher.getInstance().dispatchEvent(new SettingsEvent(SettingsEvent.EVENT_OPEN_SETTINGS, ExternalEditorsPlugin.NAMESPACE));
	}
}

class DataLabel extends Label {
	public var data:Dynamic;

	public function new(?text:String) {
		super(text);
	}
}