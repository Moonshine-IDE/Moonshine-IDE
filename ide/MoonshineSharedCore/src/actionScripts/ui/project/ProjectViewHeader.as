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
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	
	import actionScripts.ui.tabview.TabViewTab;

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
								 
			background.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			background.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			closeButton.addEventListener(MouseEvent.MOUSE_OUT, mouseOut); 
		}
		
		override protected function drawButtonState():void
		{
			if (!background) return;
			
			closeButton.x = width-closeButtonWidth;
			
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
			
			/* display close button on mouse over 
			if (_selected)
			{
				if (showCloseButton) closeButton.visible = true;
				
				labelMaskWidth -= closeButtonWidth;
				
				background.graphics.beginFill(selectedBackgroundColor);
				background.graphics.drawRect(0, 0, width, height);
				background.graphics.endFill();
			}
			else
			{
				closeButton.visible = false;				
				
				labelMaskWidth -= 5;
				
				background.graphics.beginFill(backgroundColor);
				background.graphics.drawRect(0, 0, width, height);
				background.graphics.endFill();
			}*/
			
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
		
	}
}