////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 Prominic.NET, Inc.
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
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugin.core.importer
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import actionScripts.factory.FileLocation;
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	
	public class ProjectImporterBase extends EventDispatcher
	{
		public function ProjectImporterBase(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		protected static function checkProjectType(file:FileLocation, p:AS3ProjectVO):void 
		{
			if (!p.air && file.fileBridge.exists)
			{
				var str:String = file.fileBridge.read().toString();
				if((str.indexOf("js:Application") > -1 || str.indexOf("mdl:Application") > -1) && str.indexOf("library://ns.apache.org/flexjs/basic") > -1)
				{
					// FlexJS Application
					p.FlexJS  = true;
					// FlexJS MDL applicaiton
					if (str.indexOf("mdl:Application") > -1) p.isMDLFlexJS = true;
				}
				else
				{
					//Regular application
					p.FlexJS = false;	
				}
			}
		}
		
	}
}