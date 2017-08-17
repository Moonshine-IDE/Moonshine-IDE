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
package actionScripts.ui
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	
	import mx.binding.utils.BindingUtils;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.events.CollectionEvent;
	
	import actionScripts.events.GlobalEventDispatcher;
	import actionScripts.locator.IDEModel;
	import actionScripts.ui.divider.IDEHDividedBox;
	import actionScripts.ui.divider.IDEVDividedBox;
	import actionScripts.ui.tabview.CloseTabEvent;
	import actionScripts.ui.tabview.TabEvent;
	import actionScripts.ui.tabview.TabView;
	
	import components.views.project.TreeView;
	
	// TODO: Make this an all-in-one flexible layout thing
	public class MainView extends VBox
	{
		public var isProjectViewAdded:Boolean;
		
		public var bodyPanel:IDEVDividedBox;
		private var mainContent:TabView;
		private var mainPanel:IDEHDividedBox;
		private var model:IDEModel;
		private var sidebar:IDEVDividedBox;
		private var childIndex:int=0;
		[Embed("/elements/images/Divider.png")]
		private const customDividerSkin:Class;
		public function MainView()
		{
			super();
			
			model = IDEModel.getInstance();
			model.editors.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleEditorChange);
			BindingUtils.bindSetter(activeEditorChanged, model, 'activeEditor');
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			setStyle('verticalGap', 0);
			
			bodyPanel = new IDEVDividedBox();
			bodyPanel.percentHeight = 100;
			bodyPanel.percentWidth = 100;
			bodyPanel.setStyle('backgroundColor', 0xa0a0a0);
			bodyPanel.setStyle('dividerThickness', 6);
			bodyPanel.setStyle('dividerAffordance', 2);
			bodyPanel.setStyle('verticalGap', 6);
			bodyPanel.setStyle('dividerSkin',customDividerSkin);
			addChild(bodyPanel);
			
			mainPanel = new IDEHDividedBox();
			mainPanel.percentWidth = 100;
			mainPanel.percentHeight = 100;
			mainPanel.setStyle('dividerThickness', 2);
			mainPanel.setStyle('dividerAffordance', 2);
			mainPanel.setStyle('horizontalGap', 2);
			bodyPanel.addChild(mainPanel);
			
			mainContent = new TabView();
			mainContent.styleName = "tabNav";
			mainContent.percentWidth = 100;
			mainContent.percentHeight = 100;
			mainContent.addEventListener(TabEvent.EVENT_TAB_CLOSE, handleTabClose);
			mainContent.addEventListener(TabEvent.EVENT_TAB_SELECT, focusNewEditor);
			mainPanel.addChild(mainContent);
			
			sidebar = new IDEVDividedBox();
			sidebar.percentHeight = 100;
			sidebar.width = 300;
			sidebar.setStyle('backgroundColor', 0xCFCFCF);
			sidebar.setStyle('dividerThickness', 2);
			sidebar.setStyle('dividerAffordance', 2);
			sidebar.setStyle('verticalGap', 2);
		}
		
		protected function handleEditorChange(event:CollectionEvent):void
		{
			switch (event.kind)
			{
				case 'remove':
				{
					var editor:DisplayObject = event.items[0] as DisplayObject;
					mainContent.removeChild(editor);
					// This is the only thing that changes when user saves as
					if (editor is IContentWindow)
					{
						IContentWindow(editor).removeEventListener('labelChanged', handleUpdateLabel);
					}
					break;
				}
				case 'add':
				{
					editor = model.editors.getItemAt(event.location) as DisplayObject;
					mainContent.addChild(editor);
					mainContent.selectedIndex = mainContent.getChildIndex(editor);
					model.activeEditor = editor as IContentWindow;
					if (editor is IContentWindow)
					{
						IContentWindow(editor).addEventListener('labelChanged', handleUpdateLabel);
					}
					break;
				}
					
			} 
		}
		
		protected function focusNewEditor(event:TabEvent):void
		{
			if (event.child is IContentWindow)
			{
				model.activeEditor = event.child as IContentWindow;
			}
		}
		
		protected function activeEditorChanged(newActiveEditor:IContentWindow):void
		{
			if (!mainContent) return;
			var childIndex:int = mainContent.getChildIndex(model.activeEditor as DisplayObject);
			if (childIndex != mainContent.selectedIndex) 
			{
				mainContent.selectedIndex = childIndex;
			}
			
			updateLabel(newActiveEditor);
		}
		
		protected function handleUpdateLabel(event:Event):void
		{
			/*var e:IContentWindow = event.target as IContentWindow;
			updateLabel(event.target as IContentWindow); */
		}
		
		protected function updateLabel(editor:IContentWindow):void
		{
			/*var editorLabel:String = editor.label;
			FlexGlobals.topLevelApplication.title = "Moonshine — " + editor.longLabel;	*/
		}
		
		public function handleTabClose(event:TabEvent):void
		{
			// We handle this by ourselves.
			event.preventDefault(); 
			
			var e:CloseTabEvent = new CloseTabEvent(CloseTabEvent.EVENT_CLOSE_TAB, event.child);
			GlobalEventDispatcher.getInstance().dispatchEvent(e);
		}
		
		public function addPanel(panel:IPanelWindow):void
		{
			if(panel.document.className == "TreeView")
				childIndex = 0;
			else
				childIndex = mainPanel.numChildren-1;
		   if (!sidebar.stage) mainPanel.addChildAt(sidebar,childIndex);
			sidebar.addChildAt(panel as DisplayObject,childIndex);
			isProjectViewAdded = true;
			/*if (!sidebar.stage) mainPanel.addChild(sidebar);
			sidebar.addChild(panel as DisplayObject);
			isProjectViewAdded = true*/
		}
		
		public function removePanel(panel:IPanelWindow):void
		{
			if (sidebar) sidebar.removeChild(panel as DisplayObject);
			if (sidebar.numChildren == 0) mainPanel.removeChild(sidebar);
		}
		
		public function getTreeViewPanel():TreeView
		{
			if (isProjectViewAdded)
			{
				for (var i:int=0; i < sidebar.numElements; i++)
				{
					if (sidebar.getElementAt(i) is TreeView) return (sidebar.getElementAt(i) as TreeView);
				}
			}
			
			return null;
		}
		
		public function rotatePanel(panel:IPanelWindow, newPanel:IPanelWindow):void
		{
			/*if (!sidebar || !panel.stage) return;
			
			var effect:PanelRotationEffect = new PanelRotationEffect(sidebar, panel, newPanel);
			effect.play();*/
		}
		
		private function addEditor(editor:IContentWindow):void 
		{
			mainContent.addChild(editor as DisplayObject);
			mainContent.selectedIndex = mainContent.getChildIndex(editor as DisplayObject);
		}
		
		private function replaceEditorWith(newEditor:IContentWindow):void 
		{	
			mainContent.removeChildAt( mainContent.selectedIndex );
			mainContent.addChild(newEditor as DisplayObject);
		}
	}
}