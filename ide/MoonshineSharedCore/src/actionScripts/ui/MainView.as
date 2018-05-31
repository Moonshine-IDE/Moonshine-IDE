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
    
    import mx.binding.utils.BindingUtils;
    import mx.containers.VBox;
    import mx.events.CollectionEvent;
    import mx.events.CollectionEventKind;
    
    import actionScripts.events.GlobalEventDispatcher;
    import actionScripts.locator.IDEModel;
    import actionScripts.ui.divider.IDEHDividedBox;
    import actionScripts.ui.divider.IDEVDividedBox;
    import actionScripts.ui.tabview.CloseTabEvent;
    import actionScripts.ui.tabview.TabEvent;
    import actionScripts.ui.tabview.TabView;
    import actionScripts.valueObjects.ConstantsCoreVO;
    
    import components.views.project.TreeView;
    import components.views.splashscreen.SplashScreen;

    // TODO: Make this an all-in-one flexible layout thing
	public class MainView extends VBox
	{
		public var isProjectViewAdded:Boolean;
		public var bodyPanel:IDEVDividedBox;
		public var mainPanel:IDEHDividedBox;
		public var sidebar:IDEVDividedBox;
		
		private var _mainContent:TabView;
		private var model:IDEModel;
		private var childIndex:int=0;
		
		public function MainView()
		{
			super();
			
			setStyle('backgroundAlpha', 0);
			model = IDEModel.getInstance();
			model.editors.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleEditorChange);
			BindingUtils.bindSetter(activeEditorChanged, model, 'activeEditor');
		}

		public function get mainContent():TabView
		{
			return _mainContent;
		}

		override protected function createChildren():void
		{
			super.createChildren();
			
			setStyle('verticalGap', 0);
			
			bodyPanel = new IDEVDividedBox();
			bodyPanel.percentHeight = 100;
			bodyPanel.percentWidth = 100;
			bodyPanel.setStyle('backgroundColor', 0x424242);
			bodyPanel.setStyle('dividerThickness', 7);
			bodyPanel.setStyle('dividerAffordance', 4);
			bodyPanel.setStyle('verticalGap', 7);
			addChild(bodyPanel);
			
			mainPanel = new IDEHDividedBox();
			mainPanel.percentWidth = 100;
			mainPanel.percentHeight = 100;
			mainPanel.setStyle('dividerThickness', 2);
			mainPanel.setStyle('dividerAffordance', 2);
			mainPanel.setStyle('horizontalGap', 2);
			bodyPanel.addChild(mainPanel);
			
			_mainContent = new TabView();
			_mainContent.styleName = "tabNav";
			_mainContent.percentWidth = 100;
			_mainContent.percentHeight = 100;
			_mainContent.addEventListener(TabEvent.EVENT_TAB_CLOSE, handleTabClose);
			_mainContent.addEventListener(TabEvent.EVENT_TAB_SELECT, focusNewEditor);

			mainPanel.addChild(_mainContent);
			
			sidebar = new IDEVDividedBox();
			sidebar.verticalScrollPolicy = "off";
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
				case CollectionEventKind.REMOVE:
				{
					var editor:DisplayObject = event.items[0] as DisplayObject;
					if (ConstantsCoreVO.NON_CLOSEABLE_TABS.indexOf(IContentWindow(editor).label) == -1)
                    {
                        _mainContent.removeChild(editor);
                    }
					break;
				}
				case CollectionEventKind.ADD:
				{
					editor = model.editors.getItemAt(event.location) as DisplayObject;
                    mainContent.addChild(editor);
                    mainContent.selectedIndex = _mainContent.getChildIndex(editor);
					model.activeEditor = editor as IContentWindow;
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

			if (event.type == TabEvent.EVENT_TAB_SELECT)
			{
                var e:TabEvent = new TabEvent(TabEvent.EVENT_TAB_SELECT, event.child);
                GlobalEventDispatcher.getInstance().dispatchEvent(e);
			}
		}
		
		protected function activeEditorChanged(newActiveEditor:IContentWindow):void
		{
			if (!mainContent) return;

            mainContent.setSelectedTab(model.activeEditor as DisplayObject);
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
			sidebar.addChild(panel as DisplayObject);
			isProjectViewAdded = true;
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
	}
}