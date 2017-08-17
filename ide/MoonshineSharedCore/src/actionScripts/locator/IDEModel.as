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
package actionScripts.locator
{
	import mx.collections.ArrayCollection;
	import mx.core.IFlexDisplayObject;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.interfaces.IAboutBridge;
	import actionScripts.interfaces.IContextMenuBridge;
	import actionScripts.interfaces.IFileBridge;
	import actionScripts.interfaces.IFlexCoreBridge;
	import actionScripts.ui.IContentWindow;
	import actionScripts.ui.MainView;
	import actionScripts.utils.NoSDKNotifier;
	import actionScripts.valueObjects.ProjectVO;
	import actionScripts.valueObjects.UserAuthVO;

	[Bindable] public class IDEModel
	{
		private static var instance:IDEModel;
		
		public static function getInstance():IDEModel 
		{	
			if (!instance) instance = new IDEModel();
			return instance;
		}
		
		public var fileCore: IFileBridge;
		public var contextMenuCore: IContextMenuBridge;
		public var flexCore: IFlexCoreBridge;
		public var aboutCore: IAboutBridge;
		
		// Currently active editor
		public var activeEditor:IContentWindow;
		
		// Array of current editors
		public var editors:ArrayCollection = new ArrayCollection();
		public var projects:ArrayCollection = new ArrayCollection();
		public var selectedprojectFolders:ArrayCollection = new ArrayCollection();;
		public var mainView:MainView;
		
		public var activeProject:ProjectVO;
		public var defaultSDK:FileLocation;
		public var noSDKNotifier:NoSDKNotifier = NoSDKNotifier.getInstance();
		public var sdkInstallerView:IFlexDisplayObject;
		public var antHomePath:FileLocation;
		public var antScriptFile:FileLocation; 
		public var javaPathForTypeAhead:FileLocation;
		public var isCodeCompletionJavaPresent:Boolean;
		
		public var recentlyOpenedFiles:ArrayCollection = new ArrayCollection();
		public var recentlyOpenedProjects:ArrayCollection = new ArrayCollection();
		public var recentlyOpenedProjectOpenedOption:ArrayCollection = new ArrayCollection();
		public var recentSaveProjectPath:ArrayCollection = new ArrayCollection();
		public var userSavedSDKs:ArrayCollection = new ArrayCollection();
		public var userSavedTempSDKPath:String;
		public var userAuth:UserAuthVO = new UserAuthVO();
		public var isAuthenticated:Boolean = false;
		public var isIndividualCloseTabAlertShowing:Boolean;
		public var saveFilesBeforeBuild:Boolean = false;
		
		public var version: String = "1.0.0";
		public var build: String = "";
		
		public function removeEditor(editor:Object):Boolean
		{
			var index:int = editors.getItemIndex(editor);
			if (index > -1)
			{
				editors.removeItemAt(index);
				return true;
			}
			
			return false;
		}
	}
}