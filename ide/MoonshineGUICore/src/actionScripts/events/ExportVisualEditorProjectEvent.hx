package actionScripts.events;

import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
import openfl.events.Event;

class ExportVisualEditorProjectEvent extends Event {
	public static final EVENT_INIT_EXPORT_VISUALEDITOR_PROJECT_TO_FLEX:String = "initExportVisualEditorToFlex";
	public static final EVENT_EXPORT_VISUALEDITOR_PROJECT_TO_FLEX:String = "exportVisualEditorProjectToFlex";
	public static final EVENT_EXPORT_VISUALEDITOR_PROJECT_TO_PRIMEFACES:String = "exportVisualEditorProjectToPrimeFaces";
	public static final EVENT_EXPORT_DOMINO_VISUALEDITOR_PROJECT_TO_ROYALE:String = "exportDominoVisualEditorProjectToRoyale";

	private var _exportedProject:AS3ProjectVO;

	public var exportedProject(get, never):AS3ProjectVO;

	private function get_exportedProject():AS3ProjectVO
		return _exportedProject;

	public function new(type:String, exportedProject:AS3ProjectVO = null):Void {
		super(type, false, false);

		_exportedProject = exportedProject;
	}
}