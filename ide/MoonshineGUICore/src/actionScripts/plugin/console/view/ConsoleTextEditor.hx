package actionScripts.plugin.console.view;

import moonshine.editor.text.syntax.parser.HaxeLineParser;
import moonshine.editor.text.syntax.format.HaxeSyntaxFormatBuilder;
import feathers.controls.VScrollBar;
import feathers.data.ArrayCollection;
import actionScripts.ui.editor.text.TextLineModel;
import moonshine.editor.text.syntax.parser.PlainTextLineParser;
import moonshine.editor.text.syntax.format.SyntaxFontSettings;
import openfl.text.TextFormat;
import moonshine.editor.text.syntax.format.SyntaxColorSettings;
import moonshine.editor.text.syntax.format.PlainTextFormatBuilder;
import moonshine.editor.text.syntax.parser.ILineParser;
import feathers.skins.RectangleSkin;
import moonshine.editor.text.lines.TextLineRenderer;
import moonshine.editor.text.TextEditor;
#if flash
import flash.Vector;
#else
import openfl.Vector;
#end

class ConsoleTextEditor extends TextEditor 
{
    private var consoleLineParser:ConsoleLineParser;
    public function new(?text:String, readOnly:Bool = false)
    {
        super(text, readOnly);

        this._lineHeight = 14;

        this.backgroundSkin = new RectangleSkin(SolidColor(0x373737));
        
        var fontSetting = new SyntaxFontSettings();
        fontSetting.fontSize = 12;

        var colorSetting = new SyntaxColorSettings();
        colorSetting.foregroundColor = 0xf4f4f4;

		var consoleBuild = new ConsoleSyntaxFormBuilder();
        consoleBuild.setColorSettings(colorSetting);
        consoleBuild.setFontSettings(fontSetting);

        consoleLineParser = new ConsoleLineParser();
        this.setParserAndTextStyles(consoleLineParser, consoleBuild.build());
    }

    override private function createTextLineRenderer():TextLineRenderer 
    {
		if (_textLineRendererFactory != null) {
			return cast(_textLineRendererFactory.create(), TextLineRenderer);
		}

        var tlr = new ConsoleTextLineRenderer();
        tlr.breakpoint = false;
        tlr.breakpointGutterBackgroundSkin = null;
        tlr.breakpointSkin = null;
        tlr.unverifiedBreakpointSkin = null;
        tlr.defaultTextStyleContext = 0x4;
        tlr.backgroundSkin = new RectangleSkin(SolidColor(0x373737));
        tlr.selectedTextBackgroundSkinFactory = () -> {
            return new RectangleSkin(SolidColor(0x676767));
        }
		return tlr;
	}

    public function appendtext(text:Dynamic):Void
    {
        if (Std.isOfType(text, String))
        {
            /*var lines:Array = text.split('\n');
            linesCount = lines.length;
            var p:ParagraphElement;
            var tf:TextFlow;
            var pe:ParagraphElement;
            var fe:FlowElement;
            for (var i:int = 0; i < linesCount; i++)
            {
                p = new ParagraphElement();
                tf = TextConverter.importToFlow(String(lines[i]) + "\n", TextConverter.TEXT_FIELD_HTML_FORMAT);
                pe = tf.mxmlChildren[0];
                for each (fe in pe.mxmlChildren)
                {
                    p.addChild(fe);
                }
                
                //this.textFlow.addChild(p);
            }*/
            
            //callLater(setScroll);
            //return this.numLines;
        } 
        else 
        {
            try
            {
                var vectorText:Vector<TextLineModel> = cast text;
                for (i in vectorText)
                {
                    this.text += "\n"+ i.text;
                }    
            }
            catch (e){}
        }
        /*else if (text is ParagraphElement)
        {
            //this.textFlow.addChild(text);
            //callLater(setScroll);
        }*/
        
        // Remove initial empty line (first time anything is outputted)
        //return 0;
    }
}

class ConsoleSyntaxFormBuilder extends HaxeSyntaxFormatBuilder
{
    public function new()
    {
        super();
    }

    override public function build():Map<Int, TextFormat> {
		var formats:Map<Int, TextFormat> = [];
		formats.set(0 /* default, parser fault */, getTextFormat(_colorSettings.invalidColor));
		formats.set(HaxeLineParser.HX_CODE, getTextFormat(_colorSettings.foregroundColor));
		formats.set(HaxeLineParser.HX_STRING1, getTextFormat(_colorSettings.commentColor));
		formats.set(HaxeLineParser.HX_STRING2, getTextFormat(_colorSettings.commentColor));
		formats.set(ConsoleLineParser.CL_WARNING, getTextFormat(_colorSettings.commentColor));
		return formats;
	}
}

class ConsoleTextLineRenderer extends TextLineRenderer
{
    public function new()
    {
        super();
    }
}