package actionScripts.plugin.console.view;

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
        tlr.backgroundSkin = new RectangleSkin(SolidColor(0x373737, 0.9));
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
                    var replaceDelimiter = "\n";
                    if (i.text.indexOf("\r\n") != -1) {
                        replaceDelimiter = "\r\n";
                    } else if (i.text.indexOf("\r") != -1) {
                        replaceDelimiter = "\r";
                    } else if (i.text.indexOf("\n") != -1) {
                        replaceDelimiter = "\n";
                    } else {
                        _lineDelimiter = defaultLineDelimiter;
                    }

                    // Split lines regardless of line encoding
                    i.text = ~/\r?\n|\r/g.replace(i.text, "");

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