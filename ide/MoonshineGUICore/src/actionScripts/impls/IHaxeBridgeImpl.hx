package actionScripts.impls;

import actionScripts.events.NewProjectEvent;
import actionScripts.factory.FileLocation;
import actionScripts.interfaces.IHaxeBridge;
import actionScripts.plugin.PluginBase;
import actionScripts.plugin.haxe.hxproject.CreateHaxeProject;
import actionScripts.plugin.haxe.hxproject.HaxeProjectPlugin;
import actionScripts.plugin.haxe.hxproject.importer.HaxeImporter;
import actionScripts.plugin.haxe.hxproject.vo.HaxeProjectVO;
import actionScripts.plugin.syntax.HaxeSyntaxPlugin;
import actionScripts.plugins.core.ProjectBridgeImplBase;
import actionScripts.plugins.haxe.HaxeBuildPlugin;
import actionScripts.plugins.haxelib.HaxelibPlugin;

class IHaxeBridgeImpl extends ProjectBridgeImplBase implements IHaxeBridge {
	public var runtimeVersion(get, never):String;
	public var version(get, never):String;

	private var executeCreateHaxeProject:CreateHaxeProject;

	private function get_runtimeVersion():String
		return "";

	private function get_version():String
		return "";

	public function new() {
		super();
	}

	public function getCorePlugins():Array<Class<PluginBase>> {
		return [];
	}

	public function getDefaultPlugins():Array<Class<PluginBase>> {
		return [HaxeSyntaxPlugin, HaxeProjectPlugin, HaxeBuildPlugin, HaxelibPlugin,];
	}

	public function getPluginsNotToShowInSettings():Array<Class<PluginBase>> {
		return [HaxeSyntaxPlugin, HaxeProjectPlugin, HaxelibPlugin,];
	}

	override public function createProject(event:NewProjectEvent):Void {
		executeCreateHaxeProject = new CreateHaxeProject(event);
	}

	public function testHaxe(file:Dynamic):FileLocation {
		return HaxeImporter.test(file);
	}

	public function parseHaxe(file:FileLocation, projectName:String = null, settingsFileLocation:FileLocation = null):HaxeProjectVO {
		return HaxeImporter.parse(file, projectName, settingsFileLocation);
	}
}