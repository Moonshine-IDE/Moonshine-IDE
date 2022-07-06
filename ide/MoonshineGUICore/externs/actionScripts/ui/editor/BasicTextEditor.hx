package actionScripts.ui.editor;

import moonshine.editor.text.TextEditor;
import actionScripts.factory.FileLocation;

extern class BasicTextEditor {

    public var editor:TextEditor;

    public function saveAs(file:FileLocation=null):Void;

}