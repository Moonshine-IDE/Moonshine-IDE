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

extern class ResourceVO {
	public var name:String;
	public var sourceWrapper:FileWrapper;

	@:flash.property
	public var resourcePath(default, default):String;

	@:flash.property
	public var resourceExtension(default, never):String;

	@:flash.property
	public var resourcePathWithoutRoot(default, never):String;
}
