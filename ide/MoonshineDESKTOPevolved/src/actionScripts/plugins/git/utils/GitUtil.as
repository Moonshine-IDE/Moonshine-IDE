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
package actionScripts.plugins.git.utils
{
	import mx.collections.ArrayCollection;
	
	import actionScripts.plugins.git.model.GitFileVO;

	public class GitUtil
	{
		public static function setFileSelectionForCommitAction(collection:ArrayCollection):void
		{
			for each (var file:GitFileVO in collection)
			{
				file.isSelectable = false;
				file.isSelected = false;
				switch (file.status)
				{
					case GitFileVO.GIT_STATUS_FILE_CONFLICT:
					case GitFileVO.GIT_STATUS_FILE_IGNORED:
					case GitFileVO.GIT_STATUS_FILE_NEW_DELETED:
						break;
					case GitFileVO.GIT_STATUS_FILE_NEW_NONVERSIONED:
					case GitFileVO.GIT_STATUS_FILE_NEW:
					case GitFileVO.GIT_STATUS_FILE_NEW_MODIFIED:
						file.isSelectable = true;
						break;
					case GitFileVO.GIT_STATUS_FILE_RENAMED:
					case GitFileVO.GIT_STATUS_FILE_DELETED:
					case GitFileVO.GIT_STATUS_FILE_MODIFIED:
						file.isSelectable = true;
						file.isSelected = true;
						break;
				}
			}
		}
		
		public static function setFileSelectionForRevertAction(collection:ArrayCollection):void
		{
			for each (var file:GitFileVO in collection)
			{
				file.isSelectable = false;
				file.isSelected = false;
				switch (file.status)
				{
					case GitFileVO.GIT_STATUS_FILE_CONFLICT:
					case GitFileVO.GIT_STATUS_FILE_NEW_NONVERSIONED:
					case GitFileVO.GIT_STATUS_FILE_IGNORED:
						break;
					case GitFileVO.GIT_STATUS_FILE_NEW:
					case GitFileVO.GIT_STATUS_FILE_RENAMED:
					case GitFileVO.GIT_STATUS_FILE_DELETED:
					case GitFileVO.GIT_STATUS_FILE_NEW_MODIFIED:
					case GitFileVO.GIT_STATUS_FILE_NEW_DELETED:
					case GitFileVO.GIT_STATUS_FILE_MODIFIED:
						file.isSelectable = true;
						break;
				}
			}
		}
	}
}