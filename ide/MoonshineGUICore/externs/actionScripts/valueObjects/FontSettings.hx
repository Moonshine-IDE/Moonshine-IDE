package actionScripts.valueObjects;

import flash.text.engine.FontDescription;
import flash.text.engine.FontLookup;
import flash.text.engine.FontPosture;
import flash.text.engine.FontWeight;

class FontSettings {

    public var defaultFontFamily:String = "DejaVuMonoTF";
    public var defaultFontSize:Float = 13;
    public var defaultFontEmbedded:Bool = true;
    public var defaultFontDescription:FontDescription =
        new FontDescription("DejaVuMono", FontWeight.NORMAL, FontPosture.NORMAL, FontLookup.EMBEDDED_CFF);
    public var uiFontDescription:FontDescription =
        new FontDescription("DejaVuSans", FontWeight.NORMAL, FontPosture.NORMAL, FontLookup.EMBEDDED_CFF);
        
    // Width of a tab-stop, in characters
    public var tabWidth:Int = 4;

    public function new() {
        
    }
}