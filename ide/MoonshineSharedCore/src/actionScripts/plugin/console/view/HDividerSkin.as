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
package actionScripts.plugin.console.view
{
	import mx.skins.ProgrammaticSkin;

	public class HDividerSkin extends ProgrammaticSkin
	{
		public function HDividerSkin()
		{
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			graphics.lineStyle(1, 0x2d2d2d);
			graphics.moveTo(0, 0);
			graphics.lineTo(width, 0);
			
			graphics.lineStyle(1, 0x5a5a5a);
			graphics.moveTo(0, 1);
			graphics.lineTo(width, 1);
		}
		
	}
}