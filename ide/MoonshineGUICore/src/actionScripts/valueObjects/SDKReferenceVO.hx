package actionScripts.valueObjects;

import actionScripts.factory.FileLocation;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.RoyaleOutputTarget;

class SDKReferenceVO {
    private static final JS_SDK_COMPILER_NEW:String = "js/bin/mxmlc";
    private static final JS_SDK_COMPILER_OLD:String = "bin/mxmlc";
    private static final FLEX_SDK_COMPILER:String = "bin/fcsh";

    public var version:String;
    public var build:String;
    public var status:String;

    public function new() {}

    public var isPureActionScriptSdk( get, null ):Bool;
	public function get_isPureActionScriptSdk():Bool {
		if (!fileLocation.fileBridge.isPathExists(path + "/flex-sdk-description.xml")
			&& fileLocation.fileBridge.isPathExists(path + "/air-sdk-description.xml")) {
			return true;
		}

		return false;
	}
		
	private var _path:String;

	public var path(get, set):String;

	private function set_path(value:String):String {
		_path = value;
		return _path;
	}

	private function get_path():String {
		return _path;
	}

	private var _outputTargets:Array<Dynamic>;

	public var outputTargets(get, set):Array<Dynamic>;

	private function get_outputTargets():Array<Dynamic> {
		return _outputTargets;
	}

	private function set_outputTargets(value:Array<Dynamic>):Array<Dynamic> {
		_outputTargets = value;
		return _outputTargets;
	}

	private var _name:String;

	public var name(get, set):String;

	private function get_name():String {
		return _name;
	}

	private function set_name(value:String):String {
		if (value != _name) {
			_name = getNameOfSdk(value);
		}
		return _name;
	}
	public var nameUncalculated(get, set):String;

	private function get_nameUncalculated():String {
		return _name;
	}

	private function set_nameUncalculated(value:String):String {
		_name = value;
		return _name;
	}

	public var isJSOnlySdk(get, null):Bool;

	private function get_isJSOnlySdk():Bool {
		if (outputTargets != null && outputTargets.length == 1) {
			return outputTargets[0].name == "js";
		}

		return false;
	}

	private var _fileLocation:FileLocation;

	public var fileLocation(get, null):FileLocation;

	private function get_fileLocation():FileLocation {
		if (_fileLocation == null) {
			_fileLocation = new FileLocation(path);
		}

		return _fileLocation;
	}

	private var _type:String;

	public var type(get, set):String;

	private function get_type():String {
		if (_type == null)
			_type = getType();
		return _type;
	}

	private function set_type(value:String):String {
		_type = value;
		return _type;
	}

	public var hasPlayerglobal(get, null):Bool;

	private function get_hasPlayerglobal():Bool {
		if (type == SDKTypes.ROYALE && !isJSOnlySdk) {
			var separator:String = fileLocation.fileBridge.separator;
			var playerGlobalVersion:String = getPlayerGlobalVersion();
			var fl:String = fileLocation.fileBridge.nativePath + separator + "frameworks" + separator + "libs" + separator + "player" + separator
				+ playerGlobalVersion + separator + "playerglobal.swc";
			var playerGlobalLocation:FileLocation = new FileLocation(fl);

			return playerGlobalLocation.fileBridge.exists;
		}

		return type == SDKTypes.FLEX || type == SDKTypes.FEATHERS;
	}

	public static function getNewReference(value:Dynamic):SDKReferenceVO {
		var tmpRef:SDKReferenceVO = new SDKReferenceVO();
		if (value.hasOwnProperty("build"))
			tmpRef.build = value.build;
		if (value.hasOwnProperty("name"))
			tmpRef.name = value.name;
		if (value.hasOwnProperty("path"))
			tmpRef.path = value.path;
		if (value.hasOwnProperty("status"))
			tmpRef.status = value.status;
		if (value.hasOwnProperty("version"))
			tmpRef.version = value.version;

		return tmpRef;
	}
		
	public function getPlayerGlobalVersion():String {
		for (target in outputTargets) {
			if (target.flashVersion != null) {
				return target.flashVersion;
			}
		}

		return null;
	}
		
	//--------------------------------------------------------------------------
	//
	//  PRIVATE API
	//
	//--------------------------------------------------------------------------
		
	private function getNameOfSdk(providedName:String):String {
		var suffixName:String = "(";
		var suffixSwf:String = "";

		if (outputTargets != null) {
			var outputTargesCount:Int = outputTargets.length;
			for (i in 0...outputTargesCount) {
				var outputTarget:RoyaleOutputTarget = cast outputTargets[i];
				if (outputTarget.flashVersion != null || outputTarget.airVersion != null) {
					suffixSwf = "FP" + outputTarget.flashVersion + " AIR" + outputTarget.airVersion + " ";
				}

				if (outputTargesCount > 1 && outputTargesCount - 1 <= i) {
					suffixName += ", " + outputTarget.name.toUpperCase();
				} else {
					suffixName += outputTarget.name.toUpperCase();
				}
			}
		}

		if (suffixName.length > 1) {
			return providedName + " " + suffixSwf + suffixName + ")";
		}

		return providedName;
	}
		
	private function getType():String {
		// flex
		var compilerExtension:String = ConstantsCoreVO.IS_MACOS ? "" : ".bat";
		var compilerFile:FileLocation = fileLocation.resolvePath(FLEX_SDK_COMPILER + compilerExtension);
		if (compilerFile.fileBridge.exists) {
			if (fileLocation.resolvePath("frameworks/libs/spark.swc").fileBridge.exists
				|| fileLocation.resolvePath("frameworks/libs/flex.swc").fileBridge.exists) {
				if (fileLocation.resolvePath("lib/adt.cfg").fileBridge.exists
					|| fileLocation.resolvePath("lib/adt.lic").fileBridge.exists) {
					return SDKTypes.FLEX_HARMAN;
				}
				return SDKTypes.FLEX;
			}
		}
			
		// royale
		compilerFile = fileLocation.resolvePath(JS_SDK_COMPILER_NEW + compilerExtension);
		if (compilerFile.fileBridge.exists) {
			if (fileLocation.resolvePath("frameworks/royale-config.xml").fileBridge.exists)
				return SDKTypes.ROYALE;
		}

		// feathers
		compilerFile = fileLocation.resolvePath(FLEX_SDK_COMPILER + compilerExtension);
		if (compilerFile.fileBridge.exists) {
			if (fileLocation.resolvePath("frameworks/libs/feathers.swc").fileBridge.exists)
				return SDKTypes.FEATHERS;
		}

		// flexjs
		// determine if the sdk version is lower than 0.8.0 or not
		var isFlexJSAfter7:Bool = UtilsCore.isNewerVersionSDKThan(7, this.path);

		compilerFile = fileLocation.resolvePath(JS_SDK_COMPILER_NEW + compilerExtension);
		if (isFlexJSAfter7 && compilerFile.fileBridge.exists) {
			if (name.toLowerCase().indexOf("flexjs") != -1)
				return SDKTypes.FLEXJS;
		}
			
		// @fix
		// https://github.com/Moonshine-IDE/Moonshine-IDE/issues/26
		// We've found js/bin/mxmlc compiletion do not produce
		// valid swf with prior 0.8 version; we shall need following
		// executable for version less than 0.8
		else if (!isFlexJSAfter7) {
			compilerFile = fileLocation.resolvePath(JS_SDK_COMPILER_OLD + compilerExtension);
			if (compilerFile.fileBridge.exists) {
				if (name.toLowerCase().indexOf("flexjs") != -1)
					return SDKTypes.FLEXJS;
			}
		}

		return null;
	}
}
