package actionScripts.plugin.syntax
{
   import actionScripts.events.EditorPluginEvent;
	import actionScripts.plugin.IEditorPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.plugin.settings.ISettingsProvider;
	import actionScripts.plugin.settings.vo.ISetting;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.Settings;

	import haxe.IMap;

	import moonshine.editor.text.syntax.format.HaxeSyntaxFormatBuilder;
	import moonshine.editor.text.syntax.format.SyntaxColorSettings;
	import moonshine.editor.text.syntax.format.SyntaxFontSettings;
	import moonshine.editor.text.syntax.parser.BasicLanguageLineParser;
	import moonshine.editor.text.TextEditor;
	import moonshine.editor.text.utils.AutoClosingPair;
	import moonshine.editor.text.syntax.format.BasicSyntaxFormatBuilder;

	public class BasicSyntaxPlugin extends PluginBase implements ISettingsProvider, IEditorPlugin
	{
		override public function get name():String 			{return "Basic Syntax Plugin";}
		override public function get author():String 		{return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team";}
		override public function get description():String 	{return "Provides highlighting for Basic.";}
		public function getSettingsList():Vector.<ISetting>		{return new Vector.<ISetting>();}
				
		override public function activate():void
		{ 
			super.activate();
			dispatcher.addEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, handleEditorOpen);
		}

		override public function deactivate():void
		{ 
			super.deactivate();
			dispatcher.removeEventListener(EditorPluginEvent.EVENT_EDITOR_OPEN, handleEditorOpen);
		}
				
		private function handleEditorOpen(event:EditorPluginEvent):void
		{
			if (event.fileExtension == "basic")
			{
				var formatBuilder:BasicSyntaxFormatBuilder = new BasicSyntaxFormatBuilder();
				formatBuilder.setFontSettings(new SyntaxFontSettings(Settings.font.defaultFontFamily, Settings.font.defaultFontSize));
				formatBuilder.setColorSettings(new SyntaxColorSettings());
				var formats:IMap = formatBuilder.build();
				var textEditor:TextEditor = event.editor;
				textEditor.brackets = [["{", "}"], ["[", "]"], ["(", ")"]];
				textEditor.autoClosingPairs = [
					new AutoClosingPair("", "}"),
					new AutoClosingPair("{", "}"),
					new AutoClosingPair("[", "]"),
					new AutoClosingPair("(", ")"),
					new AutoClosingPair("'", "'"),
					new AutoClosingPair("\"", "\"")
				];
				textEditor.lineComment = "`";
				textEditor.blockComment = ["/*", "*/"];
				textEditor.setParserAndTextStyles(new BasicLanguageLineParser(), formats);
				textEditor.embedFonts = Settings.font.defaultFontEmbedded;
			}
		}
	}
}