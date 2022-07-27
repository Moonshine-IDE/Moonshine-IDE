/*
	Copyright 2020 Prominic.NET, Inc.

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License

	Author: Prominic.NET, Inc.
	No warranty of merchantability or fitness of any kind.
	Use this software at your own risk.
 */

package actionScripts.interfaces;

import actionScripts.factory.FileLocation;

extern interface IFileBridge {
	@:flash.property
	public var url(default, default):String;

	@:flash.property
	public var nativeURL(default, default):String;

	@:flash.property
	public var nativePath(default, default):String;

	@:flash.property
	public var extension(default, default):String;

	@:flash.property
	public var name(default, default):String;

	@:flash.property
	public var nameWithoutExtension(default, null):String;

	@:flash.property
	public var parent(default, null):FileLocation;

	@:flash.property
	public var exists(default, null):Bool;

	@:flash.property
	public var isDirectory(default, default):Bool;

	public function read():Dynamic;

	public function canonicalize():Void;

	public function resolvePath(path:String, toRelativePath:String = null):FileLocation;

	public function browseForDirectory(title:String, selectListener:(file:Any) -> Void, ?cancelListener:() -> Void, ?startFromLocation:String):Void;

	public function getRelativePath(ref:FileLocation, useDotDot:Bool = false):String;
}
