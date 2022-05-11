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
package actionScripts.valueObjects
{
    import actionScripts.factory.FileLocation;
	import actionScripts.locator.IDEModel;

	public class ProjectReferenceVO
	{
		public var name: String;
		public var path: String = "";
		public var startIn: String = "";
		public var status:String = "";
		public var loading: Boolean;
		public var sdk:String;
		public var isAway3D:Boolean;
		public var isTemplate:Boolean;
		public var hiddenPaths:Vector.<FileLocation> = new Vector.<FileLocation>();
		public var showHiddenPaths:Boolean;
		public var sourceFolder:FileLocation;

		public function ProjectReferenceVO()
		{
		}
		
		//--------------------------------------------------------------------------
		//
		//  PUBLIC STATIC API
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Static method to translate config
		 * SO data in a loosely-coupled manner
		 */
		public static function getNewRemoteProjectReferenceVO( value:Object ) : ProjectReferenceVO
		{
			var tmpVO : ProjectReferenceVO = new ProjectReferenceVO();
			
			// value submission
			if ( value.hasOwnProperty("path") ) tmpVO.path = value.path;
			if ( value.hasOwnProperty("name") )
			{
				// since https://github.com/Moonshine-IDE/Moonshine-IDE/issues/1027 problem
				// parse by path to overcome problem during reading from already saved data
				if (tmpVO.path)
				{
					tmpVO.name = tmpVO.path.split(IDEModel.getInstance().fileCore.separator).pop() as String;
				}
				else
				{
					tmpVO.name = value.name;
				}
			}
			if ( value.hasOwnProperty("startIn") ) tmpVO.startIn = value.startIn;
			if ( value.hasOwnProperty("status") ) tmpVO.status = value.status;
			if ( value.hasOwnProperty("loading") ) tmpVO.loading = value.loading;
			if ( value.hasOwnProperty("sdk") ) tmpVO.sdk = value.sdk;
			if ( value.hasOwnProperty("isAway3D") ) tmpVO.isAway3D = value.isAway3D;
			if ( value.hasOwnProperty("isTemplate") ) tmpVO.isTemplate = value.isTemplate;

			// finally
			return tmpVO;
		}

		public static function serializeForSharedObject(value:ProjectReferenceVO):Object
		{
			return {
				name: value.name,
				path: value.path,
				startIn: value.startIn,
				status: value.status,
				loading: value.loading,
				sdk: value.sdk,
				isAway3D: value.isAway3D,
				isTemplate: value.isTemplate
			};
		}
	}
}