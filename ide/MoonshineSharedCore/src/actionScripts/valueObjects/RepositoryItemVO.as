////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.valueObjects
{
    [Bindable] public dynamic class RepositoryItemVO
	{
		public var type:String; // VersionControlTypes
		public var isRoot:Boolean;
		public var isDownloadable:Boolean;
		public var isDefault:Boolean;
		
		// this will help access to top level object from anywhere deep 
		// in-tree objects to gain top level properties
		// ideally to get/update user authentication
		public var udid:String;
		
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
		
		private var _isUpdating:Boolean;
		public function get isUpdating():Boolean						{ return _isUpdating; }
		public function set isUpdating(value:Boolean):void				{ _isUpdating = value; }
		
		private var _pathToDownloaded:String;
		public function get pathToDownloaded():String					{ return _pathToDownloaded; }
		public function set pathToDownloaded(value:String):void			{ _pathToDownloaded = value; }
	}
}