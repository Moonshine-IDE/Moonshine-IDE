package actionScripts.plugin.haxe.hxproject.importer;

import actionScripts.factory.FileLocation;
import actionScripts.plugin.core.importer.FlashDevelopImporterBase;
import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;
import openfl.filesystem.File;

extern class HaxeImporter extends FlashDevelopImporterBase {

    static function test(file:File):FileLocation;
    static function parse(file:FileLocation, projectName:String = null, settingsFileLocation:FileLocation = null):HaxeProjectVO;

}