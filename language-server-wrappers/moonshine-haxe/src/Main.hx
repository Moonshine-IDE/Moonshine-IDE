package;

import js.Node.console;
import js.Node.process;
import js.node.ChildProcess;

class Main {

    static var execPath:String;
    static var pid:Int;

    public static function main() {

        var cwd = process.cwd();
        var fn = process.mainModule.filename;
        fn = StringTools.replace( fn, "moonshine-haxe.js", "server.js" );
        var child = ChildProcess.fork( fn, [], { silent: false, cwd: cwd } );
        console.log( "%%%" + child.pid + "%%%" );
        
    }

}
