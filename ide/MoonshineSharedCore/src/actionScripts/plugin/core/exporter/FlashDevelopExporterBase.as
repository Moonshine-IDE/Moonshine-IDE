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
package actionScripts.plugin.core.exporter
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.utils.OSXBookmarkerNotifiers;
	import actionScripts.valueObjects.ProjectVO;
	
	public class FlashDevelopExporterBase
	{
		protected static function exportPaths(v:Vector.<FileLocation>, container:XML, element:XML, p:ProjectVO, absolutePath:Boolean=false, appendAsValue:Boolean=false, nullValue:String=null):XML
		{
			for each (var f:FileLocation in v) 
			{
				var e:XML = element.copy();
				var relative:String = p.folderLocation.fileBridge.getRelativePath(f, true);
				if (absolutePath) relative = null;
				if (appendAsValue) e.appendChild(relative ? relative : f.fileBridge.nativePath);
				else e.@path = relative ? relative : f.fileBridge.nativePath;
				container.appendChild( e );
			}
			
			if (v.length == 0 && nullValue)
			{
				element.appendChild(nullValue);
				container.appendChild(nullValue);
			}
			else if (v.length == 0)
			{
				container.appendChild(<!-- <empty/> -->);
			}
			
			return container;
		}
		
		protected static function exportPathString(v:Vector.<String>, container:XML, element:XML, p:ProjectVO, absolutePath:Boolean=false, appendAsValue:Boolean=false, nullValue:String=null):XML
		{
			for each (var f:String in v) 
			{
				var e:XML = element.copy();
				if (appendAsValue) e.appendChild(f);
				else e.@path = f;
				container.appendChild( e );
			}
			
			if (v.length == 0 && nullValue)
			{
				element.appendChild(nullValue);
				container.appendChild(nullValue);
			}
			else if (v.length == 0)
			{
				var tmpXML:XML = <!-- <empty/> -->
				container.appendChild(tmpXML);
			}
			
			return container;
		}
	}
}