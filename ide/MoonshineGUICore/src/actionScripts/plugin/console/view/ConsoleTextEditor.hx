package actionScripts.plugin.console.view;

import haxe.Timer;
import feathers.events.ScrollEvent;
import openfl.text.TextFormat;
import moonshine.editor.text.syntax.parser.HaxeLineParser;
import moonshine.editor.text.syntax.format.HaxeSyntaxFormatBuilder;
import feathers.controls.VScrollBar;
import feathers.data.ArrayCollection;
import actionScripts.ui.editor.text.TextLineModel;
import moonshine.editor.text.syntax.parser.PlainTextLineParser;
import moonshine.editor.text.syntax.format.SyntaxFontSettings;
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
    private var consoleLineParser = new ConsoleLineParser();
    
    public function new(?text:String, readOnly:Bool = false)
    {
        super(text, readOnly);

        this.backgroundSkin = new RectangleSkin(SolidColor(0x373737, 0.9));

        this.setParserAndTextStyles(consoleLineParser, [
            0 => new TextFormat("_typewriter", 12, 0xf4f4f4),
            ConsoleLineParser.CL_ERROR => new TextFormat("_typewriter", 12, 0xff6666),
            ConsoleLineParser.CL_WARNING => new TextFormat("_typewriter", 12, 0xFFBF0F),
            ConsoleLineParser.CL_SUCCESS => new TextFormat("_typewriter", 12, 0x33cc33)
        ]);
    }

    override private function createTextLineRenderer():TextLineRenderer 
    {
		if (_textLineRendererFactory != null) {
			return cast(_textLineRendererFactory.create(), TextLineRenderer);
		}

        var tlr = new TextLineRenderer();
        tlr.breakpoint = false;
        tlr.breakpointGutterBackgroundSkin = null;
        tlr.breakpointSkin = null;
        tlr.unverifiedBreakpointSkin = null;
        tlr.gutterGap = 0.0;
        tlr.gutterPaddingLeft = 2.0;
        tlr.gutterPaddingRight = 0.0;
        tlr.gutterBackgroundSkin = new RectangleSkin(SolidColor(0x373737, 0.9));
        tlr.backgroundSkin = new RectangleSkin(SolidColor(0x373737, 0.9));
        tlr.selectedTextBackgroundSkinFactory = () -> {
            return new RectangleSkin(SolidColor(0x676767));
        }
		return tlr;
	}

    public function clearText():Void
    {
        this.text = null;
        this.consoleLineParser.reset();   
    }

    public function appendtext(text:Dynamic, ?type:String):Void
    {
        if (Std.isOfType(text, String))
        {
            text = ~/^|$(\r?\n|\r)/g.replace(text, "");
            this.text += "\n"+ ~/^\/\*.*?(?:\*\/|\n)/.replace(text, "");
        } 
        else 
        {
        	try
        	{
        		var vectorText:Vector<TextLineModel> = cast text;
				for (i in vectorText)
				{
					// Split lines regardless of line encoding
					i.text = ~/^|$(\r?\n|\r)/g.replace(i.text, "");
	
					var consoleOutType:UInt = Reflect.getProperty(ConsoleStyle.name2style, cast(i, ConsoleTextLineModel).consoleOutputType);
					switch (consoleOutType)
					{
						case ConsoleStyle.ERROR:
							this.consoleLineParser.setErrorAtLine(this.lines.length);
						case ConsoleStyle.WARNING:
							this.consoleLineParser.setWarningAtLine(this.lines.length);
						case ConsoleStyle.SUCCESS:
							this.consoleLineParser.setSuccessAtLine(this.lines.length);
					}
					this.text += "\n"+ i.text;
				}
        	} catch (e){}
        }
        /*else if (text is ParagraphElement)
        {
            //this.textFlow.addChild(text);
            //callLater(setScroll);
        }*/

        this.scrollToMaxYScroll();
    }

    private function scrollToMaxYScroll():Void
    {
        _caretLineIndex = _lines.length;
        scrollToCaret();
    }
}