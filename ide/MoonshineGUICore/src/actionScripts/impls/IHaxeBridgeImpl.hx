/**

Copyright (C) 2016-present Prominic.NET, Inc.
 
This program is free software: you can redistribute it and/or modify
it under the terms of the Server Side Public License, version 1,
as published by MongoDB, Inc.
 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
Server Side Public License for more details.

You should have received a copy of the Server Side Public License
along with this program. If not, see
http://www.mongodb.com/licensing/server-side-public-license.

As a special exception, the copyright holders give permission to link the
code of portions of this program with the OpenSSL library under certain
conditions as described in each individual source file and distribute
linked combinations including the program with the OpenSSL library. You
must comply with the Server Side Public License in all respects for
all of the code used other than as permitted herein. If you modify file(s)
with this exception, you may extend this exception to your version of the
file(s), but you are not obligated to do so. If you do not wish to do so,
delete this exception statement from your version. If you delete this
exception statement from all source files in the program, then also delete
it in the license file.

*/

package actionScripts.impls;

import actionScripts.plugins.haxelsp.HaxeLanguageServerPlugin;
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
		return [HaxeSyntaxPlugin, HaxeProjectPlugin, HaxeBuildPlugin, HaxelibPlugin, HaxeLanguageServerPlugin,];
	}

	public function getPluginsNotToShowInSettings():Array<Class<PluginBase>> {
		return [HaxeSyntaxPlugin, HaxeProjectPlugin, HaxelibPlugin, HaxeLanguageServerPlugin,];
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