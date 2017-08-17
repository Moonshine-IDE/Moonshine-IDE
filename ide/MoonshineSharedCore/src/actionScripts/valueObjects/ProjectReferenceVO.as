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
	public class ProjectReferenceVO
	{
		public var name: String;
		public var path: String = "";
		public var startIn: String = "";
		public var status:String = "";
		public var loading: Boolean;
		public var sdk:String;
		
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
			if ( value.hasOwnProperty("name") ) tmpVO.name = value.name;
			if ( value.hasOwnProperty("path") ) tmpVO.path = value.path;
			if ( value.hasOwnProperty("startIn") ) tmpVO.startIn = value.startIn;
			if ( value.hasOwnProperty("status") ) tmpVO.status = value.status;
			if ( value.hasOwnProperty("loading") ) tmpVO.loading = value.loading;
			if ( value.hasOwnProperty("sdk") ) tmpVO.sdk = value.sdk;
			
			// finally
			return tmpVO;
		}
	}
}