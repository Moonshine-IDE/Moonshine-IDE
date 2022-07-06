package moonshine.data.preferences;

import haxe.DynamicAccess;

typedef Workspace = {

    var ?current:String;
    var ?workspaces:DynamicAccess<Array<String>>;

}