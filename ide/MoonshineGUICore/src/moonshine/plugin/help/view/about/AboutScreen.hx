package moonshine.plugin.help.view.about;

import actionScripts.events.GlobalEventDispatcher;
import actionScripts.locator.HelperModel;
import actionScripts.locator.IDEModel;
import actionScripts.plugin.console.ConsoleOutputEvent;
import actionScripts.utils.FileUtils;
import actionScripts.utils.SDKUtils;
import actionScripts.utils.SoftwareVersionChecker;
import actionScripts.valueObjects.ComponentTypes;
import actionScripts.valueObjects.ComponentVO;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.SDKReferenceVO;
import feathers.controls.AssetLoader;
import feathers.controls.Button;
import feathers.controls.GridView;
import feathers.controls.GridViewColumn;
import feathers.controls.Label;
import feathers.controls.LayoutGroup;
import feathers.controls.navigators.TabItem;
import feathers.controls.navigators.TabNavigator;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.RelativePosition;
import feathers.layout.RelativePositions;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import feathers.skins.RectangleSkin;
import flash.desktop.NativeApplication;
import haxe.xml.Access;
import moonshine.components.HDivider;
import moonshine.components.MoonshineTabNavigator;
import moonshine.theme.MoonshineTheme;
import openfl.desktop.Clipboard;
import openfl.desktop.ClipboardFormats;
import openfl.display.DisplayObject;
import openfl.events.Event;
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
	var _bottomGroupLabel2:Label;
	var _bottomGroupLayout:VerticalLayout;
	var _contentGroup:LayoutGroup;
	var _contentGroupLayout:VerticalLayout;
	var _copyButton:Button;
	var _copyIconLoader:AssetLoader;
	var _editorComponents:ArrayCollection<ComponentVO>;
	var _editorGrid:SDKGrid;
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
		_editorGrid = new SDKGrid();

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

		_bottomGroupLabel2 = new Label(ConstantsCoreVO.MOONSHINE_IDE_COPYRIGHT_LABEL);
		_bottomGroup.addChild(_bottomGroupLabel2);

		_contentGroup.addChild(_bottomGroup);

		this.addChild(_contentGroup);

		_model = IDEModel.getInstance();
	}

	override function layoutGroup_addedToStageHandler(event:Event) {
		super.layoutGroup_addedToStageHandler(event);

		getSDKs();
	}

	function copyInfoToClipboard(e:TriggerEvent) {
		var aboutInformation:String = ConstantsCoreVO.MOONSHINE_IDE_LABEL + "\n" + getAIRVersion() + "\n" + getOS();
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

		updateWithMoonshinePaths();

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
		trace("onSDKRetrievalComplete");

		for (c in _sdkComponents) {
			trace(c.title, c.installToPath);
		}

		_sdkComponents.refresh();
		_sdkComponents.updateAll();
		dispatchEvent(e);
		// getEditors();
	}

	function getEditors() {
		/*
			_softwareVersionChecker = new SoftwareVersionChecker();
			_softwareVersionChecker.addEventListener(Event.COMPLETE, onEditorRetrievalComplete, false, 0, true);
			_softwareVersionChecker.versionCheckType = SoftwareVersionChecker.VERSION_CHECK_TYPE_EDITOR;
			_softwareVersionChecker.retrieveEditorsInformation(ExternalEditorsPlugin.editors);
		 */
	}

	function onEditorRetrievalComplete(e:Event) {
		/*
			_softwareVersionChecker.removeEventListener(Event.COMPLETE, onSDKRetrievalComplete);
			trace("onRetrievalComplete");

			for ( c in _sdkComponents ) {
				trace( c.title, c.installToPath );
			}

			_components.refresh();
			_components.updateAll();
			//dispatchEvent(e);
		 */
	}

	function updateWithMoonshinePaths() {
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

		this.columns = new ArrayCollection([

			new GridViewColumn("Name", (data) -> data.title),
			new GridViewColumn("Info", (data) -> data.version)

		]);
	}
}