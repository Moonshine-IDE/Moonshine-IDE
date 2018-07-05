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
package actionScripts.plugins.git.model
{
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;

	public class GitProjectVO
	{
		public var currentBranch:String;
		public var remoteURL:String;
		public var branchList:ArrayCollection;
		public var sessionUser:String;
		public var sessionPassword:String;
		public var rootLocal:File;
		public var projectPath:String;
		
		public function GitProjectVO()
		{
		}
	}
}