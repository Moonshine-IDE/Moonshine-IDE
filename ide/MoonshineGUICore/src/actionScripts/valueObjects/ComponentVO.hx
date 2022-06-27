package actionScripts.valueObjects;

import actionScripts.utils.FileUtils;
import feathers.data.ArrayCollection;
import openfl.events.Event;
import openfl.events.EventDispatcher;

@:bind
class ComponentVO extends EventDispatcher {
	public static final EVENT_UPDATED:String = "isUpdated";

	@:bind public var createdOn(get, set):Date;
	@:bind public var description:String;
	@:bind public var displayVersion:String;
	@:bind public var downloadURL:String;
	@:bind public var downloadVariants:ArrayCollection<ComponentVariantVO>;
	@:bind public var hasError(get, set):String;
	@:bind public var hasWarning(get, set):String;
	@:bind public var id:String;
	@:bind public var imagePath:String;
	@:bind public var installToPath:String;
	@:bind public var isAlreadyDownloaded(get, set):Bool;
	@:bind public var isDownloadable:Bool = true;
	@:bind public var isDownloaded(get, set):Bool;
	@:bind public var isDownloading(get, set):Bool;
	@:bind public var isSelectedToDownload(get, set):Bool;
	@:bind public var isSelectionChangeAllowed:Bool = false;
	@:bind public var licenseSmallDescription:String;
	@:bind public var licenseTitle:String;
	@:bind public var licenseUrl:String;
	@:bind public var oldInstalledVersion:String;
	@:bind public var pathValidation:Array<String> = [];
	@:bind public var selectedVariantIndex:Int;
	@:bind public var sizeInMb:Int;
	@:bind public var title:String;
	@:bind public var type:String;
	@:bind public var variantCount(get, never):Int;
	@:bind public var version(get, set):String;
	@:bind public var website:String;

	private var _createdOn:Date;
	private var _hasError:String;
	private var _hasWarning:String;
	private var _isAlreadyDownloaded:Bool = false;
	private var _isDownloaded:Bool = false;
	private var _isDownloading:Bool = false;
	private var _isSelectedToDownload:Bool = false;
    private var _version:String;

	public function new() {
		super();
	}

	public function clone():ComponentVO {
		var c = new ComponentVO();

		c._createdOn = this._createdOn;
		c._hasError = this._hasError;
		c._hasWarning = this._hasWarning;
		c._isAlreadyDownloaded = this._isAlreadyDownloaded;
		c._isDownloaded = this._isDownloaded;
		c._isDownloading = this._isDownloading;
		c._isSelectedToDownload = this._isSelectedToDownload;
		c.description = this.description;
		c.displayVersion = this.displayVersion;
		c.downloadURL = this.downloadURL;
		c.downloadVariants = this.downloadVariants;
		c.id = this.id;
		c.imagePath = this.imagePath;
		c.installToPath = this.installToPath;
		c.isDownloadable = this.isDownloadable;
		c.isSelectionChangeAllowed = this.isSelectionChangeAllowed;
		c.licenseSmallDescription = this.licenseSmallDescription;
		c.licenseTitle = this.licenseTitle;
		c.licenseUrl = this.licenseUrl;
		c.oldInstalledVersion = this.oldInstalledVersion;
		c.pathValidation = this.pathValidation;
		c.selectedVariantIndex = this.selectedVariantIndex;
		c.sizeInMb = this.sizeInMb;
		c.title = this.title;
		c.type = this.type;
		c.version = this.version;
		c.website = this.website;

		return c;
	}

	function get_variantCount():Int {
		if (downloadVariants != null)
			return downloadVariants.length;
		return 1;
	}

	function get_isDownloading():Bool {
		return _isDownloading;
	}

	function set_isDownloading(value:Bool):Bool {
		if (_isDownloading != value) {
			_isDownloading = value;
			dispatchEvent(new Event(EVENT_UPDATED));
		}

		return _isDownloading;
	}

	function get_isDownloaded():Bool {
		return _isDownloading;
	}

	function set_isDownloaded(value:Bool):Bool {
		if (_isDownloaded != value) {
			_isDownloaded = value;
			dispatchEvent(new Event(EVENT_UPDATED));
		}

		return _isDownloaded;
	}

	function get_version():String {
		return _version;
	}

	function set_version(value:String):String {
		if (_version != value) {
			_version = value;
			dispatchEvent(new Event(EVENT_UPDATED));
		}

		return _version;
	}

	function get_hasError():String {
		return _hasError;
	}

	function set_hasError(value:String):String {
		if (_hasError != value) {
			_hasError = value;
			dispatchEvent(new Event(EVENT_UPDATED));
		}

		return _hasError;
	}

	function get_hasWarning():String {
		return _hasWarning;
	}

	function set_hasWarning(value:String):String {
		if (_hasWarning != value) {
			_hasWarning = value;
			dispatchEvent(new Event(EVENT_UPDATED));
		}

		return _hasWarning;
	}

	function get_isAlreadyDownloaded():Bool {
		return _isAlreadyDownloaded;
	}

	function set_isAlreadyDownloaded(value:Bool):Bool {
		if (_isAlreadyDownloaded != value) {
			_isAlreadyDownloaded = value;
			createdOn = FileUtils.getCreationDateForPath(installToPath);
			dispatchEvent(new Event(EVENT_UPDATED));
		}

		return _isAlreadyDownloaded;
	}

	function get_isSelectedToDownload():Bool {
		return _isSelectedToDownload;
	}

	function set_isSelectedToDownload(value:Bool):Bool {
		if (_isSelectedToDownload != value) {
			_isSelectedToDownload = value;
			dispatchEvent(new Event(EVENT_UPDATED));
		}

		return _isSelectedToDownload;
	}

	function get_createdOn():Date {
		return _createdOn;
	}

	function set_createdOn(value:Date):Date {
		if (_createdOn != value) {
			_createdOn = value;
			dispatchEvent(new Event(EVENT_UPDATED));
		}

		return _createdOn;
	}
}