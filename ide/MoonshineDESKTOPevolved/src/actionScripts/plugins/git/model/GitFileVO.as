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
	[Bindable] public class GitFileVO
	{
		public static const GIT_STATUS_FILE_MODIFIED:String = "gitStatusFileModified";
		public static const GIT_STATUS_FILE_DELETED:String = "gitStatusFileDeleted";
		public static const GIT_STATUS_FILE_NEW:String = "gitStatusFileNew";
		public static const GIT_STATUS_FILE_NEW_NONVERSIONED:String = "gitStatusFileNewNonVersioned";
		public static const GIT_STATUS_FILE_RENAMED:String = "gitStatusFileRenamed";
		public static const GIT_STATUS_FILE_IGNORED:String = "gitStatusFileIgnored";
		public static const GIT_STATUS_FILE_CONFLICT:String = "gitStatusFileHasConflict";
		
		public var path:String;
		
		public function GitFileVO()
		{
		}
		
		private var _isSelected:Boolean;
		public function get isSelected():Boolean
		{
			return _isSelected;
		}
		public function set isSelected(value:Boolean):void
		{
			_isSelected = value;
		}
		
		private var _rawStatus:String;
		public function get rawStatus():String
		{
			return _rawStatus;
		}
		public function set rawStatus(value:String):void
		{
			_rawStatus = value;
			updateStatus();
		}

		private var _status:String;
		public function get status():String
		{
			return _status;
		}
		public function set status(value:String):void
		{
			_status = value;
		}
		
		private var _isSelectable:Boolean;
		public function get isSelectable():Boolean
		{
			return _isSelectable;
		}
		public function set isSelectable(value:Boolean):void
		{
			_isSelectable = value;
		}
		
		protected function updateStatus():void
		{
			switch (rawStatus)
			{
				case "D":
					_status = GIT_STATUS_FILE_DELETED;
					break;
				case "??":
					_status = GIT_STATUS_FILE_NEW_NONVERSIONED;
					break;
				case "A":
					_status = GIT_STATUS_FILE_NEW;
					break;
				case "U":
				case "UU":
					_status = GIT_STATUS_FILE_CONFLICT;
					break;
				case "R":
					_status = GIT_STATUS_FILE_RENAMED;
					break;
				default:
					_status = GIT_STATUS_FILE_MODIFIED;
					break;
			}
		}
	}
}