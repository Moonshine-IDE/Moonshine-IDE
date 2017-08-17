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
package actionScripts.ui.divider
{
	import mx.containers.HDividedBox;
	import mx.core.IUIComponent;
	
	import actionScripts.ui.IPanelWindow;
	

	public class IDEHDividedBox extends HDividedBox
	{
		public function IDEHDividedBox()
		{
			super();
			this.dividerClass = IDEHDivider;
		}
		
		// Normalize all percent-width children to fixed width
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var panels:Vector.<IPanelWindow> = new Vector.<IPanelWindow>();
			var sizes:Vector.<Number> = new Vector.<Number>();
			var totalPercent:int = 0;
			var child:IUIComponent;
			var i:int;
			
			// First run to get the percent totals
			for (i = numChildren; i--;)
			{
				child = IUIComponent(getChildAt(i));
				
				if (!isNaN(child.percentWidth))
				{
					// Accumulate total percentage
					totalPercent += child.percentWidth;
					// Collect for fixing if its an IPanelWindow
					if (child is IPanelWindow)
					{
						panels.push(child);
						sizes.push(child.percentWidth);
					}
				}
			}
			// Second run to apply the normalization
			for (i = panels.length; i--;)
			{
				child = panels[i];
				
				child.explicitWidth = unscaledWidth * sizes[i] / totalPercent;
			}
		}		
	}
}