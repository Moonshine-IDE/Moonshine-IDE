package;

import js.Node.console;
import js.Node.process;
import js.node.ChildProcess;

class Main {

    public static function main() {

        var cwd = process.cwd();
        var fn = process.mainModule.filename;
        fn = StringTools.replace( fn, "moonshine-basic.js", "server.js" );
        var child = ChildProcess.fork( fn, [ "--stdio" ], { silent: false, cwd: cwd } );
        console.log( "%%%" + child.pid + "%%%" );
        
    }

}
