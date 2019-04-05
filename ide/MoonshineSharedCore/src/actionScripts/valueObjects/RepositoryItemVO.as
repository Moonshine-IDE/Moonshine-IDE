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
    [Bindable] public class RepositoryItemVO
	{
		public var type:String; // VersionControlTypes
		public var isRoot:Boolean;
		
		public function RepositoryItemVO()
		{
		}
		
		private var _url:String;
		public function get url():String								{ return _url; }
		public function set url(value:String):void						{ _url = value; }
		
		private var _label:String;
		public function get label():String								{ return _label; }
		public function set label(value:String):void					{ _label = value; }
		
		private var _notes:String;
		public function get notes():String								{ return _notes; }
		public function set notes(value:String):void					{ _notes = value; }
		
		private var _userName:String;
		public function get userName():String							{ return _userName; }
		public function set userName(value:String):void					{ _userName = value; }
		
		private var _userPassword:String;
		public function get userPassword():String						{ return _userPassword; }
		public function set userPassword(value:String):void				{ _userPassword = value; }
		
		private var _isRequireAuthentication:Boolean;
		public function get isRequireAuthentication():Boolean			{ return _isRequireAuthentication; }
		public function set isRequireAuthentication(value:Boolean):void	{ _isRequireAuthentication = value; }
		
		private var _isTrustCertificate:Boolean;
		public function get isTrustCertificate():Boolean				{ return _isTrustCertificate; }
		public function set isTrustCertificate(value:Boolean):void		{ _isTrustCertificate = value; }
		
		private var _children:Array;
		public function get children():Array							{ return _children; }
		public function set children(value:Array):void					{ _children = value; }
	}
}