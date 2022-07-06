package actionScripts.events;

import actionScripts.factory.FileLocation;
import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import openfl.events.Event;

class NewProjectEvent extends Event {
	public static final CREATE_NEW_PROJECT:String = "createNewProjectEvent";
	public static final IMPORT_AS_NEW_PROJECT:String = "openFolderAsNewProjectEvent";

	private var _exportProject:AS3ProjectVO;

	public var exportProject(get, never):AS3ProjectVO;

	private function get_exportProject():AS3ProjectVO
		return _exportProject;

	public var isExport(get, never):Bool;

	private function get_isExport():Bool
		return _exportProject != null;

	public var settingsFile:FileLocation;
	public var templateDir:FileLocation;
	public var projectFileEnding:String;

	public function new(type:String, projectFileEnding:String, settingsFile:FileLocation, templateDir:FileLocation, project:AS3ProjectVO = null) {
		this.projectFileEnding = projectFileEnding;
		this.settingsFile = settingsFile;
		this.templateDir = templateDir;
		_exportProject = project;

		super(type, false, true);
	}
}