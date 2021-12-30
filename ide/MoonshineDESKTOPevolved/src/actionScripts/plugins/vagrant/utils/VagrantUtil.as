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
package actionScripts.plugins.vagrant.utils
{
	public class VagrantUtil
	{
		public static const VAGRANT_UP:String = "Up";
		public static const VAGRANT_HALT:String = "Halt";
		public static const VAGRANT_RELOAD:String = "Reload (to sync files)";
		public static const VAGRANT_SSH:String = "SSH";
		public static const VAGRANT_MENU_OPTIONS:Array = [VAGRANT_UP, VAGRANT_HALT, VAGRANT_RELOAD, VAGRANT_SSH];
	}
}