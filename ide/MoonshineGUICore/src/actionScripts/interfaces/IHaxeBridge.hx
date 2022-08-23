package actionScripts.interfaces;

import actionScripts.factory.FileLocation;
import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;

interface IHaxeBridge extends IProject {

    function testHaxe(file:Dynamic):FileLocation;
    function parseHaxe(file:FileLocation, projectName:String=null, settingsFileLocation:FileLocation = null):HaxeProjectVO;

}