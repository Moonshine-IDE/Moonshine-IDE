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
import openfl.Vector;

extern class ProjectReferenceVO {
	public var name:String;
	public var path:String;
	public var startIn:String;
	public var status:String;
	public var loading:Bool;
	public var sdk:String;
	public var isAway3D:Bool;
	public var isTemplate:Bool;
	public var hiddenPaths:Vector<FileLocation>;
	public var showHiddenPaths:Bool;
}
