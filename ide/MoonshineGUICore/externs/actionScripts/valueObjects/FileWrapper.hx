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

package actionScripts.valueObjects;

import actionScripts.factory.FileLocation;

extern class FileWrapper {
	public var projectReference:ProjectReferenceVO;

	@:flash.property
	public var shallUpdateChildren(default, default):Bool;

	@:flash.property
	public var file(default, default):FileLocation;

	@:flash.property
	public var isHidden(default, never):Bool;

	@:flash.property
	public var isRoot(default, default):Bool;

	@:flash.property
	public var isSourceFolder(default, default):Bool;

	@:flash.property
	public var name(default, default):String;

	@:flash.property
	public var defaultName(default, default):String;

	@:flash.property
	public var children(default, default):Array<Dynamic>;

	@:flash.property
	public var nativePath(default, never):String;

	@:flash.property
	public var isWorking(default, default):Bool;

	@:flash.property
	public var isDeleting(default, default):Bool;
}
