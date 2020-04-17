////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.impls
{
	import spark.components.TitleWindow;
	
	import actionScripts.locator.IDEModel;
	import actionScripts.plugin.console.ConsoleOutputter;
	import actionScripts.plugins.ui.editor.dominoFormBuilder.DominoFormBuilderWrapper;
	import actionScripts.ui.resizableTitleWindow.ResizableTitleWindow;
	
	import components.skins.ResizableTitleWindowSkin;
	
	import view.dominoFormBuilder.DominoTabularForm;
	import view.interfaces.IDominoFormBuilderLibraryBridge;

	public class IDominoFormBuilderLibraryBridgeImp extends ConsoleOutputter implements IDominoFormBuilderLibraryBridge
	{
		private var model:IDEModel = IDEModel.getInstance();
		
		//--------------------------------------------------------------------------
		//
		//  INTERFACE API
		//
		//--------------------------------------------------------------------------
		
		public function getTabularEditorInterfaceWrapper():DominoTabularForm
		{
			var editor:DominoFormBuilderWrapper = model.activeEditor as DominoFormBuilderWrapper;
			if (editor)
			{
				return editor.tabularEditorInterface;
			}
			
			return null;
		}
		
		public function getNewMoonshinePopup():TitleWindow
		{
			var tmpPopup:ResizableTitleWindow = new ResizableTitleWindow();
			tmpPopup.setStyle("skinClass", ResizableTitleWindowSkin);
			
			return tmpPopup;
		}
	}
}