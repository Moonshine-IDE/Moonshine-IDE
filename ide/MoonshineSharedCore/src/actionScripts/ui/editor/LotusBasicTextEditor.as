package actionScripts.ui.editor
{
    import actionScripts.plugin.groovy.grailsproject.vo.GrailsProjectVO;

	import flash.events.KeyboardEvent;
	import actionScripts.plugin.basic.vo.BasicProjectVO;

	public class LotusBasicTextEditor extends LanguageServerTextEditor
	{
		public static const LANGUAGE_ID_BASIC:String = "basic";

		public function LotusBasicTextEditor(project:BasicProjectVO, readOnly:Boolean = false)
		{
			super(LANGUAGE_ID_BASIC, project, readOnly);
		}
	}
}