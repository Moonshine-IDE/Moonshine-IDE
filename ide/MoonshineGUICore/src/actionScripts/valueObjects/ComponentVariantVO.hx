package actionScripts.valueObjects;

@:bind
class ComponentVariantVO {
	public static final TYPE_ALPHA:String = "Alpha";
	public static final TYPE_BETA:String = "Beta";
	public static final TYPE_NIGHTLY:String = "Nightly";
	public static final TYPE_PRE_ALPHA:String = "Pre-Alpha";
	public static final TYPE_RELEASE_CANDIDATE:String = "Release Candidate";
	public static final TYPE_STABLE:String = "Stable";

    @:bind
	public var displayVersion:String;
    @:bind
	public var downloadURL:String;
    @:bind
	public var isReDownloadAvailable:Bool = false;
    @:bind
	public var sizeInMb:Int;
    @:bind
	public var title:String;
    @:bind
	public var version:String;

	public function new() {}
}