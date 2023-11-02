////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
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
    import actionScripts.plugin.fullscreen.events.FullscreenEvent;

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
		private var dispatcher:GlobalEventDispatcher = GlobalEventDispatcher.getInstance();
		private var isSectionInFullscreen:Boolean;
		
		public function MainView()
		{
			super();
			
			setStyle('backgroundAlpha', 0);
			model = IDEModel.getInstance();
			model.editors.addEventListener(CollectionEvent.COLLECTION_CHANGE, handleEditorChange);
			dispatcher.addEventListener(FullscreenEvent.EVENT_SECTION_FULLSCREEN, handleToggleSectionFullscreen);
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
			e.isUserTriggered = true;
			dispatcher.dispatchEvent(e);
		}
		
		public function addPanel(panel:IPanelWindow):void
		{
			if(panel.document && panel.document.className == "TreeView")
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
		
		private function handleToggleSectionFullscreen(event:FullscreenEvent):void
		{
			if (isSectionInFullscreen) 
			{
				this.toggle(event);
				return;
			}
			
			switch (event.value)
			{
				case FullscreenEvent.SECTION_BOTTOM:
					this.bodyPanel.setStyle('dividerSkin', null);
					this.bodyPanel.setStyle('dividerAlpha', 0);
					this.bodyPanel.setStyle('dividerThickness', 0);
					this.bodyPanel.setStyle('dividerAffordance', 0);
					this.bodyPanel.setStyle('verticalGap', 0);
					break;
			}
			
			isSectionInFullscreen = true;
		}
		
		private function toggle(event:FullscreenEvent):void
		{	
			switch (event.value)
			{
				case FullscreenEvent.SECTION_BOTTOM:
					this.bodyPanel.setStyle('dividerThickness', 7);
					this.bodyPanel.setStyle('dividerAffordance', 4);
					this.bodyPanel.setStyle('verticalGap', 7);
					this.bodyPanel.setStyle('dividerAlpha', 1);
					break;
			}
			
			isSectionInFullscreen = false;
		}
	}
}