////////////////////////////////////////////////////////////////////////////////
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
// 
////////////////////////////////////////////////////////////////////////////////
package actionScripts.valueObjects
{
	public class EnvironmentExecPaths
	{
		public static const GRADLE_ENVIRON_EXEC_PATH:String = ConstantsCoreVO.IS_MACOS ? 
			"$GRADLE_HOME/bin/gradle" : "%GRADLE_HOME%\\bin\\gradle";
		public static const GRAILS_ENVIRON_EXEC_PATH:String = ConstantsCoreVO.IS_MACOS ? 
			"$GRAILS_HOME/bin/grails" : "%GRAILS_HOME%\\bin\\grails";
		public static const HAXE_ENVIRON_EXEC_PATH:String = ConstantsCoreVO.IS_MACOS ? 
			"$HAXE_HOME/haxe" : "%HAXE_HOME%\\haxe.exe";
		public static const HAXELIB_ENVIRON_EXEC_PATH:String = ConstantsCoreVO.IS_MACOS ? 
			"$HAXE_HOME/haxelib" : "%HAXE_HOME%\\haxelib.exe";
		public static const NEKO_ENVIRON_EXEC_PATH:String = ConstantsCoreVO.IS_MACOS ? 
			"$NEKO_HOME/neko" : "%NEKO_HOME%\\neko.exe";
		public static const JAVA_ENVIRON_EXEC_PATH:String = ConstantsCoreVO.IS_MACOS ? 
			"$JAVA_HOME/bin/java" : "%JAVA_HOME%\\bin\\java.exe";
	}
}