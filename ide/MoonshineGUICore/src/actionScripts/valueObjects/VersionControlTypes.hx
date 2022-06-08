package actionScripts.valueObjects;

class VersionControlTypes {
	@:meta(Bindable("change"))
	public static final SVN:String = "svn";
	@:meta(Bindable("change"))
	public static final GIT:String = "git";
	@:meta(Bindable("change"))
	public static final XML:String = "xml";
}