//TODO
package actionScripts.valueObjects;

import actionScripts.factory.FileLocation;
import actionScripts.locator.IDEModel;
import haxe.DynamicAccess;
import openfl.Vector;

class ProjectReferenceVO {
	public var name:String;
	public var path:String = "";
	public var startIn:String = "";
	public var status:String = "";
	public var loading:Bool;
	public var sdk:String;
	public var isAway3D:Bool;
	public var isTemplate:Bool;
	public var hiddenPaths:Vector<FileLocation> = new Vector<FileLocation>();
	public var showHiddenPaths:Bool;
	public var sourceFolder:FileLocation;

	public function new() {}

	/**
	 * Static method to translate config
	 * SO data in a loosely-coupled manner
	 */
	public static function getNewRemoteProjectReferenceVO(value:Dynamic):ProjectReferenceVO {
		var tmpVO:ProjectReferenceVO = new ProjectReferenceVO();

		// value submission
		if (value.path != null)
			tmpVO.path = value.path;
		if (value.name != null) {
			// since https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1027 problem
			// parse by path to overcome problem during reading from already saved data
			if (tmpVO.path != null) {
				tmpVO.name = cast( tmpVO.path.split(IDEModel.getInstance().fileCore.separator).pop(), String );
			} else {
				tmpVO.name = value.name;
			}
		}
		if (value.startIn != null)
			tmpVO.startIn = value.startIn;
		if (value.status != null)
			tmpVO.status = value.status;
		if (value.loading != null)
			tmpVO.loading = value.loading;
		if (value.sdk != null)
			tmpVO.sdk = value.sdk;
		if (value.isAway3D != null)
			tmpVO.isAway3D = value.isAway3D;
		if (value.isTemplate != null)
			tmpVO.isTemplate = value.isTemplate;

		// finally
		return tmpVO;
	}

	public static function serializeForSharedObject(value:ProjectReferenceVO):Dynamic {
		return {
			name: value.name,
			path: value.path,
			startIn: value.startIn,
			status: value.status,
			loading: value.loading,
			sdk: value.sdk,
			isAway3D: value.isAway3D,
			isTemplate: value.isTemplate
		};
	}
}