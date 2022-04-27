/*
	Copyright 2022 Prominic.NET, Inc.

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
package actionScripts.plugin.core.compiler;

import flash.events.Event;

class ProjectActionEvent extends Event {
	public static final BUILD_DEBUG:String = "projectBuildDebug";
	public static final BUILD_AND_DEBUG:String = "projectBuildAndDebug";
	public static final BUILD_RELEASE:String = "projectBuildRelease";
	public static final BUILD_AND_RUN:String = "projectBuildAndRun";
	public static final RUN_AFTER_DEBUG:String = "projectCompilerRunAfterDebug";
	public static final BUILD:String = "projectCompilerBuild";
	public static final CLEAN_PROJECT:String = "cleanProject";
	public static final SET_DEFAULT_APPLICATION:String = "setDefaultApplication";

	public var value:Dynamic;

	public function new(type:String, value:Dynamic = null, bubbles:Bool = false, cancelable:Bool = false) {
		this.value = value;
		super(type, bubbles, cancelable);
	}
}