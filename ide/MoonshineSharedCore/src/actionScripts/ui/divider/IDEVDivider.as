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
	import mx.containers.dividedBoxClasses.BoxDivider;

	public class IDEVDivider extends BoxDivider
	{
		public function IDEVDivider()
		{
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			/*
				This would have been easier if the knob-skin could draw as it wanted.
				Currently it's /removed/ if the divider is thinner than 6 pixels.
				So we override & draw like this.
			*/
			
			graphics.beginFill(0x2d2d2d);
			graphics.drawRect(0, 0, width, 1);
			graphics.endFill();
				
			graphics.beginFill(0x5a5a5a);
			graphics.drawRect(0, 1, width, 1);
			graphics.endFill();
		}
		
	}
}