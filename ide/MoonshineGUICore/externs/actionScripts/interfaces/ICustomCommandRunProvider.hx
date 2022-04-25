package actionScripts.interfaces;

import actionScripts.plugin.build.vo.BuildActionVO;

interface ICustomCommandRunProvider {

    function runOrUpdate(command:BuildActionVO):Void;
    
}