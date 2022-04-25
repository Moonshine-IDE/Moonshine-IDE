package actionScripts.utils;

import flash.net.ServerSocket;

class FindOpenPort {

    public function FindOpenPort():Int
    {
        var portFinder:ServerSocket = new ServerSocket();
        portFinder.bind();
        var port:Int = portFinder.localPort;
        portFinder.close();
        portFinder = null;
        return port;
    }

}