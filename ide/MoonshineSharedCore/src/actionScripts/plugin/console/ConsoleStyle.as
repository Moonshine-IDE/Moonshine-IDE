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
package actionScripts.plugin.console
{
	public class ConsoleStyle
	{
		// Styles guaranteed to be present for Console history.
		// Use MarkupTextLineModel to create these.
		public static const NOTICE:uint 	= 10;
		public static const WARNING:uint	= 11;
		public static const ERROR:uint 		= 12;
		public static const WEAK:uint 		= 13;
		public static const SUCCESS:uint	= 14;
		
		// No touching, please.
		internal static var name2style:Object = {};
		
		init();
		private static function init():void
		{
			name2style['notice'] 	= NOTICE;
			name2style['warning'] 	= WARNING;
			name2style['error']		= ERROR;
			name2style['weak'] 		= WEAK;
			name2style['success']	= SUCCESS;
		}
		
		
	}
}