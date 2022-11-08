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
package actionScripts.ui.project
{
	import actionScripts.plugin.workspace.WorkspacePlugin;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.WorkspaceVO;

	import flash.events.Event;
    import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	
	import actionScripts.ui.tabview.TabViewTab;
	import actionScripts.events.GlobalEventDispatcher;
	import moonshine.plugin.workspace.events.WorkspaceEvent;

	import spark.components.DropDownList;

	import spark.components.Image;

	[Event(name="scrollFromSource", type="flash.events.Event")]
    public class ProjectViewHeader extends TabViewTab
	{
		public function ProjectViewHeader()
		{
			super();
			percentWidth = 100;
			backgroundColor = 0xeeeeee;
			selectedBackgroundColor = 0xeeeeee;
			textColor = 0x2d2d2d;
			closeButtonColor = 0x444444;
			innerGlowColor = 0xFFFFFF;
			selected = false;

			this.height = 30;

			GlobalEventDispatcher.getInstance().addEventListener(
					WorkspacePlugin.EVENT_WORKSPACE_COLLECTION_UPDATED,
					onWorkspaceListUpdates,
					false, 0, true
			);
		}

        [Embed(source='/elements/images/scroll_from_source.png')]
		private var scrollFromSourceIcon:Class;

		private var scrollFromSource:Image;
		private var workspaceDropdown:DropDownList;

		private var _showScrollFromSrouceIcon:Boolean;
		public function set showScrollFromSourceIcon(value:Boolean):void
		{
			_showScrollFromSrouceIcon = value;
		}

		private function mouseOut(event:MouseEvent):void
		{
			if (event.relatedObject == closeButton) return;
			if (event.relatedObject == background) 	return;
			selected = false;
		}
		
		private function mouseOver(event:MouseEvent):void
		{
			selected = true;
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			background.filters = [	new GlowFilter(0xFFFFFF, 1, 6, 6, 1, 1, true),
								  	new DropShadowFilter(2, -90, 0x0, 0.15, 5, 6, 1, 1, true)
								 ];

			workspaceDropdown = new DropDownList();
			workspaceDropdown.dataProvider = WorkspacePlugin.workspacesForViews;
			workspaceDropdown.requireSelection = true;
			workspaceDropdown.labelFunction = workspaceLabelFunction;
			workspaceDropdown.addEventListener(Event.CHANGE, onWorkspaceDropdownChange, false, 0, true);
			addChild(workspaceDropdown);

			if (_showScrollFromSrouceIcon)
			{
                scrollFromSource = new Image();
				scrollFromSource.source = scrollFromSourceIcon;
				scrollFromSource.verticalCenter = 0;
				scrollFromSource.width = scrollFromSource.height = 16;
				scrollFromSource.buttonMode = true;
				scrollFromSource.toolTip = resourceManager.getString('resources', 'SELECT_OPEN_FILE');
				scrollFromSource.addEventListener(MouseEvent.CLICK, onScrollToSourceIconClick);
				
				addChild(scrollFromSource);
			}

			background.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			background.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			closeButton.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);

			labelView.includeInLayout = labelView.visible = false;
		}

		override protected function drawButtonState():void
		{
			if (!background) return;
			
			closeButton.x = width - closeButtonWidth;
			closeButton.y = 4;

			background.graphics.clear();
			background.graphics.lineStyle(1, 0x0, 0.5);
			background.graphics.moveTo(0, -1);
			background.graphics.lineTo(width, -1);
			background.graphics.lineStyle(0, 0, 0);
			
			var gradWidth:int = 8;
			var labelMaskWidth:int = width-gradWidth;
			
			if (isNaN(getStyle('textPaddingLeft')) == false)
			{
				labelMaskWidth += int(getStyle('textPaddingLeft'));
			}
			
			// Show close button when project view opens
			if (showCloseButton) closeButton.visible = true;
			
			labelMaskWidth -= closeButtonWidth;
			
			background.graphics.beginFill(selectedBackgroundColor);
			background.graphics.drawRect(0, 0, width, height);
			background.graphics.endFill();

			labelViewMask.graphics.clear();
			labelViewMask.graphics.beginFill(0x0, 1);
			labelViewMask.graphics.drawRect(0, 0, labelMaskWidth, height);
			labelViewMask.graphics.endFill();
			
			var mtr:Matrix = new Matrix();
			mtr.createGradientBox(gradWidth, height, 0, labelMaskWidth, 0);
			labelViewMask.graphics.beginGradientFill('linear', [0x0, 0x0], [1, 0], [0, 255], mtr);
			labelViewMask.graphics.drawRect(labelMaskWidth, 0, gradWidth, height);
			labelViewMask.graphics.endFill();
		}

		override protected function onTabViewTabMouseOverOut(event:MouseEvent):void
		{

		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			if (scrollFromSource)
			{
				scrollFromSource.y = (height - scrollFromSource.height) / 2;
				scrollFromSource.x = width - scrollFromSource.width - closeButtonWidth - 5;
			}

			if (workspaceDropdown)
			{
				workspaceDropdown.x = 6;
				workspaceDropdown.y = 4;
				workspaceDropdown.width = scrollFromSource.x - 18;
				workspaceDropdown.height = this.height - 8;
			}
		}
		
        private function onScrollToSourceIconClick(event:MouseEvent):void
        {
		    dispatchEvent(new Event("scrollFromSource"));
        }

		private function workspaceLabelFunction(item:Object):String
		{
			if (item == workspaceDropdown.selectedItem)
			{
				return "Workspace: "+ item.label;
			}

			return item.label;
		}

		private function onWorkspaceListUpdates(event:Event):void
		{
			workspaceDropdown.dataProvider = WorkspacePlugin.workspacesForViews;
			workspaceDropdown.callLater(function():void
			{
				for each (var workspace:WorkspaceVO in workspaceDropdown.dataProvider)
				{
					if (workspace.label == ConstantsCoreVO.CURRENT_WORKSPACE)
					{
						workspaceDropdown.selectedItem = workspace;
						break;
					}
				}
			});
		}

		private function onWorkspaceDropdownChange(event:Event):void
		{
			GlobalEventDispatcher.getInstance().dispatchEvent(
					new WorkspaceEvent(WorkspaceEvent.NEW_WORKSPACE_WITH_LABEL, workspaceDropdown.selectedItem.label)
			);
		}
    }
}