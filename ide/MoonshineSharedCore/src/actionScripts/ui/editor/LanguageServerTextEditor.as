package actionScripts.ui.editor
{
	public class LanguageServerTextEditor extends BasicTextEditor
	{
		public function LanguageServerTextEditor(languageID:String)
		{
			this._languageID = languageID;
		}

		private var _languageID:String;

		public function get languageID():String
		{
			return this._languageID;
		}
	}
}